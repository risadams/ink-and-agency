# Issue Feature Breakdown

Read-only analysis of a Jira feature ticket. The skill gathers full context from Jira and Confluence, follows linked tickets, runs a multi-persona council to surface gaps and ambiguities, walks the user through clarifying questions one at a time, and produces an actionable breakdown plan — without creating, updating, or transitioning any Jira ticket along the way.

## Why this exists

Most feature tickets arrive under-specified. The acceptance criteria say what but not why; the linked design doc was last touched two months ago; the upstream dependency is implicit in a Slack thread that nobody re-pasted into the ticket. Engineers either burn a day reconstructing the picture or start coding from a partial understanding and produce something that ships and then needs rework. This skill does the reconstruction in one chat turn, then forces the implicit ambiguities into the open *before* any code is written.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "break down this feature"
  - "analyze this ticket"
  - "feature breakdown for PROJ-1234"
  - Provide a Jira ticket key in the chat
- Running the slash command: `/issue-feature-breakdown PROJ-1234`

## What it does

The skill takes a Jira ticket key, walks all linked tickets and Confluence references, invokes clarity-council with five personas to surface gaps, walks you through unresolved questions interactively, then produces a structured breakdown plan. Each unit of work in the breakdown lists what, why, acceptance criteria, dependencies, and risk/complexity flags. It does **not** modify any ticket, create child issues, or write to disk unless asked.

### Inputs

- **`ticket_key`** — string, required. Format: `[A-Z][A-Z0-9]+-\d+` (e.g., `PROJ-1234`).

### Outputs

- A **Context Summary** rendered in chat after Phase 1 (the user can interrupt and add more context).
- A **Council Synthesis** after Phase 2 surfacing agreements, conflicts, risks, and per-persona open questions.
- A **Breakdown Plan** after Phase 4 in the format defined by [BREAKDOWN-FORMAT.md](BREAKDOWN-FORMAT.md).

### External systems used

- Jira (read only — `jira_get_issue`, `jira_get_comments`, `jira_get_remote_links`, `jira_get_epic_issues`)
- Confluence (read only — `confluence_search`, `confluence_get_page`)

## How to use it

A typical session looks like this:

```text
You: break down WEB-7000

Skill: [Phase 1] Pulled WEB-7000 + 6 linked tickets + 2 Confluence pages.

       ## Context Summary
       Root: WEB-7000 — "Add Apple Pay to mobile checkout"
       Type: Epic · 4 child stories · 2 blocked-by tickets in payments-api
       Confluence: ENG/Mobile-Payments-Q2 (last edited 2026-04-30)
       Acceptance criteria: 3 listed; 2 are vague ("works on iOS").

       Anything I should add before the council reviews?

You: payments-api team confirmed they'll merge !4521 by 2026-05-15.

Skill: Noted. [Phase 2] Council deliberating...
       Senior Architect: "Apple Pay sandbox testing in CI is unresolved."
       QA: "Acceptance criterion 2 ('works on iOS') needs version range."
       Devil's Advocate: "Why now? Q2 already has 3 in-flight payment features."

       [Phase 3] I have 4 open questions. Asking one at a time.

       Q1 (from QA): "Works on iOS" — minimum supported version?
You: iOS 16 and above.
       ...
       [Phase 4] Producing breakdown plan...
```

## Getting the most out of it

- **Bring context to Phase 1.** The skill reads what's in Jira/Confluence, but you usually know one or two things that aren't written down. Drop them in when prompted at the end of Phase 1 — the council will use them.
- **Don't shortcut Phase 3.** When the skill asks a clarifying question, every honest answer eliminates a downstream surprise. Skipping questions to get to the breakdown faster trades hours now for days later.
- **Treat the breakdown as a starting point.** The output is a plan, not a contract. Reorder, merge, or split items based on team capacity. The skill is good at structure; you're better at sequencing.
- **Use it before estimating.** Pair with [issue-estimate-sp](../issue-estimate-sp/): break down first, then estimate each piece. Estimating an undecomposed feature is how 21-point tickets are born.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Create child tickets in Jira.** The breakdown is a markdown plan. Creating the actual child issues is your call to make manually after team agreement.
- ❌ **Skip the clarification phase.** Phase 3 exists because gaps that look small in a council synthesis tend to be load-bearing. Don't run the skill, ignore the questions, and act on the breakdown — the breakdown is built on the answers.
- ❌ **Use it on bug tickets.** This skill assumes a feature with scope to decompose. For bugs, use [issue-triage](../issue-triage/) instead — it ranks root causes rather than producing a breakdown.
- ❌ **Replace the design doc.** A breakdown plan is implementation-shaped. The design doc still needs to exist; the breakdown gets you to a state where the design doc's gaps are visible.

