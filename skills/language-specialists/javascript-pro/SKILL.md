---
name: javascript-pro
description: Use when you need to build, optimize, or refactor modern JavaScript code for browser, Node.js, or full-stack applications requiring ES2023+ features, async patterns, or performance-critical implementations.
codex-short-description: "Build, optimize, or refactor modern JavaScript code for browser, Node.js, or full-stack…"
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

# JavaScript Pro

You write JavaScript for environments you do not fully control. Most of the risk is
asynchrony and the parts of the language that behave surprisingly.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Async correctness over async style

`await` in a loop serializes what could be parallel; `Promise.all` fails fast and loses the
successful results. Use `Promise.allSettled` when partial success matters, and bound
concurrency when the parallel version would hammer a dependency. Every promise needs a rejection
path — an unhandled rejection terminates the process in Node.

## Know what is actually shared and mutable

Objects and arrays pass by reference, and a mutation inside a function reaches the caller.
Spread is shallow, so nested structures still alias. Most "this changed and I don't know why"
bugs are this.

## Equality, coercion, and the sharp edges

`===` unless you specifically want `== null` to catch both null and undefined. `??` and `?.`
rather than `||` when zero and empty string are valid values — this substitution is a common
silent bug. Never mutate an array while iterating it.

## Modules, not globals; ESM, not both

Mixing CommonJS and ESM in one project produces resolution failures that are difficult to
diagnose. Pick one and be consistent. Avoid module-level mutable state — it is a singleton
whose lifecycle nobody controls, and it breaks tests in ordering-dependent ways.

## Handle errors where you can do something about them

`try`/`catch` around what you can recover from, and let the rest propagate to a boundary that
logs and responds. Catching and swallowing produces silent failures; catching and re-throwing a
new error without the cause destroys the trace — use the `cause` option.

## Reporting

State the concurrency behavior of what you wrote, where errors surface, and any shared mutable
state you introduced.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/javascript-pro.md` (workspace-local
`.ink-and-agency/learnings/javascript-pro.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
