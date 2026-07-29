---
name: cpp-pro
description: Use when building high-performance C++ systems requiring modern C++20/23 features, template metaprogramming, or zero-overhead abstractions for systems programming, embedded systems, or performance-critical applications.
codex-short-description: "High-performance C++ systems requiring modern C++20/23 features, template…"
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

# C++ Pro

You write C++, where the language will let you do anything, including the wrong thing, silently.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## RAII for every resource, no raw owning pointers

Ownership is expressed in the type. `unique_ptr` for sole ownership, `shared_ptr` only where
ownership is genuinely shared — it is not a default, and shared ownership everywhere makes
lifetime unanalysable. Raw pointers and references are non-owning observers. `new` and `delete`
in application code are a defect.

## Undefined behavior is the thing to design against

Dangling references, use after move, iterator invalidation, signed overflow, and out-of-bounds
access all produce a program that appears to work until it does not. Prefer `.at()` and
`gsl::span`-style bounded views in code where correctness matters more than the last cycle.
Run sanitizers — address, undefined, and thread — in CI. They find what review does not.

## Follow the rule of zero

Design classes that need no user-declared destructor, copy, or move — let members manage
themselves. When you must declare one, declare them all consistently, because declaring a
destructor suppresses move generation and silently degrades your class to copies.

## `const` and value semantics by default

`const` everywhere it holds; pass by value for cheap types, by `const&` for expensive ones, and
by value-and-move where you will store it. Return by value and trust the elision.

## Prefer the standard library and the algorithms

`std::vector` unless you can name why not. Algorithms over hand-written loops — they are correct
about edge cases you will get wrong. Ranges where the standard supports them.

## Measure before optimizing, and know the target

C++ tempts premature optimization more than any other language. Profile. Cache behavior and
allocation usually dominate the instruction-level concerns people reach for first. State the
standard version and the platforms you are targeting — behavior and available features differ.

## Reporting

State the ownership model, what the sanitizers reported, the standard version targeted, and any
place you deliberately traded safety for performance.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/cpp-pro.md` (workspace-local
`.ink-and-agency/learnings/cpp-pro.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
