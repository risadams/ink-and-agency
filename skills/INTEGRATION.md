# Skill Composition Guide

The pack is **skills-only** — every capability is a `skills/<name>/SKILL.md`. This guide explains how
skills reference and compose with each other. (There is no separate agent layer; the former subagents
were folded into skills.)

## Two kinds of skill

The pack mixes two shapes under one primitive:

- **Workflow skills** — triggered procedures ("do X, then Y"): `sprint-plan`, `code-review`,
  `issue-triage`, the writing and Obsidian skills, etc.
- **Specialist skills** — persona experts you lean on for judgment ("act as a senior Python
  engineer"): `python-pro`, `security-auditor`, `terraform-engineer`, etc. (formerly subagents).

Both are invoked the same way; the distinction is only about how you use the output.

## How skills compose

### Pattern 1: a skill invokes another skill

A workflow skill calls a specialist or utility skill mid-run. Example: `issue-triage` invokes
`codebase-explain` to map the suspected code area, then `clarity-council` (multi mode) to hypothesize
root causes. On Claude Code this is the `Skill` tool; describe it by intent so it ports to Codex.

### Pattern 2: a skill fans out to generic sub-workers

Some skills spawn *generic* Task-workers (not named skills) to parallelize or isolate work — e.g.
`code-review` runs its Standards and Spec passes as separate workers so their context doesn't mix;
`work-plan` fires `/research` to resolve open questions. This uses the host's subagent capability and
is independent of any specific skill in the pack.

### Pattern 3: a flow chains several skills

End-to-end journeys chain skills in sequence — e.g.
`grill → work-plan → plan-to-spec → plan-to-tickets → implement (tdd + code-review)`. Named flows live
in [FLOWS.md](FLOWS.md); the [`which-skill`](which-skill/) router maps "I want to do X" onto the right
entry point.

## Declaring relationships

Skills declare workflow neighbours in frontmatter:

```yaml
---
name: issue-triage
description: "…"
related-skills:
  - codebase-explain
  - clarity-council
---
```

- **Field:** `related-skills` (optional, array of skill names). There is **no** `related-agents`
  field — the pack is skills-only.
- **Purpose:** hints at which skills work with this one. It's a discovery aid, not a runtime
  dependency; the body's prose is what actually invokes anything.

## Governance rules

Add a `related-skills` entry when:

1. **Direct use** — this skill invokes the other by name in its body.
2. **Workflow handoff** — a natural next step in a flow.
3. **Complementary** — they address the same problem from different angles.

Do **not** add one when the relationship is speculative, the target doesn't exist, or there's no clear
user benefit. `scripts/lint-skills.ps1` enforces that every `related-skills` entry resolves to a real
skill and that no tool/MCP names leak into the field.

## Discovery

- **Find a skill's neighbours:** read its `related-skills` frontmatter.
- **Find the right skill for a task:** run [`which-skill`](which-skill/) — it routes over the whole
  pack using [FLOWS.md](FLOWS.md).
- **Browse specialists:** the ~154 persona-expert skills aren't individually catalogued; they're found
  by their trigger `description`. Browse `skills/` or ask `which-skill`.

## See Also

- **[FLOWS.md](FLOWS.md)** — named flows that chain skills end-to-end
- **[CLAUDE.md](CLAUDE.md)** — skill format spec and the workflow-skill inventory
- **[README.md](README.md)** — skill discovery and usage
