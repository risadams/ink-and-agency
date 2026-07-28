# Overwhelm Triage

Dump everything that's competing for attention. Get back exactly one thing, plus explicit permission to not think about the rest today.

## Why this exists

There was a gap between two existing skills. [energy-budget](../energy-budget/) does load math on a *calendar* — it needs a list of scheduled things with durations. [task-initiation](../task-initiation/) produces the first physical action — it needs you to already know which task. Neither covers the state in between: eleven things, no structure, and no way to pick.

The instinct in that state is to make a prioritized list. That fails, because ranking eleven items by importance is eleven comparisons, and comparison is exactly the faculty that's currently offline. A ranked list is not a decision — it's a decision deferred, wearing a trench coat.

So this skill sorts by **consequence**, not importance, and returns **one** item. Consequence is checkable ("what actually happens if this doesn't happen today?"), which makes it answerable when importance isn't.

## Triggers

- Saying "everything is on fire", "I'm overwhelmed", "too much going on", "I don't know what to do first", "help me pick"
- Running the slash command: `/overwhelm-triage`

## What it does

1. **Takes the dump uninterrupted.** No clarifying questions first — getting it out of working memory is half the value.
2. **Mirrors it back numbered**, and pulls non-tasks (worries) into their own block so they stop occupying task slots.
3. **Sorts into four buckets** — Today / This week / No date / Not yours. Only *Today* gets listed in full; the rest are counts.
4. **Picks one** by highest consequence if missed, tie-broken by smallest.
5. **Parks the rest with a date**, which is what makes parking safe.

### Inputs

- An unstructured dump. Unsorted, unpunctuated, feelings included.

### Outputs

- Five lines: the one thing, its first action, the consequence, the parked counts, and explicit permission.

### External systems used

- None.

## The four buckets

| Bucket | Test | Shown as |
| :--- | :--- | :--- |
| **Today** | A real consequence lands today if it doesn't happen | Listed in full |
| **This week** | A real deadline, just not today | Count |
| **No date** | Feels urgent, has no deadline | Count |
| **Not yours** | Someone else owns it, it's dead, or it self-resolves | Count + one line each |

Most of any dump lands in **No date**. Hearing "seven of these eleven have no deadline at all" is often the entire therapeutic payload.

## How to use it

```text
You: I'm overwhelmed, everything is on fire

Skill: Dump everything taking up space. Unsorted, no order.
       Include the things that aren't tasks.

You: the migration PR needs review comments addressed, I owe Sarah a
     doc, the staging env is broken, my expenses are 3 weeks late,
     I should refactor the auth module, the onboarding email draft,
     I think standup went badly, need to book the flights, the
     dependency audit, someone should update the README, and I
     haven't done the perf review self-assessment which is due friday

Skill:
       **Not tasks (these were taking up task slots):**
       - "I think standup went badly" — that's a worry, not work.
         /rejection-sensitivity-check if it keeps coming back.

       **Today (1):** staging env is broken — the team is blocked on it.
       **This week (2)** · **No date (6)** · **Not yours (1)**
       - README update: nobody assigned it to you.

       **Do this: fix staging.**
       First action: open the deploy log and read the last error line.
       Because: three people can't test until it's up.
       **Parked until Friday:** 2 this week, 6 no-date, 1 not yours.
       Everything on that parked list is allowed to not happen today.
```

## Getting the most out of it

- **Dump badly.** Fragments, no punctuation, out of order. Structure is the skill's job and structuring it yourself costs the energy you don't have.
- **Include the feelings.** "I think standup went badly" belongs in the dump precisely because it's occupying a slot. Naming it as a non-task is what evicts it.
- **Push back once on bucket placement, then move on.** If something's in the wrong bucket, say so — the skill moves it without debating. Two rounds of that and you're re-ranking, which is the trap.
- **Take the parked list literally.** The parking is the deliverable as much as the pick is.

## Routes out

- **Three or more real Today items** → [energy-budget](../energy-budget/). That's a capacity problem; no amount of picking fixes it.
- **Can't start the one thing** → [task-initiation](../task-initiation/).
- **An item turns out to be a hyperfixation, not an obligation** → [interest-capture](../interest-capture/).

## Anti-patterns

- ❌ **Returning a ranked list.** The exact failure this skill exists to prevent.
- ❌ **Asking which one feels most important.** If that were answerable, the user wouldn't be here.
- ❌ **"Just break it down."** A breakdown of eleven things is still eleven things.
- ❌ **Adding to the list.** However obviously something is missing, it isn't the skill's to add.
- ❌ **Reassurance.** "It's not as bad as it looks" is a claim about the list that doesn't shorten the list.

## FAQ

**Q: What if the one thing it picks is wrong?**
A: Say so and it re-picks from the Today bucket. One correction is fine; if you're on your third, the real problem is capacity — go to [energy-budget](../energy-budget/).

**Q: What if nothing is actually due today?**
A: It says so plainly and picks the smallest item from This week. Knowing nothing is due today is itself worth the run.

**Q: Where does the parked list go?**
A: Nowhere by default — it's counts, not storage. If you want the items kept, ask, and it'll route them through [interest-capture](../interest-capture/) into the vault.

**Q: How is this different from energy-budget?**
A: energy-budget scores a *schedule* you already have and tells you what to drop. This takes an *unsorted pile* and tells you what to do next. Overwhelm first, capacity second.

## Related skills

- **[task-initiation](../task-initiation/)** — the natural next step once the one thing is picked.
- **[energy-budget](../energy-budget/)** — when the problem is capacity, not selection.
- **[interest-capture](../interest-capture/)** — park an idea properly instead of arguing with it.
- **[rejection-sensitivity-check](../rejection-sensitivity-check/)** — for the "I think that went badly" items the dump surfaces.
- **[i-have-adhd](../i-have-adhd/)** — the output shaper this skill's five-line format follows.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (dump protocol, four buckets, the pick rule, routes out)
