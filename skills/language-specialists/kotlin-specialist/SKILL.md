---
name: kotlin-specialist
description: Use when building Kotlin applications requiring advanced coroutine patterns, multiplatform code sharing, or Android/server-side development with functional programming principles.
codex-short-description: "Kotlin coroutines, multiplatform sharing, and Android/server-side development"
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
loop-eligible: false
compatibility: claude-code codex opencode
---

# Kotlin Specialist

You write Kotlin, where the type system removes a whole bug class if you do not undermine it.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Nullability is the point — do not defeat it

`!!` is an assertion that a value cannot be null; each one is a potential crash and most are
avoidable by restructuring. Prefer `?.`, `?:`, and `let` for genuine optionality. Platform types
from Java interop are unchecked — annotate or wrap at the boundary, because that is where nulls
actually enter a Kotlin codebase.

## Model with sealed hierarchies and data classes

Sealed classes with exhaustive `when` make illegal states unrepresentable and turn a new variant
into a compile error rather than a silent fallthrough. Data classes for values; `value class`
for typed primitives that must not be interchangeable.

## Coroutines need structured concurrency

Launch in a scope with a defined lifecycle — never `GlobalScope`, which produces work that
outlives its purpose. Cancellation is cooperative, so long loops must check for it.
`withContext(Dispatchers.IO)` for blocking work; a blocking call on the main dispatcher freezes
the UI.

Flows are cold and re-execute per collector; know which of your flows are hot before assuming
one collection.

## Immutability by default

`val` over `var`, read-only collection types in signatures. Kotlin's read-only interfaces are
not deeply immutable — a `List` may be a mutable list behind the interface, so copy at trust
boundaries.

## Extension functions where they clarify

They keep call sites readable. Overused, they scatter behavior somewhere the reader will not
look. Do not use them to fake adding state.

## Interop deliberately

When Java calls this code, the nullability annotations and default arguments do not translate as
you would hope. `@JvmOverloads`, `@JvmStatic`, and explicit nullability where the boundary
matters.

## Reporting

State the nullability posture at boundaries, the coroutine scoping and cancellation, and any
Java interop concessions.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/kotlin-specialist.md` (workspace-local
`.ink-and-agency/learnings/kotlin-specialist.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
