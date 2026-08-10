# Codebase Design

The pack's **deep-module vocabulary**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. Reference, not a procedure — the words other skills speak while designing.

## Why this exists

Architecture conversations collapse when the words drift. "Component," "service," "API," and "boundary" each mean four things depending on who's talking, so two people can agree on a sentence and disagree about the code. This skill fixes eight terms — module, interface, implementation, depth, seam, adapter, leverage, locality — and the handful of principles that make them decidable (the deletion test; the interface is the test surface; one adapter means a hypothetical seam).

It was extracted from [codebase-improve-architecture](../codebase-improve-architecture/), which used to carry the glossary inline. Several skills need the same words, and a meaning duplicated in three places drifts in three directions — so it lives here once and the others point at it.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "is this module too shallow?"
  - "where should the seam go?"
  - "how do I make this testable without mocking everything?"
  - "design this interface properly"
- Running the slash command: `/codebase-design`
- Automatically, when `codebase-improve-architecture`, `codebase-plan-refactor`, or `tdd` needs the vocabulary.

## What it does

Supplies definitions and principles. It does not scan a codebase, propose candidates, or write code — those belong to the skills that consult it.

### Inputs

- A module, interface, or refactor under discussion.

### Outputs

- Consistent vocabulary in the resulting design conversation, plan, or review.

## Files

- **[SKILL.md](SKILL.md)** — glossary, deep-vs-shallow, principles, testability, rejected framings
- **[DEEPENING.md](DEEPENING.md)** — the four dependency categories (in-process, local-substitutable, remote-but-owned, true external), seam discipline, and replace-don't-layer testing
- **[INTERFACE-DESIGN.md](INTERFACE-DESIGN.md)** — "Design It Twice": explore 3+ radically different interfaces in parallel, then compare on depth, locality, and seam placement

## Getting the most out of it

- **Read `DEEPENING.md` before proposing a port.** The dependency category decides whether a seam is real or just indirection.
- **Apply the deletion test out loud.** "If I delete this, does complexity vanish or reappear across callers?" settles most shallow-module arguments in one sentence.
- **Name the module in the domain's language.** Depth without a domain-accurate name is a module nobody can find — see [domain-modeling](../domain-modeling/).

## Which skill do you actually want?

| The problem | The skill |
| :--- | :--- |
| The shape of one module — its interface, its seam, its depth | `codebase-design` |
| The *words of the domain* — "account" means three things | [domain-modeling](../domain-modeling/) |
| You don't yet know *which* module to redesign | [codebase-improve-architecture](../codebase-improve-architecture/) — the survey that finds candidates |
| You want the design argued with, not just named | [grill-with-docs](../grill-with-docs/) |
| There's a concrete behaviour to build, with tests that survive a refactor | [tdd](../tdd/) |

## It's working if

- The design conversation stops producing "component", "service" and "boundary", and starts producing "module", "interface" and "seam".
- Someone can point at a proposed extraction and say whether it passes the deletion test, without hedging.
- A proposed seam comes with a *second* adapter named, not just the first.
- Discussion of an interface covers invariants, ordering and error modes — not only the type signature.
- **Invoking it doesn't start a session.** If the agent begins reading files and proposing refactors off `/codebase-design` alone, it has mistaken the reference for a driver — see the stopping rule in `SKILL.md`.

## Common questions

**How do I stop a stray import reaching past the interface?**
This skill doesn't answer that — it defines what a deep module *is*, not how to enforce one. Enforcement is a tooling choice: a class or closure that keeps the implementation private, a package boundary in a monorepo, or an import linter (dependency-cruiser and equivalents) that forbids paths bypassing the entry point. Pick one deliberately; without it, humans and agents both erode the interface over time.

**Isn't this really a file-structure convention — folders, barrel files, feature slices?**
No, and the glossary defines **module** as scale-agnostic on purpose. The file system is a useful hint about where modules sit, but you can have shallow modules with an immaculate folder tree and deep ones with a flat directory. Depth is a property of the interface.

**Why not Ousterhout's own definition of depth?**
His is a ratio of implementation lines to interface lines, which rewards padding the implementation. Depth-as-leverage measures the thing you actually want: behaviour exercised per unit of interface learned.

## Anti-patterns

- ❌ **Measuring depth as lines-of-implementation over lines-of-interface.** That rewards padding. Depth is leverage at the interface.
- ❌ **Introducing a port for one adapter.** One adapter is a hypothetical seam; that's indirection with extra steps.
- ❌ **Testing past the interface.** If a test reaches inside, the module is the wrong shape — or the seam is in the wrong place.
- ❌ **Saying "boundary."** It's overloaded with DDD's bounded context. Say seam or interface.

## Related skills

- **[codebase-improve-architecture](../codebase-improve-architecture/)** — scans a codebase for deepening candidates and runs the grilling loop; speaks this vocabulary throughout.
- **[codebase-plan-refactor](../codebase-plan-refactor/)** — turns an agreed deepening into ordered, tiny commits.
- **[tdd](../tdd/)** — puts behaviour tests at the interface once the seam is agreed.
- **[domain-modeling](../domain-modeling/)** — supplies the names the deepened modules should carry.

## Host portability

Runs on Claude Code, Codex, and opencode. Pure reference — no host-specific tools. `INTERFACE-DESIGN.md` describes parallel sub-agents; on a host without them, run the alternatives sequentially. See [PORTABILITY.md](../PORTABILITY.md).
