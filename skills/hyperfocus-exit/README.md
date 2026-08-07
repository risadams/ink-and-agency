# Hyperfocus Exit

Stop a deep session on purpose without paying for it tomorrow. Captures the half of your context that exists only in working memory, writes a park file, drops a `PARKED` breadcrumb at the exact line you were on, and gets out of your way in under two minutes.

The inverse of [hyperfocus-recovery](../hyperfocus-recovery/), which reads what this writes.

## Why this exists

The pack already had three of the four corners: starting ([task-initiation](../task-initiation/)), re-entering ([hyperfocus-recovery](../hyperfocus-recovery/)), and capturing a distraction ([interest-capture](../interest-capture/)). Stopping was missing, and it's the one with the worst failure mode.

When you're deep in something, roughly half the context isn't on disk. The repo knows which files are dirty. It does not know the hypothesis you were three minutes from testing, the two explanations you already ruled out, or that you set `DEBUG_AUTH=1` in a shell you're about to close. Drop cold and that half evaporates — `hyperfocus-recovery` can reconstruct the on-disk half tomorrow, and reconstructing the rest costs an hour.

This skill spends 90 seconds now to save that hour.

## Triggers

- Saying "I have to stop", "meeting in 10", "park this", "save my place", "I'm being pulled away", "hyperfocus exit"
- Running the slash command: `/hyperfocus-exit`

## The clock rules everything

The skill asks how long you have and runs the matching tier. It will not run a longer tier than the clock allows.

| Time | Tier | What happens |
| :--- | :--- | :--- |
| <1 min | **Slam** | No questions. Artifact snapshot, park file with `[not captured]` head-state, done. |
| 1–3 min | **Standard** | One question, snapshot, park file, breadcrumb. |
| 3+ min | **Full** | Standard, plus loose-end sweep and a stated re-entry action. |

## The one question

> **What were you about to try next, and what have you already ruled out?**

That answer is the whole point of the skill — it's the part that exists nowhere else. Everything else can be reconstructed from git.

## What it does

### Inputs

- Minutes available (asked first, always).
- The one question's answer (skipped in slam tier).

### Outputs

- `.ink-and-agency/park/<YYYY-MM-DD-HHmm>.md` — the park file.
- A `// PARKED <timestamp>: <one line>` comment at the cursor line.
- A ≤5-line report so you can walk away.

### External systems used

- Git (read-only: `status`, `diff --stat`, `branch`, `stash list`).

## The park file

Six sections, one screen maximum, because it gets read by a brain that has lost the thread:

| Section | Holds |
| :--- | :--- |
| **The thread** | What you were doing and what for — reconstructed from artifacts |
| **In my head, not in the repo** | The one-question answer. The highest-value field in the file. |
| **Re-entry action** | One literal ≤2-minute step that restarts the loop |
| **State of the tree** | Dirty files, staged vs unstaged, branch, failing test |
| **Do not lose** | Running processes, set env vars, unsaved buffers, temporary hacks to revert |

`hyperfocus-recovery` reads the newest file in `.ink-and-agency/park/` before anything else, and scans for `PARKED` alongside TODO/FIXME/XXX.

## How to use it

```text
You: hyperfocus-exit, standup in 3 minutes

Skill: How many minutes do you have?  → 3
       What were you about to try next, and what have you ruled out?

You: was about to check whether the 401 comes from the refresh path
     rather than login. already ruled out the clock skew theory and
     the missing header.

Skill: **Parked.** .ink-and-agency/park/2026-07-28-0912.md —
       breadcrumb at src/auth/refresh.ts:88.
       **Do not lose:** dev server on :3000; DEBUG_AUTH=1 set in your shell.
       **Re-entry:** run /hyperfocus-recovery.
```

Tomorrow, `/hyperfocus-recovery` opens with the ruled-out list instead of making you re-derive it.

## Getting the most out of it

- **Answer the one question badly rather than not at all.** A fragment of the hypothesis beats a clean `[not captured]`.
- **Say the real number of minutes.** Claiming five when you have one gets you a half-written park file at the moment you leave.
- **Mention the invisible state.** Running processes, exported env vars, a paused debugger, a browser tab with the one Stack Overflow answer. That's what "Do not lose" is for, and nothing else will remember it.
- **Park before the meeting, not during.** Two minutes early costs two minutes. Parking from the meeting costs the meeting.

## Anti-patterns

- ❌ **Stashing or committing on the way out.** The hot, dirty state *is* the context. The skill won't do it unless you ask.
- ❌ **Writing tomorrow's plan.** Park the present. Planning the future is a different skill and a different energy level.
- ❌ **Tidying on exit.** Formatting, fixing a lint error, "just one more thing" — that's how a two-minute exit becomes twenty.
- ❌ **A park file longer than a screen.** If it needs skimming, it won't get read.
- ❌ **Using it as a daily journal.** It's an interrupt handler. Park files are disposable.

## FAQ

**Q: How is this different from just committing WIP?**
A: A WIP commit records the files. It doesn't record what you were about to try or what you'd already eliminated — and that's the expensive part to rebuild.

**Q: Do I need to clean up old park files?**
A: They're disposable. Delete the directory whenever; `hyperfocus-recovery` only reads the newest.

**Q: Should `.ink-and-agency/park/` be gitignored?**
A: Usually yes — it's personal working state, same as the learnings journals. Add `.ink-and-agency/` to `.gitignore` if it isn't already.

**Q: What if I get pulled away with zero warning?**
A: Then you use [hyperfocus-recovery](../hyperfocus-recovery/) tomorrow and rebuild from artifacts. This skill needs at least a few seconds of notice; the recovery skill assumes none.

## Related skills

- **[hyperfocus-recovery](../hyperfocus-recovery/)** — the other half of the pair; reads the park file and the `PARKED` breadcrumb.
- **[task-initiation](../task-initiation/)** — when the re-entry action still doesn't get you moving.
- **[interest-capture](../interest-capture/)** — for parking an *idea* that showed up mid-session, rather than the session itself.
- **[handoff](../handoff/)** — the same problem at agent scale: compact a session so a fresh agent can pick it up.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (tiers, the one question, park file format, breadcrumb)
