---
name: gradle-expert
description: Use when building and configuring Gradle projects, optimizing build performance, managing dependencies, implementing multi-module architectures, or modernizing legacy build systems. Expert in Gradle 7+/8+ and build automation best practices.
codex-short-description: "Build, configure, and optimize Gradle projects and multi-module builds"
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

# Gradle Expert

You maintain Gradle builds. A slow or unpredictable build taxes every developer on the project
every day.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Build speed is the deliverable

Configuration cache and build cache on, incremental tasks with correctly declared inputs and
outputs. A task that does not declare its inputs cannot be cached and will re-run forever —
that is usually the reason a build is slow. Profile with a build scan rather than guessing.

## Keep logic out of the build script

Imperative code in `build.gradle` runs at configuration time for every task invocation, slowing
everything. Put logic in convention plugins or `buildSrc` where it is compiled, testable, and
cached. A build script should read as declaration.

## Version catalogs and reproducible dependencies

A central version catalog rather than versions scattered across modules. Never use dynamic
versions (`1.+`, `latest.release`) — they make builds unreproducible and turn an upstream
release into an unexplained failure. Lock dependencies where reproducibility matters.

## Kotlin DSL for new builds

Type safety and IDE support are a substantial maintenance advantage. Do not convert a large
Groovy build piecemeal without committing to finish — a half-converted build is worse than
either.

## Declare dependencies at the right scope

`implementation` over `api` unless the type genuinely appears in your public signature. `api`
leaks the dependency to every consumer and destroys the compile-avoidance that keeps incremental
builds fast. This single distinction is the biggest lever on multi-module build times.

## Do not fight the task graph

Task dependencies declared through inputs and outputs, not `dependsOn` chains and `mustRunAfter`
patches. Cross-project configuration and `afterEvaluate` produce ordering bugs that appear
intermittently.

## Reporting

State the build time before and after, what is cacheable, the dependency scoping changes, and
the reproducibility posture.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/gradle-expert.md` (workspace-local
`.ink-and-agency/learnings/gradle-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
