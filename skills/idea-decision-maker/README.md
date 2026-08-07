# Idea Decision Maker

A forced-pick skill for when you're stuck between two (or more) defensible options. Three personas vote, majority wins, you get the picked option with reasoning, the cost of being wrong, and a concrete "revisit if" trigger. It does **not** expand the option space, surface more considerations, or offer a framework — that's what got you stuck.

## Why this exists

Analysis paralysis is a specific failure mode: the decision is genuinely hard because the options are all roughly defensible, so the brain keeps looking for the deciding factor that doesn't exist. Adding more analysis makes it worse — the brain interprets every new consideration as evidence to keep looking. The way out is to commit to a pick, define what would cause you to reconsider, and close the decision. This skill does that by externalizing the pick through a three-persona vote: removing the personal stakes from the choice makes it easier to act on, and the explicit "revisit if" trigger gives the brain permission to stop ruminating until the trigger fires.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "I can't decide between..."
  - "help me pick"
  - "decision paralysis"
  - "break the tie"
  - "which should I..."
  - "I keep going back and forth"
  - "just tell me what to do"
- Running the slash command: `/idea-decision-maker`

The skill will ask you to constrain the option set to 2-4 — if you have more, you'll be asked to drop the worst first.

## What it does

The skill produces five sections: (1) the pick — one option, one sentence, no hedging; (2) why this one — 3-5 concrete bullets referencing your own success criteria; (3) why not the others — one bullet per rejected option; (4) cost of being wrong — table with reversibility; (5) revisit point — the explicit trigger that would warrant re-opening. For non-trivial decisions it invokes [clarity-council](../clarity-council/) with `senior-architect + devils-advocate + personal-assistant`; majority wins. For trivial low-stakes reversible decisions it picks inline.

### Inputs

- **2-4 options** (more = drop the weakest first).
- **What success looks like in 30 days** — concrete picture, not abstract values.
- **Cost of picking wrong** — and is it reversible?

### Outputs

- A five-section markdown decision document with the pick and the revisit trigger.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: decision breaker. I can't decide between (a) building the
     dashboard in React, (b) using the existing internal templating
     system, or (c) just shipping a static HTML page for now.

Skill: (asks three questions)

You:
  1. (the three options above)
  2. in 30 days I want the team to be able to add new charts in
     under an hour without my help
  3. wrong pick = a few weeks of rework. Reversible but expensive.

Skill: (invokes council — senior-architect, devils-advocate,
       personal-assistant)

       ### The pick: **(b) Internal templating system**

       Two votes for (b), one for (c). Senior-architect went (b)
       for the team-can-add-charts criterion. Personal-assistant
       went (b) for the maintenance-load argument. Devils-advocate
       went (c) — argued that "ship something first" beats picking
       a permanent tool too early.

       ### Why this one
       - Your 30-day success criterion is "team can add charts
         without my help." Internal templating is the only option
         where that's true on day one — the team already knows it.
       - React adds a build pipeline, deployment story, and a
         component library decision before the team can ship a
         chart. Three more decisions.
       - Static HTML scales to the second chart, not the fifth.
       - You said wrong picks cost weeks of rework. (b) has the
         lowest rework cost if it turns out wrong because the
         templating is already wired to the data layer.

       ### Why not the others
       - **(a) React:** higher ceiling, but you don't need the
         ceiling — you need the team self-sufficient by week 4. The
         setup cost eats the runway.
       - **(c) Static HTML:** ships fastest, but the rework
         conversation happens at chart #3, which is week 2.

       ### Cost of being wrong

       | If wrong | Cost | Reversible? |
       |---|---|---|
       | Templating turns out to be a dead end | 2-3 weeks to port to React | Yes |
       | Templating works but team still can't add charts | A few hours of doc + examples | Yes |

       ### Revisit point
       **Revisit if:** by end of week 2, no one on the team has
       added a chart on their own AND you've written docs/examples
       for it. That'd be evidence the tool, not the docs, is the
       blocker.

       Until then, the decision is closed.
