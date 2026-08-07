# Time Reality Check

A calibrated estimator that counters time blindness. You say "twenty minutes." The skill captures that gut number first, then produces a three-point estimate (best / likely / worst) that accounts for the things your gut silently dropped: setup cost, interruption probability, decision points, and the cost of re-entering after a context switch. Ends with a recommended commitment if you're committing to someone else, or a personal target if not.

## Why this exists

Initial time estimates are systematically wrong in one direction. The brain models the *best-case linear path* — uninterrupted, all decisions already made, no setup, no re-entry. Reality includes interruptions, switching costs, hidden subtasks that surface only mid-flow, and the non-coding parts (PR description, screenshot, message to teammate) that the original estimate didn't picture. The asymmetry isn't a personality flaw; it's how everyone's brain estimates. For ADHD/autistic folks it tends to be worse, because attention switches cost more and re-entry is slower. This skill is the corrective lens.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "how long will this take"
  - "time check"
  - "reality check"
  - "estimate this"
  - "am I being realistic"
  - "I'll do it in [X minutes]"
- Running the slash command: `/time-reality-check`

The skill always captures the gut estimate first, then calibrates against it — the gut number is the data point.

## What it does

The skill produces five sections: (1) restated gut estimate, (2) a three-point estimate table (best / likely / worst) with what each assumes about interruptions and setup, (3) "what your gut probably missed" — concrete to the task, not generic, (4) recommended commitment (worst-case minus buffer if external, likely if personal), (5) one-line summary. For non-trivial estimates it invokes [clarity-council](../clarity-council/) with `statistics-expert + devils-advocate`. For trivial single-task estimates it runs inline with a one-liner.

### Inputs

- **Task description** — concrete enough to estimate against.
- **Gut estimate** — captured before any analysis.
- **Last similar task duration** — anchor to reality, not memory.

### Outputs

- A five-section markdown estimate with recommended commitment time.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: time check. I'll get this PR review done in 20 minutes.

Skill: (asks three questions)

You:
  1. review of the queue-worker refactor PR (~600 LOC, 8 files)
  2. 20 minutes
  3. last similar review I did took 90 minutes but I had distractions

Skill:

       ### Your gut: 20 minutes

       ### Calibrated range

       | | Time | What it assumes |
       |---|---|---|
       | **Best case** | 35 min | No questions surface; one read-through is enough |
       | **Likely** | 75 min | Two passes; you write 3-5 comments; one back-and-forth with the author |
       | **Worst case** | 2.5 hours | You spot a design issue and have to write a longer note; one or two interruptions during review |

       ### What your gut probably missed
       - 600 LOC across 8 files is at least 20 minutes of reading
         even before thinking.
       - PR reviews involve switching between files repeatedly —
         that's not in a 20-minute mental model.
       - Writing the actual comments well takes more time than
         reading the code.
       - You said the last similar review took 90 minutes — that's
         a data point your gut ignored.

       ### Recommended commitment
       **Commit to:** review done by end of day
       **Personal target:** 75 min, scheduled as a single block

       ### One-line summary
       Block 75 minutes, don't promise faster.
```

## Getting the most out of it

- **Always state the gut estimate first.** Without it the skill has nothing to calibrate against. The gut number is the most useful single data point.
- **Anchor to a real past task.** "The last similar thing took X" is far more useful than "I think this should take Y." Memory beats forecast.
- **Use the worst case for commitments to others.** Personal targets can use the likely; commitments to other people should leave buffer for the worst case so you don't ship late and have to renegotiate.
- **Re-run the skill after the task ends.** Tell it how long it actually took. Over time the calibration sharpens because you're feeding back ground-truth data.

## Anti-patterns

- ❌ **Multiplying the gut by 2x or 3x as a default.** That's lazy and wrong as often as it's right. The skill estimates per-task, not by formula.
- ❌ **Catastrophizing.** "It'll take all day" without specific reasons is unhelpful. The worst case has to be a coherent scenario, not just a big number.
- ❌ **Assuming the user can't focus.** Some tasks really do take 20 minutes. The skill calibrates against the specific task, not against a stereotype.
- ❌ **Lecturing about time blindness.** The user knows.

## Examples

### Example: A task that the gut estimate is actually right on

```text
You: time check. Renaming a variable across the codebase. 5 minutes.

