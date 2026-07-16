#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Lint and validate every SKILL.md in the pack.

.DESCRIPTION
    The pack is skills-only. This validates skill YAML frontmatter and folder
    consistency:
      - required fields: name, description
      - name is lowercase kebab-case (dots allowed) and matches its folder
      - description length bounds (>= 10 error, > 800 warn, > 1024 error)
      - description carries trigger phrasing (use when / when user / triggers on)
        so auto-invocation fires reliably (warn; skipped for user-invoked skills)
      - description first sentence fits the Codex picker label (<= 90 chars) or a
        codex-short-description override is supplied (warn)
      - allowed-tools: core tools spelled correctly; anything else (MCP/custom)
        surfaced as a warning
      - related-skills: every entry resolves to a real skill folder, no
        self-reference, and no non-skill (tool/agent) names leaked in
      - loop-eligible: true requires a recurrence-hint of daily|weekly|on-demand|none
      - self-evolve: optional true|false; every skill carries the Self-Evolve Loop
        footer (markers + section, link resolving to skills/SELF-EVOLVE.md) unless
        it opts out with self-evolve: false — maintained by add-self-evolve.ps1
      - body carries no stale subagent-era boilerplate ("When invoked:", "Query
        context manager", "Integration with other agents", requesting_agent JSON)
        that contradicts the skills-only/run-inline model (warn)
      - large bodies (> 350 lines) should split depth into references/*.md (warn)
      - each skill should ship a sibling README.md (warn)

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

# Pass 1: collect all skill folder names (for related-skills resolution).
# Skills live in category subfolders (skills/<category>/<name>/SKILL.md), so
# discovery is RECURSIVE: each SKILL.md's parent directory is a skill.
$skillDirs = Get-ChildItem -Path $SkillsPath -Recurse -Filter 'SKILL.md' -File |
    ForEach-Object { $_.Directory } |
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
    # description bounds: >=10 error, >800 soft warn, >1024 hard error
    # (1024 is the validator-backed MAX_DESCRIPTION_LENGTH ceiling)
    if ($fm['description']) {
        $desc = $fm['description']
        $len = $desc.Length
        if ($len -lt 10) { Add-Error "$folder : Description too short (>= 10 chars)" }
        elseif ($len -gt 1024) { Add-Error "$folder : Description over hard cap ($len chars, max 1024)" }
        elseif ($len -gt 800) { Add-Warning "$folder : Description very long ($len chars)" }

        # trigger phrasing drives auto-invocation; user-invoked skills are exempt
        $userInvoked = $fm['disable-model-invocation'] -eq 'true'
        if (-not $userInvoked -and $desc -notmatch '(?i)\buse (this skill )?(when|for|to|before|after|if)\b|\bwhen (the )?user\b|\btriggers? on\b|\bwhen you\b|\binvoke') {
            Add-Warning "$folder : Description lacks trigger phrasing ('Use when ...') - weakens auto-invocation"
        }

        # Codex picker label is the first sentence trimmed to ~90 chars; warn when
        # it will truncate and no explicit override is supplied
        if (-not $fm['codex-short-description']) {
            $first = $desc
            if ($first -match '^(.*?[.!?])(\s|$)') { $first = $matches[1] }
            elseif ($first -match '^(.*?);') { $first = $matches[1] }
            if ($first.Length -gt 90) {
                Add-Warning "$folder : Description first sentence $($first.Length) chars (>90); add codex-short-description for a clean Codex picker label"
            }
        }
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

    # self-evolve: optional boolean opt-out of the Self-Evolve Loop footer
    if ($fm['self-evolve'] -and $fm['self-evolve'] -notin @('true', 'false')) {
        Add-Error "$folder : invalid self-evolve '$($fm['self-evolve'])' (must be true or false)"
    }

    # --- body hygiene (skills-only pack: no subagent-era orchestration prose) --
    $body = Get-Content -Path $skillMd -Raw
    $staleHits = @()
    if ($body -match '(?im)^\s*When invoked:') { $staleHits += 'When invoked:' }
    if ($body -match '(?i)Query context manager') { $staleHits += 'Query context manager' }
    if ($body -match '(?i)Integration with other agents') { $staleHits += 'Integration with other agents' }
    if ($body -match '(?i)requesting_agent') { $staleHits += 'requesting_agent' }
    if ($body -match '(?i)## Communication Protocol') { $staleHits += '## Communication Protocol' }
    if ($staleHits.Count) {
        Add-Warning "$folder : Stale subagent boilerplate ($($staleHits -join ', ')) - pack is skills-only/run-inline"
    }

    # --- Self-Evolve Loop footer invariant (see skills/SELF-EVOLVE.md) ---------
    $optedOut = $fm['self-evolve'] -eq 'false'
    $hasSelfEvolve = $body.Contains('<!-- self-evolve:start -->') -and $body -match '## Self-Evolve Loop'
    if ($optedOut -and $hasSelfEvolve) {
        Add-Error "$folder : self-evolve: false but footer present - run scripts/add-self-evolve.ps1"
    }
    elseif (-not $optedOut -and -not $hasSelfEvolve) {
        Add-Error "$folder : missing Self-Evolve Loop footer - run scripts/add-self-evolve.ps1"
    }
    if ($hasSelfEvolve -and $body -match '\[SELF-EVOLVE\.md\]\(([^)]+)\)') {
        $target = Join-Path $dir.FullName $matches[1]
        if (-not (Test-Path $target)) {
            Add-Error "$folder : Self-Evolve footer link '$($matches[1])' does not resolve - run scripts/add-self-evolve.ps1"
        }
    }

    # --- progressive disclosure: large bodies should split into references/*.md -
    $lineCount = @($body -split '\r?\n').Count
    $hasRefs = @(Get-ChildItem -Path $dir.FullName -Recurse -Filter '*.md' -File |
        Where-Object { $_.Name -ne 'SKILL.md' -and $_.Name -ne 'README.md' -and $_.Directory.Name -ne 'agents' }).Count -gt 0
    if ($lineCount -gt 350 -and -not $hasRefs) {
        Add-Warning "$folder : SKILL.md is $lineCount lines with no supporting .md - split depth into references/*.md"
    }

    # --- docs coverage: each skill should ship a README.md ---------------------
    if (-not (Test-Path (Join-Path $dir.FullName 'README.md'))) {
        Add-Warning "$folder : No sibling README.md"
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
