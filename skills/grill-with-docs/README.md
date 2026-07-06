# Grill With Docs

A grilling session that stress-tests your plan against the project's existing domain model and documented decisions. The skill challenges your terminology against the project's `CONTEXT.md`, sharpens fuzzy terms inline, cross-references claims against the codebase, and updates `CONTEXT.md` and `docs/adr/` artifacts as decisions crystallize — turning the grilling itself into documentation.

## Why this exists

A plan that uses domain terms imprecisely produces an implementation that does too. A decision that gets re-litigated every six months because no one wrote down why it was made the first time is one of the great recurring costs of a long-running codebase. This skill solves both: it grills you with the project's existing vocabulary loaded as context, calls out conflicts between what you say and what's documented, and writes the resolved decisions back into `CONTEXT.md` (terms) and `docs/adr/` (architectural decisions worth recording) as they emerge — not after the meeting, when nobody remembers.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "grill me on this design and update the docs"
  - "stress-test this against our domain model"
  - "challenge my plan against CONTEXT.md"
  - "grill with docs"
- Running the slash command: `/grill-with-docs`

## What it does

The skill walks the user through their plan one question at a time (same discipline as [grill-me](../grill-me/)), but adds three behaviors: (1) it loads the project's `CONTEXT.md` and `docs/adr/` as context first; (2) it challenges terminology that conflicts with the documented glossary; (3) it updates `CONTEXT.md` inline when terms are sharpened, and offers ADRs when a decision meets a strict three-criteria bar (hard to reverse, surprising without context, result of a real tradeoff). Files are created lazily — only when there's something to write.

### Inputs

- **Plan or design description** — free-form.
- **Optional `CONTEXT.md`** — read first if present.
- **Optional `docs/adr/` directory** — read first if present.

### Outputs

- A series of question/answer exchanges (one at a time).
- *Inline side effects*: appended terms to `CONTEXT.md`, drafted ADRs in `docs/adr/`.

### External systems used

- Local filesystem (read codebase + docs; write `CONTEXT.md` and `docs/adr/` files inline)

## How to use it

A typical session looks like this:

```text
You: grill me on letting customers cancel partial orders.

Skill: (Reading CONTEXT.md and docs/adr/...)
       Found: CONTEXT.md defines "Cancellation" as the full reversal of
       an Order before fulfillment. ADR-0007 says "we explicitly chose
       not to support partial cancellation in v1 because it complicates
       the inventory release logic."

       Q1: Your plan uses "cancel partial orders" but our glossary's
       Cancellation is full-only. Are you proposing a new concept
       (e.g., "Partial Reversal"), or a change to what Cancellation means?

You: a new concept — partial reversal.

Skill: Good — that keeps Cancellation stable. I'll add Partial Reversal
       to CONTEXT.md when we sharpen it. Q2: Does Partial Reversal
       happen pre-fulfillment, post-fulfillment, or both? My recommendation:
       both, but with different mechanisms (pre-fulfillment releases
       inventory; post-fulfillment refunds money and triggers a return).

You: both.

Skill: Q3: Does this contradict ADR-0007? My read: not necessarily —
       ADR-0007 was about Cancellation specifically, not about partial
       handling in general. But it's close enough that I'd write a new
       ADR (ADR-0019: Partial Reversal pattern) to head off "didn't we
       say no to this?" in 6 months. Sound right?

You: yes — and add the term.

Skill: [Updates CONTEXT.md with the Partial Reversal definition]
       [Drafts docs/adr/0019-partial-reversal.md with the rationale]
       Continuing...
```

## Getting the most out of it

- **Have a CONTEXT.md before running.** Without one, the skill starts from scratch — fine, but slower. Even a 10-line glossary makes the grilling much sharper from question one.
- **Argue with the documented terms.** When the skill says "your glossary defines X as Y," that's a checkpoint, not a constraint. If your new use of the term is genuinely better, update the glossary. The skill will help.
- **Accept the ADR offer when it appears.** ADRs are offered sparingly — only when the decision meets all three criteria (hard to reverse, surprising without context, real tradeoff). When you see the offer, the documentation is worth the 5 minutes.
- **Cross-reference with code is free.** When the skill says "your code does X but you just said Y — which is right?", treat it as a gift. Better to surface that contradiction now than in code review.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Update CONTEXT.md without your confirmation.** The skill drafts the addition and shows it; you confirm. Same for ADRs.
- ❌ **Couple CONTEXT.md to implementation details.** The glossary is for terms meaningful to domain experts. "PostgreSQL connection pool" doesn't go in CONTEXT.md — "Order" does.
- ❌ **Offer ADRs for trivial decisions.** All three criteria must hold. Offering an ADR for "we used kebab-case for filenames" is noise; the skill skips it.
- ❌ **Run on a codebase with no docs.** Technically you can, but the skill's value compounds with existing docs. For greenfield, draft a starter CONTEXT.md first (the skill will help).

## Examples

### Example: Sharpening a fuzzy term