Skill: (skips council — trivial)

       ### Your gut: 5 min

       Calibrated read: 5-8 min. Search-and-replace plus one quick
       test run. Your gut is right.

       Only gotcha: if the variable name collides with something in
       a string literal or comment, you'll spend a few extra minutes
       sorting out the false matches. Use a regex with word
       boundaries to skip that risk.
```

The skill is comfortable saying "your gut is right" — the calibration isn't a fixed multiplier.

### Example: A planning task that's way bigger than it looks

```text
You: time check. I need to draft the design doc for the rate-
     limiter rewrite. 1 hour.

Skill: (council session — non-trivial estimate)

You:
  1. design doc for rate-limiter rewrite, ~3 pages
  2. 1 hour
  3. last design doc I wrote took most of an afternoon and a chunk
     of the next morning

Skill:

       ### Your gut: 1 hour

       ### Calibrated range

       | | Time | What it assumes |
       |---|---|---|
       | **Best case** | 2 hours | Thinking is already done; just transcribing |
       | **Likely** | 4-5 hours, possibly split across two sessions | Thinking partly done; some decisions surface during writing |
       | **Worst case** | Most of two days | Two open design questions force you to talk to others before you can finish |

       ### What your gut probably missed
       - The hard part of a design doc is the thinking, not the
         typing. Your gut estimated typing time.
       - Drawing the architecture diagram or sequence diagram —
         not in the 1-hour mental model.
       - You said the last one took most of an afternoon plus the
         next morning. That's the strongest data point and your
         gut ignored it.
       - You'll likely discover at least one open question while
         writing — that's a decision point requiring async, not
         resolvable inside this estimate.

       ### Recommended commitment
       **Commit to:** ship by end of week
       **Personal target:** today, 2-3 hour block + tomorrow's
       follow-up if needed

       ### One-line summary
       Don't promise tomorrow — block two sessions across this
       week.
```

## Internals

The three questions are deliberately ordered:
1. Task name (concrete enough to estimate against)
2. Gut estimate (captured *before* anything else, so the skill has the uncalibrated number)
3. Last similar task duration (the strongest reality anchor)

For non-trivial estimates the skill invokes [clarity-council](../clarity-council/) in `council_consult` mode with `[statistics-expert, devils-advocate]`:
- statistics-expert handles the three-point estimate and base rates.
- devils-advocate stress-tests both the best case ("what makes this faster than expected?") and worst case ("what makes this an all-week task?").

The "what your gut probably missed" section is task-specific by design. Generic lists ("you forgot interruptions") are not useful; specific items ("you forgot the screenshot + PR description, that's 15 min") are.

Hard constraints: never multiply gut by a fixed factor; never catastrophize without a concrete scenario; separate task time from elapsed time; don't lecture about time blindness.

## FAQ

**Q: What if I have no comparable past task?**
A: Say so — the skill will fall back to typical durations for similar shapes of work and flag the lower confidence in the output. The recommended commitment will be more conservative as a result.

**Q: Is the "likely" estimate the one I should use?**
A: For personal targets, yes. For commitments to other people, use worst-case-minus-buffer. The two are different because the cost of being late differs.

**Q: What if the estimate comes back as "this is way bigger than you think"?**
A: That's the most useful version of this skill — it surfaces estimates that would otherwise turn into missed commitments. The right response is usually renegotiating scope or timeline before starting.

**Q: Does it learn from past calibrations?**
A: Not automatically. If you re-run the skill after the fact with the actual time, you can build a habit of feeding ground-truth back; over time your gut anchors get better.

## Related skills

- **[energy-budget](../energy-budget/)** — sibling for cost-counting, but for energy rather than time. They pair well: time-reality-check tells you how long; energy-budget tells you whether you can afford it today.
- **[idea-decision-maker](../idea-decision-maker/)** — when the time estimate reveals you can't do everything and have to pick.
- **[issue-estimate-sp](../issue-estimate-sp/)** — Jira-ticket-specific story point estimation with scrum-poker council.
- **[clarity-council](../clarity-council/)** — the statistics-expert + devils-advocate pairing is the engine.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (council wiring and output format)
