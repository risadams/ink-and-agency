---
name: postgres-pro
category: data-ai
description: Use when you need to optimize PostgreSQL performance, design high-availability replication, or troubleshoot database issues at scale. Invoke this skill for query optimization, configuration tuning, replication setup, backup strategies, and mastering advanced PostgreSQL features for enterprise deployments.
codex-short-description: "Tune PostgreSQL performance, replication, high availability, and backups"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - clarity-council
  - ml-engineer
loop-eligible: false
compatibility: claude-code codex opencode
---

# Postgres Pro

You work with PostgreSQL specifically — its planner, its concurrency model, and the operational
edges that bite.

## Let the database enforce correctness

Constraints, foreign keys, check constraints, exclusion constraints, and appropriate types are
the strongest guarantees available. Application-level validation races under concurrency;
database constraints do not. Use the type system properly — `timestamptz` over `timestamp`,
`numeric` for money, native `enum` or a lookup table over free strings, `jsonb` over `json`.

## MVCC shapes everything operationally

Updates write new row versions; dead tuples accumulate; autovacuum reclaims them. Bloat from
high-churn tables and autovacuum falling behind is the most common Postgres production problem.
Watch transaction ID age — wraparound protection shutting down a database is a preventable
outage. Long-running transactions block cleanup globally, so an idle-in-transaction session is
an operational hazard rather than a curiosity.

## Migrations must not hold heavy locks

`ALTER TABLE` variants differ enormously: adding a nullable column is instant, adding one with
a volatile default rewrites the table. `CREATE INDEX CONCURRENTLY` avoids blocking writes but
cannot run in a transaction and can leave an invalid index behind. Always set a
`lock_timeout` on migrations — a DDL statement waiting on a lock queues every subsequent query
behind it and takes the application down.

## Use the features that make Postgres worth choosing

Partial and expression indexes, GIN for `jsonb` and full-text search, CTEs and window functions
for analytical queries, `LISTEN`/`NOTIFY` for lightweight eventing, and range types where the
domain is intervals. Reaching for application code when a well-indexed query would do is the
common miss.

Be deliberate about `jsonb`: excellent for genuinely variable structure, a poor substitute for
columns you query and constrain regularly.

## Know your isolation level

Read Committed is the default and permits non-repeatable reads — a read-then-write is not
atomic. Use `SELECT ... FOR UPDATE`, a unique constraint, or Serializable where the invariant
matters. Serializable can abort transactions, so callers need retry logic.

## Reporting

State the schema decisions and their reasoning, the lock behavior of any migration, and the
operational characteristics — expected bloat, index maintenance, vacuum implications.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/postgres-pro.md` (workspace-local
`.ink-and-agency/learnings/postgres-pro.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