```text
You: ...the customer should be notified when their account is flagged.

Skill: Q: You're using "account" — do you mean Customer or User? Those
       are different entities in this codebase (see CONTEXT.md:
       Customer is the human; User is the auth identity, possibly
       multiple per Customer). My recommendation: Customer, since
       notification is human-facing.

You: yes — Customer.

Skill: Updating CONTEXT.md to add a "Customer Notification" entry:

       ## Customer Notification
       A message sent to a Customer through their preferred channel
       (email, SMS) about an event affecting their account holder
       state. Distinct from User Notification (auth-scoped events
       like new device login).

       Add this? (Yes / Edit / Skip)

You: yes.

Skill: [Appends to CONTEXT.md]
       Continuing...
```

The term gets defined in real-time, not in a follow-up doc that nobody writes.

### Example: ADR offered (and accepted)

```text
You: ...so we'll use eventual consistency between the order service
     and the inventory service, with up to 30s of staleness.

Skill: This decision meets all three ADR criteria:
       1. Hard to reverse — once inventory clients depend on staleness,
          tightening to strong consistency requires fanning out to all
          clients.
       2. Surprising without context — a future engineer sees the lag
          and wonders "is this a bug or a design choice?"
       3. Real tradeoff — strong consistency would require a 2PC or
          distributed lock; you're trading that complexity for staleness.

       Want me to draft ADR-0023: Eventual Consistency Between Order
       and Inventory? It'll record the staleness bound (30s), the
       alternative considered (2PC), and the rationale (operational
       simplicity).

You: yes.

Skill: [Drafts docs/adr/0023-eventual-consistency-order-inventory.md]
       Linked to from ADR-0007 and tagged in CONTEXT.md.
       Continuing...
```

The ADR becomes a permanent answer to "why is this lag here?" — saving an afternoon for somebody six months from now.

## Internals

The skill follows the [grill-me](../grill-me/) discipline (one question at a time, recommendation per question, codebase exploration over asking when possible) plus three additions:

1. **Load docs first** — read `CONTEXT.md` and `docs/adr/` (or per-context versions if `CONTEXT-MAP.md` exists, indicating multiple bounded contexts in the repo).
2. **Challenge against the glossary** — when the user uses a term that conflicts with `CONTEXT.md`, call it out immediately.
3. **Sharpen fuzzy language** — when the user uses vague or overloaded terms, propose a precise canonical term.
4. **Cross-reference with code** — when the user states how something works, verify against the code; surface contradictions.
5. **Update CONTEXT.md inline** — when a term is resolved, append it (with user confirmation) using the format in [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md). Don't batch.
6. **Offer ADRs sparingly** — only when all three criteria hold (hard to reverse, surprising without context, real tradeoff). Use the format in [ADR-FORMAT.md](ADR-FORMAT.md).

File-creation rules:

- **Create files lazily.** No `CONTEXT.md` exists? Create it when the first term is resolved. No `docs/adr/`? Create it when the first ADR is needed.
- **Never couple `CONTEXT.md` to implementation details.** Domain-meaningful terms only.

Repo structure conventions:

- **Single context**: `CONTEXT.md` at root, `docs/adr/` at root.
- **Multiple contexts**: `CONTEXT-MAP.md` at root pointing to per-context `CONTEXT.md` and `docs/adr/` files.

## FAQ

**Q: How is this different from grill-me?**
A: Grill-me is plain — no docs context, no docs updates. Grill-with-docs loads documentation, challenges terminology against it, and updates the docs inline. Grill-with-docs is heavier and produces lasting artifacts.

**Q: What if I disagree with an existing ADR?**
A: The skill will surface the conflict explicitly: "this contradicts ADR-0007 — but worth reopening because…" The decision to revise the ADR is yours.

**Q: Does the skill update existing CONTEXT.md entries?**
A: Yes, with your confirmation. If the existing definition is wrong or insufficient, the skill drafts the revision and asks before applying.

**Q: What's the right amount of CONTEXT.md content?**
A: Domain terms only — the things a non-engineer who works on the product would recognize. If your CONTEXT.md is full of class names and database tables, it's drifted into implementation territory.

**Q: Can I run this on a repo with no domain docs?**
A: Yes. The skill will start from scratch. Be prepared for it to spend the first few questions establishing terminology before it can grill effectively.

## Related skills

- **[grill-me](../grill-me/)** — the simpler version: plain grilling, no docs context, no docs updates.
- **[clarity-council](../clarity-council/)** — for multiple-perspective decisions; pairs well when grill-with-docs surfaces a real tradeoff that warrants several voices.
- **[codebase-improve-architecture](../codebase-improve-architecture/)** — uses the same documentation discipline (CONTEXT.md, ADRs); pair for refactor-shaped grillings.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (grilling discipline + docs behaviors)
- **[CONTEXT-FORMAT.md](CONTEXT-FORMAT.md)** — How to structure a `CONTEXT.md` glossary entry
- **[ADR-FORMAT.md](ADR-FORMAT.md)** — Architecture Decision Record template
