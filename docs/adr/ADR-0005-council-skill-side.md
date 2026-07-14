# ADR-0005: The Persona Council Lives Skill-Side, Not as Agents

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** Maintainer review

## Context

The persona "council" — structured multi-perspective consultation used across the pack (issue-triage,
issue-estimate-sp, energy-budget, meeting-decompression, idea-generate, the sprint pulses, and ~20
other skills) — is the single most-invoked cross-component integration in the plugin. It originally
shipped as **three subagents** under `agents/00-council/` (`council-single-persona`,
`council-multi-persona`, `council-iterative`), routed to by a thin `clarity-council` skill, with the
38 persona contracts stored in `references/council-personas/`.

That structure had three concrete problems:

1. **Codex can't bundle agents.** The Codex plugin manifest (`plugin.json`) bundles only `./skills/`
   (see [AGENTS.md](../../AGENTS.md) source-of-truth table). So on Codex, the `clarity-council` skill
   shipped and told the model to "invoke `council-multi-persona`" — an agent that was **not in the
   bundle**. The pack's most-used integration was broken on one of its two target hosts.
2. **Persona duplication.** `references/` is not part of the Codex skill bundle either, so the persona
   contracts had to be duplicated into `skills/clarity-council/skills/personas/` to reach Codex at all.
   The two copies were byte-identical and drifted independently — edit one, the other rotted.
3. **Category / naming friction.** `00-council` was an out-of-band 11th category never sanctioned by
   [ADR-0001](ADR-0001-category-taxonomy.md) (which defines exactly ten, 01–10), and persona names
   (`scrum-master`, `product-manager`, `security-expert`) collided with real top-level agent names.

## Decision

**The council is a skill, not a set of agents.** `clarity-council` absorbs all three behaviors as
inline **modes** — `single`, `multi`, `iterative` — in one `SKILL.md`. The persona library lives
inside the skill at `skills/clarity-council/skills/personas/` as its single canonical home.

Consequences of the decision:

- The three `agents/00-council/*.md` files and the `00-council` category are removed. `ADR-0001`'s
  ten-category taxonomy is restored (the linter's `$ValidCategories` no longer lists `00-council`).
- `references/council-personas/` is deleted; the in-skill copy is canonical.
- Callers invoke the council via `Skill`, naming a mode
  (`invoke clarity-council in multi mode with personas [...]`) instead of naming a subagent.
- The council now ships **identically on both hosts** inside the `./skills/` bundle — no separate
  agent install, no unbundled reference.

## Consequences

**Positive**
- Dual-host parity for the pack's core integration; nothing to install separately on Codex.
- Single source of truth for personas; duplication and drift eliminated.
- Taxonomy conforms to ADR-0001; one fewer name-collision surface.

**Negative / trade-offs**
- The council is no longer a first-class Claude Code *subagent* (it can't be spawned via the `/agent`
  picker or run in its own isolated context window). It runs inline like any other skill. For the
  council's consultative use this is acceptable — callers already invoked it via `Skill`, and the
  structured-markdown output is unchanged.
- `SKILL.md` is longer (three modes in one file) than the old thin router. Mitigated by keeping each
  mode's workflow terse and pushing worked examples to `EXAMPLES.md`.

## Compliance

- Do **not** reintroduce `agents/00-council/` or an `agents/`-side council. New personas go in
  `skills/clarity-council/skills/personas/` (enforced by convention; see AGENTS.md editing rules).
- If a future host *can* bundle agents and a subagent council is desired there, generate it from the
  skill — do not fork a hand-maintained agent copy.
