# Code Review

A **two-axis** review of your working diff since a fixed point: **Standards** (does it follow the repo's coding standards plus a code-smell baseline?) and **Spec** (does it match the originating ticket/spec?). The two axes run as parallel sub-agents and are reported side by side, never merged — so a clean-code pass can't mask a wrong-feature fail, or vice versa.

## Why this exists

A single blended review lets one dimension hide another: code that follows every convention but builds the wrong thing reads as "looks good," and code that does exactly what was asked but violates the repo's patterns slips through on the strength of matching the spec. Splitting the review into two independent axes — and refusing to rerank across them — keeps both visible. Running them as separate sub-agents also keeps each one's context clean, so the Standards reviewer isn't distracted by the spec and vice versa.

> **This is not `mr-review`.** `code-review` reviews your **local working diff** (pre-MR) on two focused axes while you build. `mr-review` / `mr-gatekeep` review a **posted GitLab MR** for process compliance and sign-off. Use this one before the MR exists.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "review my changes" / "code-review this branch"
  - "review since main" / "review since `<commit>`"
  - "review the work-in-progress"
- Running the slash command: `/code-review`
- Automatically, when `/implement` runs with review on.

## What it does

Pins the fixed point (a commit/branch/tag; confirms it resolves and the diff is non-empty), identifies the spec source (commit refs → Jira/GitLab → a spec file/Confluence page → asks) and the standards sources (repo docs + a built-in Fowler code-smell baseline), then spawns two parallel `general-purpose` sub-agents — one per axis — and aggregates their reports under `## Standards` and `## Spec` without merging or reranking.

### Inputs

- **A fixed point** — commit SHA, branch, tag, `main`, `HEAD~5`. Asked for if not given.
- **Optional spec path** — otherwise auto-discovered from commits/tracker.

### Outputs

- Two reports side by side (Standards / Spec), each with per-finding citations, plus a one-line per-axis summary.

### External systems used

- **Git** — the diff and commit list.
- **Jira / GitLab / Confluence** — to fetch the originating spec, when referenced.
- **Sub-agents** (`general-purpose` ×2) — one per axis, run in parallel.

## How to use it

```text
You: /code-review since main

Skill: Fixed point main resolves; 4 commits, non-empty diff. Spec: PRJ-1490
       (from commit "Closes PRJ-1490"). Spawning Standards + Spec reviewers...

       ## Standards
       - export.ts:42 — possible Feature Envy (judgement call): reaches into
         Cart internals; consider moving onto Cart. ...
       ## Spec
       - Missing: spec asks for CSV escaping of embedded commas — not handled. ...

       Standards: 3 findings (worst: Feature Envy). Spec: 1 finding (missing requirement).
```

## Getting the most out of it

- **Give it a meaningful fixed point.** `main` or the branch point is usual; `HEAD~5` to review just recent work. The diff is three-dot (against the merge-base), so it's the changes *your branch* introduced.
- **Point it at the spec if auto-discovery misses.** The Spec axis is only as good as the spec it finds — pass the path or Jira key if commits don't reference it.
- **Read the axes separately.** That's the design. Don't ask "which is the one big problem" — each axis has its own worst finding.
- **Treat baseline smells as judgement calls.** They're labelled heuristics ("possible…"), and a documented repo standard always overrides them.

## Anti-patterns

- ❌ **Confusing it with `mr-review`.** This is pre-MR, two-axis, working-diff. `mr-review` is post-MR process gating.
- ❌ **Merging or reranking the axes.** Keeping them separate is the whole point; a cross-axis "winner" re-hides what the split exposed.
- ❌ **Running it on a bad ref or empty diff.** The skill fails fast at step 1 rather than spawning sub-agents on nothing.
- ❌ **Flagging what tooling already enforces.** Linters/formatters own that; the review targets what they can't catch.

## Related skills

- **[implement](../implement/)** — runs this as its review phase (skippable for prototypes).
- **[tdd](../tdd/)** — the build loop that precedes review; refactoring flagged here happens after green.
- **`mr-review`** / **`mr-gatekeep`** — the post-MR counterparts (private skills) for a posted GitLab MR.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (two-axis process, smell baseline, parallel sub-agents)
