<!-- Generated from AGENTS.md by scripts/convert-agents-to-codex.ps1 -- do not edit by hand. Edit AGENTS.md instead. -->

# AGENTS.md

Guidance for coding agents (Codex, Claude Code, or others) working in this repository.

## Nature of this repo

This is a dual-host **agent plugin**: a pack of prompt-based skills and subagent definitions installable into both Claude Code and OpenAI Codex. There is no build system or test runner; the only automation is the PowerShell scripts under `scripts/`.

## Source of truth

| Artifact | Role |
| :--- | :--- |
| `skills/<name>/SKILL.md` | Canonical skill definitions (open Agent Skills format — shared by both hosts as-is) |
| `agents/<category>/<name>.md` | Canonical agent definitions (Claude Code markdown frontmatter format) |
| `.codex/agents/*.toml` | **Generated** — Codex custom-agent files derived from `agents/**/*.md` |
| `plugin.json` (root) | **Generated** — Codex plugin manifest (bundles `./skills/`; Codex plugins cannot carry agents) |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest (hand-maintained) |
| `.claude-plugin/marketplace.json` | Claude Code marketplace catalog (hand-maintained; required by `/plugin marketplace add`) |
| `.agents/plugins/marketplace.json` | Codex marketplace catalog (hand-maintained; required by `codex plugin marketplace add`) |

**Never edit `.codex/agents/*.toml` or the root `plugin.json` by hand.** Edit the markdown source, then regenerate:

```
pwsh ./scripts/convert-agents-to-codex.ps1
```

## Editing rules

- Skill entry point is `SKILL.md` at the skill folder root; never move it. Supporting docs stay in the same folder and are referenced by paths relative to the skill folder (no host-specific variables like `${CLAUDE_PLUGIN_ROOT}` in new content).
- Skills must stay host-portable: describe intent ("ask the user", "consult the psychologist persona — via the `council-single-persona` subagent if available, otherwise inline") rather than naming host-specific tools. Host-specific behavior goes in a clearly marked note.
- Agent frontmatter requires `name` (kebab-case, matches filename), `description`, and `tools`; see `scripts/lint-agents.ps1` for the full ruleset (categories, model values, alphabetical ordering).
- Council personas are reference documents, not agents. New personas go in `references/council-personas/`, not `agents/`.
- Folder and agent names are stable once published — do not rename.
- After changing any agent or adding/removing a skill, re-run `convert-agents-to-codex.ps1` and commit the regenerated files alongside the source change.

## Validation

```
pwsh ./scripts/lint-agents.ps1 -AgentPath ./agents    # frontmatter + taxonomy rules
pwsh ./scripts/convert-agents-to-codex.ps1            # must exit 0 with no errors
```

## Deeper guidance

- `skills/CLAUDE.md` — full skill format spec (frontmatter fields, Loop Method, quality loops) and the skills inventory table
- `README.md` — repo layout and install instructions for both hosts
- `docs/adr/` — architecture decision records governing taxonomy, models, and tool permissions
