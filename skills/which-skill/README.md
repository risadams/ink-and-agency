# Which Skill

A **router** over the pack. Tell it your situation and it names the one skill (or flow) that fits, why, and the exact command — without running anything. It's the cure for the cognitive load of a 61-skill pack: one skill to remember instead of sixty-one.

## Why this exists

A large skill pack has a discovery problem. User-invoked skills carry zero context load precisely because the model *can't* see them — which means the human is the index that must remember they exist. Past a dozen or so, nobody does. A router fixes that: it's the single user-invoked skill you *do* remember, and its whole job is to point at the rest. It reads the pack's [FLOWS.md](../FLOWS.md) and maps "I want to do X" onto the right entry point, including the distinctions between near-duplicate skills that are easy to confuse.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "which skill fits this?"
  - "what should I use for X?"
  - "is there a skill for…?"
  - "I don't remember what's available"
- Running the slash command: `/which-skill`

> **Note:** This skill sets `disable-model-invocation: true` — it's user-invoked only. That's intrinsic to what a router *is*: it names other user-invoked skills, which by definition the model can't reach. Only the human can fire it.

## What it does

Given a situation, it (1) reads the situation and asks one clarifying question if it's vague; (2) matches to a **flow** first, then a skill; (3) answers in a fixed shape — the skill, a one-line why, the literal invocation, the next step in the flow, and any close-second sibling; (4) suggests `/skill-create` when genuinely nothing fits. It points; it does not run the target skill.

### Inputs

- **A situation** — free-form. "I need to plan a migration", "a bug report came in", "I can't start this task".

### Outputs

- A short routing answer: skill name, why, exact command, and the next/sibling skill where relevant.

### External systems used

- Reads [FLOWS.md](../FLOWS.md) and [CLAUDE.md](../CLAUDE.md#skills-inventory) — the flow map and the one-line inventory. No external services.

## How to use it

```text
You: /which-skill I need to plan a big migration but can't see the whole path

Skill: Flow: plan-a-big-effort.
       Skill: /work-plan — charts a large, foggy effort as decision tickets
              and resolves one decision per session.
       Invoke: /work-plan
       Then: it fires /research subagents for research-type tickets.
       Or: /codebase-plan-refactor if the steps are actually known and you
           want an executable plan rather than a decision map.
```

## Getting the most out of it

- **Describe the situation, not the skill.** "A message stung and I'm not sure if it's criticism" routes better than "the rejection skill."
- **Answer its one clarifying question.** When it asks which flow you're in, that's what turns a vague ask into a precise route.
- **Keep FLOWS.md current.** The router is only as good as the flow map it reads — when you add a skill, add it to a flow.

## Anti-patterns

- ❌ **Running the target skill for you.** It points and steps out; you invoke. (It can't fire user-invoked skills anyway — nothing can but the human.)
- ❌ **Listing all 61 skills.** It names the *one* that fits, plus at most one sibling — a menu dump defeats the purpose.
- ❌ **Guessing when nothing fits.** If no skill matches, it says so and suggests `/skill-create`.

## Related skills

- **[skill-create](../skill-create/)** — what the router suggests when no existing skill fits.
- **Every other skill** — the router's job is to point at them; [FLOWS.md](../FLOWS.md) is the map it routes against.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (routing process and disambiguation shortcuts)
