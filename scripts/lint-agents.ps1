#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Lint and validate all agents in the Claude Code collection.

.DESCRIPTION
    Validates agent YAML frontmatter, filename consistency, category structure,
    alphabetical ordering, and compliance with ADR policies.

.PARAMETER AgentPath
    Path to the agents folder (default: current directory)

.PARAMETER Verbose
    Show detailed validation output

.EXAMPLE
    .\lint-agents.ps1
    .\lint-agents.ps1 -AgentPath "C:\agents" -Verbose

.NOTES
    Validation rules based on:
    - ADR-0001: Category taxonomy (valid categories, structure)
    - ADR-0002: Model assignment policy (valid model values)
    - ADR-0003: Tool permissions framework (valid tool combinations)
    - ADR-0004: Frontmatter invariants (required fields, format)
#>

param(
    [string]$AgentPath = (Get-Location).Path,
    [switch]$Verbose = $false
)

# Configuration
$ValidCategories = @(
    '01-core-development',
    '02-language-specialists',
    '03-infrastructure',
    '04-quality-security',
    '05-data-ai',
    '06-developer-experience',
    '07-specialized-domains',
    '08-business-product',
    '09-meta-orchestration',
    '10-research-analysis'
)

$ValidModels = @('haiku', 'sonnet', 'opus')

$ValidTools = @('Read', 'Write', 'Edit', 'Bash', 'Glob', 'Grep', 'WebFetch', 'WebSearch')

$ToolProfiles = @{
    'ReadOnly' = @('Read', 'Grep', 'Glob')
    'Research' = @('Read', 'Grep', 'Glob', 'WebFetch', 'WebSearch')
    'Development' = @('Read', 'Write', 'Edit', 'Bash', 'Glob', 'Grep')
    'Documentation' = @('Read', 'Write', 'Edit', 'Glob', 'Grep', 'WebFetch', 'WebSearch')
    'Orchestration' = @('Read', 'Write', 'Edit', 'Glob', 'Grep')
}

# Results tracking
$errors = @()
$warnings = @()
$validAgents = @()
$allRelationships = @()  # Track all relationships for circular dependency detection

