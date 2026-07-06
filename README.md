# Ink and Agency

A Claude Code plugin merging two libraries into one installable unit:

- **Ink** — 51 skills covering writing, sprint/Scrum workflows, issue management, Obsidian tooling, codebase analysis, and neurodivergent-friendly executive-function support (`skills/`)
- **Agency** — 160 specialist subagents organized by domain, plus a persona-council system for multi-perspective decision making (`agents/`)

Formerly two repositories: [risadams/skills](https://github.com/risadams/skills) and [risadams/claude-subagent](https://github.com/risadams/claude-subagent). Both histories are preserved via `git subtree`.

## Structure

```
ink-and-agency/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/                      # 51 skills, one folder per skill
│   └── <skill-name>/SKILL.md
├── agents/                      # Subagents, grouped by category
│   ├── 00-council/              # Council orchestration agents
│   ├── 01-core-development/
│   ├── 02-language-specialists/
│   ├── ...
│   └── 10-research-analysis/
├── references/
│   └── council-personas/        # Persona contracts consumed by council agents
│                                # (not agents themselves — kept out of agents/
│                                # to avoid loader pickup and name collisions)
├── scripts/
│   ├── bulk-loop-update-skills.ps1
│   ├── bulk-loop-update-agents.ps1
│   └── lint-agents.ps1
└── docs/
    ├── adr/                     # Architecture decision records
    └── assets/                  # Banners, skill map
```

## Install

```
/plugin marketplace add risadams/ink-and-agency
/plugin install ink-and-agency
```

Or load locally for development:

```
claude --plugin-dir /path/to/ink-and-agency
```

## Conventions

- Skills and agents cross-reference each other via `related-skills` / `related-agents` frontmatter.
- Cross-component file paths use `${CLAUDE_PLUGIN_ROOT}` so they resolve regardless of the user's working directory.
- Council personas are reference documents, not agents. New personas go in `references/council-personas/`, not `agents/`.
- Skill names are namespaced by the plugin at install time (`ink-and-agency:skill-name`), so local project skills won't collide.

## License

MIT
