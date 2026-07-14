# Ink and Agency

An agent plugin for **Claude Code and OpenAI Codex**, merging two libraries into one installable unit:

- **Ink** — 55 skills covering writing, sprint/Scrum workflows, issue management, Obsidian tooling, codebase analysis, debugging, research, teaching, and neurodivergent-friendly executive-function support (`skills/`)
- **Agency** — 160 specialist subagents organized by domain, plus a persona-council system for multi-perspective decision making (`agents/`)

Formerly two repositories: [risadams/skills](https://github.com/risadams/skills) and [risadams/claude-subagent](https://github.com/risadams/claude-subagent). Both histories are preserved via `git subtree`.

## Structure

```text
ink-and-agency/
├── .claude-plugin/
│   ├── plugin.json              # Claude Code plugin manifest
│   └── marketplace.json         # Claude Code marketplace catalog
├── .agents/
│   └── plugins/
│       └── marketplace.json     # Codex marketplace catalog
├── plugin.json                  # Codex plugin manifest (GENERATED — do not edit)
├── AGENTS.md                    # Maintainer guidance (canonical; Codex auto-loads it)
├── CLAUDE.md                    # Mirror of AGENTS.md (GENERATED — do not edit)
├── skills/                      # 55 skills, one folder per skill (shared by both hosts)
│   ├── <skill-name>/SKILL.md    #   canonical skill (both hosts read this)
│   ├── <skill-name>/agents/openai.yaml  # Codex picker metadata (GENERATED — do not edit)
│   └── PORTABILITY.md           # How to interpret Claude tool names on other hosts
├── agents/                      # Subagents, grouped by category (canonical markdown)
│   ├── 00-council/              # Council orchestration agents
│   ├── 01-core-development/
│   ├── 02-language-specialists/
│   ├── ...
│   └── 10-research-analysis/
├── .codex/
│   └── agents/                  # Codex agent TOMLs (GENERATED from agents/ — do not edit)
├── references/
│   └── council-personas/        # Persona contracts consumed by council agents
│                                # (not agents themselves — kept out of agents/
│                                # to avoid loader pickup and name collisions)
├── scripts/
│   ├── bulk-loop-update-skills.ps1
│   ├── bulk-loop-update-agents.ps1
│   ├── convert-agents-to-codex.ps1  # Regenerates all GENERATED artifacts (below)
│   └── lint-agents.ps1
└── docs/
    ├── adr/                     # Architecture decision records
    └── assets/                  # Banners, skill map
```

## Install

### Claude Code

```sh
/plugin marketplace add risadams/ink-and-agency
/plugin install ink-and-agency
```

Or load locally for development:

```sh
claude --plugin-dir /path/to/ink-and-agency
```

### OpenAI Codex

```sh
codex plugin marketplace add risadams/ink-and-agency
codex plugin install ink-and-agency
```

The plugin bundles the skills. Codex plugins don't carry subagents, so install the agent TOMLs separately (personal scope), or just work inside a clone of this repo — `.codex/agents/` is picked up project-scoped:

```sh
git clone https://github.com/risadams/ink-and-agency
cp ink-and-agency/.codex/agents/*.toml ~/.codex/agents/
```

If your Codex version predates plugin marketplaces, copy the skills directly too:

```sh
cp -r ink-and-agency/skills/* ~/.agents/skills/
```

Skills are invoked with `$skill-name` (or picked up automatically when a task matches a skill's description). Subagents are spawned on request or via `/agent`.

## Conventions

- Skills and agents cross-reference each other via `related-skills` / `related-agents` frontmatter.
- Cross-component file paths are written relative to the referencing file (or described as "under the plugin root"), so they resolve on any host. Claude Code additionally exposes the plugin root as `${CLAUDE_PLUGIN_ROOT}`.
- Skill bodies use Claude Code tool vocabulary; [skills/PORTABILITY.md](skills/PORTABILITY.md) defines how other hosts map those names by intent.
- The markdown under `agents/` and `skills/`, plus `AGENTS.md`, are the single source of truth. Everything Codex-facing is **generated** from them by `pwsh ./scripts/convert-agents-to-codex.ps1`: `.codex/agents/*.toml`, `skills/*/agents/openai.yaml` (per-skill Codex picker metadata + invocation policy), the root `plugin.json`, and the root `CLAUDE.md` (mirror of `AGENTS.md`). After editing any source, re-run the script and commit the output; CI fails if they drift.
- One skill, both hosts: a skill's invocation mode lives once in its `SKILL.md` frontmatter (`disable-model-invocation: true` = user-invoked only) and is projected to Codex as `policy.allow_implicit_invocation: false`. Never hand-edit `openai.yaml`. See [AGENTS.md](AGENTS.md#skill-invocation-across-hosts).
- Council personas are reference documents, not agents. New personas go in `references/council-personas/`, not `agents/`.
- On Claude Code, skill names are namespaced by the plugin at install time (`ink-and-agency:skill-name`), so local project skills won't collide.

## License

MIT