function Add-Error {
    param([string]$message)
    $errors += $message
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Add-Warning {
    param([string]$message)
    $warnings += $message
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Add-Success {
    param([string]$message)
    if ($Verbose) {
        Write-Host "[OK] $message" -ForegroundColor Green
    }
}

function Test-AgentFilename {
    param([string]$filename)
    
    # Must be .md and lowercase with hyphens only
    if ($filename -notmatch '^[a-z0-9\-]+\.md$') {
        return $false
    }
    
    return $true
}

function Test-AgentName {
    param([string]$name)
    
    # Lowercase kebab-case, no leading/trailing hyphens, ≤50 chars
    if ($name -notmatch '^[a-z0-9]([a-z0-9\-]{0,48}[a-z0-9])?$') {
        return $false
    }
    
    return $true
}

function Extract-Frontmatter {
    param([string]$filePath)
    
    $content = Get-Content -Path $filePath -Raw
    
    # Extract YAML frontmatter between --- markers
    if ($content -match '^---\s*\n([\s\S]*?)\n---') {
        $frontmatter = $matches[1]
        $result = @{}
        
        # Parse YAML-like format (simple key: value)
        $frontmatter -split '\n' | ForEach-Object {
            if ($_ -match '^(\w+):\s*(.*)$') {
                $key = $matches[1]
                $value = $matches[2].Trim('"')
                $result[$key] = $value
            }
        }
        
        return $result
    }
    
    return $null
}

function Test-LoopMethodFields {
    param(
        [string]$filePath,
        [string]$filename,
        [string]$category,
        [hashtable]$fm,
        [hashtable]$allAgentNames,
        [hashtable]$allSkillNames
    )

    # Check related-skills if present
    if ($fm['related-skills']) {
        $skills = @($fm['related-skills'] -split ',\s*' | ForEach-Object { $_.Trim() })
        foreach ($skill in $skills) {
            if ($skill -and -not $allSkillNames.ContainsKey($skill)) {
                Add-Warning "$category/$filename : related-skill '$skill' does not exist"
            }
        }
    }

    # Check related-agents if present
    if ($fm['related-agents']) {
        $agents = @($fm['related-agents'] -split ',\s*' | ForEach-Object { $_.Trim() })
        foreach ($agent in $agents) {
            if ($agent -and -not $allAgentNames.ContainsKey($agent)) {
                Add-Warning "$category/$filename : related-agent '$agent' does not exist"
            }
            # Check for self-reference
            if ($agent -eq $fm['name']) {
                Add-Error "$category/$filename : Self-reference in related-agents (cannot reference itself)"
                return $false
            }
        }
    }

    # Check loop-eligible
    if ($fm['loop-eligible'] -eq 'true') {
        if (-not $category.StartsWith('09-')) {
            Add-Error "$category/$filename : loop-eligible=true only allowed in 09-meta-orchestration"
            return $false
        }
    }

    return $true
}

function Validate-Agent {
    param(
        [string]$filePath,
        [string]$category,
        [hashtable]$allAgentNames
    )
    
    $filename = Split-Path -Leaf $filePath
    $filenameWithoutExt = $filename -replace '\.md$', ''
    
    # Test filename format
    if (-not (Test-AgentFilename $filename)) {
        Add-Error "$category/$filename : Invalid filename format (must be lowercase kebab-case .md)"
        return $null
    }
    
    # Extract frontmatter
    $fm = Extract-Frontmatter -FilePath $filePath
    if (-not $fm) {
        Add-Error "$category/$filename : No YAML frontmatter found"
        return $null
    }
    
    # Validate required fields
    $requiredFields = @('name', 'description', 'tools')
    foreach ($field in $requiredFields) {
        if (-not $fm[$field]) {
            Add-Error "$category/$filename : Missing required field '$field'"
            return $null
        }
    }
    
    $name = $fm['name']
    $description = $fm['description']
    $tools = $fm['tools']
    $model = $fm['model'] -or 'sonnet'
    
    # Validate name
    if (-not (Test-AgentName $name)) {
        Add-Error "$category/$filename : Invalid name format '$name' (must be lowercase kebab-case, ≤50 chars)"
        return $null
    }
    
    # Validate filename matches name
    if ($filenameWithoutExt -ne $name) {
        Add-Error "$category/$filename : Filename doesn't match name field '$name'"
        return $null
    }
    
    # Check for duplicate names
    if ($allAgentNames.ContainsKey($name)) {
        Add-Error "$category/$filename : Duplicate name found (also in $($allAgentNames[$name]))"
        return $null
    }
    
    # Validate description
    if ($description.Length -lt 10) {
        Add-Error "$category/$filename : Description too short (must be ≥10 characters)"
        return $null
    }
    
    if ($description.Length -gt 200) {
        Add-Error "$category/$filename : Description too long (must be ≤200 characters)"
        return $null
    }
    
    # Validate model
    if ($model -notin $ValidModels) {
        Add-Error "$category/$filename : Invalid model value '$model' (must be: haiku, sonnet, opus)"
        return $null
    }
    
    # Validate tools
    $toolList = @($tools -split ',\s*' | ForEach-Object { $_.Trim() })
    $invalidTools = @($toolList | Where-Object { $_ -notin $ValidTools })
    
    if ($invalidTools.Count -gt 0) {
        Add-Error "$category/$filename : Invalid tools: $($invalidTools -join ', ')"
        return $null
    }
    
    # Warn about non-standard tool combinations
    $isStandard = $false
    foreach ($profileTools in $ToolProfiles.Values) {
        if (($toolList | Sort-Object) -eq ($profileTools | Sort-Object)) {
            $isStandard = $true
            break
        }
    }
    
    if (-not $isStandard) {
        Add-Warning "$category/$filename : Non-standard tool combination (custom: $tools)"
    }
    
    Add-Success "$category/$filename : Valid"

    return @{
        Category = $category
        Filename = $filename
        Name = $name
        Description = $description
        Tools = $tools
        Model = $model
        Frontmatter = $fm
    }
}

# Load skill names from skills directory for cross-validation
function Get-AllSkillNames {
    param([string]$rootPath)

    $skillNames = @{}
    $skillsPath = Join-Path (Split-Path $rootPath -Parent) "skills"

    if (Test-Path $skillsPath -PathType Container) {
        Get-ChildItem -Path $skillsPath -Directory | ForEach-Object {
            $skillNames[$_.Name] = $true
        }
    }

    return $skillNames
}

# Main validation logic
Write-Host "Linting Claude Code agents collection..." -ForegroundColor Cyan
Write-Host ""

$agentsByCategory = @{}
$allAgentNames = @{}
$allSkillNames = Get-AllSkillNames $AgentPath

# Find all agent files
foreach ($category in $ValidCategories) {
    $categoryPath = Join-Path $AgentPath $category
    
    if (-not (Test-Path $categoryPath -PathType Container)) {
        Add-Warning "Category folder missing: $category"
        continue
    }
    
    $agentFiles = Get-ChildItem -Path $categoryPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" } | Sort-Object Name
    
    if ($agentFiles.Count -eq 0) {
        Add-Warning "$category : No agents found"
        continue
    }
    
    $agentsByCategory[$category] = @()
    $previousFilename = $null
    
    foreach ($file in $agentFiles) {
        # Validate alphabetical ordering
        if ($previousFilename -and ($file.Name -lt $previousFilename)) {
            Add-Error "$category : Out of alphabetical order at $($file.Name) (comes after $previousFilename)"
        }

        $agent = Validate-Agent -FilePath $file.FullName -Category $category -AllAgentNames $allAgentNames
        if ($agent) {
            # Validate Loop Method fields
            $loopValid = Test-LoopMethodFields -FilePath $file.FullName -Filename $file.Name -Category $category -Frontmatter $agent.Frontmatter -AllAgentNames $allAgentNames -AllSkillNames $allSkillNames
            if (-not $loopValid) {
                $previousFilename = $file.Name
                continue
            }

            $agentsByCategory[$category] += $agent
            $allAgentNames[$agent.Name] = "$category/$($agent.Filename)"
            $validAgents += $agent
        }

        $previousFilename = $file.Name
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$agentCount = $validAgents.Count
$errorCount = $errors.Count
$warningCount = $warnings.Count

Write-Host "Total agents validated: $agentCount" -ForegroundColor Cyan
Write-Host "Errors: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $warningCount" -ForegroundColor $(if ($warningCount -eq 0) { "Green" } else { "Yellow" })

if ($errorCount -eq 0 -and $warningCount -eq 0) {
    Write-Host ""
    Write-Host "[✓] All agents validated successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    if ($errorCount -gt 0) {
        Write-Host "[✗] Validation failed with $errorCount error(s)" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "[⚠] Validation succeeded with $warningCount warning(s)" -ForegroundColor Yellow
        exit 0
    }
}
