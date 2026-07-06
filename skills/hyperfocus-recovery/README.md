# Hyperfocus Recovery

A forensic context-reconstruction skill. You came back from a deep work session (or an interruption, or yesterday) and have no idea where you were. The skill reads recent git artifacts (status, diff, log, stash), modified files, breadcrumb comments, and any open IDE context, then produces a structured "here's where you were, here's the next concrete action" handoff.

## Why this exists

Hyperfocus is a great way to lay down a lot of state and a terrible way to remember any of it. The same is true of being yanked away by an interruption mid-task — the mental scratchpad evaporates within minutes. The artifacts you left behind, though, are still there: uncommitted changes, stashes, `// TODO` comments to yourself, the file that was open in the editor. This skill assembles those artifacts into the context your brain just lost, ranks the threads by recency and certainty, and ends with the smallest concrete next action (same shape as [task-initiation](../task-initiation/)). No council — it's pure reconstruction.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "what was I doing"
  - "where did I leave off"
  - "I lost my place"
  - "help me get back in"
  - "context recovery"
  - "hyperfocus recovery"
  - "I just came back from [meeting / lunch / yesterday]"
- Running the slash command: `/hyperfocus-recovery`

The skill is **read-only**. It never commits, stashes, or modifies anything during recovery.

## What it does

The skill runs a gathering pass (git status, git diff, git diff --staged, git log -10, git stash list, recently-modified files, TODO/FIXME comments, open editor file) and produces a five-section handoff: (1) one-paragraph reconstruction of the apparent goal with citations to specific files; (2) ranked list of active threads (High/Medium/Low confidence); (3) breadcrumb comments the user left themselves; (4) loose ends (uncommitted, stashed, failing tests); (5) one suggested re-entry action calibrated to ≤30 seconds, plus an optional "drop it" alternative. Always inline — no council.

### Inputs

- **Working directory** — the git repo to reconstruct from.
- **Optional time window** — defaults to "recent" (last few hours).

### Outputs

- A five-section markdown handoff with the suggested re-entry point.

### External systems used

- **Local git repo** (read-only) — status, diff, log, stash.
- **Local filesystem** (read-only) — recently modified files.

## How to use it

A typical session looks like this:

```text
You: what was I doing? Just came back from a 2-hour meeting and I had
     been deep in something this morning.

Skill: (runs git status / diff / log; scans recently-modified files)

       ### Where you were
       Based on the uncommitted changes in src/queue/worker.ts and
       the TODO at line 89, you were partway through replacing the
       polling loop with the new event-driven dispatcher. The last
       commit (2h ago) was the test scaffolding for it.

       ### What you were doing
       - **[High confidence]** src/queue/worker.ts — replacing
         pollForJobs() with the new on('job') handler. Half-done;
         the new handler exists but the old loop is still being
         called.
       - **[High confidence]** src/queue/worker.test.ts —
         new test suite committed but several tests are failing
         (3 of 8 — see loose ends).
       - **[Low confidence]** docs/architecture.md — touched, but
         only whitespace changes; probably accidental.

       ### Breadcrumbs you left yourself
       - src/queue/worker.ts:89 — `// TODO: remove polling loop once
         dispatcher is wired in all call sites`
       - src/queue/worker.ts:142 — `// XXX: handle null payload —
         spec is ambiguous here, ask Sara`

       ### Loose ends
       - 3 uncommitted files (worker.ts, worker.test.ts,
         architecture.md)
       - No stashes
       - 3 failing tests in worker.test.ts: dispatchesOnEvent,
         handlesNullPayload, retriesOnTransientError

       ### To get back in, do this:
       Open src/queue/worker.ts:89. Read the TODO. That's where you
       were — the polling loop still needs to come out and the call
       sites still need to be wired to the new handler.

       Or: if you want to drop this thread, `git stash` and I can
       help you pick something new.
```

## Getting the most out of it

- **Run it before you do anything else after returning.** The recovery is fastest when the working tree state is exactly as you left it. If you start poking around first, the artifacts shift.
- **Trust the High-confidence threads, verify the Low.** The skill is conservative about confidence — High means the evidence is unambiguous, Low means "this file was touched but I can't tell why."
- **Read the breadcrumbs.** TODO/XXX/FIXME comments you left yourself are usually the highest-fidelity record of intent. The skill always surfaces them.
- **If nothing looks familiar, say so.** Sometimes you come back and the artifacts don't match what you remember. That's data — usually it means you didn't save, or you were in a different worktree, or the deep session was thinking-only and never landed in code.

## Anti-patterns

