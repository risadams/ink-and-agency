# Ink and Agency

An agent plugin for **Claude Code and OpenAI Codex**, merging two libraries into one installable unit:

- **Ink** — 61 skills covering writing, sprint/Scrum workflows, issue management, Obsidian tooling, codebase analysis, debugging, research, teaching, an end-to-end build loop (plan→spec→tickets→implement→tdd→review), and neurodivergent-friendly executive-function support, with a `which-skill` router over them all (`skills/`)
- **Agency** — 157 specialist subagents organized by domain (`agents/`), plus the `clarity-council` skill: a persona-council system for multi-perspective decision making (single / multi / iterative modes), bundled with the skills so it ships identically on both hosts

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
├── skills/                      # 61 skills, one folder per skill (shared by both hosts)
│   ├── <skill-name>/SKILL.md    #   canonical skill (both hosts read this)
│   ├── <skill-name>/agents/openai.yaml  # Codex picker metadata (GENERATED — do not edit)
│   ├── FLOWS.md                 # How skills chain into flows (which-skill routes on this)
│   └── PORTABILITY.md           # How to interpret Claude tool names on other hosts
├── agents/                      # Subagents, grouped by category (canonical markdown)
│   ├── 01-core-development/
│   ├── 02-language-specialists/
│   ├── ...
│   └── 10-research-analysis/
├── .codex/
│   └── agents/                  # Codex agent TOMLs (GENERATED from agents/ — do not edit)
│                                # (the persona council is a skill — see skills/clarity-council/)
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

Add the marketplace once, then install the plugin:

```sh
/plugin marketplace add risadams/ink-and-agency
/plugin install ink-and-agency
```

This installs both the 61 skills and the 157 subagents. Or load locally for development (no marketplace, picks up your working copy):

```sh
claude --plugin-dir /path/to/ink-and-agency
```

### OpenAI Codex

Add the marketplace once, then install the plugin:

```sh
codex plugin marketplace add risadams/ink-and-agency
codex plugin install ink-and-agency
```

The plugin bundles the **skills**. Codex plugins can't carry subagents, so install the agent TOMLs separately (personal scope):

```sh
git clone https://github.com/risadams/ink-and-agency
cp ink-and-agency/.codex/agents/*.toml ~/.codex/agents/
```

Alternatively, work inside a clone of this repo and the agents are picked up **project-scoped** from `.codex/agents/` — no copy needed. If your Codex version predates plugin marketplaces, copy the skills directly too:

```sh
cp -r ink-and-agency/skills/* ~/.agents/skills/
```

## Update

Releases are cut with [semantic versioning](https://semver.org/) and published as GitHub Releases (see [CHANGELOG.md](CHANGELOG.md)). To move to the latest version:

### Updating on Claude Code

```sh
/plugin marketplace update ink-and-agency   # refresh the catalog
/plugin update ink-and-agency               # pull the new version
```

For a local dev checkout, just `git pull` — `--plugin-dir` always reflects the working tree.

### Updating on OpenAI Codex

```sh
codex plugin marketplace update ink-and-agency
codex plugin update ink-and-agency
```

If you installed the agent TOMLs by hand, re-copy them after updating so the subagents match the new release:

```sh
cd ink-and-agency && git pull
cp .codex/agents/*.toml ~/.codex/agents/
```

## Invoking skills and agents

The plugin ships two kinds of component. **Skills** are prompt-driven workflows; **agents** (subagents) are specialist personas you delegate a task to. How you reach each differs by host.

### Invoking on Claude Code

| Component | How to invoke |
| :--- | :--- |
| **Skill** (explicit) | Type `/ink-and-agency:<skill-name>` — e.g. `/ink-and-agency:which-skill`. Names are namespaced by the plugin at install time, so they never collide with your project's own skills. |
| **Skill** (automatic) | Most skills auto-fire when your request matches their `description`. The exceptions are user-invoked-only skills (`which-skill`, `handoff`, `teach`, `work-plan`, `codebase-explain`, `implement`, `plan-to-spec`, `plan-to-tickets`) — reach those by typing the name. |
| **Subagent** | Ask for it in natural language ("use the *iterative council* agent…") or spawn it with the `/agent` picker. |

Not sure which skill fits? Run `/ink-and-agency:which-skill` — it routes over the whole pack and hands you the exact invocation.

### Invoking on OpenAI Codex

| Component | How to invoke |
| :--- | :--- |
| **Skill** (explicit) | Type `$<skill-name>` — e.g. `$which-skill`. |
| **Skill** (automatic) | Skills auto-fire on a matching task, *except* those marked user-invoked (same list as above), which Codex keeps out of automatic reach via `policy.allow_implicit_invocation: false`. |
| **Subagent** | Select it from Codex's custom-agent picker (the TOMLs you installed to `~/.codex/agents/`, or the project-scoped `.codex/agents/`). |

A skill's invocation mode is identical on both hosts — it's authored once in `SKILL.md` frontmatter and projected to each host, so a skill that's user-invoked in Claude Code is user-invoked in Codex too.

## Conventions

- Skills and agents cross-reference each other via `related-skills` / `related-agents` frontmatter.
- Cross-component file paths are written relative to the referencing file (or described as "under the plugin root"), so they resolve on any host. Claude Code additionally exposes the plugin root as `${CLAUDE_PLUGIN_ROOT}`.
- Skill bodies use Claude Code tool vocabulary; [skills/PORTABILITY.md](skills/PORTABILITY.md) defines how other hosts map those names by intent.
- The markdown under `agents/` and `skills/`, plus `AGENTS.md`, are the single source of truth. Everything Codex-facing is **generated** from them by `pwsh ./scripts/convert-agents-to-codex.ps1`: `.codex/agents/*.toml`, `skills/*/agents/openai.yaml` (per-skill Codex picker metadata + invocation policy), the root `plugin.json`, and the root `CLAUDE.md` (mirror of `AGENTS.md`). After editing any source, re-run the script and commit the output; CI fails if they drift.
- One skill, both hosts: a skill's invocation mode lives once in its `SKILL.md` frontmatter (`disable-model-invocation: true` = user-invoked only) and is projected to Codex as `policy.allow_implicit_invocation: false`. Never hand-edit `openai.yaml`. See [AGENTS.md](AGENTS.md#skill-invocation-across-hosts).
- The persona council is the `clarity-council` skill (three inline modes), not a set of subagents — so it ships in the skills bundle on both hosts. Personas are reference documents bundled inside it (`skills/clarity-council/skills/personas/`), not agents. See [ADR-0005](docs/adr/ADR-0005-council-skill-side.md).
- On Claude Code, skill names are namespaced by the plugin at install time (`ink-and-agency:skill-name`), so local project skills won't collide.

## License

MIT
