# Plan to Spec

Synthesize a settled design discussion into a **spec (PRD)** and stage it as a **local file** — no interview, just write-up. The step between thinking (grilling, work-planning) and doing (tickets): it captures what you've already decided in a structured, extensive spec. Publishing to Confluence is opt-in and only happens on request, after you confirm where.

## Why this exists

The moment a design is settled in conversation is exactly when it's most likely to evaporate — the context window fills, the session ends, and the decisions live only in a transcript nobody re-reads. A spec fixes the decisions in one durable place. This skill deliberately does **not** interview you (that's `/grill-with-docs`'s job) — it assumes the thinking is done and turns it into a document, grounded in the codebase and the project's domain vocabulary. It writes **locally first** so the spec is yours before any remote system sees it; pushing to Confluence is a separate, explicit step.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "write this up as a spec" / "turn this into a PRD"
  - "spec this out"
  - "stage a spec for what we discussed"
- Running the slash command: `/plan-to-spec`

> **Note:** `disable-model-invocation: true` — user-invoked only. Writing a spec is a deliberate act, not something to auto-trigger mid-discussion.

## What it does

Resolves a **staging location** you control (argument → memory default → ask), explores the repo to ground the spec, sketches the **test seams** (fewest and highest possible, confirmed with you), then writes a spec to a fixed template into `<staging>/NNN-<feature-slug>/spec.md` — spec-kit style, one numbered feature folder per spec. That's where it stops by default. If you later ask to publish, it confirms the Confluence destination first, creates the page, cross-links a source Jira ticket, and records the published URL back into the local file.

### Inputs

- **The current conversation** — a settled design, grilling result, or `/work-plan` outcome.
- **A staging location** — a path you pass, the `reference_plan_staging_dir.md` default, or answered when asked.
- **Optional: a source Jira ticket** — cross-linked *if* you later publish to Confluence.

### Outputs

- **A local `spec.md`** at `<staging>/NNN-<feature-slug>/spec.md` — the source of truth.
- **On request only:** a Confluence page created from it, a remote link from a source Jira ticket, and a `> Published: <url>` line written back into the local file.

### External systems used

- **Local filesystem** — the default and only guaranteed write.
- **Confluence** (`confluence_create_page`) / **Jira** (`jira_add_remote_link`) — opt-in, on request, after confirming the destination. Keys from `reference_confluence_default_space.md` / `reference_jira_default_project.md`.

## How to use it

```text
You: /plan-to-spec   (after a grilling session on a new export feature)

Skill: Staging dir? (default from memory: ./specs/)   [you: yes]
       Test seams: the existing ExportService integration test is the
       highest seam — one seam, no new ones. Match your expectations?
You: yes
Skill: Wrote ./specs/003-csv-export-v2/spec.md. Staged — ready for
       /plan-to-tickets. (Say "publish to Confluence" if you want a remote copy.)

You: publish it to Confluence
Skill: Space PP, under the "Specs" parent — confirm?   [you: yes]
       Published "CSV Export v2 — Spec"; linked from PRJ-1481; recorded the
       URL back into spec.md.
```

## Getting the most out of it

- **Do the thinking first.** This skill synthesizes; it doesn't sharpen. Run `/grill-with-docs` or `/work-plan` if the design isn't settled.
- **Set a staging default once.** Recording `reference_plan_staging_dir.md` means it stops asking where to write — the numbered folders then accrue in one predictable place.
- **Check the seams.** The seam sketch is the one point it pauses for you — a wrong seam here propagates into the tasks and the tests.
- **Publish deliberately.** The local spec is the source of truth; push to Confluence only when you want a shareable copy, and the local file records the link so the two stay reconciled.

## It's working if

- It starts writing rather than opening a fresh round of questions — the thinking was supposed to be done upstream.
- It puts the test seams to you before it writes, and proposes as few as it can get away with.
- It comes back in your project's nouns, not generic product-management boilerplate.
- Every decision in it is one you can remember making. Nothing was invented to fill a section.
- The out-of-scope section has real things in it — what you refused is usually the most useful part of the page.
- It tells you when the work is small enough not to need a spec at all.

## Anti-patterns

- ❌ **Publishing to Confluence by default.** Local-first is the whole point — a remote write happens only when you ask and confirm the destination.
- ❌ **Interviewing the user.** If you're asking design questions, the thinking isn't done — that's `/grill-with-docs`, not this.
- ❌ **Inlining file paths or code.** They rot. Decisions are described, not pasted (bar the prototype-shape exception).
- ❌ **Writing to a location the user didn't choose.** Staging is argument → memory default → ask; it doesn't guess a path silently.

## Related skills

- **[grill-with-docs](../grill-with-docs/)** / **[work-plan](../work-plan/)** — the thinking steps that precede this write-up.
- **[plan-to-tickets](../plan-to-tickets/)** — the next step: breaks this spec into a local numbered task list beside it.
- **[issue-feature-breakdown](../issue-feature-breakdown/)** — the read-only counterpart when you want analysis of an *existing* Jira ticket rather than a fresh spec.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (staging resolution, synthesis process, spec template, opt-in publish)
