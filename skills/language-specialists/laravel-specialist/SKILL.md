---
name: laravel-specialist
description: Use when building Laravel 10+ applications, architecting Eloquent models with complex relationships, implementing queue systems for async processing, or optimizing API performance.
codex-short-description: "Laravel 10+ applications, architecting Eloquent models with complex relationships…"
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

# Laravel Specialist

You build Laravel applications. The framework is productive by convention, and the trouble
starts where convenience hides cost.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Eloquent will issue queries you did not ask for

Lazy loading in a loop is the standard Laravel performance failure — a relation accessed inside
a `foreach` runs a query per row. Eager load with `with()`, and enable `preventLazyLoading` in
development so it fails loudly rather than silently costing you. Use `chunk` or `cursor` for
large sets instead of loading everything.

Reach for the query builder when a query is genuinely complex; forcing it through Eloquent
relationships produces something slower and harder to read.

## Validate in Form Requests, authorize explicitly

Validation rules belong in a Form Request, not inline in the controller. Authorization goes
through policies or gates and is checked on every action — an authorization check that exists
only in the Blade template hides the button without protecting the endpoint.

Never pass request input straight to `create()` or `update()` without guarding fillable
attributes; mass assignment is how a user grants themselves a role.

## Keep controllers thin

Business logic in services or actions. Fat controllers become untestable and duplicated across
the web route, the API route, and the console command. Jobs and listeners should be thin
wrappers over the same logic.

## Queues need to be idempotent and bounded

A queued job will be retried, so it must tolerate running twice. Set `tries` and `timeout`
explicitly, handle `failed()`, and monitor the failed jobs table — an unwatched failed queue is
work silently disappearing.

## Migrations, seeders, and factories are part of the change

A migration that changes an existing column needs the doctrine dependency and careful review of
the resulting SQL. Factories keep tests honest against the real schema.

## N+1, caching, and config caching in production

Cache config, routes, and views in deployment. Anything cached must have an invalidation story
before it has a caching strategy.

## Reporting

State the eager loading, the authorization path, the queue retry semantics, and the cache
invalidation.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/laravel-specialist.md` (workspace-local
`.ink-and-agency/learnings/laravel-specialist.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
