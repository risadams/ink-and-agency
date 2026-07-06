#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bulk-update agents with Loop Method frontmatter fields (related-skills, related-agents, loop-eligible).

.DESCRIPTION
    Adds or updates Loop Method fields in agent frontmatter based on category and standard patterns.

    Patterns by category:
    - 01-core-development: related-skills=[codebase-explain, request-refactor-plan], related-agents=[code-reviewer]
    - 02-language-specialists: related-skills=[codebase-explain, request-refactor-plan], related-agents=[code-reviewer]
    - 03-infrastructure: related-skills=[request-refactor-plan], related-agents=[terraform-engineer, devops-engineer]
    - 04-quality-security: related-skills=[clarity-council], related-agents=[code-reviewer]
    - 05-data-ai: related-skills=[clarity-council], related-agents=[ml-engineer]
    - 06-developer-experience: related-skills=[request-refactor-plan], related-agents=[refactoring-specialist]
    - 07-specialized-domains: related-skills=[], related-agents=[] (domain-specific)
    - 08-business-product: related-skills=[sprint-snapshot, clarity-council], related-agents=[scrum-master]
    - 09-meta-orchestration: SKIP (already done in Wave 1)
    - 10-research-analysis: related-skills=[idea-generate, clarity-council], related-agents=[]
    - 00-council: SKIP (already done in Wave 1)

.PARAMETER AgentPath
    Path to agents folder (default: current directory)

.PARAMETER DryRun
    Show what would be changed without making changes

.EXAMPLE
    .\bulk-loop-method-update.ps1 -DryRun
    .\bulk-loop-method-update.ps1
#>

param(
    [string]$AgentPath = (Get-Location).Path,
    [switch]$DryRun = $false
)

# Pattern definitions by category
$patterns = @{
    '01-core-development' = @{
        'related-skills' = @('codebase-explain', 'request-refactor-plan')
        'related-agents' = @('code-reviewer')
    }
    '02-language-specialists' = @{
        'related-skills' = @('codebase-explain', 'request-refactor-plan')
        'related-agents' = @('code-reviewer')
    }
    '03-infrastructure' = @{
        'related-skills' = @('request-refactor-plan')
        'related-agents' = @('terraform-engineer')
    }
    '04-quality-security' = @{
        'related-skills' = @('clarity-council')
        'related-agents' = @('code-reviewer')
    }
    '05-data-ai' = @{
        'related-skills' = @('clarity-council')
        'related-agents' = @('ml-engineer')
    }
    '06-developer-experience' = @{
        'related-skills' = @('request-refactor-plan')
        'related-agents' = @('refactoring-specialist')
    }
    '07-specialized-domains' = @{
        'related-skills' = @()
        'related-agents' = @()
    }
    '08-business-product' = @{
        'related-skills' = @('sprint-snapshot', 'clarity-council')
        'related-agents' = @('scrum-master')
    }
    '10-research-analysis' = @{
        'related-skills' = @('idea-generate', 'clarity-council')
        'related-agents' = @()
    }
}

$updated = 0
$skipped = 0

# Categories to process (skip 00-council and 09-meta-orchestration - already done)
$categoriesToProcess = @('01-core-development', '02-language-specialists', '03-infrastructure',
    '04-quality-security', '05-data-ai', '06-developer-experience', '07-specialized-domains',
    '08-business-product', '10-research-analysis')

foreach ($category in $categoriesToProcess) {
    $categoryPath = Join-Path $AgentPath $category

    if (-not (Test-Path $categoryPath)) {
        Write-Host "Skipping: $category (path does not exist)" -ForegroundColor Yellow
        continue
    }

    $agentFiles = Get-ChildItem -Path $categoryPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

    if ($agentFiles.Count -eq 0) {
        continue
    }

    Write-Host "`n[$category] Processing $($agentFiles.Count) agents..." -ForegroundColor Cyan

    $pattern = $patterns[$category]
    $skillsList = ($pattern['related-skills'] | ForEach-Object { "  - $_" }) -join "`n"
    $agentsList = ($pattern['related-agents'] | ForEach-Object { "  - $_" }) -join "`n"

    foreach ($file in $agentFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        # Check if already has loop-eligible field (skip if already updated)
        if ($content -match 'loop-eligible:') {
            $skipped++
            continue
        }

        # Find the end of frontmatter (last ---)
        if ($content -match '^---\s*\n([\s\S]*?)\n---') {
            $frontmatter = $matches[1]
            $frontmatterEnd = $content.IndexOf("---`n", $content.IndexOf("---") + 3)

            # Build new fields
            $newFields = ""

            # Add related-skills if not already present
            if ($skillsList -and $content -notmatch 'related-skills:') {
                $newFields += "related-skills:`n$skillsList`n"
            }

            # Add related-agents if not already present
            if ($agentsList -and $content -notmatch 'related-agents:') {
                $newFields += "related-agents:`n$agentsList`n"
            }

            # Always add loop-eligible
            $newFields += "loop-eligible: false`n"

            # Insert fields before the closing ---
            $newContent = $content.Substring(0, $frontmatterEnd) + $newFields + $content.Substring($frontmatterEnd)

            if ($DryRun) {
                Write-Host "  [DRY RUN] Would update: $($file.Name)" -ForegroundColor Green
            } else {
                Set-Content -Path $file.FullName -Value $newContent
                Write-Host "  ✓ Updated: $($file.Name)" -ForegroundColor Green
                $updated++
            }
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Bulk Update Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Updated: $updated agents" -ForegroundColor Green
Write-Host "Skipped (already updated): $skipped agents" -ForegroundColor Yellow
