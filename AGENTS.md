# AGENTS.md

Guidance for coding agents (Codex, Claude Code, or others) working in this repository.

## Nature of this repo

This is a dual-host **skills plugin**: a single-primitive pack of prompt-based skills installable into both Claude Code and OpenAI Codex. Everything is a skill, organized into category subfolders: `skills/<category>/<name>/SKILL.md` (e.g. `skills/language-specialists/python-pro/SKILL.md`). Skill discovery is **recursive** — a `SKILL.md` at any depth under `skills/` is a skill, so categories are just folders and carry no meaning to the hosts. The 15 categories are listed in [`skills/CATEGORIES.md`](skills/CATEGORIES.md). The pack once shipped a separate library of subagents under `agents/`, but those were folded into the skills namespace so the whole pack ships in the one bundle both hosts read (Codex plugins bundle only `./skills/` — they cannot carry agents). See [ADR-0006](docs/adr/ADR-0006-agents-folded-into-skills.md) and [ADR-0007](docs/adr/ADR-0007-skill-categories.md). There is no build system or test runner; the only automation is the PowerShell scripts under `scripts/`.

## Source of truth

| Artifact | Role |
| :--- | :--- |
| `skills/<category>/<name>/SKILL.md` | Canonical skill definitions (open Agent Skills format — shared by both hosts as-is) |
| `AGENTS.md` | Canonical maintainer guidance (this file — Codex auto-loads it) |
| `skills/<category>/<name>/agents/openai.yaml` | **Generated** — Codex per-skill picker metadata derived from each `SKILL.md` frontmatter |
| `plugin.json` (root) | **Generated** — Codex plugin manifest (bundles `./skills/`) |
| `CLAUDE.md` (root) | **Generated** — mirror of `AGENTS.md` so Claude Code maintainers auto-load the same guidance |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest (hand-maintained) |
| `.claude-plugin/marketplace.json` | Claude Code marketplace catalog (hand-maintained; required by `/plugin marketplace add`) |
| `.agents/plugins/marketplace.json` | Codex marketplace catalog (hand-maintained; required by `codex plugin marketplace add`) |

**Never edit generated files by hand** — `skills/**/agents/openai.yaml`, the root `plugin.json`, or the root `CLAUDE.md`. Edit the markdown source (a `SKILL.md`, or `AGENTS.md`), then regenerate:

```
pwsh ./scripts/convert-agents-to-codex.ps1
```

## Editing rules

- Skill entry point is `SKILL.md` at the skill folder root; never move it. Supporting docs stay in the same folder and are referenced by paths relative to the skill folder (no host-specific variables like `${CLAUDE_PLUGIN_ROOT}` in new content).
- New skills go in `skills/<category>/<name>/SKILL.md` under one of the 15 categories in [`skills/CATEGORIES.md`](skills/CATEGORIES.md). The **skill name is the leaf folder** (`<name>`) and must be globally unique across all categories. `name` is the invocation identifier and is independent of the category folder — moving a skill between categories does not change how it's invoked, but cross-skill relative links encode the category path (`../../<category>/<name>/`), so update those if you move one.
- Skills must stay host-portable: describe intent ("ask the user", "consult the psychologist persona via the `clarity-council` skill in single mode") rather than naming host-specific tools. Host-specific behavior goes in a clearly marked note.
- Skill frontmatter requires `name` (kebab-case, matches the leaf folder) and `description`; `allowed-tools`, `related-skills`, `loop-eligible`/`recurrence-hint`, `compatibility`, and `disable-model-invocation` are optional. See `scripts/lint-skills.ps1` for the full ruleset. There is no `related-agents` field — the pack is skills-only; cross-references go in `related-skills`.
- Council personas are reference documents bundled inside the `clarity-council` skill. New personas go in `skills/clarity-council/skills/personas/`. The council itself is a skill (three inline modes: single / multi / iterative) — see [ADR-0005](docs/adr/ADR-0005-council-skill-side.md).
- Many skills are former specialist subagents (persona experts like `python-pro`, `security-auditor`). They run inline like any skill — Claude Code no longer spawns them as isolated parallel subagents. See [ADR-0006](docs/adr/ADR-0006-agents-folded-into-skills.md).
- Folder and skill names are stable once published — do not rename.
- After adding/removing/editing a skill, re-run `convert-agents-to-codex.ps1` and commit the regenerated files alongside the source change.

## Skill invocation across hosts

Every skill is reachable one of two ways, and the axis is **who can invoke it**. This is a single decision in the canonical `SKILL.md` frontmatter; the generator projects it onto both hosts.

- **Model-invoked** (default) — reachable by the model *or* the user. Omit `disable-model-invocation`. Keep the rich trigger phrasing in `description` ("Use when the user says…, mentions…") so auto-invocation fires. The generated `openai.yaml` carries only the `interface` block.
- **User-invoked** — reachable *only* when the human types the skill name. Set `disable-model-invocation: true` in the frontmatter. The generator then adds `policy.allow_implicit_invocation: false` to that skill's `openai.yaml` — the Codex analog — so neither host lets the model reach it. There are currently eight: `codebase-explain`, `handoff`, `implement`, `plan-to-spec`, `plan-to-tickets`, `teach`, `which-skill`, `work-plan`.

Because the Codex side is **generated from the Claude-side frontmatter**, the two can't drift: a skill is user-invoked in both harnesses or neither. Do not hand-edit `openai.yaml` to change invocation — flip `disable-model-invocation` in `SKILL.md` and regenerate.

**Picker label:** `openai.yaml`'s `short_description` is derived from the first sentence of `description` (trimmed to ~90 chars). When that first sentence is trigger-heavy or truncates badly, add an optional `codex-short-description:` line to the `SKILL.md` frontmatter — the generator uses it verbatim as the override.

## Validation

```sh
pwsh ./scripts/lint-skills.ps1              # SKILL.md frontmatter + referential integrity
pwsh ./scripts/convert-agents-to-codex.ps1 # must exit 0 with no errors
```

## Releasing

Releases are cut by the **Release** workflow (`.github/workflows/release.yml`),
triggered manually from the Actions tab with a `bump` level (`patch` / `minor` /
`major`, default `minor`). The workflow:

1. Regenerates Codex artifacts and **fails if the tree is out of sync** (same
   guard as `validate.yml`) — always commit generated files before releasing.
2. Lints skill frontmatter.
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
- `docs/adr/` — architecture decision records (note: ADR-0001–0004 governed the retired `agents/` taxonomy and are historical; ADR-0005/0006 record the fold to a skills-only pack)
