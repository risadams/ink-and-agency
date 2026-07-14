# TDD

The **red → green** loop, plus the reference that makes its tests worth keeping: what a good test is, where tests go (seams), the anti-patterns, and the rules of the loop. A primitive other skills reach for — `implement` drives it as its test-first phase — and one you can invoke directly to build a behaviour test-first.

## Why this exists

TDD done badly produces tests that are worse than none: implementation-coupled tests that break on every refactor, tautological tests that can never fail, and bulk-written tests that verify imagined behaviour. This skill is the discipline that avoids all three — test behaviour through public interfaces at agreed seams, one vertical slice at a time, red before green. It's written as a reference consulted *during* the loop, not a one-time read.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "build this test-first" / "TDD this"
  - "red-green-refactor"
  - "write integration tests for X"
- Running the slash command: `/tdd`
- Automatically, when `/implement` runs with test-first on.

## What it does

Establishes the rules of the red→green loop and the standard for tests: **behaviour through public interfaces**, tested at **pre-agreed seams** (confirmed with you before any test is written), in **vertical slices** (one test → one implementation → repeat). It names the three anti-patterns to avoid and points to worked examples ([tests.md](tests.md)) and mocking guidance ([mocking.md](mocking.md)).

### Inputs

- **A behaviour to build** — a feature or bug fix, and the public interface it lives behind.
- **Agreed seams** — confirmed with you at the start.

### Outputs

- Tests at the agreed seams plus the minimal code to pass them, built slice by slice.

### External systems used

- The repo's test runner and typechecker. No external services.

## How to use it

```text
You: /tdd — build the discount calculator

Skill: What's the public interface, and which seams should we test?
You: calculateDiscount(cart, coupon) — test at that function.
Skill: Seam confirmed. Red: test "10% coupon takes 10% off subtotal"
       → fails (function missing). Green: minimal implementation → passes.
       Next slice: "expired coupon is ignored"...
```

## Getting the most out of it

- **Agree the seams first.** You can't test everything; naming the seams up front lands the effort on critical paths, not every edge case.
- **One slice at a time.** One seam, one failing test, minimal code. Resist writing the next three tests "while you're here" — that's horizontal slicing.
- **Let expected values come from outside the code.** A known literal or worked example, never a value recomputed the way the implementation does it.
- **Keep refactoring out of the loop.** Red→green is build-only; refactoring is the review stage's job.

## Anti-patterns

- ❌ **Implementation-coupled tests** — mocking internal collaborators or verifying through a side channel. The tell: breaks on refactor when behaviour didn't change.
- ❌ **Tautological tests** — the assertion recomputes the expected value the way the code does, so it passes by construction.
- ❌ **Horizontal slicing** — all tests first, then all implementation. Verifies imagined behaviour and locks in test structure before you understand the code.
- ❌ **Testing at unconfirmed seams** — no test is written at a seam you haven't agreed.

## Related skills

- **[implement](../implement/)** — drives this skill as its test-first phase (and can skip it for prototypes).
- **[debug](../debug/)** — for hard bugs, builds a failing repro loop first; TDD is for building *features* test-first.
- **[code-review](../code-review/)** — the stage where refactoring happens, after the red→green loop is green.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (rules of the loop, seams, anti-patterns)
- **[tests.md](tests.md)** — Good vs bad test examples
- **[mocking.md](mocking.md)** — When and how to mock at system boundaries
