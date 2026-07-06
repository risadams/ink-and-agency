# Issue Triage

Read-only triage of a Jira ticket or free-form bug description. The skill maps the suspected code area, pulls related signals from git/MRs/Confluence, hypothesizes ranked root causes via a multi-persona council, and produces a structured triage report — without touching any ticket field, code file, or merge request along the way.

## Why this exists

Bug triage burns an outsized share of a developer's day: switching between a Jira tab, a code editor, the git log, and three Confluence pages just to form a hypothesis worth typing into a comment. This skill compresses that scavenger hunt into a single chat turn, and it surfaces the *evidence chain* alongside each hypothesis so the next person doesn't have to redo the lookup. The strict read-only default means you can run it speculatively — even on tickets you weren't planning to own — without leaving fingerprints.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "triage PROJ-1234"
  - "triage this"
  - "what's causing this bug"
  - "help me find the root cause"
- Running the slash command: `/issue-triage`

You can also pass a free-form description instead of a ticket key — the skill will still work, but Phase 7 (publishing the report as a Jira comment) is skipped.

## What it does

The skill takes either a Jira ticket key matching `[A-Z][A-Z0-9]+-\d+` or a free-form bug description, then runs a 7-phase workflow that ends in a markdown triage report. It uses the Atlassian, GitLab, and codebase-explain skills to gather signals, then delegates root-cause hypothesis generation to clarity-council with a fixed persona panel. It does **not** propose code edits, modify ticket fields, or change MR state.

### Inputs

- **`ticket key` OR `free-form description`** — string, required. One or the other.

### Outputs

- A markdown **Triage Report** rendered in chat, with: symptom, suspected area, ranked root-cause hypotheses (each with falsifiable prediction + first diagnostic step + proposed solution path), signals consulted, open questions, and a recommended next step.
- *Optional*: the same report posted as a Jira comment (Phase 7, requires explicit opt-in).

### External systems used

- Jira (read; write only on opt-in for the comment)
- Confluence (read)
- GitLab (read — recent commits + MRs touching suspected files)
- Local git + filesystem (read)

## How to use it

A typical session looks like this:

```text
You: triage WEB-7890

Skill: [Phase 1] Pulling WEB-7890 from Jira...
       Symptom: checkout button silently fails on Safari 17 only.
       Reporter notes: started after the 2026-04-22 deploy.
       No prior triage comments. Confirmed?

You: confirmed.

Skill: [Phase 2-3] Mapping suspected area + pulling signals.
       - Stack frame in description points at `src/checkout/cart-button.tsx`
       - !4521 (merged 2026-04-22) refactored that component
       - One sibling ticket WEB-7634 closed 2 weeks ago — different cause.

       [Phase 5] Council ran. Top hypotheses:

       ## Triage Report: WEB-7890
       ### Hypotheses (ranked)
       1. Safari-only event-bubbling regression in !4521 — high
          Predict: button works in Chrome at the same commit, breaks at Safari 17.
       ...

       Publish this report as a comment on WEB-7890? (No / Yes)

You: no.

Skill: Report kept local. No comment posted.
```

## Getting the most out of it

- **Run it before opening the file.** The whole point is to get a hypothesis-shaped map *before* you start reading code. Reading first defeats the purpose — you'll just confirm whatever you noticed first.
- **Provide a stack trace if you have one.** A single stack frame collapses Phase 2 from "guess the module" to "walk this trace." If the ticket lacks one and you have it locally, paste it into the chat.
- **Don't skip Phase 4 just because you're impatient.** When the skill asks clarifying questions, the answers usually move the top hypothesis up or down a band. Skipping them gets you a polished-looking report built on quicksand.
- **Treat the falsifiable predictions as a script.** Each ranked hypothesis comes with "if this is the cause, then X should reproduce." That's your diagnostic test — actually run it before committing to a fix branch.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Propose a code fix.** The output is a hypothesis chain plus a first diagnostic step. If you want the skill to actually change the code, hand the report to a separate implementation pass.
- ❌ **Auto-publish the comment.** Phase 7 always requires an explicit yes/no. Past sessions don't carry forward — every run prompts again.
- ❌ **Triage tickets in bulk.** Use one ticket per invocation. The signal-gathering is too heavy to do well across many tickets in one pass; for sweep work, see [issue-dup-find](../issue-dup-find/) instead.
- ❌ **Replace incident response.** This is a hypothesis-shaping tool, not an on-call runbook. If the bug is paging, fix first, triage later.

## Examples

### Example: Production crash after recent deploy

