#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Inject or sync the Self-Evolve Loop footer in every SKILL.md.

.DESCRIPTION
    Every skill carries a short "## Self-Evolve Loop" footer pointing at the shared
    contract in skills/SELF-EVOLVE.md. The footer sits between the markers
    <!-- self-evolve:start --> and <!-- self-evolve:end --> and is MACHINE-MAINTAINED
    (like the generated Codex artifacts): edit the template in this script and re-run,
    never hand-edit a footer. The script is idempotent:
      - skills without a footer get one appended
      - skills whose footer drifted from the template get it rewritten in place
      - skills with `self-evolve: false` in frontmatter get their footer removed
    The relative link to SELF-EVOLVE.md is computed per skill (category-nested skills
    are one level deeper than top-level ones like clarity-council).

.PARAMETER SkillsPath
    Path to the skills folder (default: ./skills relative to repo root)

.PARAMETER DryRun
    Report what would change without writing.

.EXAMPLE
    pwsh ./scripts/add-self-evolve.ps1 -DryRun
    pwsh ./scripts/add-self-evolve.ps1
#>

param(
    [string]$SkillsPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'skills'),
    [switch]$DryRun = $false
)

$ErrorActionPreference = 'Stop'

$startMark = '<!-- self-evolve:start -->'
$endMark   = '<!-- self-evolve:end -->'

function Write-FileWithRetry {
    # AV/indexer scans briefly memory-map freshly-touched files on Windows, which
    # makes writes fail with "user-mapped section open" — retry through it.
    param([string]$Path, [string]$Content)
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try { [IO.File]::WriteAllText($Path, $Content); return }
        catch [System.IO.IOException] {
            if ($attempt -eq 5) { throw }
            Start-Sleep -Milliseconds (200 * $attempt)
        }
    }
}

function Get-FooterBlock {
    param([string]$Name, [string]$RelPrefix)
    $lines = @(
        $startMark,
        '',
        '## Self-Evolve Loop',
        '',
        'This skill learns across invocations — the full contract is',
        "[SELF-EVOLVE.md](${RelPrefix}SELF-EVOLVE.md). **Start:** read the learnings",
        "journal — ``~/.ink-and-agency/learnings/$Name.md`` and/or the workspace-local",
        "``.ink-and-agency/learnings/$Name.md`` — if present, and apply its guidance.",
        '**End:** self-evaluate the results; optionally ask the user for feedback (never',
        'block on it); append signal-bearing learnings to the journal (user-global when',
        'the sandbox allows writing there, workspace-local otherwise); route',
        'skill-improvement ideas per the contract''s tiers — edit the canonical source',
        'when one is present, never the plugin cache.',
        '',
        $endMark
    )
    return ($lines -join "`n")
}

if (-not (Test-Path $SkillsPath)) {
    Write-Host "Skills path not found: $SkillsPath" -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $SkillsPath -Recurse -Filter 'SKILL.md' -File | Sort-Object FullName
Write-Host "Syncing Self-Evolve Loop footers ($($files.Count) skills)..." -ForegroundColor Cyan

$added = 0; $synced = 0; $unchanged = 0; $removed = 0

foreach ($f in $files) {
    $raw = Get-Content -Path $f.FullName -Raw
    $name = $f.Directory.Name

    # opt-out lives in frontmatter only
    $optOut = $false
    if ($raw -match '^---\r?\n([\s\S]*?)\r?\n---' -and $matches[1] -match '(?m)^self-evolve:\s*false\s*$') {
        $optOut = $true
    }

    $blockPattern = '(?s)' + [regex]::Escape($startMark) + '.*?' + [regex]::Escape($endMark)
    $hasFooter = $raw.Contains($startMark)

    if ($optOut) {
        if ($hasFooter) {
            $new = [regex]::Replace($raw, '\r?\n*' + $blockPattern + '\r?\n*', "`n")
            $new = $new.TrimEnd() + "`n"
            if (-not $DryRun) { Write-FileWithRetry -Path $f.FullName -Content $new }
            Write-Host "  - removed (opt-out): $name" -ForegroundColor Yellow
            $removed++
        }
        continue
    }

    # relative path from this skill folder up to the skills root
    $rel = [IO.Path]::GetRelativePath($f.Directory.FullName, $SkillsPath) -replace '\\', '/'
    $prefix = if ($rel -eq '.') { './' } else { "$rel/" }
    $expected = Get-FooterBlock -Name $name -RelPrefix $prefix

    if ($hasFooter) {
        $currentBlock = [regex]::Match($raw, $blockPattern).Value
        if ($currentBlock -eq $expected) { $unchanged++; continue }
        $new = [regex]::Replace($raw, $blockPattern, { param($m) $expected })
        if (-not $DryRun) { Write-FileWithRetry -Path $f.FullName -Content $new }
        Write-Host "  ~ synced: $name" -ForegroundColor Cyan
        $synced++
    }
    else {
        $new = $raw.TrimEnd() + "`n`n" + $expected + "`n"
        if (-not $DryRun) { Write-FileWithRetry -Path $f.FullName -Content $new }
        Write-Host "  + added: $name" -ForegroundColor Green
        $added++
    }
}

Write-Host ""
Write-Host "Self-Evolve footer summary$(if ($DryRun) { ' (dry run)' })" -ForegroundColor Cyan
Write-Host "  Added:     $added"
Write-Host "  Synced:    $synced"
Write-Host "  Unchanged: $unchanged"
Write-Host "  Removed:   $removed (opt-out)"
exit 0
