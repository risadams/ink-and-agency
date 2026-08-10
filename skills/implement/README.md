# Implement

Build a piece of work through a **tunable pipeline** — source → test-first → verify → review → track — where every phase can be skipped or tuned. The same skill runs a throwaway prototype (build directly, no tests, no tracking) and a CCB-gated feature (full TDD, review, Jira + MR). The one constant is that it proposes a **run plan** first and lets you edit it before a line of code is written.

## Why this exists

A build-loop that assumes full ceremony is wrong most of the time — a spike doesn't need TDD, a repo with no test setup can't "run the suite", and a scratch experiment shouldn't open an MR or move a ticket. But a build-loop with *no* structure is just "go write code." This skill resolves the tension by making the *process* predictable while the *phases* vary: it auto-detects a preset from the context, shows you the plan, and you tune any line. What runs is explicit and agreed; what's skipped is reported, never silently dropped.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "implement this" / "build this ticket"
  - "build PRJ-1490" / "implement the spec"
  - "let's build this out"
- Running the slash command: `/implement`

> **Note:** `disable-model-invocation: true` — user-invoked only. Actually building (and possibly committing/opening MRs) is a deliberate act you trigger.

## What it does

**Step 1 — proposes a run plan.** It auto-detects a preset (`prototype` / `standard` / `full`) from the context and presents the five phases as an editable list; you tune any line or name a preset, and nothing builds until you approve. **Step 2 — executes only the enabled phases** in order, honouring each tuning: test-first via `/tdd` in vertical slices, verify (typecheck + tests), review via `/code-review`, and track (commit / MR / move ticket / nothing). **Step 3 — closes out**, reporting what ran *and what was skipped* explicitly.

### Inputs

- **A source** — a Jira ticket, a `/plan-to-spec` Confluence page, or free-form from the conversation.
- **Optional preset/tuning** — say "prototype" or edit any run-plan line.

### Outputs

- Built code, plus whatever the enabled phases produce: tests, a review report, a commit, an MR, a transitioned ticket — or just uncommitted code for a prototype.
- A close-out naming every phase that ran and every phase that was skipped.

### External systems used

- **[tdd](../tdd/)** — the red→green loop (when test-first is on).
- **[code-review](../code-review/)** — two-axis review (when review is on).
- **Jira / GitLab** (`mr-draft` if installed) — when tracking is on. Keys from memory.

## How to use it

```text
You: /implement PRJ-1490

Skill: Run plan (auto-detected: full — edit any line, or say a preset):
       - Source:     PRJ-1490 (Jira ticket)
       - Test-first: TDD at the ExportService seam
       - Verify:     typecheck + full suite
       - Review:     code-review (Standards + Spec)
       - Track:      commit + MR + move ticket
You: standard, and skip the ticket move
Skill: Plan: TDD at ExportService · typecheck+tests · code-review · commit + MR.
       Building...
       [3 red→green slices, suite green, code-review clean]
       Done — ran TDD (3 slices), verify, code-review. Skipped: ticket move.
       Committed a1b2c3d on feature/csv-export-v2, drafted MR !412.
```

Prototype end of the spectrum:

```text
You: /implement — quick spike to see if the streaming API even works
Skill: Run plan (auto-detected: prototype):
       - Test-first: off   - Verify: off   - Review: off   - Track: nothing
       Building directly...
       Done — spike works. Nothing committed (track = nothing). Want to keep it?
```

## Getting the most out of it

- **Trust the auto-detect, then tune.** The preset is a starting point matched to the context — a spike lands on `prototype`, a ticketed feature on `full`. Adjust the one or two lines that don't fit.
- **Say the preset name to move fast.** "prototype" / "standard" / "full" set all five phases at once; edit individual lines only for exceptions.
- **Confirm the seams when test-first is on.** The run plan pulls `/tdd`'s seam agreement forward — that's your chance to aim the testing effort.
- **Read the skip line in the close-out.** "Skipped: tests" is a decision you made; the report makes it visible so it's never a surprise later.

## It's working if

- The run plan arrives first, with every phase named on or off, and nothing starts until you approve it.
- It echoes the resolved work item **and its title** back before building — so a mis-resolved `#2` fails in front of you.
- You can see an actual `/tdd` invocation in the trace, not just tests appearing in the diff.
- Typechecks and single test files run repeatedly during the run; the full suite runs once near the end.
- The review runs against a commit, not an uncommitted tree — a "clean" review of an empty diff is the tell.
- The diff is one work item's worth of change: a vertical slice through every layer, not several tickets swept together.
- The close-out names every skipped phase, and says plainly that the ticket is still open when Track didn't move it.

## Anti-patterns

- ❌ **Building before the plan is approved.** The run plan is the one mandatory checkpoint — Phase 2 never starts before you sign off on Phase 1.
- ❌ **Silently skipping a phase.** Every off phase is named in the close-out; "no tests" is a stated outcome, not an omission.
- ❌ **Fabricating tooling.** Verify off means there's nothing to run — it won't invent a test command; track = nothing means it won't commit.
- ❌ **Reimplementing the primitives.** Test-first is `/tdd`, review is `/code-review`, MR drafting is `/mr-draft`. This skill orchestrates; it doesn't duplicate them.
- ❌ **Refactoring inside the red→green loop.** Refactoring is the review phase's job (per `/tdd`).

## Related skills

- **[tdd](../tdd/)** — the test-first phase; the red→green loop and what makes a test worth keeping.
- **[code-review](../code-review/)** — the review phase; two-axis (Standards + Spec) review of the working diff.
- **[plan-to-tickets](../plan-to-tickets/)** — produces the tickets this skill consumes, one per fresh context.
- **`mr-review`** / **`mr-gatekeep`** — the *next* stage: reviewing/gating the MR once it's posted (private skills; `code-review` is the pre-MR counterpart).

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the five-phase tunable pipeline + presets)