```text
You: triage PROJ-1234

Skill: ...gathered context...

       ## Triage Report: PROJ-1234

       ### Symptom
       NullReferenceException on every login since 2026-05-09.

       ### Hypotheses (ranked)
       1. Auth middleware regression in !892 — high
          Why this fits: !892 (merged 2026-05-09 16:14) refactored
          `auth/middleware.go`; the stack trace bottoms out in that file.
          Falsifiable: rolling back to commit before !892 should fix it.
          First step: `git revert` !892 in a scratch branch and deploy
          to staging.

       2. Session token shape change — medium
          Why this fits: ABC-456 (closed 2 weeks ago) renamed a JWT claim;
          old sessions may not deserialize.
          Falsifiable: cleared cookies should bypass; if so, this is it.
          First step: ask the reporter to clear cookies and retry.
```

The two hypotheses are scoped narrowly enough that each can be tested in under 10 minutes — that's the goal. A "could be anything" report is a failed report.

### Example: Free-form description, no ticket

```text
You: triage this — search returns no results when query has trailing
     whitespace, but trims fine in the UI

Skill: [No ticket — Phase 7 will be skipped.]
       Restating: search backend ignores trimmed input despite UI trim?
       Anything missing?

You: only happens in production, dev is fine.

Skill: ...maps `internal/search/handler.go`, finds no recent commits...
       ## Triage Report: search trim mismatch
       1. Edge proxy strips whitespace in dev only — high
       ...
```

When there's no ticket key, the report is delivered to chat only and never offered as a comment.

## Internals

The skill follows a 7-phase workflow. Phases 1-3 gather context, Phase 4 closes information gaps, Phase 5 generates hypotheses, Phase 6 renders the report, and Phase 7 optionally posts it back to Jira:

1. **Gather issue context** — pulls the ticket, comments, changelog, and remote links; or restructures a free-form description into Symptom/When/Expected vs Actual/Environment.
2. **Map suspected code area** — invokes `/codebase-explain` against the most likely module(s); walks any stack trace top-down.
3. **Pull related signals** — recent commits, recent MRs touching suspected files, linked Confluence pages, and sibling Jira tickets matching the error keyword.
4. **Clarify gaps with the user** — invokes `/grill-me` for material gaps only; skipped when the hypothesis space is already narrow.
5. **Hypothesize root causes** — invokes `/clarity-council` with `senior-architect`, `senior-developer`, `qa-engineer`, and `devils-advocate` personas. The first three propose; the last challenges anything that fits too neatly.
6. **Produce the triage report** — single markdown block; ranked hypotheses with falsifiable predictions and first diagnostic steps.
7. **Optional: publish as Jira comment** — only with explicit yes/no opt-in, only if input was a Jira ticket key. The Jira wiki-markup conversion + AI disclaimer panel come from [jira-comment-template.md](jira-comment-template.md).

Key constraints:

- **Read-only across all systems** — exactly one permitted write: `jira_add_comment` in Phase 7, post-opt-in.
- **Time-boxed signal gathering** — five recent commits beats fifty; one close sibling ticket beats ten weak matches.
- **Disclaimer is mandatory** when a comment is posted; it cannot be edited or omitted.

## FAQ

**Q: Why does it always ask me before posting the comment, even after I said yes last session?**
A: Posting is irreversible and visible to everyone watching the ticket. The opt-in resets every run on purpose — past consent doesn't generalize.

**Q: Can I skip the council session and go straight to the report?**
A: Not from the skill itself. The council is what turns "list of signals" into "ranked hypotheses with predictions" — without it the output collapses to a context dump.

**Q: What happens when the suspected code area is genuinely unclear?**
A: Phase 2 stops and asks you which subsystem you suspect rather than guessing. Guessing wastes context budget on the wrong module.

**Q: Does it work on tickets in projects I don't own?**
A: Yes — anywhere your Jira read access reaches. Read-only by default means you can triage broadly without coordinating with the owning team.

**Q: How long does a typical run take?**
A: Two to five minutes for a Jira ticket with rich context; under two minutes for a free-form description with a stack trace included.

## Related skills

- **[issue-dup-find](../issue-dup-find/)** — when you suspect the bug has already been reported, run this first. Triage assumes the ticket is novel.
- **[issue-feature-breakdown](../issue-feature-breakdown/)** — for *features* (not bugs), use the breakdown skill instead. It surfaces ambiguity rather than ranking causes.
- **[codebase-explain](../codebase-explain/)** — Phase 2 invokes this directly. Run it standalone when you just want the module map without the rest of the triage flow.
- **[clarity-council](../clarity-council/)** — Phase 5 invokes this. Worth knowing standalone if you want to apply the same persona panel to a non-bug decision.
- **[grill-me](../grill-me/)** — Phase 4 invokes this when gaps are material. Useful standalone for stress-testing any plan.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
- **[jira-comment-template.md](jira-comment-template.md)** — Jira wiki-markup template and mandatory AI disclaimer panel used in Phase 7
