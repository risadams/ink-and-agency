# Flows

Most skills in this pack aren't islands — they chain. A **flow** is a path through several skills toward one outcome. This document names the flows so the pack reads as designed, not piled. The [`which-skill`](which-skill/) router uses it to map "I want to do X" onto the right entry point.

Skills below are written `/skill-name`; invoke them by name (Codex: `$skill-name`). A skill can appear in more than one flow.

---

## Sprint flow — run a Scrum sprint

The ceremony chain, start to close. Most run per-sprint or per-day.

```text
sprint-snapshot ──> sprint-plan ──> daily-standup-prep ──> sprint-sos-report ──> sprint-review
   (capture board)   (plan scope)    (daily, w/ burndown)   (weekly, 2 snapshots)  (close-out)
```

- **`/sprint-snapshot`** — point-in-time capture of the board (canvas + markdown + JSONL trend). The data source every other sprint skill reads.
- **`/sprint-plan`** — turn the start-of-sprint canvas into a planning report (capacity vs commitment, carry-over, risks).
- **`/daily-standup-prep`** — per-team daily report with sprint-pulse burndown; reads the snapshot trend.
- **`/sprint-sos-report`** — weekly scrum-of-scrums comparing two snapshots.
- **`/sprint-review`** — end-of-sprint stakeholder report comparing `start.canvas` to `end.canvas`.

**On-ramp:** **`/good-morning`** runs `sprint-snapshot` → `daily-standup-prep` → `daily-briefing` in one command — the daily entry point onto this flow.

## Issue flow — a Jira ticket, cradle to release

```text
issue-triage ──> issue-feature-breakdown ──> issue-estimate-sp ──> [build] ──> issue-draft-release-notes
 (root-cause /    (gaps, context, plan)        (story points)                    (customer-facing note)
  or classify)
```

Supporting, any time: **`/issue-dup-find`** (dedupe a project), **`/issue-suggest-component`** (tag/categorize), **`/issue-create`** and **`/issue-backlog-prioritize`** (private skills, if installed).

## Idea flow — from spark to committed decision

```text
idea-generate ──> idea-choice ──> idea-decision-maker
 (diverge+harden)  (pros/cons,      (force the pick when
                    Impact×Conf)     stuck)
```

- **`/idea-generate`** — generate and stress-test options from a loose topic (council + grill).
- **`/idea-choice`** — deliberate pros/cons across one or more options; produces a written record.
- **`/idea-decision-maker`** — force a fast binary pick to defeat analysis paralysis (no written artifact).

**Adjacent:** **`/interest-capture`** parks an idea you don't want to develop now; **`/grill-me`** hardens a single plan without generating options.

## Plan-a-big-effort flow — chart the fog

```text
grill-with-docs / grill-me ──> work-plan ──> plan-to-spec ──> plan-to-tickets ──> implement ──> mr-review
 (sharpen the idea)             (chart          (local spec.md,   (local tasks.md,   (build, per     (post-MR
                                 decisions)      publish opt-in)    push opt-in)       ticket)         gate)
```

- **`/grill-with-docs`** — sharpen an idea by interview *against the codebase*, leaving a paper trail (CONTEXT.md, ADRs). Use `/grill-me` when there's no codebase.
- **`/work-plan`** — chart a large effort as a map of decision tickets; resolve one decision per session. Fires **`/research`** subagents for research-type tickets and **`/prototype`** for prototype-type ones.
- **`/prototype`** — settle a design question with throwaway code before committing to a build: a hand-driven TUI over a pure logic module (state models), or N structurally different UI variants behind one switcher. Answers the question, then gets thrown away — only the decision moves forward.
- **`/plan-to-spec`** — once the design is settled, synthesize the conversation into a spec (PRD) staged as a local `spec.md` (spec-kit style). No interview — just write-up. Publishing to Confluence is opt-in, on request.
- **`/plan-to-tickets`** — break the spec (or plan/conversation) into a local numbered `tasks.md` (tracer-bullet vertical slices, explicit dependencies, `[P]` markers). Pushing to Jira as tickets with native "Blocks" links is opt-in, on request.
- **`/implement`** — build one ticket through a **tunable pipeline** (test-first → verify → review → track), every phase skippable. Auto-detects a preset from `prototype` to `full`. Drives **`/tdd`** and **`/code-review`** internally.

## Build sub-loop — inside `/implement`

`implement` orchestrates two primitives you can also invoke directly:

```text
implement ──┬──> tdd          (red → green, one vertical slice at a time)
            └──> code-review  (two-axis: Standards + Spec, on the working diff)
```

