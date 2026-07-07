#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generate Codex custom-agent TOML files and the Codex plugin manifest
    from the canonical markdown agents.

.DESCRIPTION
    The markdown files under agents/ are the single source of truth (Claude
    Code reads them directly). This script derives the Codex-facing artifacts:

      .codex/agents/<name>.toml   one per agent: name, description,
                                  developer_instructions (= markdown body)
      plugin.json                 Codex plugin manifest at the repo root,
                                  components listing every skill and agent

    Claude-only frontmatter (tools, model, related-*, loop-eligible) is
    intentionally dropped: Codex governs capability via sandbox_mode and
    session config, and model choice should follow the user's session.

    Re-run after adding, renaming, or editing any agent or skill. Stale
    TOML files for removed agents are deleted.

.PARAMETER RepoRoot
    Path to the repository root (default: parent of this script's folder)

.EXAMPLE
    ./scripts/convert-agents-to-codex.ps1
#>

param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$agentsDir = Join-Path $RepoRoot 'agents'
$skillsDir = Join-Path $RepoRoot 'skills'
$outDir    = Join-Path $RepoRoot '.codex/agents'
$manifest  = Join-Path $RepoRoot 'plugin.json'

if (-not (Test-Path $agentsDir)) { throw "agents/ not found under $RepoRoot" }
New-Item -ItemType Directory -Force $outDir | Out-Null

function ConvertTo-TomlBasicString {
    param([string]$s)
    $s = $s -replace '\\', '\\'
    $s = $s -replace '"', '\"'
    return $s
}

$generated = @()
$errors = @()

$agentFiles = Get-ChildItem -Path $agentsDir -Recurse -Filter '*.md' |
    Where-Object { $_.Name -ne 'README.md' -and $_.FullName -notmatch '[\\/]\.github[\\/]' } |
    Sort-Object FullName

foreach ($file in $agentFiles) {
    $raw = Get-Content -Path $file.FullName -Raw

    if ($raw -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$') {
        $errors += "$($file.FullName): no frontmatter block"
        continue
    }
    $frontmatter = $Matches[1]
    $body = $Matches[2].Trim()

    $name = $null
    $description = $null
    foreach ($line in ($frontmatter -split '\r?\n')) {
        if ($line -match '^name:\s*(.+)$')        { $name = $Matches[1].Trim().Trim('"') }
        elseif ($line -match '^description:\s*(.+)$') { $description = $Matches[1].Trim().Trim('"') }
    }

    if (-not $name -or -not $description) {
        $errors += "$($file.FullName): missing name or description"
        continue
    }
    if ($body -match "'''") {
        $errors += "$($file.FullName): body contains ''' which breaks TOML literal strings"
        continue
    }

    $relPath = [IO.Path]::GetRelativePath($RepoRoot, $file.FullName) -replace '\\', '/'
    $toml = @(
        "# Generated from $relPath by scripts/convert-agents-to-codex.ps1 -- do not edit by hand."
        "name = `"$(ConvertTo-TomlBasicString $name)`""
        "description = `"$(ConvertTo-TomlBasicString $description)`""
        "developer_instructions = '''"
        $body
        "'''"
    ) -join "`n"

    $outFile = Join-Path $outDir "$name.toml"
    [IO.File]::WriteAllText($outFile, $toml + "`n", [Text.UTF8Encoding]::new($false))
    $generated += "$name.toml"
}

# Remove TOMLs for agents that no longer exist
Get-ChildItem -Path $outDir -Filter '*.toml' | Where-Object { $_.Name -notin $generated } | ForEach-Object {
    Write-Host "Removing stale $($_.Name)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Confirm:$false
}

# Skills = every skills/ subfolder containing a SKILL.md
$skillPaths = Get-ChildItem -Path $skillsDir -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
    Sort-Object Name |
    ForEach-Object { "skills/$($_.Name)" }

$agentPaths = $generated | Sort-Object | ForEach-Object { ".codex/agents/$_" }

$claudeManifest = Get-Content (Join-Path $RepoRoot '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json

$manifestObj = [ordered]@{
    name        = $claudeManifest.name
    version     = $claudeManifest.version
    description = $claudeManifest.description
    homepage    = $claudeManifest.homepage
    license     = $claudeManifest.license
    components  = [ordered]@{
        skills = @($skillPaths)
        agents = @($agentPaths)
    }
    install_policy = 'AVAILABLE'
}
# Normalize to LF so output is byte-identical on Windows and Linux (CI sync check)
$json = ($manifestObj | ConvertTo-Json -Depth 5) -replace "`r`n", "`n"
[IO.File]::WriteAllText($manifest, $json + "`n", [Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Generated $($generated.Count) agent TOMLs in .codex/agents/" -ForegroundColor Green
Write-Host "Manifest plugin.json lists $($skillPaths.Count) skills and $($agentPaths.Count) agents" -ForegroundColor Green

if ($errors.Count -gt 0) {
    Write-Host ""
    $errors | ForEach-Object { Write-Host "[ERROR] $_" -ForegroundColor Red }
    exit 1
}
