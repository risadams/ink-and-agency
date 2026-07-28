---
name: overwhelm-triage
codex-short-description: "Dump everything that's on fire, get back exactly one thing to do"
description: >
  Take an unstructured dump of everything competing for attention and return
  exactly one thing to do now, with the rest explicitly parked and dated.
  Counters the paralysis that comes from ranking eleven items by importance.
  Use when the user says "everything is on fire", "I'm overwhelmed", "too much
  going on", "I don't know what to do first", "help me pick", "triage this",
  or invokes /overwhelm-triage.
version: 1.0.0
license: MIT
compatibility: claude-code codex opencode
allowed-tools:
  - Read
  - AskUserQuestion
  - Skill
related-skills:
  - task-initiation
  - energy-budget
  - interest-capture
  - i-have-adhd
loop-eligible: false
---

# Overwhelm Triage

Everything is competing for the same slot and none of it is moving. The user does not need a prioritized list — a prioritized list is eleven decisions wearing a trench coat. They need **one thing**, and explicit permission to not think about the other ten.

## Let them dump first

Do not ask clarifying questions before the dump. If they have already dumped, work with that. If they have only said "I'm overwhelmed," ask once:

> **Dump everything that's taking up space. Unsorted, unpunctuated, no order. Include the things that aren't tasks.**

Getting it out of working memory is half the value of this skill. Do not interrupt it.

## Externalize it

Mirror the dump back as a numbered list, verbatim in meaning, one item per line. No commentary yet.

Pull anything that is **not a task** into a separate short block first:

> **Not tasks (these are worries, and they were taking up task slots):**
> - The thing about whether the review went badly

A worry parked as a worry stops competing with work. If one belongs to [`rejection-sensitivity-check`](../rejection-sensitivity-check/) or [`meeting-decompression`](../meeting-decompression/), say so in one line and move on.

## Sort into four buckets

Show counts, not full re-listings, for everything except **Today**.

- **Today** — a real consequence lands today if it doesn't happen. List these in full.
- **This week** — a real deadline, just not today. Count only.
- **No date** — it feels urgent and has no deadline. Count only. Most of the list lands here, and saying so out loud is the point.
- **Not yours** — someone else owns it, it's already dead, or it resolves itself. Count, plus one line each on why it's off the list.

Be strict about **Today**. "It would be good to" is not a consequence. If the user pushes back on a placement, move it and continue — do not debate.

## Pick one

From **Today**, pick by **highest consequence if missed**, tie-broken by **smallest**. Not by importance — importance is the axis that jammed.

If **Today** is empty, pick the smallest item from **This week** and say plainly that nothing is actually due today.

## Output

Five lines, no more:

> **Do this: [the one thing].**
> First action: [one literal ≤2-minute step].
> Because: [the consequence that lands today].
> **Parked until [when]:** [N] this week, [N] no-date, [N] not yours.
> Everything on that parked list is allowed to not happen today.

Then stop. Do not restate the buckets. Do not offer a schedule.

## Route out

- **Three or more real Today items** — this is a capacity problem, not a triage problem. Say so and hand to [`energy-budget`](../energy-budget/) via `Skill`.
- **User can't start the one thing** — hand to [`task-initiation`](../task-initiation/) via `Skill`.
- **An item is a hyperfixation, not an obligation** — hand to [`interest-capture`](../interest-capture/) so it gets stored instead of argued with.

## Why no council

The user is drowning in options. Adding personas adds options. Run inline, always fast.

## What NOT to do

- Do not return a ranked list of everything — that is the failure this skill exists to prevent.
- Do not ask which one *feels* most important. If they could answer that, they would not be here.
- Do not say "just break it down" — a breakdown of eleven things is still eleven things.
- Do not add anything to the list, however obviously missing.
- Do not reassure, reframe, or point out that it's not as bad as it seems.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

This skill learns across invocations — the full contract is
[SELF-EVOLVE.md](../../SELF-EVOLVE.md). **Start:** read the learnings
journal — `~/.ink-and-agency/learnings/overwhelm-triage.md` and/or the workspace-local
`.ink-and-agency/learnings/overwhelm-triage.md` — if present, and apply its guidance.
**End:** self-evaluate the results; optionally ask the user for feedback (never
block on it); append signal-bearing learnings to the journal (user-global when
the sandbox allows writing there, workspace-local otherwise); route
skill-improvement ideas per the contract's tiers — edit the canonical source
when one is present, never the plugin cache.

<!-- self-evolve:end -->
