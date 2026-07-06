# Energy Budget

Spoon-theory accounting for your calendar. Log today's load — meetings, deep work, sensory stuff, social events — and the skill scores each item by duration × intensity, totals against your stated capacity, flags burnout risk, and proposes specific defers ranked by energy saved per item dropped. Does the load math **before** the day falls apart, not after.

## Why this exists

Calendars track clock time. They don't track cognitive or social or sensory cost. A day with one back-to-back meeting block and a customer call can look identical to a day with two short syncs and a long block of deep work — same hours, very different toll. People who work past their actual capacity tend to discover it at the bad end of the day (3pm crash, snapping at a colleague, the small task that suddenly takes two hours) rather than at the planning end. This skill makes the cost visible in advance, with an honest ranking of which items would buy back the most energy if deferred. For ADHD, autistic, chronically-ill, or burnout-vulnerable folks, this is the difference between coasting through a busy day and crashing through one.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "energy budget"
  - "spoon check"
  - "am I overcommitted"
  - "what should I drop"
  - "burnout check"
  - "look at my day"
  - "I'm already tired and it's [time]"
- Running the slash command: `/energy-budget`

For non-trivial budgets (>4 items, spanning a full day, or starting from an already-drained baseline) the skill invokes [clarity-council](../clarity-council/) with `personal-assistant + psychologist`. Trivial budgets are scored inline.

## What it does

The skill produces five sections: (1) today's load — a table scoring each item by duration / intensity (1-5) / type / cost; (2) total vs capacity — sum, percentage of stated baseline, traffic-light verdict (🟢 safe / 🟡 tight / 🔴 over); (3) burnout-risk flags — the specific items that push the day from tight to over; (4) suggested defers — ranked by energy saved per item dropped, capped at three; (5) recovery plan — what tonight should look like to recover if the day is tight or over.

### Inputs

- **Today's items** — meetings, deliverables, errands, social plans.
- **Today's baseline** — already drained / normal / unusually rested.
- **Non-negotiables** — so the skill doesn't suggest dropping them.

If a calendar tool is available (Outlook, etc.), the skill offers to pull today's events automatically.

### Outputs

- A five-section markdown budget with the traffic-light verdict and ranked defer suggestions.

### External systems used

- **Outlook** (optional) — read-only, to pull today's calendar.

## How to use it

A typical session looks like this:

```text
You: energy budget. it's 8am, I have a busy day, I'm already tired
     from a bad night's sleep.

Skill: (asks about items, baseline, non-negotiables)

You:
  - 9:30 standup (30min, normal)
  - 10-12 customer demo prep + customer demo (high stakes, masking)
  - 12:30 lunch with skip-level (40 min, social)
  - 2-3 deep work on rate-limiter rewrite
  - 3-4 1:1 with manager
  - 4-5 code review backlog
  - 7pm dinner with friends
  baseline: drained
  non-negotiables: customer demo, 1:1, friends dinner

Skill: (council session — multi-item drained baseline)

       ### Today's load

       | Item | Duration | Intensity (1-5) | Type | Cost |
       |---|---|---|---|---|
       | Standup | 30min | 3 | meeting | 1.5 |
       | Demo prep | 60min | 4 | deep-work | 4.0 |
       | Customer demo | 60min | 5 | masking + performance | 5.0 |
       | Skip-level lunch | 40min | 4 | social + masking | 2.7 |
       | Rate-limiter deep work | 60min | 4 | deep-work | 4.0 |
       | 1:1 | 60min | 3 | meeting | 3.0 |
       | Code reviews | 60min | 3 | admin | 3.0 |
       | Friends dinner | 120min | 2 | recovery-leaning social | 4.0 |
       | **TOTAL** | | | | **27.2** |

       ### Total vs capacity
       Drained baseline puts capacity around 18-22 today. You're
       at 27.2, which is **🔴 over** (~135% of capacity).

       ### Burnout-risk flags
       - The customer demo (5) right after the demo prep (4)
         stacks the two highest-intensity items back to back with
         no recovery gap. Even on a normal day that's tight; on a
         drained day it'll cost the afternoon.
       - The skip-level lunch immediately after the demo means
         four hours straight of masking-heavy activity from 10am to
         1pm.

       ### Suggested defers (ranked by energy saved)
       1. **Defer code review backlog to tomorrow** — saves 3.0.
          It's the lowest-stakes item and the only one with no
          social cost. Move to tomorrow morning.
       2. **Defer rate-limiter deep work** — saves 4.0. You won't
          have the focus for it post-demo on a drained baseline.
          Reschedule for tomorrow's deep-work block.
       3. **Move skip-level lunch to next week** — saves 2.7 and
          breaks the 4-hour masking stack. Short message: "Can we
          push to next week? Today got compressed."

       Dropping all three brings you to ~17.5, which is back inside
       your capacity for a drained day.

       ### Recovery plan
       Even with defers, tonight is recovery-only after the friends
       dinner: no screens past 9, lights low. Plan tomorrow's
       morning to be light — protect the deep-work block, no
       meetings before 11.
```