## Examples

### Example: A well-specified ticket

```text
You: break down ABC-1042

Skill: [Phase 1] Pulled ABC-1042. Acceptance criteria all concrete.
       Linked tickets: 0. Confluence: 1 design doc, current.

       ## Context Summary
       This ticket is well-specified. No gaps surfaced in Phase 1.
       Anything to add?

You: nope.

Skill: [Phase 2] Council found 1 risk + 0 conflicts.
       [Phase 3] 1 open question:

       Q1 (from Senior Architect): "Does the rate-limit budget on the upstream
       service accommodate the projected volume?"

You: yes — checked with the platform team yesterday, 3x headroom.

Skill: [Phase 4] Breakdown:
       1. Add API client wrapper (auth-service module) — 3 SP — no deps.
       2. Wire rate-limited queue (notifications-worker) — 5 SP — depends on #1.
       3. Backfill metrics dashboard (existing Grafana) — 2 SP — no deps.
       Total: 10 SP across 3 work items.
```

When a ticket arrives clean, the skill moves quickly. The value-add is verifying nothing was assumed.

### Example: Ambiguous ticket exposes scope creep

```text
You: break down WEB-7000

Skill: ...
       [Phase 2 council synthesis]
       Devil's Advocate raised: "The ticket asks for 'Apple Pay' but the
       Confluence page describes 'all mobile wallet providers including
       Google Pay'. Which scope is canonical?"

       Q1: Apple Pay only, or all mobile wallets?

You: oh — actually, leadership wants Google Pay first.

Skill: Re-running breakdown with revised scope. The Apple Pay items
       become a follow-on epic.
```

The clarification often reveals a misalignment that would otherwise surface mid-implementation.

## Internals

The skill follows a 4-phase workflow with explicit user gates at each transition:

1. **Gather context** — pulls the root ticket, comments, all linked tickets (issuelinks), parent epic + sibling stories if applicable, and Confluence pages reachable via remote links and CQL search. Presents a summary; gates on user-supplied additions.
2. **Council analysis** — invokes `/clarity-council` with `senior-architect`, `product-owner`, `tech-lead`, `qa-engineer`, `devils-advocate`. Surfaces agreements, conflicts, and per-persona questions.
3. **Clarify** — walks open questions one at a time. For each: which persona raised it, why it matters, recommended answer if context suggests one, then waits for user input.
4. **Breakdown plan** — produces a structured plan per [BREAKDOWN-FORMAT.md](BREAKDOWN-FORMAT.md). Each item has what / why / acceptance criteria / dependencies / risk-or-complexity flag. Gates on user approval; iterates if needed.

Key constraints:

- **Read-only across Jira and Confluence.** No `jira_create_issue`, `jira_update_issue`, `jira_transition_issue`, or any write op.
- **No filesystem writes by default.** The breakdown stays in chat unless the user asks to save it.
- **One question at a time in Phase 3.** Asking five at once produces noise; one at a time produces decisions.

## FAQ

**Q: Can I run it on an epic that has 30 child stories?**
A: Yes, but the context fetch will be expensive. The skill caps Confluence fetches at the most relevant pages and walks linked tickets one hop deep — it doesn't recurse infinitely.

**Q: What if I don't know the answers to the Phase 3 questions?**
A: Mark them unresolved. The breakdown will include a "Decisions needed before implementation" section listing them. You can return after gathering answers.

**Q: Does it write the breakdown back to the Jira ticket?**
A: No. Read-only by default. Paste it as a comment yourself or save it to a planning document.

**Q: How is this different from issue-triage?**
A: Triage ranks root causes for a bug. Breakdown decomposes scope for a feature. Both are read-only, but the analytical mode is different.

## Related skills

- **[issue-estimate-sp](../issue-estimate-sp/)** — pair with this. Break down a feature first, then estimate each piece.
- **[issue-triage](../issue-triage/)** — for bugs, not features. Ranks hypotheses rather than decomposing scope.
- **[clarity-council](../clarity-council/)** — Phase 2 invokes this. Use standalone when you want the same panel for a non-ticket decision.
- **[grill-me](../grill-me/)** — Phase 3 borrows the one-question-at-a-time pattern. Use grill-me when there's no Jira ticket to anchor against.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
- **[BREAKDOWN-FORMAT.md](BREAKDOWN-FORMAT.md)** — Output template for the Phase 4 breakdown plan
