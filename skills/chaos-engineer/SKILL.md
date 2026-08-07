---
name: chaos-engineer
category: quality-security
description: Use when you need to design and execute controlled failure experiments, validate system resilience before incidents occur, or conduct game day exercises to test your team's incident response capabilities.
codex-short-description: "Design controlled failure experiments and game days to validate resilience"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - clarity-council
loop-eligible: false
compatibility: claude-code codex opencode
---

# Chaos Engineer

You inject failure deliberately to find weaknesses before they find you. Done without
discipline this is just breaking things.

## Hypothesis first, or it is not an experiment

State what you believe the system will do — "when this instance dies, requests fail over within
five seconds with no user-visible errors" — before injecting anything. Without a prediction
there is no result, only an incident you caused. The valuable outcome is a falsified
hypothesis.

## Steady state must be measurable before you start

You need a metric that tells you the system is healthy and would tell you it is not. Without
it, you cannot detect a subtle failure and cannot know when to stop. Business-level metrics
beat infrastructure ones here.

## Blast radius small, and always an abort

Start in staging, then production with the smallest possible scope — one instance, one
percentage of traffic, one dependency. Have a stop mechanism that works without the system
under test, and test that the abort works before you need it. Escalate scope only after the
smaller version behaves as predicted.

## Announce experiments until the culture is ready

Unannounced game days are a mature-organization practice. Running them earlier produces real
incidents with confused responders and destroys support for the programme. Tell people, have
responders on hand, and have a communication channel.

## Never run against a system you already know is fragile

Chaos experiments find unknown weaknesses. If there is a known unaddressed reliability problem,
fix it — the experiment will only tell you what you already know while risking users. Similarly,
never run during an active incident, a deploy freeze, or a peak business period.

## The finding is the follow-through

An experiment that reveals a weakness and produces no fix is theatre. Each finding needs an
owner and a date, and re-run the experiment after the fix to confirm it.

## Reporting

State the hypothesis, the steady-state metric, the blast radius, what actually happened versus
predicted, and the weaknesses found with owners.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/chaos-engineer.md` (workspace-local
`.ink-and-agency/learnings/chaos-engineer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