- **`/tdd`** — the red→green loop and what makes a test worth keeping (seams, anti-patterns). On its own when you just want to build a behaviour test-first.
- **`/code-review`** — two-axis review of the *working diff* (pre-MR). Distinct from **`/mr-review`** / **`/mr-gatekeep`**, which gate a *posted* GitLab MR.

**Tuning:** throwaway work runs `implement` with test-first/review/track all off (its `prototype` *preset* — not the **`/prototype`** skill, which answers a design question instead of building the thing); a CCB-gated feature runs the full pipeline into an MR. The pipeline is the same; the phases vary.

## Codebase-understanding flow

```text
codebase-explain ──> codebase-churn ──> codebase-improve-architecture
 (map an area)        (find unstable      (find deepening / refactor
                       hotspots)           opportunities)
```

Plus **`/debug`** (six-phase diagnosis loop for a specific bug) and **`/codebase-plan-refactor`** (incremental refactor RFC → GitHub issue).

## Merge / branch flow

```text
branch-rebase ──> branch-resolve-conflicts        mr-draft ──> mr-review ──> mr-gatekeep
 (rebase onto      (complex conflicts)             (private skills — describe / review / gate an MR)
  upstream)
```

## Writing flow — raw material to finished piece

```text
writing-fragments ──> writing-shape / writing-beats ──> writing-draft-article ──> writing-humanize
 (mine raw nuggets)    (impose structure)                (finish the piece)         (strip AI tells)
```

Short-form helpers: **`/writing-cold-open`** (first sentence of a message), **`/writing-tone-check`** (pre-send landing check), **`/writing-social-script`** / **`/writing-apology-calibrator`** (specific messages).

## Daily-operations flow — personal

```text
good-morning ──┬──> (sprint flow, above)
               ├──> daily-briefing        (24h email + calendar recap, focus blocks)
               └──> daily-standup-prep     (team standup)
```

## Executive-function support — situational, not a chain

These fire when a specific state hits, not in sequence:

| When you feel… | Reach for |
| :--- | :--- |
| Can't start a known task | **`/task-initiation`** |
| Eleven things and can't pick one | **`/overwhelm-triage`** |
| Have to stop mid-flow, right now | **`/hyperfocus-exit`** |
| Overcommitted / heading to burnout | **`/energy-budget`** |
| "How long will this really take?" | **`/time-reality-check`** |
| Lost the thread after a deep session | **`/hyperfocus-recovery`** |
| A message stung — is it criticism? | **`/rejection-sensitivity-check`** |
| Post-meeting overload | **`/meeting-decompression`** |
| "What does this message actually mean?" | **`/break-it-down`** |
| An idea is derailing today's focus | **`/interest-capture`** |

Two of them are **modes, not moments** — they reshape every response for the rest of the session rather than answering one situation: **`/i-have-adhd`** (next action first, state restated each turn, no preamble) and **`/i-am-autistic`** (direct, modality-labeled, literal, quantified uncertainty). They compose; resolve conflicts safety → explicitness → brevity. Make either permanent with a pointer line in `CLAUDE.md`; see [Making it permanent](exec-function/i-have-adhd/README.md#making-it-permanent).

One pair is a **chain**: `hyperfocus-exit` writes the park file and the `PARKED` breadcrumb that `hyperfocus-recovery` reads back.

```text
hyperfocus-exit ──> .ink-and-agency/park/<ts>.md ──> hyperfocus-recovery ──> task-initiation
   (leaving)              + PARKED breadcrumb            (coming back)         (if still stuck)
```

## Vocabulary layers — run underneath other flows

Not entry points; other skills invoke them.

- **`/clarity-council`** — multi-persona consultation; the engine behind `idea-generate`, sprint pulses, many others.
- **`/grill-me`**, **`/grill-with-docs`** — the interview primitive.
- **`/research`** — background primary-source investigation; fired by `work-plan`.
- **`/handoff`** — compact a session for a fresh agent to pick up (crosses between any flows).
- **The `obsidian-*` skills** — vault read/write; invoked by anything that persists notes.

---

## Roadmap

The **idea → ship** flow is now end-to-end: `grill → work-plan → plan-to-spec → plan-to-tickets → implement (tdd + code-review) → mr-review`. It stages locally first (spec-kit `spec.md` / `tasks.md`) and treats Confluence/Jira/GitLab as opt-in publish targets, with `/implement`'s tunable phases spanning throwaway prototypes to CCB-gated features.
