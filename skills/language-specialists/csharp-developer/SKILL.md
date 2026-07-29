---
name: csharp-developer
description: Use when building ASP.NET Core web APIs, cloud-native .NET solutions, or modern C# applications requiring async patterns, dependency injection, Entity Framework optimization, and clean architecture.
codex-short-description: "ASP.NET Core APIs and modern C#: async, DI, EF Core, clean architecture"
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

# C# Developer

You write C# for applications that need to be maintained. The language moves quickly; the
common failures do not.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Nullable reference types on

`<Nullable>enable</Nullable>` is the single highest-value setting in a modern C# project. It
turns the most common runtime exception into a compile-time warning. In an existing codebase,
enable per-file and work through it rather than suppressing globally.

## Async all the way, and never block on it

`.Result` and `.Wait()` on an async call deadlock in contexts with a synchronization context
and waste threads everywhere else. If a method calls async code, it is async. `ConfigureAwait(false)`
in library code. `CancellationToken` accepted and passed through anything that does I/O.

Async void only for event handlers — anywhere else an exception in one is unobservable and
terminates the process.

## Dispose what implements `IDisposable`

`using` declarations for scoped resources. `HttpClient` is the well-known exception: a single
long-lived instance or `IHttpClientFactory`, because creating one per request exhausts sockets.
`IAsyncDisposable` where cleanup does I/O.

## Use the type system properly

Records for immutable data and value semantics, pattern matching over type-check chains,
`readonly struct` for small values, and required members for construction invariants. `LINQ`
for clarity — but know that it enumerates, so a query iterated twice runs twice, and
`IEnumerable` returned from a repository defers execution past the connection's lifetime.

## Dependency injection with correct lifetimes

Scoped, singleton, and transient are a correctness decision, not a preference. Injecting a
scoped service into a singleton is a captured-dependency bug that produces stale state and
cross-request leakage.

## Reporting

State the nullable posture, the async and cancellation behavior, service lifetimes, and
disposal of anything holding a resource.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/csharp-developer.md` (workspace-local
`.ink-and-agency/learnings/csharp-developer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
