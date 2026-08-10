---
name: domain-modeling
category: research-analysis
description: Actively build and sharpen a project's domain model — challenge fuzzy terms, stress-test with scenarios, and write CONTEXT.md and ADRs inline as decisions crystallise. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model.
codex-short-description: "Sharpen domain terminology and record it in CONTEXT.md and ADRs"
related-skills:
  - grill-with-docs
  - codebase-design
  - codebase-improve-architecture
  - documentation-engineer
loop-eligible: false
compatibility: claude-code codex opencode
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the **active** discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and the decisions down the moment they crystallise.

Merely *reading* `CONTEXT.md` for vocabulary is not this skill; that's a one-line habit any skill can do. Reach for this skill when you are **changing** the model, not just consuming it.

## File structure

Most repos have a single context:

```text
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```text
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed. Full layout rules: [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).

`CONTEXT.md` is a glossary and nothing else. Keep it free of implementation details; it is not a spec, a scratch pad, or a home for implementation decisions.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](ADR-FORMAT.md).

## Quality Loop

Before ending a modelling pass, check the artifacts against what the session actually settled:

1. **Every resolved term is written down** — nothing settled in conversation is left only in the transcript.
2. **Definitions say what a thing IS** — not what it does, not how it's implemented.
3. **Rejected words are recorded** — each term carries the `_Avoid_` list that keeps the language opinionated.
4. **No general programming concepts** — timeouts, retries, and error types are not domain terms.
5. **Each ADR passes all three gates** — hard to reverse, surprising without context, a real trade-off.

If two or more fail, fix the artifacts and re-check. Cap at two passes.

## Delegation Map

| User need | Delegate via | Notes |
| :--- | :--- | :--- |
| Stress-test a *plan* against the domain model | Invoke `grill-with-docs` | That skill runs the interview and calls this discipline inline |
| Name a deepened module in the domain's language | Invoked *by* `codebase-design` / `codebase-improve-architecture` | Resolve the term here, then name the module after it |
| Turn the settled model into a written spec | Invoke `plan-to-spec` | The glossary supplies the spec's vocabulary |

**Loop eligibility:** false — the model sharpens when the design conversation happens, not on a schedule.

> **Host portability:** this skill only reads the repo and writes markdown — no host-specific tools. See [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/domain-modeling.md` (workspace-local
`.ink-and-agency/learnings/domain-modeling.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