## Getting the most out of it

- **Score baseline honestly.** "Normal" when you're actually drained will produce a budget that says "you're fine" when you're not. The baseline is the most important single input.
- **List non-negotiables before scoring.** Otherwise the defer ranking may suggest dropping the thing you can't drop, which wastes everyone's time.
- **Trust the intensity rubric.** Defaulting everything to a 3 is the most common error — be honest. A customer-facing demo or a hard conversation is a 5; routine work is a 2-3.
- **Take the top defer, even if it's annoying.** The ranking is by energy-saved-per-item, so the top item gives the most relief. Resist re-arguing it.
- **Run mid-day if needed.** If something blew up (extra meeting, hard conversation), re-run the budget for the rest of the day with the updated context.

## Anti-patterns

- ❌ **Lecturing about pacing or self-care.** The user knows. The skill scores; it doesn't moralize.
- ❌ **"Just power through."** That's how the user got here.
- ❌ **Scoring everything as a 3.** Lazy default. The intensities differentiate the day.
- ❌ **Suggesting non-negotiables get dropped.** You asked, listen to the answer.
- ❌ **Producing a daily plan.** Different skill. This one budgets.
- ❌ **Telling them to meditate.**

## Examples

### Example: A light day that turns out to be tight

```text
You: spoon check. day looks light but I'm dreading it.

Skill:

You:
  - 10am 30-min call with new vendor (haven't met before)
  - 12pm lunch with team
  - 2pm 2-hour focus block (planned)
  baseline: normal
  non-negotiables: none

Skill:

       ### Today's load

       | Item | Duration | Intensity (1-5) | Type | Cost |
       |---|---|---|---|---|
       | New-vendor call | 30min | 4 | new people, masking | 2.0 |
       | Team lunch | 60min | 4 | social, all-team | 4.0 |
       | Focus block | 120min | 3 | deep-work | 6.0 |
       | **TOTAL** | | | | **12.0** |

       ### Total vs capacity
       Normal baseline = ~25 capacity. You're at 12, which is
       🟢 safe (48%).

       ### Why you're dreading it anyway
       The two morning items are both 4-intensity (new people +
       group social). On the clock it's 90 minutes; on the cost
       side it's 6.0 — half of today's total. The dread isn't
       irrational; it's just front-loaded.

       ### Suggested adjustments
       - Plan a 30-min decompress buffer between lunch and the
         2pm focus block, even at the cost of starting the focus
         block at 2:30. The transition cost from social to deep-
         work is high.
       - No defers needed otherwise.

       ### Recovery plan
       (skipped — day is safe)
```

The skill identifies why a numerically-light day feels heavy: cost density, not total cost.

### Example: A drained day that's over capacity with no defers possible

