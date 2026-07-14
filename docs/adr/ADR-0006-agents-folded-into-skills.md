# ADR-0006: The Agent Library Is Folded Into Skills (Skills-Only Pack)

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** Maintainer review
**Supersedes:** the operative parts of ADR-0001 (category taxonomy), ADR-0002 (model
assignment), ADR-0003 (tool permissions), ADR-0004 (agent frontmatter invariants) — those governed
the `agents/` layer, which no longer exists. They are retained as historical record.

## Context

The pack shipped two primitives: **skills** (`skills/<name>/SKILL.md`) and **subagents**
(`agents/<category>/<name>.md`, compiled to `.codex/agents/*.toml`). This split caused ongoing
friction:

- **Codex can't bundle agents.** The Codex plugin manifest bundles only `./skills/`. The 157 agent
  TOMLs had to be hand-installed on Codex — the agent half of the pack never shipped through the
  plugin on one of the two target hosts. (This is the same constraint that forced the council fold in
  [ADR-0005](ADR-0005-council-skill-side.md).)
- **Two toolchains, two lint rulesets, two doc trees** for what users experience as one library.
- **Most agents were persona experts** ("act as a senior Python engineer"), which is expressible as a
  skill; and **most were orphans** — 134 of 157 were referenced by no skill.

## Decision

**Collapse to a single primitive: skills.** Every agent became a `skills/<name>/SKILL.md` via a
one-time migration (`scripts/convert-agents-to-skills.ps1`):

- Frontmatter transformed: `tools:` → `allowed-tools:`; `model:` dropped (skills run on the session
  model); `related-agents:` folded into `related-skills:` (all targets are skills now); `type`,
  `tags`, `instructions_version` dropped; `compatibility` added. Bodies kept verbatim.
- **Deduped** redundant clusters: `machine-learning-engineer` + `mlops-engineer` → `ml-engineer`;
  `mobile-app-developer` → `mobile-developer` (survivor descriptions absorb the dropped triggers).
  157 agents → 154 skills.
- Deleted `agents/` and `.codex/agents/` entirely.

Toolchain:

- `scripts/convert-agents-to-codex.ps1` no longer emits agent TOMLs; it generates per-skill
  `openai.yaml`, the root `plugin.json`, and the `CLAUDE.md` mirror.
- `scripts/lint-agents.ps1` → replaced by `scripts/lint-skills.ps1` (validates SKILL.md frontmatter,
  `related-skills` referential integrity and type-correctness, recurrence consistency — the
  skill-linter gap prior audits had flagged).
- `scripts/bulk-loop-update-agents.ps1` removed.

## Consequences

**Positive**
- The entire library ships in the `./skills/` bundle on both hosts — no separate Codex install.
- One primitive, one toolchain, one lint ruleset, one mental model.
- Redundancy pruned; the never-referenced-orphan problem is moot (skills are discovered by trigger
  description, not by a curated cross-reference graph).

**Negative / trade-offs (accepted)**
- **No isolated/parallel subagent execution.** Former agents run inline in the main context. Skills
  that fan out work (`code-review`, `work-plan`) still spawn *generic* Task-workers / the `/research`
  skill on Claude Code — that capability is independent of the deleted `agents/` roster — but the
  pack no longer ships named, model-assigned, separately-context-windowed specialists.
- **Persona-as-skill is a slight category stretch.** A skill is a triggered procedure; a persona is
  delegatable expertise. The converted bodies read as "act as X" skills, which is acceptable but less
  idiomatic than a subagent.
- **ADR-0001–0004 are now historical.** The category taxonomy, model policy, and agent frontmatter
  invariants no longer bind anything.

## Compliance

- Do not reintroduce an `agents/` tree or a `related-agents` frontmatter field.
- New specialist capabilities are authored as skills under `skills/<name>/`.
- If a future host supports skill-spawned isolated subagents and that capability is wanted, derive it
  from the skill — do not fork a parallel agent library.