- ❌ **Acting before recovery.** Don't start typing or running commands first. The skill works from the working-tree snapshot.
- ❌ **Asking it to plan.** It reconstructs, it doesn't plan. If you want a plan once you're back in, route to a planning skill afterward.
- ❌ **Modifying state during recovery.** No commits, no stashes, no resets. Read-only by design.
- ❌ **Trusting "Low confidence" threads as if they were High.** Low confidence means the skill is guessing — verify before acting.

## Examples

### Example: Recovery after a short interruption

```text
You: lost my place — got pulled into a 20-minute call. What was I on?

Skill: (gathers state — small change since last commit, one open editor file)

       ### Where you were
       Editing src/api/users.ts. The only uncommitted change is a
       new function `validateEmail()` at line 47, currently half-
       written (the function signature exists but the body is just
       `// TODO`).

       ### What you were doing
       - **[High confidence]** src/api/users.ts:47 — writing
         validateEmail(). Signature in place, body empty.

       ### Breadcrumbs you left yourself
       - src/api/users.ts:47 — `// TODO`

       ### Loose ends
       - 1 uncommitted file (users.ts)
       - No stashes
       - No tests run yet

       ### To get back in, do this:
       Open src/api/users.ts:47. Write the first regex check. Even
       a wrong one. The function shape matters more than the regex
       being perfect right now.
```

### Example: Recovery after a weekend

```text
You: hyperfocus recovery — Monday morning, I have no idea what I
     was on Friday.

Skill: (gathers git log, last 7d modified files, current branch state)

       ### Where you were
       Friday's last commit (Fri 4:47pm) was "WIP: extract
       authMiddleware into separate module" on the
       feature/auth-refactor branch. There are 4 uncommitted files
       on top of that commit.

       ### What you were doing
       - **[High confidence]** src/middleware/auth.ts — new file,
         mostly complete extraction of the old inline middleware.
       - **[Medium confidence]** src/server.ts — modified to import
         the new middleware but the import isn't wired into the
         route handlers yet.
       - **[Medium confidence]** test/auth.test.ts — added but
         tests are failing because the import path is wrong.
       - **[Low confidence]** package.json — only the lockfile
         hash changed, probably from an npm install you forgot you
         ran.

       ### Breadcrumbs you left yourself
       - src/middleware/auth.ts:1 — `// FIXME: handle the legacy
         cookie format here, see #1247`
       - src/server.ts:24 — `// TODO: wire new auth middleware in
         after extraction is done`

       ### Loose ends
       - 4 uncommitted files
       - 1 stash from Wed ("debug logging — drop before commit")
       - test/auth.test.ts has 2 failing tests

       ### To get back in, do this:
       Open src/server.ts:24. Read the TODO. The next step is to
       wire the new middleware import into the route handlers —
       that'll unblock the failing tests too.

       Or: if you want to drop this branch and start fresh on
       something else, `git stash` and I can help you pick.
```

## Internals

The gathering pass runs in parallel where possible:

| Source | What it reveals |
|---|---|
| `git status` | What's uncommitted and what's been added |
| `git diff` (working) | Active edits |
| `git diff --staged` | Decisions you'd already made |
| `git log --oneline -10` | The trajectory of thought |
| `git stash list` | Abandoned threads |
| `find -mmin -240` | Recently-touched files outside git |
| `grep TODO\|FIXME\|XXX` (recent files) | Breadcrumbs you left yourself |
| IDE-open file | The literal point of attention |

Confidence is assigned by combining: how fresh the change is, whether the file has substantive edits or only whitespace, whether there's a corresponding breadcrumb comment, and whether the change appears in a coherent thread (multiple related files) vs. in isolation (probably accidental).

Hard constraints: read-only; do not guess intent beyond what the artifacts support; do not produce a plan; do not encourage; do not modify any state.

## FAQ

**Q: What if I wasn't using git?**
A: The skill falls back to recently-modified files and any open editor context. It's less accurate without git but still produces a usable reconstruction.

**Q: What if I had multiple things going at once?**
A: The threads list captures them separately. The "suggested re-entry" picks the one with the strongest signal; you can choose a different one.

**Q: Will it remember from previous sessions?**
A: No. Each invocation is fresh from artifacts. This is by design — the artifacts are the source of truth, not a memory store that can drift.

**Q: What if recovery shows nothing?**
A: That's a valid output. The skill will say so plainly — "no recent changes, no relevant breadcrumbs, looks like a clean slate." That usually means the work was on a different machine, in a different worktree, or never landed in code.

## Related skills

- **[task-initiation](../task-initiation/)** — sibling for the case where you're not returning to anything, you just can't start. Same shape of one-action handoff.
- **[interest-capture](../interest-capture/)** — for stashing a new idea that surfaces during recovery so it doesn't pull you sideways.
- **[good-morning](../good-morning/)** — calls hyperfocus-recovery as part of the morning routine.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (gathering pass and output format)