```

## Getting the most out of it

- **Constrain to 2-4 options before invoking.** More than four and the decision isn't paralyzed-by-choice, it's underdefined. Drop the obvious losers first; the skill works on the genuinely-hard remainder.
- **Take the "revisit if" trigger seriously.** It's the part that lets your brain stop ruminating. Without an explicit trigger, the brain treats every new piece of information as a reason to re-open.
- **If you find yourself disagreeing with the pick, that's data.** Strong instinctive rejection of a council pick often reveals a constraint you didn't articulate. Re-run with the new constraint surfaced.
- **Don't pre-decide and ask the skill to confirm.** If your gut already knows, you don't have paralysis, you have anxiety about commitment. Different problem; this skill won't help with that.

## Anti-patterns

- ❌ **Presenting a framework.** Frameworks generate more decisions, not fewer.
- ❌ **"Both have merit."** That's already where the user is.
- ❌ **"It depends."** Doesn't pick. Won't do it.
- ❌ **Listing considerations to weigh.** The skill weighs them, then picks. Listing is the trap.
- ❌ **Encouraging the user to "trust their gut."** Their gut sent them here.
- ❌ **Introducing a dominant third option.** Only if it's actually obviously dominant — otherwise it adds paralysis.

## Examples

### Example: A trivial reversible decision (no council)

```text
You: decision breaker. Should the date picker default to today or
     to empty?

Skill:

       ### The pick: **default to today**

       Lower-friction for the 80% case (logging today's event); the
       20% case (logging a different date) costs one extra click,
       which is cheaper than the typing required to set today from
       empty.

       ### Cost of being wrong
       Five-minute change. Fully reversible.

       ### Revisit if:
       Usage data shows >40% of entries get the date changed away
       from today. Until then, the decision is closed.
```

The skill skipped the council for a fully reversible UX micro-decision.

### Example: A high-stakes hiring decision

```text
You: decision breaker. Two candidates. (a) Senior engineer, deep
     experience but limited team experience. (b) Mid-level, less
     deep but has led a team before.

Skill: (council session)

You: (provides 30-day success and cost-of-wrong)

       ### The pick: **(b) Mid-level with team experience**

       Two-one vote. Senior-architect voted (a) — "you can't fake
       depth, you can grow leadership." Personal-assistant and
       devils-advocate voted (b) — both for the same reason:
       team-experience is the harder of the two to coach in 6 months,
       and your stated 30-day need is "set the team direction."

       ### Why this one
       - Your 30-day criterion was "set technical direction with
         the team" — that's a team-shaped problem, not a
         depth-shaped one.
       - Depth gaps are debuggable: pair them with someone deeper,
         buy time. Team gaps surface as missed meetings, dropped
         decisions, and quiet departures — much slower to spot.
       - (b)'s reference call surfaced concrete instances of
         leadership work; (a)'s didn't.

       ### Why not the other
       - **(a) Senior:** the depth would be a strong asset for an
         IC role — but you're hiring for a team-shaping role and
         that's not the same job.

       ### Cost of being wrong

       | If wrong | Cost | Reversible? |
       |---|---|---|
       | (b) can't grow technical depth | 3-6 months of slower decisions; coaching needed | Partial |
       | (b) is great but you also needed depth | Add a second senior IC later | Yes |

       ### Revisit point
       **Revisit if:** in the first 30 days, the team makes one or
       more decisions that the candidate can't credibly review.
       That'd be the depth gap showing up early enough to course
       correct.

       Until then, the decision is closed.
```

## Internals

For non-trivial decisions the skill invokes [clarity-council](../clarity-council/) in `council_consult` mode with `[senior-architect, devils-advocate, personal-assistant]`:

- The **senior-architect** votes on long-term technical/structural fit.
- The **devils-advocate** stress-tests the picked option and forces the worst-case scenario into the cost-of-wrong section.
- The **personal-assistant** votes on what's actually executable given current state and constraints.

Majority wins. Ties are broken by which option has the lowest cost-of-being-wrong (per the personal-assistant vote).

Hard constraints: do not introduce new options; do not produce a framework; do not say "it depends"; must end with a single pick; revisit trigger must be a concrete, observable signal (not "if it feels wrong").

## FAQ

**Q: What if the pick feels wrong?**
A: Two possibilities — you have an unarticulated constraint that didn't make it into the inputs (re-run with it surfaced), or the pick is genuinely right and the discomfort is commitment-anxiety rather than evaluation. The revisit trigger handles the second case: act on the pick, watch for the trigger, re-decide if it fires.

**Q: What if I want to argue with the council?**
A: Push back on the specific vote. The skill will re-run with your counter-argument included.

**Q: What if there's really only one option?**
A: Then you don't have a decision, you have a constraint. The skill is for genuine forks.

**Q: Can I use this for personal life decisions?**
A: Yes — the personas adapt. Senior-architect becomes "long-term thinker", personal-assistant stays operational, devils-advocate stays critical.

## Related skills

- **[clarity-council](../clarity-council/)** — the underlying voting engine.
- **[grill-me](../grill-me/)** — use first if the options aren't well-defined yet. Grill clarifies, idea-decision-maker picks.
- **[time-reality-check](../time-reality-check/)** — pairs well when the decision is about how much you can commit to.
- **[energy-budget](../energy-budget/)** — pairs well when the decision is about what to drop.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (council wiring and output format)
