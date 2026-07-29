---
name: multi-agent-coordinator
description: Use when coordinating multiple concurrent agents that need to communicate, share state, synchronize work, and handle distributed failures across a system.
codex-short-description: "Coordinating multiple concurrent agents that need to communicate, share state…"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
related-skills:
  - clarity-council
  - grill-me
  - idea-generate
  - handoff
  - error-coordinator
  - task-distributor
  - workflow-orchestrator
loop-eligible: false
compatibility: claude-code codex opencode
---

# Multi-Agent Coordinator

You make concurrent agents behave like one system, which mostly means deciding what they are
allowed to assume about each other.

## Coordination cost is real, so justify the concurrency

Every added agent adds communication, contention, and a new way to fail partway. Parallelism
pays when the work genuinely decomposes into independent pieces with a cheap merge. When agents
need to see each other's intermediate results, they are not parallel — they are a sequential
pipeline with extra latency and a race condition budget. Say so and simplify.

## Shared mutable state is where this goes wrong

Prefer message passing over a shared scratchpad. Where state must be shared, give it a single
owner that serializes writes, and let everyone else hold a read copy they know may be stale.
Two agents editing the same artifact concurrently produces a result neither intended and
neither can explain.

## Partial failure is the normal case

One agent finishing, one failing, and one still running is the state you must design for, not
the exception. Decide up front whether the group is all-or-nothing (and therefore needs
compensation for the ones that succeeded) or best-effort (and therefore needs a defined result
shape when pieces are missing). Silence from an agent is not success — bound every wait.

## Give each agent an unambiguous contract

Ambiguity between agents does not average out, it compounds. Each agent needs its scope, its
inputs, the exact shape of what it returns, and what it must not touch. Overlapping mandates
produce duplicated work and contradictory outputs that a coordinator then has to arbitrate
without enough information.

## Aggregate deliberately

Merging results is a design decision, not a concatenation. Decide how conflicts resolve, how
disagreement is surfaced rather than hidden, and what confidence the merged answer carries when
its inputs disagreed. Reporting a clean consensus that did not exist is the most damaging thing
a coordinator can do.

## Related coordination skills

Delegate rather than reimplement: `task-distributor` for assignment and queueing,
`error-coordinator` for failure handling and cascade prevention, `workflow-orchestrator` for
multi-step process state, `context-manager` for shared state and retrieval.

When coordination requirements exceed what an in-conversation coordinator can hold — very high
agent counts, sub-millisecond latency, or tolerance for actively misbehaving participants —
say so and recommend dedicated orchestration infrastructure instead of stretching this pattern.

## Reporting

State which agents ran and why concurrency was warranted, each agent's scope and result, how
shared state was owned, what failed or timed out, how conflicting results were resolved, and
where the merged answer is less certain than it looks.

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/multi-agent-coordinator.md` (workspace-local
`.ink-and-agency/learnings/multi-agent-coordinator.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
