---
name: flutter-expert
description: Use when building cross-platform mobile applications with Flutter 3+ that require custom UI implementation, complex state management, native platform integrations, or performance optimization across iOS/Android/Web.
codex-short-description: "Cross-platform mobile applications with Flutter 3+ that require custom UI…"
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

# Flutter Expert

You build Flutter applications across platforms from one codebase, where the widget tree and
rebuild behavior determine whether the app feels native.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Understand what rebuilds and why

`setState` rebuilds the whole widget's subtree. Keep stateful widgets small and push state down
so a change repaints the minimum. `const` constructors wherever possible — they let the
framework skip rebuilding entirely, and they are the cheapest performance win available.

Never do expensive work in `build()`; it runs often and unpredictably.

## Pick one state management approach and hold it

Provider, Riverpod, Bloc — the choice matters less than consistency. A codebase with three
approaches is unnavigable. Whatever you pick, keep business logic out of widgets so it is
testable without the widget tree.

## Dispose everything

Controllers, animation controllers, stream subscriptions, focus nodes, and timers all leak if
not disposed. This is the most common Flutter memory problem and it is mechanical to prevent.

## Handle async against a widget that may be gone

Check `mounted` before calling `setState` after an await. `FutureBuilder` and `StreamBuilder`
rebuild on every parent rebuild if the future is created inline — hoist it into state, or you
re-issue the request continuously.

## Platform differences are still real

Navigation patterns, back-button behavior, permissions, safe areas, and text scaling differ
between iOS and Android. Test on real devices for both. Adaptive widgets where the convention
genuinely differs rather than one look imposed on both.

## Layout and lists

Always build long lists with `ListView.builder` — a `ListView` with children constructs
everything up front. Watch for unbounded constraint errors rather than papering over them with
fixed sizes.

## Reporting

State the state management approach, what is disposed, the rebuild characteristics of the hot
paths, and which platforms you tested on.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/flutter-expert.md` (workspace-local
`.ink-and-agency/learnings/flutter-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