```text
You: budget. drained, no sleep last night, half the day is meetings
     I can't move.

Skill:

You:
  - 9-10 customer call (non-neg)
  - 10:30-12 director review (non-neg)
  - 1-2 incident review (non-neg)
  - 2-3 1:1 with direct report (non-neg)
  - 3-5 expected to ship the migration PR before EOD
  baseline: drained
  non-negotiables: all four meetings

Skill:

       ### Today's load

       | Item | Duration | Intensity (1-5) | Type | Cost |
       |---|---|---|---|---|
       | Customer call | 60min | 4 | masking | 4.0 |
       | Director review | 90min | 5 | high-stakes + masking | 7.5 |
       | Incident review | 60min | 4 | conflict potential | 4.0 |
       | 1:1 with report | 60min | 3 | meeting | 3.0 |
       | Ship migration PR | 120min | 4 | deep-work | 8.0 |
       | **TOTAL** | | | | **26.5** |

       ### Total vs capacity
       Drained baseline = 18-22 capacity. You're at 26.5, **🔴 over**
       (~130%).

       ### Burnout-risk flags
       The meeting block 9-12 is the worst stack: customer →
       director review back to back, both masking-heavy on no
       sleep. By 1pm you'll be tapped out, which is exactly when
       the incident review starts.

       ### Suggested defers
       1. **Ship the PR tomorrow morning instead of today** —
          saves 8.0. Non-negotiable meetings stay, deep work
          moves. You said the PR was "expected" by EOD, not
          committed. Send a one-line "shipping tomorrow AM, head
          fog from no sleep, want it right not fast" message in
          your team channel. People will understand.

       That single defer brings you to 18.5 — back inside your
       drained-day capacity.

       ### Recovery plan
       After the 1:1, declare yourself unavailable for the rest of
       the day. No code, no Slack. Tomorrow morning is the deep-
       work block for the PR — protect it.
```

## Internals

The intensity rubric is the most subjective part of the skill, so it's spelled out:

- **1:** routine, low-effort, recovers you (a walk, a hobby task)
- **2:** light effort, neutral
- **3:** standard work cost
- **4:** masking, conflict, new people, sensory-heavy environment
- **5:** high-stakes performance, dreaded conversation, sensory hell

Cost is duration × intensity (hours × intensity score). Capacity is calibrated from baseline: drained = 18-22, normal = 24-28, rested = 30+. These ranges are intentionally approximate — the skill doesn't claim measurement-grade precision.

For non-trivial budgets the skill invokes [clarity-council](../clarity-council/) in `council_consult` mode with `[personal-assistant, psychologist]`:
- The personal-assistant ranks defers by recoverable energy and considers logistics (who needs to be notified, what's the cost of moving it).
- The psychologist names the masking and recovery dynamics and validates the baseline self-assessment.

Hard constraints: don't moralize; don't assume neurotypical recovery; distinguish duration cost from intensity cost; don't suggest non-negotiables.

## FAQ

**Q: Are the numbers scientifically calibrated?**
A: No. They're heuristic. The rubric is consistent and useful for relative comparison — "this day is 30% over what last Wednesday was" — not for cross-person absolute claims.

**Q: What if I'm always over capacity?**
A: Then the budget is doing its job — telling you the load is structurally too high. The next conversation is about what to cut from the standing schedule, not what to defer today.

**Q: What about hidden recovery items (exercise, hobby, alone time)?**
A: Include them with negative intensities if they're recovery-leaning, or with low intensities (1-2) if they're neutral. The total accounts for them.

**Q: Why personal-assistant + psychologist and not just personal-assistant?**
A: Personal-assistant on its own would optimize for clock time and miss the masking/recovery dynamics. Psychologist on its own would validate feelings without producing actionable defers. The pair does both.

## Related skills

- **[time-reality-check](../time-reality-check/)** — pairs naturally. Time-reality-check says "this task will take 3 hours, not 1"; energy-budget says "and you don't have the capacity for 3 hours today."
- **[meeting-decompression](../meeting-decompression/)** — for after a meeting that ate more cost than budgeted.
- **[idea-decision-maker](../idea-decision-maker/)** — when budget reveals you can't do everything and have to pick.
- **[daily-briefing](../daily-briefing/)** — covers similar territory for general daily planning; energy-budget is the spoon-aware specialization.
- **[clarity-council](../clarity-council/)** — the personal-assistant + psychologist engine.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (rubric, council wiring, output format)
