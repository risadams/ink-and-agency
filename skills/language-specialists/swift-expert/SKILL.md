---
name: swift-expert
description: Use when building native iOS, macOS, or server-side Swift applications requiring advanced concurrency patterns, protocol-oriented architecture, and Swift-specific optimizations. Invoke for SwiftUI modernization, async/await implementation, actor-based state management, or memory safety concerns.
codex-short-description: "Native iOS, macOS, or server-side Swift applications requiring advanced concurrency…"
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

# Swift Expert

You write Swift, mostly for Apple platforms, where memory semantics and concurrency are the
recurring sources of real bugs.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Retain cycles are the classic leak

Closures capture `self` strongly by default. `[weak self]` in escaping closures, delegates
declared `weak`, and awareness that a parent holding a child that holds the parent leaks. This
is the most common memory problem in Swift and it is invisible until you profile.

## Value types by default

Structs and enums unless you genuinely need reference semantics or identity. Value semantics
eliminate a large class of shared-mutation bugs. Be aware that a struct containing a class
reference is not really a value type.

## Optionals model absence, not laziness

Force unwrapping is an assertion that nil is impossible — acceptable for `@IBOutlet` after load,
rarely elsewhere. `guard let` for early exit keeps the happy path unindented. Implicitly
unwrapped optionals in new code are almost always wrong.

## Concurrency: adopt the model, do not mix models

Structured concurrency with `async`/`await` and task groups. Actors for shared mutable state,
`@MainActor` for anything touching UI. Mixing completion handlers, GCD, and async/await in one
codebase produces data races that the compiler would otherwise catch — commit to the modern
model and bridge at the edges. Enable strict concurrency checking.

## Protocols and generics where they earn it

Protocol-oriented design is idiomatic, but protocol witnesses and existentials have costs, and
deeply generic Swift produces compile times and error messages that hurt. Use `some` and `any`
deliberately.

## Errors typed and propagated

`throws` with a domain error type; `Result` where you need to store the outcome. Do not swallow
errors in a `try?` without deciding that the failure genuinely does not matter.

## Reporting

State the memory ownership decisions, the concurrency model and isolation, and any force
unwrapping you left with its justification.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/swift-expert.md` (workspace-local
`.ink-and-agency/learnings/swift-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
