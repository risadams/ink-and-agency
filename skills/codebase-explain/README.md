# Codebase Explain

A meta-skill that tells the agent to step back and explain a code area at a higher level of abstraction. The goal is a *map* — modules involved, callers, callees, the project's domain glossary terms — rather than a line-by-line walkthrough. Use it when you're parachuting into unfamiliar territory and need orientation before reading code.

## Why this exists

The default failure mode when you ask an agent "what does this code do" is a guided tour of the file you pointed at. That tour answers the wrong question. What you usually need first is "what's this *for*, who calls it, what's the surrounding shape" — orientation, not exposition. This skill is a tiny, deliberate prompt that flips the agent into map-making mode rather than line-reading mode. The skill itself is fewer than 10 lines because the work is in changing the question, not in adding tooling.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "explain this code with broader context"
  - "give me the big picture for {module}"
  - "I don't know this area — go up a layer"
  - "map out how {feature} fits together"
- Running the slash command: `/codebase-explain` (referenced by other skills like `issue-triage`)

## What it does

The skill instructs the agent to: skip the line-by-line tour, go up an abstraction layer, identify all relevant modules and their callers, and use the project's domain glossary vocabulary if one exists (typically `CONTEXT.md`). The output is a map you can use to orient before diving in. It does **not** modify any files, propose refactors, or design new interfaces.

### Inputs

- **Code area** — file path, module name, function, feature description, or stack trace. Free-form.

### Outputs

- A map describing: which modules are involved, how they connect (callers, callees), what concepts (in domain glossary terms) they implement, and where the seams are.

### External systems used

- Local filesystem (read only — Glob, Grep, Read on the codebase)
- Optionally `CONTEXT.md` if the project has a domain glossary

## How to use it

A typical session looks like this:

```text
You: explain the checkout flow — I haven't looked at this part of the codebase

Skill: Stepping back. Here's the map of the checkout flow:

       Entry: src/checkout/cart-button.tsx (React component, user-facing)
         calls → src/api/checkout.ts (HTTP client wrapper)
           calls → POST /api/v2/checkout (handled by web-checkout backend)

       Backend: internal/checkout/handler.go
         depends on → internal/payments/charge.go (payment authorization)
         depends on → internal/inventory/reserve.go (stock hold)
         emits → checkout.completed event → notifications-worker

       Domain concepts (per CONTEXT.md):
         - "Cart" = mutable pre-order state (cart-button.tsx, cart-store.ts)
         - "Order" = immutable post-checkout record (checkout/handler.go)
         - "Charge" = payment authorization, may be refunded (payments/charge.go)

       Seams worth knowing:
         - The Cart → Order transition is the only place inventory is reserved.
         - Payment authorization is idempotent; safe to retry.
         - notifications-worker is a downstream consumer — failures don't block
           checkout, but they do affect the order confirmation email.
```

## Getting the most out of it

- **Run it before you read code, not after.** The map is most useful as orientation. Reading the file first defeats the purpose — you'll just confirm what you noticed.
- **Be specific about the entry point.** "Explain the checkout flow" gets a better map than "explain the checkout code." Naming a starting symbol or file gives the skill an anchor.
- **Use it inside other skills' workflows.** `issue-triage` invokes `/codebase-explain` automatically in Phase 2. You can also chain it manually before running `codebase-improve-architecture` for additional grounding.
- **Pair with the project's CONTEXT.md.** If the project has a domain glossary, the map will use those terms. If not, the map describes shapes generically — consider adding a CONTEXT.md afterward (use [grill-with-docs](../grill-with-docs/) to draft one).

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Walk through code line-by-line.** That's the failure mode the skill exists to avoid. If you want a line-by-line, ask for one explicitly without invoking this skill.
- ❌ **Propose refactors.** The output is descriptive, not prescriptive. For refactor suggestions, use [codebase-improve-architecture](../codebase-improve-architecture/).
- ❌ **Substitute for reading the design doc.** A map is a partial substitute for tribal knowledge, not a substitute for the actual design document if one exists.
- ❌ **Find bugs.** Mapping is orientation; bug-finding is investigation. For triage, use [issue-triage](../issue-triage/).

