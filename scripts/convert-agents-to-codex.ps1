#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generate the Codex-facing artifacts (per-skill metadata, plugin manifest,
    and the CLAUDE.md maintainer mirror) from the canonical markdown sources.

.DESCRIPTION
    The pack is skills-only: every capability lives under skills/ as a SKILL.md,
    which Claude Code reads directly. This script derives everything Codex needs,
    so a skill is authored once and works on both hosts:

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

    Claude-only frontmatter (allowed-tools, related-skills, loop-eligible) is
    intentionally dropped: Codex governs capability via sandbox_mode and
    session config, and model choice follows the user's session.

    Re-run after adding, renaming, or editing any skill, or after editing
    AGENTS.md. Stale openai.yaml files for removed skills are deleted.

    (Historical: the pack once shipped subagents under agents/ that were
    compiled to .codex/agents/*.toml here. Those were folded into skills; see
    docs/adr/ADR-0006.)

.PARAMETER RepoRoot
    Path to the repository root (default: parent of this script's folder)

.EXAMPLE
    ./scripts/convert-agents-to-codex.ps1
#>

param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$skillsDir = Join-Path $RepoRoot 'skills'
$manifest = Join-Path $RepoRoot 'plugin.json'

if (-not (Test-Path $skillsDir)) { throw "skills/ not found under $RepoRoot" }

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

$errors = @()

# --- Per-skill Codex metadata: skills/**/<name>/agents/openai.yaml --------
# Hand-authored SKILL.md is the source of truth; this derives the Codex picker
# metadata beside it. User-invoked skills (disable-model-invocation: true) also
# get policy.allow_implicit_invocation: false so Codex keeps them out of the
# model's reach, matching Claude Code. Skills are organized into category
# subfolders (skills/<category>/<name>/SKILL.md), so discovery is RECURSIVE:
# any SKILL.md at any depth under skills/ is a skill. The 'agents' subfolder we
# generate is excluded so we never treat generated output as a skill.
$skillYamlCount = 0
$skillMdFiles = Get-ChildItem -Path $skillsDir -Recurse -Filter 'SKILL.md' -File |
Sort-Object FullName

foreach ($skillMdFile in $skillMdFiles) {
    $skill = $skillMdFile.Directory
    $skillMd = $skillMdFile.FullName
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

    $relSkillPath = [IO.Path]::GetRelativePath($RepoRoot, $skillMd) -replace '\\', '/'
    $yaml = @(
        "# Generated from $relSkillPath by scripts/convert-agents-to-codex.ps1 -- do not edit by hand."
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

# Remove openai.yaml for skills that no longer exist (folder deleted). Recurse,
# and only treat an agents/openai.yaml as orphaned if its sibling SKILL.md is gone.
Get-ChildItem -Path $skillsDir -Recurse -Filter 'openai.yaml' -File | ForEach-Object {
    $skillDir = $_.Directory.Parent   # <skill>/agents/openai.yaml -> <skill>
    if ($skillDir -and -not (Test-Path (Join-Path $skillDir.FullName 'SKILL.md'))) {
        Write-Host "Removing stale $([IO.Path]::GetRelativePath($RepoRoot,$_.FullName) -replace '\\','/')" -ForegroundColor Yellow
        Remove-Item $_.FullName -Confirm:$false
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

# Count skills (informational): every SKILL.md anywhere under skills/
$skillCount = @($skillMdFiles).Count

# Codex plugin manifest (root plugin.json). Official schema: plugins bundle
# skills / apps / MCP servers via directory-path fields. This pack is skills-only,
# so it bundles ./skills/. Metadata mirrors .claude-plugin/plugin.json.
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
Write-Host "Generated $skillYamlCount skill openai.yaml files in skills/*/agents/" -ForegroundColor Green
Write-Host "Mirrored AGENTS.md -> CLAUDE.md" -ForegroundColor Green
Write-Host "Manifest plugin.json written ($skillCount skills bundled via ./skills/)" -ForegroundColor Green

if ($errors.Count -gt 0) {
    Write-Host ""
    $errors | ForEach-Object { Write-Host "[ERROR] $_" -ForegroundColor Red }
    exit 1
}
