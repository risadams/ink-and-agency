#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generate the Codex-facing artifacts (agent TOMLs, per-skill metadata,
    plugin manifest, and the CLAUDE.md maintainer mirror) from the canonical
    markdown sources.

.DESCRIPTION
    The markdown files under agents/ and skills/ are the single source of
    truth (Claude Code reads them directly). This script derives everything
    Codex needs, so a skill/agent is authored once and works on both hosts:

      .codex/agents/<name>.toml        one per agent: name, description,
                                       developer_instructions (= markdown body)
      skills/<name>/agents/openai.yaml one per skill: Codex picker metadata
                                       (interface.display_name +
                                       interface.short_description) and, for
                                       user-invoked skills (frontmatter
                                       disable-model-invocation: true), the
                                       policy.allow_implicit_invocation: false
                                       that pairs with it
      plugin.json                      Codex plugin manifest at the repo root,
                                       bundling ./skills/
      CLAUDE.md                        mirror of AGENTS.md so Claude Code
                                       maintainers auto-load the same guidance
                                       (avoids a git symlink, which breaks on
                                       Windows checkouts)

    Claude-only frontmatter (tools, model, related-*, loop-eligible) is
    intentionally dropped: Codex governs capability via sandbox_mode and
    session config, and model choice should follow the user's session.

    Re-run after adding, renaming, or editing any agent or skill, or after
    editing AGENTS.md. Stale TOML files for removed agents are deleted; stale
    openai.yaml files for removed skills are deleted.

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
$outDir = Join-Path $RepoRoot '.codex/agents'
$manifest = Join-Path $RepoRoot 'plugin.json'

if (-not (Test-Path $agentsDir)) { throw "agents/ not found under $RepoRoot" }
New-Item -ItemType Directory -Force $outDir | Out-Null

function ConvertTo-TomlBasicString {
    param([string]$s)
    $s = $s -replace '\\', '\\'
    $s = $s -replace '"', '\"'
    return $s
}

function ConvertTo-YamlBasicString {
    param([string]$s)
    # Double-quoted YAML scalar: escape backslash and double-quote.
    $s = $s -replace '\\', '\\'
    $s = $s -replace '"', '\"'
    return $s
}

# Read one scalar frontmatter key, supporting plain, folded (>) and literal (|)
# block scalars. Block scalars collapse to a single space-joined line, which is
# what we want for a picker description.
function Get-FrontmatterScalar {
    param([string]$Frontmatter, [string]$Key)
    $lines = $Frontmatter -split '\r?\n'
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^$([regex]::Escape($Key)):\s*(.*)$") {
            $inline = $Matches[1].Trim()
            if ($inline -and $inline -notmatch '^[>|][+-]?$') {
                return $inline.Trim('"').Trim("'")
            }
            # Block scalar: gather deeper-indented following lines.
            $block = @()
            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match '^\s*$') { $block += ''; continue }
                if ($lines[$j] -match '^(\s+)(.*)$') { $block += $Matches[2]; continue }
                break   # dedented to a new top-level key
            }
            return (($block -join ' ') -replace '\s+', ' ').Trim()
        }
    }
    return $null
}

# "work-plan" -> "Work Plan"; acronyms preserved, minor joining words lowercased
# unless first ("plan-to-spec" -> "Plan to Spec").
function ConvertTo-DisplayName {
    param([string]$Slug)
    $keep  = @{ 'sp' = 'SP'; 'cli' = 'CLI'; 'sos' = 'SoS'; 'ai' = 'AI'; 'tdd' = 'TDD' }
    $minor = @('to', 'a', 'an', 'of', 'the', 'in', 'on', 'and', 'or', 'vs', 'for')
    $parts = $Slug -split '-'
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $w = $parts[$i]
        if ($keep.ContainsKey($w))            { $parts[$i] = $keep[$w] }
        elseif ($i -gt 0 -and $w -in $minor)  { $parts[$i] = $w }
        else                                  { $parts[$i] = $w.Substring(0,1).ToUpper() + $w.Substring(1) }
    }
    $parts -join ' '
}

