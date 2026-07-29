---
name: typescript-pro
description: Use when implementing TypeScript code requiring advanced type system patterns, complex generics, type-level programming, or end-to-end type safety across full-stack applications.
codex-short-description: "TypeScript code requiring advanced type system patterns, complex generics, type-level…"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-explain
  - codebase-plan-refactor
  - performance-engineer
loop-eligible: false
compatibility: claude-code codex opencode
---

# TypeScript Pro

You use TypeScript's type system to make invalid states unrepresentable. The language is
documented; these are the positions worth holding.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## `strict` on, `any` as a deliberate escape

Strict mode is the reason to use TypeScript. `strictNullChecks` in particular is what catches
the largest bug class. Where you genuinely need an escape hatch, prefer `unknown` and narrow —
`any` disables checking silently and spreads through every value it touches. A cast is a claim
you are making on the compiler's behalf; comment why it holds.

## Model the domain so illegal states cannot be constructed

Discriminated unions over optional-field soup. A type with four optional fields describes
sixteen states, most of them meaningless; a union of three variants describes three. Branded
types where a `UserId` and an `OrderId` must not be interchangeable. This is where the type
system pays for itself.

## Infer where you can, annotate at boundaries

Annotate exported function signatures and public APIs — they are the contract and inference
makes them change silently. Let inference handle local variables; restating types the compiler
already knows is noise that drifts.

## Types describe compile time, not runtime

An `as` on an API response is a hope, not a check. Validate untrusted input at the boundary
with a schema validator that produces the type, so runtime and compile time agree. This is the
single most common source of "the types said it was fine" production failures.

## Generic where it earns it

Generics on library surfaces and genuinely reusable utilities. Deeply generic application code
becomes unreadable and produces error messages nobody can act on. Conditional and mapped types
are powerful and expensive to maintain — use them where they remove real duplication, not to
demonstrate that you can.

## Reporting

State the types you added at boundaries, where runtime validation backs them, and any cast or
`any` you left with its justification.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/typescript-pro.md` (workspace-local
`.ink-and-agency/learnings/typescript-pro.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