## Examples

### Example: Map a single function's neighborhood

```text
You: I'm looking at internal/payments/charge.go's RefundCharge function — explain
     who calls it and what else it depends on.

Skill: RefundCharge is called from:
       - internal/checkout/handler.go (when an order is canceled within 30 min)
       - internal/admin/refund.go (manual refund tooling)
       - cmd/jobs/auto-refund.go (scheduled job for failed shipments)

       It depends on:
       - internal/payments/provider/stripe.go (the actual API call)
       - internal/payments/ledger.go (records the refund in the ledger)
       - internal/notifications/email.go (sends refund confirmation)

       Failure mode: ledger.go writes happen before the email; if email fails,
       the refund is recorded but the user isn't notified. There's a retry
       worker (notifications-worker) that handles this.
```

### Example: Map a feature spanning multiple files

```text
You: explain how feature flags work in this codebase — go up a layer

Skill: Feature flags live in three places:
       - config/feature-flags.json (source of truth, committed to repo)
       - internal/flags/loader.go (parses + caches the file at startup)
       - internal/flags/check.go (the IsEnabled API used by callers)

       Callers (top 5 by usage): checkout/handler.go, auth/middleware.go,
       experiments/ab.go, search/ranker.go, billing/invoicing.go.

       Domain concepts: flags are gates for "experiments" (CONTEXT.md
       defines an Experiment as a flag + a metric + a treatment cohort).
```

The map is the deliverable. Reading individual files is your next step, not the skill's.

## Internals

The skill is intentionally minimal — it's a prompt that reframes the question. The agent does the work using its standard codebase-reading tools (Glob, Grep, Read). The reframing pushes the agent to:

1. **Explore breadth before depth** — find all related files first.
2. **Trace callers and callees** — map relationships, not implementations.
3. **Use domain vocabulary** — if `CONTEXT.md` exists, use those terms; otherwise describe generically.
4. **Identify seams** — note where behavior could be altered without editing in place.

Key constraints:

- **No file modifications.** Read-only by design.
- **No prescriptive output.** Descriptions only; no refactor proposals.
- **The agent decides depth.** Tell it the scope you want — "go one level up" vs "give me the whole subsystem."

## FAQ

**Q: Why is the SKILL.md only 8 lines?**
A: The skill is a *prompt change*, not a procedure. Most of the value is in shifting the agent's framing from "explain this file" to "give me a map." More instructions would dilute that.

**Q: Does it work without a CONTEXT.md?**
A: Yes — the map will use generic descriptions. If you find yourself wanting domain vocabulary, that's a signal to draft a CONTEXT.md (see [grill-with-docs](../grill-with-docs/)).

**Q: Can I limit the scope?**
A: Yes — be specific in your request. "Explain just the auth middleware" gets a tighter map than "explain auth."

**Q: What's the difference vs running grep/find myself?**
A: The skill produces *synthesis* — relationships and concepts — not just a list of files. You can do it yourself; it's faster to ask.

**Q: Why is `disable-model-invocation: true` in the frontmatter?**
A: The skill is meant to be invoked deliberately, not auto-triggered. That keeps the agent from over-using "let me explain at a higher level" when the user actually wants line-level detail.

## Related skills

- **[codebase-improve-architecture](../codebase-improve-architecture/)** — once you have a map, this skill helps you decide what to deepen or refactor.
- **[issue-triage](../issue-triage/)** — Phase 2 invokes `/codebase-explain` automatically when triaging a Jira bug.
- **[grill-with-docs](../grill-with-docs/)** — when the project has no CONTEXT.md, use this to draft one. The map quality improves dramatically once domain vocabulary is captured.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (8 lines — the entire skill is a reframing prompt)
