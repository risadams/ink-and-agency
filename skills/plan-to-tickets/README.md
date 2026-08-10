# Plan to Tickets

Break a spec, plan, or conversation into a **local, numbered task list** — spec-kit style, tracer-bullet vertical slices with explicit dependencies — staged where you choose. Pushing the tasks to Jira (as tickets with native "Blocks" links) is opt-in and only happens on request, after you confirm. The local `tasks.md` is the source of truth.

## Why this exists

A plan or spec is a wall of intent; tasks are grabbable work. The translation goes wrong two ways: **horizontal slicing** (a task per layer — "build the schema", "build the API" — none demoable alone) and **premature remote writes** (dozens of tickets created in Jira before anyone has reviewed the breakdown, then painfully un-picked). This skill fixes both. Every task is a **tracer bullet** cutting a complete vertical path through all layers, dependencies are explicit (`T001` blocked by nothing, `[P]` for parallelizable), and it all lands in a **local numbered `tasks.md` first** — reviewable, editable, diffable — with Jira as a deliberate downstream projection you trigger when ready.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "break this into tasks" / "turn the spec into a task list"
  - "plan the tickets for this"
  - "slice this into work"
- Running the slash command: `/plan-to-tickets`

> **Note:** `disable-model-invocation: true` — user-invoked only.

## What it does

Resolves a **staging location** (beside the source spec → argument → memory default → ask), gathers context, optionally explores the codebase for prefactoring, drafts **vertical slices** with blocking edges, then **quizzes you** on granularity and dependencies until you approve — writing nothing before then. On approval it writes a numbered `tasks.md` (`T001`, `T002`, … in dependency order, `[P]` parallel markers). That's the default stopping point. If you later ask, it pushes the tasks to Jira in dependency order with native "Blocks" links and writes the `T00N → KEY` mapping back into the local file. Wide refactors are sequenced expand → migrate-in-batches → contract rather than forced into one slice.

### Inputs

- **A spec, plan, or conversation** — a staged `spec.md`, a Confluence URL, a Jira key, or the live discussion.
- **A staging location** — beside the spec, a path you pass, the memory default, or answered when asked.

### Outputs

- **A local `tasks.md`** at `<staging>/NNN-<feature-slug>/tasks.md` — numbered tasks, dependencies, acceptance criteria; the source of truth.
- **On request only:** Jira tickets created blockers-first with "Blocks" links, and a `T00N → KEY` mapping recorded back into `tasks.md`.

### External systems used

- **Local filesystem** — the default and only guaranteed write.
- **Jira** — opt-in, on request, after confirming project + issue type: `jira_create_issue`, `jira_link_issues` ("Blocks"), `jira_get_issue_link_types`. Project key from `reference_jira_default_project.md`.

## How to use it

```text
You: /plan-to-tickets   (from the staged CSV Export v2 spec)

Skill: Writing beside the spec: ./specs/003-csv-export-v2/tasks.md.
       Proposed slices:
       T001 Export empty CSV end-to-end (schema→API→UI→test)  Blocked by: none [P]
       T002 Populate rows + pagination                        Blocked by: T001
       T003 Async export for >10k rows                         Blocked by: T002
       Granularity right? Edges correct?
You: split T003 — the job queue is its own slice
Skill: [re-presents 4 tasks] ... approved?
You: yes
Skill: Wrote tasks.md (T001–T004, dependency order). Staged — ready for
       /implement. (Say "push to Jira" to create tickets.)

You: push to Jira
Skill: Project PRJ, issue type Task — confirm?   [you: yes]
       Created PRJ-1490..1493 blockers-first, wired Blocks links, recorded
       the T00N→KEY mapping in tasks.md. Frontier: PRJ-1490.
```

## Getting the most out of it

- **Slice vertically.** If a task only touches one layer, it's wrong — each should be demoable on its own. Push back if the breakdown drifts horizontal.
- **Get the edges right at the quiz.** Dependencies drive the `[P]` markers and the frontier; a wrong edge hides a takeable task or exposes one that isn't ready.
- **Work the local file first.** `tasks.md` is diffable and editable — refine it, hand it to `/implement`, and only push to Jira when you actually want tickets on the board.
- **Name wide refactors explicitly.** A rename with a big blast radius shouldn't be a tracer bullet — say so, and let the skill sequence expand–contract.

## It's working if

- Every ticket answers "what can I demo when this is done?" — and the answer is behaviour, not a layer.
- The list comes back numbered, with a *Blocked by* line on each, before anything is published.
- The ticket at the top has no blockers and can be started immediately.
- Every acceptance criterion is false at the base commit. One that's already true grades nothing.
- Nothing in a ticket body is a file path or a line number, except a snippet a prototype produced.
- Each ticket reads like something a fresh session could finish without you in the room.
- Prefactoring, where it found any, is at the front of the order rather than mixed into feature tickets.
- It pushed back when the change was small enough to skip slicing entirely.

## Anti-patterns

- ❌ **Creating Jira tickets by default.** Local-first — a remote write happens only when you ask and confirm project + issue type.
- ❌ **Horizontal slices.** A task per layer defeats the tracer-bullet model. Each task cuts through every layer.
- ❌ **Writing before approval.** The breakdown is quizzed and iterated first; the `tasks.md` write happens only after sign-off.
- ❌ **Forcing a wide refactor into one slice.** It can't land green. Sequence expand → migrate batches → contract.
- ❌ **Touching the parent.** Link to the source ticket; never transition or close it.

## Related skills

- **[plan-to-spec](../plan-to-spec/)** — the usual source: a staged `spec.md` this skill slices into tasks beside it.
- **[work-plan](../work-plan/)** — plans *decisions* for a foggy effort; this turns a *settled* plan into build tasks (the next step once the fog clears).
- **[implement](../implement/)** — works the staged tasks one at a time through its tunable build pipeline.
- **[issue-estimate-sp](../issue-estimate-sp/)** — estimate story points once tasks become Jira tickets.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (staging resolution, vertical-slice rules, task template, opt-in Jira push)
