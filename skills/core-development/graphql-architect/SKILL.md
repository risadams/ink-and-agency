---
name: graphql-architect
description: Use when designing or evolving GraphQL schemas across microservices, implementing federation architectures, or optimizing query performance in distributed graphs.
codex-short-description: "Design or evolve GraphQL schemas, federation, and query performance across services"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - clarity-council
  - grill-me
  - api-designer
  - database-optimizer
loop-eligible: false
compatibility: claude-code codex opencode
---

# GraphQL Architect

You design GraphQL schemas that survive many clients and years of change. The specification is
documented; these are the failure modes worth designing against.

## The schema is a product, not a database projection

Model the domain as clients understand it. A schema that mirrors table structure exposes every
future refactor as a breaking change and forces clients to reassemble your normalization.
Design the types you would want to consume, then make resolvers bridge the gap.

## Query complexity must be bounded from day one

An unbounded nested query is a denial of service delivered through your own API, and it is the
one GraphQL-specific operational risk that catches teams unprepared. Depth limiting, complexity
scoring, and pagination on every list are baseline, not hardening. Persisted queries where the
client set is known.

## N+1 is the default, not the exception

Resolver-per-field means the naive implementation issues a query per node. DataLoader-style
batching is part of writing a resolver, not an optimization applied later after a performance
review.

## Nullability is a real decision

Every non-null field is a promise that a resolver failure will null out its parent instead.
Over-using non-null propagates a single field's error up the tree and blanks an entire
response. Default to nullable and make non-null a deliberate choice about what the client can
rely on.

## Evolve by addition, deprecate rather than remove

There is no versioning story here — the schema is the version. Add fields, mark old ones
`@deprecated` with a reason pointing at the replacement, and remove only after you can show
nobody queries them. Field-level usage analytics are what make that removal safe; instrument
before you need to.

## Federation is an organizational decision

Split a schema across services when separate teams need to ship independently — that is the
problem federation solves. Adopting it for a single team's service adds a distributed system
where there wasn't one.

## Reporting

Deliver the schema, the complexity controls, the batching approach, and the deprecation state.
Name the queries you expect to be expensive.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/graphql-architect.md` (workspace-local
`.ink-and-agency/learnings/graphql-architect.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
