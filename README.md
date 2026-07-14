# Ink and Agency

A **skills plugin** for **Claude Code and OpenAI Codex** — one installable unit, one primitive (skills):

- **Ink** — workflow skills: writing, sprint/Scrum, issue management, Obsidian tooling, codebase analysis, debugging, research, teaching, an end-to-end build loop (plan→spec→tickets→implement→tdd→review), and neurodivergent-friendly executive-function support, with a `which-skill` router over them all.
- **Agency** — ~154 specialist skills (language/framework experts, infra, data/AI, security, product, and more — formerly subagents), plus the `clarity-council` skill: a persona-council for multi-perspective decisions (single / multi / iterative modes).

**215 skills total.** Everything lives under `skills/` and ships in the one bundle both hosts read. (The pack previously shipped a separate `agents/` subagent library; those were folded into skills so Codex — which can't bundle agents — gets the full library. See [ADR-0006](docs/adr/ADR-0006-agents-folded-into-skills.md).)

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
├── skills/                      # 215 skills in 15 category folders (shared by both hosts)
│   ├── <category>/<name>/SKILL.md         # canonical skill (discovery is recursive)
│   ├── <category>/<name>/agents/openai.yaml  # Codex picker metadata (GENERATED — do not edit)
│   ├── language-specialists/    #   e.g. python-pro, rust-engineer, typescript-pro
│   ├── infrastructure/          #   e.g. kubernetes-specialist, terraform-engineer
│   ├── research-analysis/clarity-council/  # the persona council (skill w/ bundled personas)
│   ├── ... (15 categories — see CATEGORIES.md)
│   ├── CATEGORIES.md            # Browsable index of all skills by category
│   ├── FLOWS.md                 # How skills chain into flows (which-skill routes on this)
│   └── PORTABILITY.md           # How to interpret Claude tool names on other hosts
├── scripts/
│   ├── bulk-loop-update-skills.ps1
│   ├── convert-agents-to-codex.ps1  # Regenerates GENERATED artifacts (openai.yaml, plugin.json, CLAUDE.md)
│   └── lint-skills.ps1
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

This installs all 215 skills. Or load locally for development (no marketplace, picks up your working copy):

```sh
claude --plugin-dir /path/to/ink-and-agency
```

### OpenAI Codex

Add the marketplace once, then install the plugin:

```sh
codex plugin marketplace add risadams/ink-and-agency
codex plugin install ink-and-agency
```

The plugin bundles all skills via `./skills/` — nothing to install separately. If your Codex version predates plugin marketplaces, copy the skills directly:

```sh
git clone https://github.com/risadams/ink-and-agency
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

## Invoking skills

Everything is a **skill** — a prompt-driven capability. Specialist skills (former subagents like `python-pro`, `security-auditor`) run inline like any other skill.

### Invoking on Claude Code

| | How to invoke |
| :--- | :--- |
| **Explicit** | Type `/ink-and-agency:<skill-name>` — e.g. `/ink-and-agency:which-skill`. Names are namespaced by the plugin at install time, so they never collide with your project's own skills. |
| **Automatic** | Most skills auto-fire when your request matches their `description`. The exceptions are user-invoked-only skills (`which-skill`, `handoff`, `teach`, `work-plan`, `codebase-explain`, `implement`, `plan-to-spec`, `plan-to-tickets`) — reach those by typing the name. |

Not sure which skill fits? Run `/ink-and-agency:which-skill` — it routes over the whole pack and hands you the exact invocation.

### Invoking on OpenAI Codex

| | How to invoke |
| :--- | :--- |
| **Explicit** | Type `$<skill-name>` — e.g. `$which-skill`. |
| **Automatic** | Skills auto-fire on a matching task, *except* those marked user-invoked (same list as above), which Codex keeps out of automatic reach via `policy.allow_implicit_invocation: false`. |

A skill's invocation mode is identical on both hosts — it's authored once in `SKILL.md` frontmatter and projected to each host, so a skill that's user-invoked in Claude Code is user-invoked in Codex too.

## Conventions

- Skills cross-reference each other via the `related-skills` frontmatter field.
- Cross-component file paths are written relative to the referencing file (or described as "under the plugin root"), so they resolve on any host. Claude Code additionally exposes the plugin root as `${CLAUDE_PLUGIN_ROOT}`.
- Skill bodies use Claude Code tool vocabulary; [skills/PORTABILITY.md](skills/PORTABILITY.md) defines how other hosts map those names by intent.
- The markdown under `skills/`, plus `AGENTS.md`, are the single source of truth. Everything Codex-facing is **generated** from them by `pwsh ./scripts/convert-agents-to-codex.ps1`: `skills/*/agents/openai.yaml` (per-skill Codex picker metadata + invocation policy), the root `plugin.json`, and the root `CLAUDE.md` (mirror of `AGENTS.md`). After editing any source, re-run the script and commit the output; CI fails if they drift.
- One skill, both hosts: a skill's invocation mode lives once in its `SKILL.md` frontmatter (`disable-model-invocation: true` = user-invoked only) and is projected to Codex as `policy.allow_implicit_invocation: false`. Never hand-edit `openai.yaml`. See [AGENTS.md](AGENTS.md#skill-invocation-across-hosts).
- The persona council is the `clarity-council` skill (three inline modes), not a set of subagents — so it ships in the skills bundle on both hosts. Personas are reference documents bundled inside it (`skills/research-analysis/clarity-council/skills/personas/`), not agents. See [ADR-0005](docs/adr/ADR-0005-council-skill-side.md).
- On Claude Code, skill names are namespaced by the plugin at install time (`ink-and-agency:skill-name`), so local project skills won't collide.

## License

MIT