# Codex short_description: prefer an explicit `codex-short-description` override,
# else the first sentence of `description`, trimmed to a picker-friendly length.
function Get-ShortDescription {
    param([string]$Override, [string]$Description)
    if ($Override) { return $Override.Trim() }
    $d = $Description.Trim()
    # First sentence: up to the first '. ', '! ', '? ' or ';' boundary.
    if ($d -match '^(.*?[.!?])(\s|$)') { $d = $Matches[1] }
    elseif ($d -match '^(.*?);') { $d = $Matches[1] }
    $d = $d.TrimEnd('.', ' ')
    if ($d.Length -gt 90) { $d = $d.Substring(0, 87).TrimEnd() + '...' }
    return $d
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
        if ($line -match '^name:\s*(.+)$') { $name = $Matches[1].Trim().Trim('"') }
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

# --- Per-skill Codex metadata: skills/<name>/agents/openai.yaml -----------
# Hand-authored SKILL.md is the source of truth; this derives the Codex picker
# metadata beside it. User-invoked skills (disable-model-invocation: true) also
# get policy.allow_implicit_invocation: false so Codex keeps them out of the
# model's reach, matching Claude Code. Skill folders (junctions to _private/)
# are followed like any directory.
$skillYamlCount = 0
$skillFolders = Get-ChildItem -Path $skillsDir -Directory |
Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
Sort-Object Name

foreach ($skill in $skillFolders) {
    $skillMd = Join-Path $skill.FullName 'SKILL.md'
    $raw = Get-Content -Path $skillMd -Raw

    if ($raw -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n') {
        $errors += "${skillMd}: no frontmatter block"
        continue
    }
    $fm = $Matches[1]

    $skillName = Get-FrontmatterScalar $fm 'name'
    $skillDesc = Get-FrontmatterScalar $fm 'description'
    $override = Get-FrontmatterScalar $fm 'codex-short-description'
    if (-not $skillName) { $skillName = $skill.Name }
    if (-not $skillDesc) { $errors += "${skillMd}: missing description"; continue }

    # User-invoked in Claude Code => must be user-invoked in Codex too.
    $userInvoked = $fm -match '(?m)^disable-model-invocation:\s*true\s*$'

    $display = ConvertTo-DisplayName $skillName
    $short = Get-ShortDescription $override $skillDesc

    $yaml = @(
        "# Generated from skills/$($skill.Name)/SKILL.md by scripts/convert-agents-to-codex.ps1 -- do not edit by hand."
        "interface:"
        "  display_name: `"$(ConvertTo-YamlBasicString $display)`""
        "  short_description: `"$(ConvertTo-YamlBasicString $short)`""
    )
    if ($userInvoked) {
        $yaml += @(
            "policy:"
            "  allow_implicit_invocation: false"
        )
    }

    $skillAgentsDir = Join-Path $skill.FullName 'agents'
    New-Item -ItemType Directory -Force $skillAgentsDir | Out-Null
    $yamlPath = Join-Path $skillAgentsDir 'openai.yaml'
    $out = ($yaml -join "`n") + "`n"
    [IO.File]::WriteAllText($yamlPath, $out, [Text.UTF8Encoding]::new($false))
    $skillYamlCount++
}

# Remove openai.yaml for skills that no longer exist (folder deleted).
Get-ChildItem -Path $skillsDir -Directory -Filter '*' | ForEach-Object {
    $orphan = Join-Path $_.FullName 'agents/openai.yaml'
    if ((Test-Path $orphan) -and -not (Test-Path (Join-Path $_.FullName 'SKILL.md'))) {
        Write-Host "Removing stale $([IO.Path]::GetRelativePath($RepoRoot,$orphan) -replace '\\','/')" -ForegroundColor Yellow
        Remove-Item $orphan -Confirm:$false
    }
}

# --- CLAUDE.md maintainer mirror -----------------------------------------
# AGENTS.md is the canonical maintainer guide (Codex auto-loads it). Mirror it
# to a root CLAUDE.md so Claude Code maintainers auto-load the same text. A git
# symlink would be cleaner but materializes as a plain file on Windows checkout,
# so we generate a real copy with a provenance header instead.
$agentsMd = Join-Path $RepoRoot 'AGENTS.md'
$claudeMd = Join-Path $RepoRoot 'CLAUDE.md'
if (Test-Path $agentsMd) {
    $agentsBody = (Get-Content -Path $agentsMd -Raw) -replace "`r`n", "`n"
    $header = "<!-- Generated from AGENTS.md by scripts/convert-agents-to-codex.ps1 -- do not edit by hand. Edit AGENTS.md instead. -->`n`n"
    [IO.File]::WriteAllText($claudeMd, $header + $agentsBody, [Text.UTF8Encoding]::new($false))
}
else {
    $errors += "AGENTS.md not found -- cannot generate CLAUDE.md mirror"
}

# Count skills (informational): every skills/ subfolder containing a SKILL.md
$skillCount = @($skillFolders).Count

# Codex plugin manifest (root plugin.json). Official schema: plugins bundle
# skills / apps / MCP servers via directory-path fields; agents are NOT plugin
# components (they install to ~/.codex/agents/ or work project-scoped from
# .codex/agents/). Metadata mirrors .claude-plugin/plugin.json.
$claudeManifest = Get-Content (Join-Path $RepoRoot '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json

$manifestObj = [ordered]@{
    name        = $claudeManifest.name
    version     = $claudeManifest.version
    description = $claudeManifest.description
    author      = [ordered]@{
        name = $claudeManifest.author.name
        url  = $claudeManifest.author.url
    }
    homepage    = $claudeManifest.homepage
    repository  = $claudeManifest.repository
    license     = $claudeManifest.license
    keywords    = @($claudeManifest.keywords)
    skills      = './skills/'
    interface   = [ordered]@{
        displayName      = 'Ink and Agency'
        shortDescription = 'Writing, sprint, and decision-support skills plus a persona council.'
    }
}
# Normalize to LF so output is byte-identical on Windows and Linux (CI sync check)
$json = ($manifestObj | ConvertTo-Json -Depth 5) -replace "`r`n", "`n"
[IO.File]::WriteAllText($manifest, $json + "`n", [Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Generated $($generated.Count) agent TOMLs in .codex/agents/" -ForegroundColor Green
Write-Host "Generated $skillYamlCount skill openai.yaml files in skills/*/agents/" -ForegroundColor Green
Write-Host "Mirrored AGENTS.md -> CLAUDE.md" -ForegroundColor Green
Write-Host "Manifest plugin.json written ($skillCount skills bundled via ./skills/)" -ForegroundColor Green

if ($errors.Count -gt 0) {
    Write-Host ""
    $errors | ForEach-Object { Write-Host "[ERROR] $_" -ForegroundColor Red }
    exit 1
}
