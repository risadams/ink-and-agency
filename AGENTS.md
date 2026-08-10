# AGENTS.md

Guidance for coding agents (Codex, Claude Code, or others) working in this repository.

## Nature of this repo

This is an **[Agent Plugins](https://agent-plugins.org) 1.0.0 plugin**: a single-primitive pack of prompt-based skills that any conformant host can install — Claude Code, OpenAI Codex, Cursor, Copilot, Kiro, VS Code. Everything is a skill, and the layout is **flat**: `skills/<name>/SKILL.md` (e.g. `skills/python-pro/SKILL.md`).

**The flat layout is not a style choice.** Agent Plugins §7.1 fixes skills at the *immediate children* of `skills/` and states that clients "MUST NOT recursively search deeper descendants". A `SKILL.md` nested any deeper is invisible to a conformant host, so both `lint-skills.ps1` and `convert-agents-to-codex.ps1` fail on one. Skills used to live in category subfolders; the category now rides in the `category:` frontmatter field, which is what drives the browsable listing in [`skills/CATEGORIES.md`](skills/CATEGORIES.md) (15 categories, plus `featured` for `clarity-council`).

The portable manifest is the root `plugin.json`. Its schema is **closed** — ten fields, no others — so anything host-specific goes under `extensions` in a reverse-domain namespace (`com.openai.codex` carries the Codex picker metadata). Claude Code additionally reads `.claude-plugin/plugin.json`, whose `skills` array is generated from the tree so it can never drift. The pack once shipped a separate library of subagents under `agents/`, but those were folded into the skills namespace so the whole pack ships in the one bundle every host reads. There is no build system or test runner; the only automation is the PowerShell scripts under `scripts/`.

## Source of truth

| Artifact | Role |
| :--- | :--- |
| `skills/<name>/SKILL.md` | Canonical skill definitions (open Agent Skills format — shared by every host as-is) |
| `AGENTS.md` | Canonical maintainer guidance (this file — Codex auto-loads it) |
| `skills/<name>/agents/openai.yaml` | **Generated** — Codex per-skill picker metadata derived from each `SKILL.md` frontmatter |
| `plugin.json` (root) | **Generated** — the Agent Plugins 1.0.0 manifest. Closed schema; version and metadata mirror `.claude-plugin/plugin.json` |
| `CLAUDE.md` (root) | **Generated** — mirror of `AGENTS.md` so Claude Code maintainers auto-load the same guidance |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest and the **version source of truth**; metadata hand-maintained, the `skills` array **generated** from the tree |
| `assets/logo.svg` | Brand mark, source of truth. Not referenced by any manifest — it renders correctly only in a browser engine (`feTurbulence`/`feDisplacementMap` filters plus `mix-blend-mode: multiply`) |
| `assets/logo.png` | **Generated** from `logo.svg` — 512×512, transparent, trimmed and centered for icon use. What the Codex `interface` block (`logo`, `composerIcon`) points at; `brandColor` there is the mark's rose `#CB0162`. Claude Code's plugin and marketplace schemas define no icon field, so the mark surfaces only in hosts implementing that namespace. Regenerate by rendering the SVG in a headless browser at 3× (ImageMagick's own SVG reader drops the filters), then `magick in.png -trim +repage -background none -gravity center -extent "%[fx:max(w,h)*1.16]x%[fx:max(w,h)*1.16]" -resize 512x512 -strip assets/logo.png` |
| `mcp.json` (root) | Not present — the pack ships no MCP servers. Agent Plugins §6.2 treats an absent fixed location as normal, not an error |
| `.claude-plugin/marketplace.json` | Claude Code marketplace catalog (hand-maintained; required by `/plugin marketplace add`) |
| `.agents/plugins/marketplace.json` | Codex marketplace catalog (hand-maintained; required by `codex plugin marketplace add`) |
| Self-Evolve footer in every `SKILL.md` | **Machine-maintained** — the block between `<!-- self-evolve:start -->`/`end` markers is written by `scripts/add-self-evolve.ps1` from its template; the contract it points to is [`skills/SELF-EVOLVE.md`](skills/SELF-EVOLVE.md) |

**Never edit generated files by hand** — `skills/*/agents/openai.yaml`, the root `plugin.json`, the root `CLAUDE.md`, the `skills` array in `.claude-plugin/plugin.json`, or the Self-Evolve footer blocks in `SKILL.md` files (change the template in `scripts/add-self-evolve.ps1` and re-run it). Edit the markdown source (a `SKILL.md`, or `AGENTS.md`), then regenerate (the other keys in `.claude-plugin/plugin.json` stay hand-maintained):

```sh
pwsh ./scripts/convert-agents-to-codex.ps1
```

## Editing rules

- Skill entry point is `SKILL.md` at the skill folder root; never move it. Supporting docs stay in the same folder and are referenced by paths relative to the skill folder (no host-specific variables like `${CLAUDE_PLUGIN_ROOT}` in new content).
- New skills go in `skills/<name>/SKILL.md` — one level under `skills/`, never deeper. The **skill name is the folder name** and must be globally unique; it is the invocation identifier. Pick a `category:` from the 15 in [`skills/CATEGORIES.md`](skills/CATEGORIES.md) (or `featured`); recategorizing is a one-line frontmatter edit that moves nothing and breaks no links.
- Cross-skill relative links are now a single hop: `../<name>/`. Anything still written `../../<category>/<name>/` is stale.
- Skills must stay host-portable: describe intent ("ask the user", "consult the psychologist persona via the `clarity-council` skill in single mode") rather than naming host-specific tools. Host-specific behavior goes in a clearly marked note.
- Skill frontmatter requires `name` (kebab-case, matches the folder), `description`, and `category`; `allowed-tools`, `related-skills`, `loop-eligible`/`recurrence-hint`, `compatibility`, `disable-model-invocation`, and `self-evolve` are optional. See `scripts/lint-skills.ps1` for the full ruleset. There is no `related-agents` field — the pack is skills-only; cross-references go in `related-skills`.
- **Self-Evolve Loop:** every skill ends with a machine-maintained footer implementing cross-invocation learning — self-evaluate at the end of a run, persist signal-bearing learnings to a per-skill journal (user-global `~/.ink-and-agency/learnings/<name>.md`, or workspace-local `.ink-and-agency/learnings/<name>.md` where the sandbox confines writes), read it back at the start of future runs, and route skill-improvement ideas tiered: edit the canonical checkout when present (**never a plugin cache**), record suggestions otherwise. Contract: [`skills/SELF-EVOLVE.md`](skills/SELF-EVOLVE.md); sweep: `pwsh ./scripts/add-self-evolve.ps1` (run it after adding a skill — lint fails on a missing footer); opt out per skill with `self-evolve: false`.
- Council personas are reference documents (not skills — they have no `SKILL.md`) in `skills/persona/`. New personas go there. Because it holds no `SKILL.md`, a conformant host simply skips that directory during discovery, which is why it can sit alongside the skills. The `clarity-council` skill reads them; the council itself is a skill (three inline modes: single / multi / iterative) and carries `category: featured`.
- Many skills are former specialist subagents (persona experts like `python-pro`, `security-auditor`). They run inline like any skill — Claude Code no longer spawns them as isolated parallel subagents.
- Folder and skill names are stable once published — do not rename.
- After adding/removing/editing a skill, re-run `convert-agents-to-codex.ps1` and commit the regenerated files alongside the source change.

## Skill invocation across hosts

Every skill is reachable one of two ways, and the axis is **who can invoke it**. This is a single decision in the canonical `SKILL.md` frontmatter; the generator projects it onto both hosts.

- **Model-invoked** (default) — reachable by the model *or* the user. Omit `disable-model-invocation`. Keep the rich trigger phrasing in `description` ("Use when the user says…, mentions…") so auto-invocation fires. The generated `openai.yaml` carries only the `interface` block.
- **User-invoked** — reachable *only* when the human types the skill name. Set `disable-model-invocation: true` in the frontmatter. The generator then adds `policy.allow_implicit_invocation: false` to that skill's `openai.yaml` — the Codex analog — so neither host lets the model reach it. There are currently eight: `codebase-explain`, `handoff`, `implement`, `plan-to-spec`, `plan-to-tickets`, `teach`, `which-skill`, `work-plan`.

Because the Codex side is **generated from the Claude-side frontmatter**, the two can't drift: a skill is user-invoked in both harnesses or neither. Do not hand-edit `openai.yaml` to change invocation — flip `disable-model-invocation` in `SKILL.md` and regenerate.

**Picker label:** `openai.yaml`'s `short_description` is derived from the first sentence of `description` (trimmed to ~90 chars). When that first sentence is trigger-heavy or truncates badly, add an optional `codex-short-description:` line to the `SKILL.md` frontmatter — the generator uses it verbatim as the override.

## Agent Plugins conformance

The pack targets [Agent Plugins 1.0.0](https://agent-plugins.org). Four rules do real work here; break one and conformant hosts stop seeing skills:

1. **Flat skills.** `skills/<name>/SKILL.md`, never deeper (§7.1). `references/`, `scripts/`, and the generated `agents/` folder inside a skill are fine — the no-recursion rule is about where a *skill* may live, not what a skill may contain.
2. **Closed manifest.** Root `plugin.json` may carry only `$schema`, `name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`, `extensions` (§5.2). No top-level `skills` key: the location is already fixed at `skills/`, and Codex documents its own `skills` field as a *supplement* to default discovery rather than a replacement, so dropping it costs nothing.
3. **Host data under `extensions`.** Reverse-domain namespaces only (§8.1). Hosts ignore namespaces they don't implement, so adding one can't break another host.
4. **Containment.** Every plugin-relative path starts with `./` and stays inside the plugin root (§4.1).

`lint-skills.ps1` enforces 1–3 and validates `mcp.json` if one is ever added. When bumping to a future spec version, change the `$schema` value in `convert-agents-to-codex.ps1` *and* the matching constant in `lint-skills.ps1` — they are deliberately checked against each other.

## Validation

```sh
pwsh ./scripts/lint-skills.ps1              # SKILL.md frontmatter, flat-layout + manifest conformance
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
