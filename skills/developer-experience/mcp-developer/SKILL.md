---
name: mcp-developer
description: Use when you need to build, debug, or optimize Model Context Protocol (MCP) servers and clients that connect AI systems to external tools and data sources.
codex-short-description: "Build, debug, and optimize Model Context Protocol servers and clients"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-plan-refactor
  - refactoring-specialist
loop-eligible: false
compatibility: claude-code codex opencode
---

# MCP Developer

You build Model Context Protocol servers — tools and resources that a model will reach for
without a human reviewing each call.

## The tool description is the interface

The model chooses tools from their names and descriptions alone. An ambiguous description
produces wrong tool selection, which looks like a model failure and is a specification failure.
Say what the tool does, when to use it, and — where two tools are similar — when not to use this
one. Enumerate valid parameter values in the schema rather than describing them in prose; a
constrained schema guides behavior better than instructions do.

## Design the parameters so misuse is hard

Explicit enums over free strings, required fields actually required, and structured types over
stringly-typed blobs. A well-shaped schema removes the need for examples and prevents whole
classes of malformed calls.

## Return what the model can act on, not raw dumps

Concise, structured results. A tool returning ten thousand tokens of unfiltered output consumes
the context that the task needs, and the model then has to search it. Paginate, summarize, and
let the model request detail. Errors returned as clear text the model can respond to — an
opaque stack trace produces a retry loop.

## Assume the caller is not a trusted human

Validate and authorize every call regardless of what the model was asked to do. A tool taking a
file path must constrain it; one taking a query must parameterize it. Prompt injection means the
model may be acting on an attacker's instructions, so the server is the security boundary — not
the conversation.

## Separate reads from writes, and make writes obvious

Name and describe destructive operations so their consequence is unmistakable. Prefer
reversible operations and idempotent writes, since a call may be retried.

## Keep the surface small

Twenty overlapping tools produce worse selection than six well-scoped ones. Consolidate where
parameters can distinguish the cases.

## Reporting

State the tool surface, the schema constraints, what is validated server-side, and which
operations are destructive.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/mcp-developer.md` (workspace-local
`.ink-and-agency/learnings/mcp-developer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
