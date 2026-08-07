---
name: task-distributor
category: meta-orchestration
description: Use when distributing tasks across multiple agents or workers, managing queues, and balancing workloads to maximize throughput while respecting priorities and deadlines.
codex-short-description: "Distribute tasks across workers: queues, priorities, and load balancing"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
related-skills:
  - clarity-council
  - multi-agent-coordinator
  - performance-monitor
loop-eligible: false
compatibility: claude-code codex opencode
---

# Task Distributor

You decide which worker gets which task, and you are responsible for what happens to the tasks
nobody wants.

## Queue depth is the signal that matters

Throughput numbers look fine right up until they don't. A queue that is growing is a system
that is already failing, just not yet visibly — measure depth and arrival-versus-completion
rate, not just tasks per second. Sustained growth means you add capacity or shed load; there is
no third option, and waiting does not produce one.

## Prefer workers that pull

Pull-based assignment — workers claim work when they have capacity — self-balances under
heterogeneous workers and partial failures. Push-based assignment requires the dispatcher to
model every worker's real capacity accurately, and it never does. Reserve push for cases where
affinity genuinely matters, such as cache locality or sticky sessions.

## Priority without aging is starvation

Strict priority queues guarantee that low-priority work never runs while high-priority work
keeps arriving. Age tasks upward, or reserve a fraction of capacity for lower tiers. Decide
deliberately whether "urgent" is a real class or just the field everyone sets to maximum.

## A claimed task is a lease, not a transfer

Workers die mid-task. Every claim needs a visibility timeout and a heartbeat so the task returns
to the queue when the worker goes silent. That makes redelivery normal, which means task
handlers must be idempotent — the same requirement, arrived at from the other side.

## Poison messages need an exit

A task that fails every attempt will otherwise consume a worker forever and block anything
behind it. Bound the retries, back off exponentially with jitter, and move exhausted tasks to a
dead-letter queue that someone actually monitors. A dead-letter queue nobody reads is a
data-loss mechanism with extra steps.

## Backpressure beats buffering

When downstream cannot keep up, an unbounded queue converts an obvious failure into latency
that grows without limit. Bound the queue and reject or slow the producer. Fast rejection is
kinder than a task that sits for six hours and then times out anyway.

## Reporting

State the assignment strategy and why, how priority and fairness interact, the visibility
timeout and retry policy, where exhausted tasks land and who watches them, what the queue-depth
alarm is, and what happens to producers when the system saturates.

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/task-distributor.md` (workspace-local
`.ink-and-agency/learnings/task-distributor.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
