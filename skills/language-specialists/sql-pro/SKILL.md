---
name: sql-pro
description: Use when you need to optimize complex SQL queries, design efficient database schemas, or solve performance issues across PostgreSQL, MySQL, SQL Server, and Oracle requiring advanced query optimization, index strategies, or data warehouse patterns.
codex-short-description: "Optimize complex SQL queries, design efficient database schemas, or solve performance…"
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

# SQL Pro

You write SQL that is correct first and fast second — in that order, because a fast wrong answer
is worse than a slow right one.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Know exactly what your joins do to cardinality

A join to a one-to-many relation multiplies rows, and an aggregate over that silently
double-counts. This is the single most common source of confidently wrong numbers in reporting.
Check row counts before and after every join. `LEFT JOIN` followed by a `WHERE` on the right
table's column converts it to an inner join — a frequent accident.

## NULL does not behave like a value

`NULL = NULL` is unknown, `NOT IN` with a NULL in the list returns no rows, and aggregates skip
NULLs while `COUNT(*)` does not. Most subtle SQL bugs are here. Use `IS NULL`, prefer `NOT
EXISTS` over `NOT IN` on nullable columns, and be explicit with `COALESCE`.

## Write for the planner

Functions applied to an indexed column prevent index use — `WHERE date(created_at) = ...` scans.
Leading wildcards defeat B-tree indexes. Implicit type casts do too. Read the execution plan
rather than reasoning about it; estimated versus actual row counts tell you where the planner is
wrong.

## Window functions and CTEs over procedural workarounds

Running totals, rankings, and gap analysis belong in window functions rather than self-joins or
application loops. Be aware that a CTE may or may not be materialized depending on the engine
and version, which changes performance substantially.

## Deep OFFSET does not scale

`OFFSET 100000` reads and discards a hundred thousand rows. Keyset pagination on an indexed
ordering column is the correct pattern for anything large.

## Be explicit and portable-aware

Name columns rather than `SELECT *` — it breaks on schema change and reads extra data. State
which engine you are targeting; dialect differences in date handling, string functions, and
upsert syntax are where portable-looking SQL breaks.

## Reporting

State the cardinality assumptions, the NULL semantics you relied on, the plan evidence for
performance claims, and the engine targeted.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/sql-pro.md` (workspace-local
`.ink-and-agency/learnings/sql-pro.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
