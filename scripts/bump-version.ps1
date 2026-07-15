#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bump the plugin version and regenerate all Codex artifacts so both hosts
    stay in lockstep.

.DESCRIPTION
    .claude-plugin/plugin.json is the single source of truth for the version.
    This script reads it, computes the next semantic version for the requested
    bump level, and writes it back with a byte-preserving regex replace (the
    file's 2-space indent, key order, and trailing LF newline are untouched).

    It then invokes scripts/convert-agents-to-codex.ps1, which propagates the
    new version into the root plugin.json (the Codex manifest) and regenerates
    every other derived artifact. Because only the one source manifest is
    hand-bumped and everything else is generated from it, the Claude Code and
    Codex plugin versions can never diverge.

    The new version is printed to stdout. When running under GitHub Actions
    (GITHUB_OUTPUT set), it is also emitted as the step output `new_version`.

.PARAMETER Bump
    Which semver component to increment: patch, minor (default), or major.

.PARAMETER RepoRoot
    Path to the repository root (default: parent of this script's folder).

.PARAMETER SkipConvert
    Skip the convert-agents-to-codex.ps1 regeneration step (source manifest
    only). Intended for testing; a real release must regenerate.

.EXAMPLE
    ./scripts/bump-version.ps1 -Bump minor

.EXAMPLE
    ./scripts/bump-version.ps1 -Bump patch -SkipConvert
#>

param(
    [ValidateSet('patch', 'minor', 'major')]
    [string]$Bump = 'minor',
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$SkipConvert
)

$ErrorActionPreference = 'Stop'

$sourceManifest = Join-Path $RepoRoot '.claude-plugin/plugin.json'
if (-not (Test-Path $sourceManifest)) {
    throw ".claude-plugin/plugin.json not found under $RepoRoot"
}

$raw = Get-Content -Path $sourceManifest -Raw

if ($raw -notmatch '"version":\s*"(\d+)\.(\d+)\.(\d+)"') {
    throw "Could not find a semver `"version`" field in $sourceManifest"
}
$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$oldVersion = "$major.$minor.$patch"

switch ($Bump) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
}
$newVersion = "$major.$minor.$patch"

# Byte-preserving replace: only the version value changes, everything else
# (indent, key order, trailing newline) stays exactly as authored.
$updated = $raw -replace '("version":\s*")\d+\.\d+\.\d+(")', "`${1}$newVersion`${2}"
[IO.File]::WriteAllText($sourceManifest, $updated, [Text.UTF8Encoding]::new($false))

Write-Host "Bumped version: $oldVersion -> $newVersion ($Bump)" -ForegroundColor Green

if (-not $SkipConvert) {
    $converter = Join-Path $PSScriptRoot 'convert-agents-to-codex.ps1'
    Write-Host "Regenerating Codex artifacts via convert-agents-to-codex.ps1..." -ForegroundColor Cyan
    & $converter -RepoRoot $RepoRoot
    # $LASTEXITCODE is $null when the child script succeeds without an explicit
    # `exit` (PowerShell leaves it unset). `if ($LASTEXITCODE)` is truthy only
    # for a non-null, non-zero code, so a clean run ($null or 0) never throws;
    # a real failure exits non-zero (or throws, which propagates through `&`).
    if ($LASTEXITCODE) {
        throw "convert-agents-to-codex.ps1 failed with exit code $LASTEXITCODE"
    }
}

# Emit the new version for the GitHub Actions workflow to consume.
if ($env:GITHUB_OUTPUT) {
    "new_version=$newVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

# Machine-readable last line on stdout (workflow fallback if GITHUB_OUTPUT unset).
Write-Output $newVersion
