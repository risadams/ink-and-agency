---
name: time-reality-check
description: >
  Counter time blindness — you say "20 minutes" but it'll take 2 hours. Skill
  asks about the task, factors in your usual underestimation pattern, and
  offers a calibrated estimate with reasoning. Use when user says "how long
  will this take", "time check", "reality check", "estimate this", "am I being
  realistic", or invokes /time-reality-check.
version: 1.0.0
license: MIT
related-agents:
  - project-manager
  - scrum-master
compatibility: claude-code opencode
allowed-tools:
  - Read
  - AskUserQuestion
  - Skill
related-skills:
  - clarity-council
loop-eligible: false

---

# Time Reality Check

The user gave themselves an estimate. The user is almost certainly wrong. Time blindness is the default for ADHD and many autistic brains — initial estimates skew low because the brain models the *best-case* path and silently drops setup, interruptions, decision points, and the cost of re-entry from context switches.

Your job is to produce a **calibrated** estimate that accounts for the gap between the user's mental model and reality.

## Lens: statistics-expert + devils-advocate

For non-trivial estimates (anything the user is using to commit to others, anything over an hour, anything that will affect their schedule), invoke `clarity-council` via `Skill` in `council-multi-persona` agent with personas `[statistics-expert, devils-advocate]`:

- **user_problem:** *"The user estimated [X] for [task]. Produce a calibrated range that accounts for known time-blindness factors: setup cost, interruption probability, decision points, re-entry cost from context switches."*
- **context:** task description, user's gut estimate, deadline if any, similar tasks they've done before (if recalled).
- **desired_outcome:** *"A three-point estimate (best / likely / worst), an explicit list of factors the user's gut estimate probably missed, and a recommended buffer."*
- **constraints:** `[do not flatter the gut estimate, do not catastrophize, base multipliers on stated patterns rather than generic ADHD lore, separate task time from elapsed time]`
- **depth:** `brief`.

For trivial estimates (a single small task with no setup), skip the council and produce a one-line calibrated read.

## When to activate

When the user says:
- "I'll do it in [X minutes]"
- "How long will this take?"
- "Can I get this done before [time]?"
- "Am I being realistic?"

## The questions

Ask these in one `AskUserQuestion` call:

1. **What's the task?** (Concrete enough to estimate against.)
2. **What's your gut estimate?** (Capture this *before* anything else — the gut number is the data point.)
3. **What's the last similar task you did and how long did it actually take?** (Anchor against reality, not memory.)

## Output format

### Your gut: [X]

Restate the user's gut estimate, plainly. No judgment.

### Calibrated range

| | Time | What it assumes |
|---|---|---|
| **Best case** | [X] | Zero setup, zero interruptions, no decision paralysis |
| **Likely** | [X] | Normal setup, 1-2 small interruptions, expected decision points |
| **Worst case** | [X] | Multiple context switches, hidden subtasks surface, re-entry cost |

### What your gut probably missed

A bulleted list. Be specific to the task, not generic. Examples:
- Setup: opening the right files, finding where you left off
- Decision points: every place the task forks and requires a choice
- Re-entry cost from any interruption longer than 5 minutes
- The non-coding parts (PR description, screenshot, message to teammate)

### Recommended commitment

If the user is committing to another person, **use the worst case minus a small buffer.** If only committing to themselves, use the **likely**.

> **Commit to:** [X by Y]
> **Personal target:** [X]

### One-line summary

If the user only reads one line, this is it: a flat declarative sentence with the recommended time.

## What NOT to do

- Do not multiply the gut estimate by a fixed factor (2x, 3x) — that's lazy and wrong as often as it's right
- Do not catastrophize — "it'll take all day" is not useful
- Do not assume the user can't focus; some tasks genuinely take 20 minutes
- Do not skip the gut estimate question — you need their number to calibrate against
- Do not lecture about time blindness; the user knows

