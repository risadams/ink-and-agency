#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bulk-update skills with Loop Method frontmatter fields (related-skills, loop-eligible, recurrence-hint).

.DESCRIPTION
    Adds or updates Loop Method fields in skill frontmatter based on skill domain and standard patterns.

    Patterns by domain:
    - Writing skills: All inter-reference, related-agents=[content-quality-editor], loop-eligible=false
    - Sprint/Scrum skills: All inter-reference, related-agents=[scrum-master], loop-eligible varies
    - Decision skills: All inter-reference clarity-council, related-agents=[council-*], loop-eligible=false
    - Issue skills: Peer group inter-references, related-agents=[scrum-master], loop-eligible=false
    - Code/Codebase skills: Peer references, related-agents=[code-reviewer], loop-eligible=false
    - Obsidian skills: Peer group inter-references, loop-eligible=false
    - Other skills: Related to closest matching domain

.PARAMETER SkillsPath
    Path to skills folder (default: parent/skills)

.PARAMETER DryRun
    Show what would be changed without making changes

.EXAMPLE
    .\bulk-loop-method-update.ps1 -DryRun
    .\bulk-loop-method-update.ps1
#>

param(
    [string]$SkillsPath = (Get-Location).Path,
    [switch]$DryRun = $false
)

$skillPatterns = @{
    # Writing domain
    'writing-humanize' = @{ 'related-skills' = @('writing-tone-check', 'writing-shape'); 'loop-eligible' = 'false' }
    'writing-draft-article' = @{ 'related-skills' = @('writing-shape', 'writing-beats', 'clarity-council'); 'loop-eligible' = 'false' }
    'writing-shape' = @{ 'related-skills' = @('writing-draft-article', 'writing-beats'); 'loop-eligible' = 'false' }
    'writing-beats' = @{ 'related-skills' = @('writing-shape', 'writing-fragments'); 'loop-eligible' = 'false' }
    'writing-fragments' = @{ 'related-skills' = @('writing-shape'); 'loop-eligible' = 'false' }
    'writing-tone-check' = @{ 'related-skills' = @('writing-humanize'); 'loop-eligible' = 'false' }

    # Issue/Jira domain
    'issue-triage' = @{ 'related-skills' = @('codebase-explain', 'clarity-council'); 'loop-eligible' = 'false' }
    'issue-estimate-sp' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }
    'issue-dup-find' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'issue-feature-breakdown' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }
    'issue-suggest-component' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }

    # Code/Codebase domain
    'codebase-explain' = @{ 'related-skills' = @('request-refactor-plan'); 'loop-eligible' = 'false' }
    'codebase-improve-architecture' = @{ 'related-skills' = @('request-refactor-plan', 'grill-with-docs'); 'loop-eligible' = 'false' }
    'codebase-churn' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'request-refactor-plan' = @{ 'related-skills' = @('codebase-improve-architecture'); 'loop-eligible' = 'false' }

    # Git domain
    'branch-rebase' = @{ 'related-skills' = @('branch-resolve-conflicts'); 'loop-eligible' = 'false' }
    'branch-resolve-conflicts' = @{ 'related-skills' = @('branch-rebase'); 'loop-eligible' = 'false' }

    # Daily/Personal domain
    'daily-briefing' = @{ 'related-skills' = @('energy-budget'); 'loop-eligible' = 'true' }
    'task-initiation' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'hyperfocus-recovery' = @{ 'related-skills' = @('task-initiation'); 'loop-eligible' = 'false' }
    'energy-budget' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }
    'break-it-down' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'rejection-sensitivity-check' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }
    'time-reality-check' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }
    'interest-capture' = @{ 'related-skills' = @('task-initiation'); 'loop-eligible' = 'false' }
    'meeting-decompression' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }

    # Obsidian domain
    'obsidian-vault' = @{ 'related-skills' = @('obsidian-markdown', 'obsidian-canvas'); 'loop-eligible' = 'false' }
    'obsidian-canvas' = @{ 'related-skills' = @('obsidian-markdown', 'obsidian-bases'); 'loop-eligible' = 'false' }
    'obsidian-markdown' = @{ 'related-skills' = @('obsidian-vault', 'obsidian-canvas'); 'loop-eligible' = 'false' }
    'obsidian-cli' = @{ 'related-skills' = @('obsidian-vault'); 'loop-eligible' = 'false' }
    'obsidian-bases' = @{ 'related-skills' = @('obsidian-canvas', 'obsidian-charts'); 'loop-eligible' = 'false' }
    'obsidian-charts' = @{ 'related-skills' = @('obsidian-bases'); 'loop-eligible' = 'false' }

    # Utilities
    'handoff' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'defuddle' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'skill-create' = @{ 'related-skills' = @(); 'loop-eligible' = 'false' }
    'grill-with-docs' = @{ 'related-skills' = @('grill-me', 'clarity-council'); 'loop-eligible' = 'false' }
    'idea-choice' = @{ 'related-skills' = @('clarity-council', 'idea-generate'); 'loop-eligible' = 'false' }
    'idea-decision-maker' = @{ 'related-skills' = @('clarity-council'); 'loop-eligible' = 'false' }

    # Sprint domain (remaining)
    'sprint-review' = @{ 'related-skills' = @('sprint-snapshot', 'clarity-council'); 'loop-eligible' = 'true' }
    'sprint-sos-report' = @{ 'related-skills' = @('sprint-snapshot', 'sprint-plan'); 'loop-eligible' = 'false' }
    'daily-standup-prep' = @{ 'related-skills' = @('sprint-snapshot', 'clarity-council'); 'loop-eligible' = 'true' }
}

