# Domain Modeling

Actively build and sharpen a project's **ubiquitous language** — challenge fuzzy terms, stress-test them with scenarios, and write `CONTEXT.md` and ADRs the moment a decision crystallises.

## Why this exists

Every project accumulates words that mean two things. "Account" is the Customer to one person and the User to another; "cancellation" means a refund upstream and a state transition downstream. The cost lands later, as code that models a concept nobody agreed on.

Reading `CONTEXT.md` for vocabulary is a one-line habit any skill can do. This skill is the **active** half: changing the model, not consuming it. It was extracted from [grill-with-docs](../grill-with-docs/) so the same discipline could be reached by the architecture skills without duplicating it.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "what should we call this?"
  - "we're using 'account' to mean two different things"
  - "should this be an ADR?"
  - "update the glossary"
- Running the slash command: `/domain-modeling`
- Automatically, when `grill-with-docs` or `codebase-improve-architecture` resolves a term or hits a decision worth recording.

## What it does

Runs the modelling discipline inline while a design conversation is happening: challenge against the glossary, sharpen fuzzy language, probe with concrete scenarios, cross-reference the code, write terms down as they resolve, and offer an ADR only when all three gates hold.

### Inputs

- A live design conversation, plus whatever `CONTEXT.md` / `CONTEXT-MAP.md` / `docs/adr/` already exists.

### Outputs

- **`CONTEXT.md`** — an opinionated glossary: what each term IS, the words to avoid, and the relationships between them. Created lazily, on the first resolved term.
- **`docs/adr/NNNN-slug.md`** — a short record of a decision that was hard to reverse, surprising, and a real trade-off.

### External systems used

- None. It reads the repo and writes markdown.

## How to use it

```text
You: the Order should hold the invoice status

Skill: Your CONTEXT.md defines Invoice as "a request for payment sent after
       delivery," owned by Billing. If the Order holds its status, either the
       Order owns the Invoice lifecycle or you're caching a Billing fact —
       which is it?

You: caching it, for the list view
Skill: Then it isn't "invoice status" on the Order — it's a projection.
       Adding **Order Payment State** to CONTEXT.md with _Avoid_: invoice
       status. And this is ADR-worthy: hard to reverse, and the next reader
       will assume Order owns it.
```

## Getting the most out of it

- **Let it interrupt you.** The value is in the challenge landing mid-sentence, not in a glossary review at the end.
- **Keep `CONTEXT.md` implementation-free.** It is a glossary. The moment it holds schemas or endpoints, it stops being one and nobody trusts it.
- **Be opinionated in `_Avoid_`.** Recording the rejected synonym is what stops the term drifting back.
- **Say no to most ADRs.** Three gates, all three required. An ADR trail nobody reads is worse than none.

## Anti-patterns

- ❌ **Batching glossary updates to the end of the session.** They get lost, or get written from memory.
- ❌ **Adding general programming concepts.** Timeouts, retries, and error types are not domain terms, however much the project uses them.
- ❌ **Definitions that describe behaviour.** "Order — handles checkout and emits events" is a class comment. "Order — a customer's request for goods at agreed prices" is a definition.
- ❌ **ADRs for reversible decisions.** You'll just reverse them, and the record becomes noise.

## Related skills

- **[grill-with-docs](../grill-with-docs/)** — the interview that runs this discipline inline; the grilling half lives there, the modelling half here.
- **[codebase-design](../codebase-design/)** — the architecture vocabulary. Domain terms name the modules; these terms describe their shape.
- **[codebase-improve-architecture](../codebase-improve-architecture/)** — triggers this skill when a deepened module needs a domain-accurate name, or a rejection needs recording.
- **[plan-to-spec](../plan-to-spec/)** — a spec written in the settled language needs no glossary of its own.

## Files

- **[SKILL.md](SKILL.md)** — file layout, the session disciplines, the ADR gates, quality loop
- **[CONTEXT-FORMAT.md](CONTEXT-FORMAT.md)** — the `CONTEXT.md` structure, its rules, and single- vs multi-context repos
- **[ADR-FORMAT.md](ADR-FORMAT.md)** — the ADR template, numbering, and what qualifies

## Host portability

Runs on Claude Code, Codex, and opencode. Everything it does is reading the repo and writing markdown — no host-specific tools. See [PORTABILITY.md](../PORTABILITY.md).
