# AGENTS.md

Guidance for coding agents (Codex, Claude Code, or others) working in this repository.

## Nature of this repo

This is a dual-host **agent plugin**: a pack of prompt-based skills and subagent definitions installable into both Claude Code and OpenAI Codex. There is no build system or test runner; the only automation is the PowerShell scripts under `scripts/`.

## Source of truth

| Artifact | Role |
| :--- | :--- |
| `skills/<name>/SKILL.md` | Canonical skill definitions (open Agent Skills format — shared by both hosts as-is) |
| `agents/<category>/<name>.md` | Canonical agent definitions (Claude Code markdown frontmatter format) |
| `AGENTS.md` | Canonical maintainer guidance (this file — Codex auto-loads it) |
| `.codex/agents/*.toml` | **Generated** — Codex custom-agent files derived from `agents/**/*.md` |
| `skills/<name>/agents/openai.yaml` | **Generated** — Codex per-skill picker metadata derived from each `SKILL.md` frontmatter |
| `plugin.json` (root) | **Generated** — Codex plugin manifest (bundles `./skills/`; Codex plugins cannot carry agents) |
| `CLAUDE.md` (root) | **Generated** — mirror of `AGENTS.md` so Claude Code maintainers auto-load the same guidance |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest (hand-maintained) |
| `.claude-plugin/marketplace.json` | Claude Code marketplace catalog (hand-maintained; required by `/plugin marketplace add`) |
| `.agents/plugins/marketplace.json` | Codex marketplace catalog (hand-maintained; required by `codex plugin marketplace add`) |

**Never edit generated files by hand** — `.codex/agents/*.toml`, `skills/*/agents/openai.yaml`, the root `plugin.json`, or the root `CLAUDE.md`. Edit the markdown source (the skill/agent `.md`, or `AGENTS.md`), then regenerate:

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

## Skill invocation across hosts

Every skill is reachable one of two ways, and the axis is **who can invoke it**. This is a single decision in the canonical `SKILL.md` frontmatter; the generator projects it onto both hosts.

- **Model-invoked** (default) — reachable by the model *or* the user. Omit `disable-model-invocation`. Keep the rich trigger phrasing in `description` ("Use when the user says…, mentions…") so auto-invocation fires. The generated `openai.yaml` carries only the `interface` block.
- **User-invoked** — reachable *only* when the human types the skill name. Set `disable-model-invocation: true` in the frontmatter. The generator then adds `policy.allow_implicit_invocation: false` to that skill's `openai.yaml` — the Codex analog — so neither host lets the model reach it. There are currently eight: `codebase-explain`, `handoff`, `implement`, `plan-to-spec`, `plan-to-tickets`, `teach`, `which-skill`, `work-plan`.

Because the Codex side is **generated from the Claude-side frontmatter**, the two can't drift: a skill is user-invoked in both harnesses or neither. Do not hand-edit `openai.yaml` to change invocation — flip `disable-model-invocation` in `SKILL.md` and regenerate.

**Picker label:** `openai.yaml`'s `short_description` is derived from the first sentence of `description` (trimmed to ~90 chars). When that first sentence is trigger-heavy or truncates badly, add an optional `codex-short-description:` line to the `SKILL.md` frontmatter — the generator uses it verbatim as the override.

## Validation

```sh
pwsh ./scripts/lint-agents.ps1 -AgentPath ./agents    # frontmatter + taxonomy rules
pwsh ./scripts/convert-agents-to-codex.ps1            # must exit 0 with no errors
```

## Releasing

Releases are cut by the **Release** workflow (`.github/workflows/release.yml`),
triggered manually from the Actions tab with a `bump` level (`patch` / `minor` /
`major`, default `minor`). The workflow:

1. Regenerates Codex artifacts and **fails if the tree is out of sync** (same
   guard as `validate.yml`) — always commit generated files before releasing.
2. Lints agent frontmatter.
3. Bumps the version in `.claude-plugin/plugin.json` (the single source of truth)
   and re-runs `convert-agents-to-codex.ps1`, so the root `plugin.json` and every
   Codex artifact pick up the new version — **the Claude Code and Codex plugin
   versions can never diverge**.
4. Prepends a Keep a Changelog section to `CHANGELOG.md` from commit messages
   since the last tag (conventional-commit prefixes map to Added / Fixed /
   Changed / …).
5. Commits with `[skip ci]`, creates the annotated tag `v<version>`, pushes both
   to `main`, and publishes a GitHub Release with the generated notes.

The two helper scripts run locally for a dry run before releasing:

```sh
pwsh ./scripts/bump-version.ps1 -Bump minor -SkipConvert   # preview version, source manifest only
pwsh ./scripts/generate-changelog.ps1 -Version 1.1.0       # preview the changelog section
git checkout -- .                                          # revert the dry run
```

## Deeper guidance

- `skills/CLAUDE.md` — full skill format spec (frontmatter fields, Loop Method, quality loops) and the skills inventory table
- `README.md` — repo layout and install instructions for both hosts
- `docs/adr/` — architecture decision records governing taxonomy, models, and tool permissions