$updated = 0
$skipped = 0

if (-not (Test-Path $SkillsPath)) {
    Write-Host "Skills path not found: $SkillsPath" -ForegroundColor Red
    exit 1
}

Write-Host "Updating skills with Loop Method fields..." -ForegroundColor Cyan

foreach ($skillName in $skillPatterns.Keys) {
    $skillPath = Join-Path $SkillsPath $skillName "SKILL.md"

    if (-not (Test-Path $skillPath)) {
        # Write-Host "  [SKIP] $skillName (not found)" -ForegroundColor Yellow
        continue
    }

    $content = Get-Content -Path $skillPath -Raw

    # Check if already has loop-eligible field
    if ($content -match 'loop-eligible:') {
        $skipped++
        continue
    }

    $pattern = $skillPatterns[$skillName]
    $skillsList = if ($pattern['related-skills'].Count -gt 0) {
        "related-skills:`n" + ($pattern['related-skills'] | ForEach-Object { "  - $_" } | Join-String -Separator "`n") + "`n"
    } else {
        ""
    }

    # Find frontmatter end
    if ($content -match '^---\s*\n([\s\S]*?)\n---') {
        $frontmatterEnd = $content.IndexOf("`n---", 3)

        $newFields = ""
        if ($skillsList -and $content -notmatch 'related-skills:') {
            $newFields += $skillsList
        }
        $newFields += "loop-eligible: $($pattern['loop-eligible'])`n"

        $newContent = $content.Substring(0, $frontmatterEnd) + "`n$newFields" + $content.Substring($frontmatterEnd)

        if ($DryRun) {
            Write-Host "  [DRY RUN] Would update: $skillName" -ForegroundColor Green
        } else {
            Set-Content -Path $skillPath -Value $newContent
            Write-Host "  ✓ Updated: $skillName" -ForegroundColor Green
            $updated++
        }
    }
}

Write-Host "`nBulk Update Summary" -ForegroundColor Cyan
Write-Host "Updated: $updated skills" -ForegroundColor Green
Write-Host "Skipped (already updated): $skipped skills" -ForegroundColor Yellow
