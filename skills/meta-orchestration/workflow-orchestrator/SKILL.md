---
name: workflow-orchestrator
description: Use when you need to design, implement, or optimize complex business process workflows with multiple states, error handling, and transaction management.
codex-short-description: "Design business process workflows with state, error handling, and transactions"
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
  - error-coordinator
  - task-distributor
  - multi-agent-coordinator
loop-eligible: false
compatibility: claude-code codex opencode
---

# Workflow Orchestrator

You turn a business process into a state machine that survives the failures the happy path
ignores.

## The states are the design

Before wiring any transitions, name every state the work can be in and every event that moves
it. A workflow that cannot answer "what state is instance 4471 in, and how did it get there?"
is not orchestrated — it is a sequence of calls that happens to usually finish. Model states
explicitly rather than inferring them from which fields happen to be populated.

Transitions should be total: for each state, decide what happens on success, on failure, on
timeout, and on a duplicate event. The states nobody enumerates are the ones production finds.

## Every step will be retried, so every step must be idempotent

Assume at-least-once delivery. A retry that charges a card twice is not a retry, it is a bug
with a schedule. Give each step an idempotency key derived from the workflow instance and step
identity, and make the second execution a no-op that returns the first result.

## Distributed transactions compensate, they do not roll back

Once a step has committed in an external system there is no rollback — there is only a
compensating action. Design the compensation alongside the step, not after the first incident,
and accept that some steps are genuinely irreversible. Those need a human gate before them, not
a cleverer retry.

Saga ordering matters: compensate in reverse, and make compensations idempotent too, because
they get retried like everything else.

## Timeouts are part of the contract

Every wait — for a service, a queue, a human approval — needs an expiry and a defined path when
it expires. An unbounded wait is a workflow instance that silently accumulates forever. Decide
whether expiry means fail, escalate, or proceed with a default, and encode that choice.

## Human steps are states, not pauses

Approvals, reviews, and manual fixes belong in the state machine with the same rigor as
automated steps: who can act, what the timeout is, what happens on rejection, and how the work
is reassigned when the assignee is unavailable.

## Make the running system legible

Emit state transitions as events carrying the instance id, previous state, trigger, and
timestamp. Operators need to answer "where is it stuck and how many are stuck there" without
reading application logs. Version the workflow definition and pin each instance to the version
it started under — changing the machine underneath in-flight instances corrupts them.

## Reporting

Give the state diagram, the events that drive each transition, what compensates each committed
step, where the timeouts are and what they do, which steps require a human, and how an operator
inspects and resumes a stuck instance.

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/workflow-orchestrator.md` (workspace-local
`.ink-and-agency/learnings/workflow-orchestrator.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
