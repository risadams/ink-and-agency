#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Lint and validate every SKILL.md in the pack.

.DESCRIPTION
    The pack is skills-only. This validates skill YAML frontmatter and folder
    consistency:
      - required fields: name, description
      - name is lowercase kebab-case (dots allowed) and matches its folder
      - description length bounds (>= 10, <= 800 chars)
      - allowed-tools: core tools spelled correctly; anything else (MCP/custom)
        surfaced as a warning
      - related-skills: every entry resolves to a real skill folder, no
        self-reference, and no non-skill (tool/agent) names leaked in
      - loop-eligible: true requires a recurrence-hint of daily|weekly|on-demand|none

.PARAMETER SkillsPath
    Path to the skills folder (default: ./skills relative to repo root)

.PARAMETER Verbose
    Show per-skill OK lines.

.EXAMPLE
    ./scripts/lint-skills.ps1
#>

param(
    [string]$SkillsPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'skills'),
    [switch]$Verbose = $false
)

$ErrorActionPreference = 'Stop'

$ValidTools = @('Read', 'Write', 'Edit', 'Bash', 'Glob', 'Grep', 'WebFetch', 'WebSearch', 'AskUserQuestion', 'Agent', 'Skill', 'TodoWrite', 'NotebookEdit', 'WebFetch')
$ValidRecurrence = @('daily', 'weekly', 'on-demand', 'none')

$errors = @()
$warnings = @()
$validSkills = @()

function Add-Error { param([string]$m) $script:errors += $m; Write-Host "[ERROR] $m" -ForegroundColor Red }
function Add-Warning { param([string]$m) $script:warnings += $m; Write-Host "[WARNING] $m" -ForegroundColor Yellow }
function Add-Ok { param([string]$m) if ($Verbose) { Write-Host "[OK] $m" -ForegroundColor Green } }

function Get-Frontmatter {
    param([string]$filePath)
    $content = Get-Content -Path $filePath -Raw
    if ($content -notmatch '^---\s*\r?\n([\s\S]*?)\r?\n---') { return $null }
    $fm = $matches[1]
    $result = @{}
    $lines = @($fm -split '\r?\n')
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
            $key = $matches[1]
            $inline = $matches[2].Trim()
            if ($inline -match '^[>|][+-]?$') {
                # folded (>) or literal (|) block scalar: gather indented lines
                $block = @()
                for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                    if ($lines[$j] -match '^\s*$') { $block += ''; continue }
                    if ($lines[$j] -match '^(\s+)(.*)$') { $block += $matches[2]; continue }
                    break
                }
                $i = $j - 1
                $result[$key] = (($block -join ' ') -replace '\s+', ' ').Trim()
            }
            elseif (-not $inline) {
                # block list: collect following "  - item" lines
                $items = @()
                while ($i + 1 -lt $lines.Count -and $lines[$i + 1] -match '^\s+-\s*(.+)$') {
                    $items += $matches[1].Trim().Trim('"')
                    $i++
                }
                $result[$key] = ($items -join ', ')
            }
            elseif ($inline -match '^\[(.*)\]$') {
                # inline list
                $result[$key] = (($matches[1] -split ',') | ForEach-Object { $_.Trim().Trim('"',"'") } | Where-Object { $_ }) -join ', '
            }
            else {
                $result[$key] = $inline.Trim('"')
            }
        }
    }
    return $result
}

# Pass 1: collect all skill folder names (for related-skills resolution)
$skillDirs = Get-ChildItem -Path $SkillsPath -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
    Sort-Object Name
$allSkillNames = @{}
foreach ($d in $skillDirs) { $allSkillNames[$d.Name] = $true }

Write-Host "Linting skills collection ($($skillDirs.Count) skills)..." -ForegroundColor Cyan
Write-Host ""

# Pass 2: validate each SKILL.md
foreach ($dir in $skillDirs) {
    $folder = $dir.Name
    $skillMd = Join-Path $dir.FullName 'SKILL.md'
    $fm = Get-Frontmatter -filePath $skillMd
    if (-not $fm) { Add-Error "$folder : No YAML frontmatter found"; continue }

    # required fields
    foreach ($field in @('name', 'description')) {
        if (-not $fm[$field]) { Add-Error "$folder : Missing required field '$field'" }
    }
    if (-not $fm['name']) { continue }

    $name = $fm['name']
    # name format
    if ($name -notmatch '^[a-z0-9]([a-z0-9.\-]{0,62}[a-z0-9])?$') {
        Add-Error "$folder : Invalid name format '$name' (lowercase kebab-case)"
    }
    # name matches folder
    if ($name -ne $folder) {
        Add-Error "$folder : name field '$name' does not match folder"
    }
    # description bounds
    if ($fm['description']) {
        $len = $fm['description'].Length
        if ($len -lt 10) { Add-Error "$folder : Description too short (>= 10 chars)" }
        if ($len -gt 800) { Add-Warning "$folder : Description very long ($len chars)" }
    }

    # allowed-tools: core tools spelled right; others (MCP/custom) => warning
    if ($fm['allowed-tools']) {
        $toolList = @($fm['allowed-tools'] -split ',\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        $unknown = @($toolList | Where-Object { $_ -notin $ValidTools -and $_ -notmatch '^mcp__' })
        if ($unknown.Count) { Add-Warning "$folder : Non-core tools in allowed-tools: $($unknown -join ', ')" }
    }

    # related-skills: resolve, no self-ref, type-correctness (no tool/mcp names)
    if ($fm['related-skills']) {
        $rel = @($fm['related-skills'] -split ',\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        foreach ($r in $rel) {
            if ($r -eq $name) { Add-Error "$folder : Self-reference in related-skills" }
            elseif ($r -match '^mcp__' -or $r -in @('Bash','Read','Write','Edit','Glob','Grep','Agent','Skill','AskUserQuestion','WebFetch','WebSearch','TodoWrite')) {
                Add-Error "$folder : Tool name '$r' leaked into related-skills (belongs in allowed-tools)"
            }
            elseif (-not $allSkillNames.ContainsKey($r)) {
                Add-Warning "$folder : related-skill '$r' does not exist"
            }
        }
    }

    # related-agents must not exist anymore (skills-only pack)
    if ($fm['related-agents']) {
        Add-Error "$folder : 'related-agents' is obsolete (pack is skills-only) - fold into related-skills"
    }

    # loop-eligible / recurrence-hint consistency
    if ($fm['loop-eligible'] -eq 'true') {
        if (-not $fm['recurrence-hint']) {
            Add-Error "$folder : loop-eligible=true requires recurrence-hint"
        }
        elseif ($fm['recurrence-hint'] -notin $ValidRecurrence) {
            Add-Error "$folder : invalid recurrence-hint '$($fm['recurrence-hint'])' (must be: $($ValidRecurrence -join ', '))"
        }
    }

    Add-Ok "$folder : Valid"
    $validSkills += $folder
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total skills validated: $($validSkills.Count)" -ForegroundColor Cyan
Write-Host "Errors: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host "Warnings: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -eq 0) { 'Green' } else { 'Yellow' })

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "[x] Validation failed with $($errors.Count) error(s)" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "[ok] Skills validated$(if ($warnings.Count) { " with $($warnings.Count) warning(s)" })" -ForegroundColor Green
exit 0
