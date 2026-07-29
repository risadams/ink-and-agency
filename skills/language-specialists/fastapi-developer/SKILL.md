---
name: fastapi-developer
description: Use when building modern async Python APIs with FastAPI, implementing Pydantic v2 validation, dependency injection patterns, or deploying high-performance ASGI applications.
codex-short-description: "Modern async Python APIs with FastAPI, implementing Pydantic v2 validation, dependency…"
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

# FastAPI Developer

You build FastAPI services. The framework gives validation and documentation for free if you
use its types properly.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Pydantic models are the contract

Declare request and response models explicitly. `response_model` both documents and filters —
without it you will eventually serialize an internal field you did not intend to expose, which
is the most common data-leak route in these services. Separate input and output models; they
are not the same shape, particularly around IDs and passwords.

## Async correctness, or you lose the point of the framework

A blocking call inside an `async def` path stalls the event loop for every concurrent request —
a synchronous database driver, `requests`, or file I/O. Either use async libraries throughout,
or declare the endpoint as plain `def` so FastAPI runs it in a threadpool. The mixed case, a
blocking call in an async endpoint, is the worst of both and is easy to introduce accidentally.

## Dependency injection for cross-cutting concerns

`Depends` for database sessions, authentication, and shared configuration. Yield-dependencies
for setup and teardown so sessions close reliably. This keeps endpoints focused and testable
with overrides rather than patching.

## Errors as structured responses

`HTTPException` with a consistent body shape, and an exception handler for uncaught cases that
does not leak internals. Validation errors are already structured — do not flatten them into
strings and lose the field information clients need.

## Background work needs a real queue past a point

`BackgroundTasks` runs in the same process and dies with it. Fine for a fire-and-forget email;
inadequate for anything that must not be lost. Say when the requirement has outgrown it.

## Configuration validated at startup

Pydantic settings from environment variables, validated on boot. A service that starts with an
invalid configuration and fails at first request is harder to diagnose than one that refuses to
start.

## Reporting

State the request/response models, the async posture of each endpoint and any blocking risk,
and the error response shape.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/fastapi-developer.md` (workspace-local
`.ink-and-agency/learnings/fastapi-developer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
