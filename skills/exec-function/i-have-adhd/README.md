# I Have ADHD

An output-shaping skill. It does not change *what* the agent tells you — it changes the shape it arrives in: next action on the first line, multi-step work numbered, progress state restated every turn, one thread at a time, numeric time estimates, wins stated plainly, no preamble and no closing pleasantries.

## Why this exists

Most agent output is written for a reader with intact working memory and cheap task-switching. That reader can hold "we're on step 3 of 5" across three messages, skim past a two-sentence windup, and turn "this will take some work" into a plan. An ADHD reader can't do any of those for free — each one costs the exact resource that's scarce.

Five facts drive the whole ruleset:

1. **Working memory is small.** Anything not on screen is gone, so state has to be restated, not carried.
2. **Knowing the answer is not doing the answer.** The friction between "got it" and "done it" is where work dies — so the answer leads with something to *do*.
3. **Starting is the hardest step.** The first action must be small, obvious, and doable now.
4. **Time estimates feel uniform.** "A bit of work" and "a few hours" register the same, so estimates get numbers and conditions.
5. **Dopamine is scarce.** A win buried inside a recap doesn't land as a win, so completed work is named in concrete terms with the command that proves it.

## Triggers

- Saying "I have ADHD", "shape this for ADHD", "ADHD mode", or asking for output that leads with the next action
- Running the slash command: `/i-have-adhd`

Once invoked it applies to **every** subsequent message in the session — code, debugging, planning, and casual chat — including messages that never mention brevity.

## Making it permanent

The skill lasts one session. For always-on shaping, put the intent somewhere the agent loads every session:

- **Per project** — add a line to the project's `CLAUDE.md` / `AGENTS.md`: *"Shape all output per the `i-have-adhd` skill."*
- **Per user** — add the same line to `~/.claude/CLAUDE.md`, or save it as a user memory.

Either way the skill stays the single source of truth for the rules; the pointer just makes it load unprompted.

## What it does

### Inputs

- None. It reads whatever the current request is and shapes the response to it.

### Outputs

- Every response for the rest of the session, reshaped: action-first, numbered, state-carrying, tangent-free.

### External systems used

- None.

## Form, not substance

The one thing that would break this skill is treating "shorter" as the goal. It isn't. A stripped answer that omits a needed caveat, a correctness detail, or half the requested scope is a worse answer no matter how fast it reads.

The rules only govern **packaging**: what goes first, what gets numbered, what gets deleted from the *edges* (windups, recaps, sidebars, hedges). When the content genuinely needs length — an architecture explanation, a migration plan, a subtle bug — it gets the length, with headers so the reader can skim back.

## Getting the most out of it

- **Say "still broken" plainly when it is.** Three of those in a row trips the debug-spiral override, which stops code iteration and gets you a diagnostic question instead of a fourth guess.
- **Ask to "walk me through" when you want depth.** That word switches off the compression rules while keeping the no-preamble/no-closer discipline.
- **Take the last line seriously.** Every response ends on one action you can finish in under two minutes. That's the handle for re-entry after you get pulled away.
- **Let it park tangents.** When the agent says "Separately: X — handle that next?", answering "yes" later is cheaper than reading about X now.

## Anti-patterns

- ❌ **Using it to shorten answers that need to be long.** Compression of the edges, never of the substance.
- ❌ **Skipping confirmation on destructive commands** because the shape rules favour speed. Safety overrides brevity, always.
- ❌ **Numbering a single-step task.** A one-action answer is one line, not a list of one.
- ❌ **Stacking six items because they're all real.** Rank them and split into "do now" / "later".
- ❌ **Replacing encouragement with coldness.** Matter-of-fact is the target, not curt. State cause and fix; don't editorialize either direction.

## Examples

### Example: a bug report

**Before**

> Great question! Let me take a look at what's happening here. Your test is failing, which is often caused by a few different things — it could be a missing header, or possibly a config issue, or the token might be expired. Uh oh, looking at the trace, it seems like there may be a problem with authentication. I've now investigated the failure and found the cause…

**After**

> Add `Authorization: Bearer ${token}` to the request in `auth.spec.ts:38`.
>
> Cause: `auth.spec.ts:42` expected 200, got 401 — the request goes out with no auth header.
>
> Next: run `npm test -- auth.spec.ts` and paste the first failing line if it's still red.

### Example: multi-step work, mid-task

**Before**

> Done with that part. As I mentioned earlier we still have the remaining pieces to get through, and I also noticed your README is out of date and one of your dependencies is stale. Ready for the next part?

**After**

> Step 3 of 5 done: schema updated — `users.timeout_ms` exists and migrates cleanly.
>
> Next: backfill the new column. ~5 min for 40k rows.
>
> Run `npm run migrate:backfill`?
>
> Separately: the README is out of date. Handle that after step 5?

### Example: a scoping question

**Before**

> This will take some work. There are a few moving pieces to consider, and it depends on the state of your test coverage, so it could possibly take a while depending on how things go.

**After**

> ~15 min if `auth.spec.ts` already covers the token path; an afternoon if it doesn't and the fixtures need rewriting.
>
> Next: open `auth.spec.ts` and check whether any test asserts on an expired token.

## FAQ

**Q: Does this make the agent skip work or give shallower answers?**
A: No. It reorders and de-pads. If a task needs five files changed, it still changes five files — it just tells you the first action before the reasoning.

**Q: What if I actually want the reasoning?**
A: Ask to be walked through it. The explain override runs the body as long as the topic needs.

**Q: Why the ban on "Hope this helps"?**
A: A closing pleasantry occupies the last line, which is the highest-value real estate in the response — it's where the next action goes. The pleasantry costs a re-read to find the action.

**Q: Isn't restating the state every turn repetitive?**
A: It's repetitive for a reader who was holding the state anyway. For one who wasn't, it's the difference between resuming and re-deriving.

## Related skills

- **[task-initiation](../task-initiation/)** — for when you know the task and still can't start; produces one literal ≤30-second action.
- **[time-reality-check](../time-reality-check/)** — when a ballpark estimate isn't enough and you need a calibrated best/likely/worst.
- **[hyperfocus-recovery](../hyperfocus-recovery/)** — reconstruct where you left off after a deep session or interruption.
- **[break-it-down](../break-it-down/)** — the inbound counterpart: decode a message someone sent *you* into plain language.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the ten rules, overrides, and pre-send check)
