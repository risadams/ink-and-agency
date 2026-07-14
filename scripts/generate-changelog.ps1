#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build a Keep a Changelog section for a release from git commits and prepend
    it to CHANGELOG.md.

.DESCRIPTION
    Collects commit subjects since the previous tag (or the whole history on the
    first release), groups them into Keep a Changelog categories by conventional-
    commit prefix, and prepends a new `## [X.Y.Z] - YYYY-MM-DD` block to
    CHANGELOG.md. CHANGELOG.md is created with a standard header if absent.

    Prefix mapping:
      feat / feature        -> Added
      fix / bugfix          -> Fixed
      remove / removed       -> Removed
      deprecate / deprecated -> Deprecated
      security               -> Security
      everything else        -> Changed  (docs, refactor, chore, style, test,
                                          perf, build, ci, and unprefixed)

    Merge commits and the release's own version-bump commit are skipped. The
    freshly written section (only) is also printed to stdout so a workflow can
    use it verbatim as the GitHub Release body.

.PARAMETER Version
    The version being released, e.g. "1.1.0" (no leading "v").

.PARAMETER RepoRoot
    Path to the repository root (default: parent of this script's folder).

.PARAMETER Date
    Release date as YYYY-MM-DD (default: today, UTC).

.PARAMETER PreviousTag
    Override the previous tag to diff from. Default: `git describe --tags
    --abbrev=0` of the current HEAD, or empty (full history) if no tags exist.

.EXAMPLE
    ./scripts/generate-changelog.ps1 -Version 1.1.0
#>

param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$Date = ([DateTime]::UtcNow.ToString('yyyy-MM-dd')),
    [string]$PreviousTag
)

$ErrorActionPreference = 'Stop'

Push-Location $RepoRoot
try {
    if (-not $PSBoundParameters.ContainsKey('PreviousTag')) {
        $PreviousTag = (git describe --tags --abbrev=0 2>$null)
        if ($LASTEXITCODE -ne 0) { $PreviousTag = '' }
    }

    $range = if ($PreviousTag) { "$PreviousTag..HEAD" } else { 'HEAD' }

    # %s = subject only; drop merge commits with --no-merges.
    $subjects = @(git log $range --no-merges --pretty=format:'%s')
    if ($LASTEXITCODE -ne 0) { throw "git log failed for range '$range'" }

    $buckets = [ordered]@{
        Added      = [System.Collections.Generic.List[string]]::new()
        Changed    = [System.Collections.Generic.List[string]]::new()
        Deprecated = [System.Collections.Generic.List[string]]::new()
        Removed    = [System.Collections.Generic.List[string]]::new()
        Fixed      = [System.Collections.Generic.List[string]]::new()
        Security   = [System.Collections.Generic.List[string]]::new()
    }

    foreach ($subject in $subjects) {
        $s = $subject.Trim()
        if (-not $s) { continue }
        # Skip the release bump commit this flow produces.
        if ($s -match '^(?i)chore\(release\)|^Release v?\d+\.\d+\.\d+|^Bump version') { continue }

        # Split an optional conventional-commit prefix from the description.
        $category = 'Changed'
        $text = $s
        if ($s -match '^(?<type>[a-zA-Z]+)(?:\([^)]*\))?!?:\s*(?<rest>.+)$') {
            $type = $Matches['type'].ToLower()
            $text = $Matches['rest'].Trim()
            switch ($type) {
                { $_ -in 'feat', 'feature' }        { $category = 'Added' }
                { $_ -in 'fix', 'bugfix' }          { $category = 'Fixed' }
                { $_ -in 'remove', 'removed' }      { $category = 'Removed' }
                { $_ -in 'deprecate', 'deprecated' } { $category = 'Deprecated' }
                'security'                          { $category = 'Security' }
                default                             { $category = 'Changed' }
            }
        }
        # Capitalize first letter for a tidy bullet.
        if ($text.Length -gt 0) { $text = $text.Substring(0, 1).ToUpper() + $text.Substring(1) }
        $buckets[$category].Add($text)
    }

    # Build the section body.
    $sectionLines = [System.Collections.Generic.List[string]]::new()
    $sectionLines.Add("## [$Version] - $Date")
    $anyEntries = $false
    foreach ($cat in $buckets.Keys) {
        $items = $buckets[$cat]
        if ($items.Count -eq 0) { continue }
        $anyEntries = $true
        $sectionLines.Add('')
        $sectionLines.Add("### $cat")
        foreach ($item in $items) { $sectionLines.Add("- $item") }
    }
    if (-not $anyEntries) {
        $sectionLines.Add('')
        $sectionLines.Add('- No notable changes.')
    }
    $section = ($sectionLines -join "`n") + "`n"

    # Prepend to (or create) CHANGELOG.md.
    $changelogPath = Join-Path $RepoRoot 'CHANGELOG.md'
    $header = @(
        '# Changelog'
        ''
        'All notable changes to this project are documented in this file.'
        ''
        'The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),'
        'and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).'
        ''
    ) -join "`n"

    if (Test-Path $changelogPath) {
        $existing = (Get-Content -Path $changelogPath -Raw) -replace "`r`n", "`n"
        # Split the existing file into its header (up to the first "## ") and body.
        $idx = $existing.IndexOf("`n## ")
        if ($idx -ge 0) {
            $existingHeader = $existing.Substring(0, $idx + 1)
            $existingBody = $existing.Substring($idx + 1)
            $newContent = $existingHeader.TrimEnd("`n") + "`n`n" + $section + "`n" + $existingBody.TrimEnd("`n") + "`n"
        }
        else {
            # No prior release sections; keep whatever header exists.
            $newContent = $existing.TrimEnd("`n") + "`n`n" + $section
        }
    }
    else {
        $newContent = $header + "`n" + $section
    }

    [IO.File]::WriteAllText($changelogPath, $newContent, [Text.UTF8Encoding]::new($false))

    $where = if ($PreviousTag) { "since $PreviousTag" } else { 'full history (no prior tag)' }
    Write-Host "Wrote CHANGELOG.md section [$Version] ($where)" -ForegroundColor Green

    # Emit just the new section to stdout for use as a release body.
    Write-Output $section
}
finally {
    Pop-Location
}
