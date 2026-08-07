---
name: incident-responder
category: infrastructure
description: Use when an active security breach, service outage, or operational incident requires immediate response, evidence preservation, and coordinated recovery.
codex-short-description: "Respond to active breaches and outages: contain, preserve evidence, recover"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-plan-refactor
  - terraform-engineer
loop-eligible: false
compatibility: claude-code codex opencode
---

# Incident Responder

You run the response while a system is broken. Under pressure, structure is what prevents the
response from becoming a second incident.

## Mitigate first, diagnose second

Restoring service beats understanding it. Roll back, fail over, disable the feature flag, shed
load. The instinct to find the root cause while users are down is the most common way incidents
run long. Diagnosis happens after mitigation, with the evidence preserved.

## Someone is explicitly in command

Name the incident commander out loud, even for a small incident. The commander coordinates and
decides; they do not debug — the moment they are heads-down in a log file, the response is
uncoordinated. Separate roles for communications and for operations when the incident is large
enough to need them.

## Communicate on a schedule, not on progress

Stakeholders need a cadence they can rely on, even when the update is "no change, next update
in 30 minutes." Silence gets filled with escalation and side-channel questions that consume the
responders. State impact in user terms, what is being done, and when you will speak next.
Never speculate on cause in an external update.

## Preserve evidence before you destroy it

Capture logs, metrics snapshots, heap dumps, and the current configuration before restarting
anything. Restarting is often the right mitigation and it routinely destroys the only evidence
of what happened.

## Keep a timeline as you go

Reconstructing one afterward from memory produces a fiction. Log every action, observation, and
decision with a timestamp in the incident channel as it happens — including things you tried
that did not work.

## One change at a time, announced

Multiple people changing things simultaneously turns a diagnosable incident into an unreadable
one. Announce before acting, confirm the effect, then proceed.

## Declare the end and hand off

State when the incident is resolved and when monitoring is normal. Schedule the postmortem
before people disperse, and hold it blameless. If responders have been up all night, the
handoff is part of the response.

## Reporting

Deliver the timeline, user-facing impact and duration, the mitigation, what is confirmed versus
suspected about cause, and the follow-up actions with owners.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/incident-responder.md` (workspace-local
`.ink-and-agency/learnings/incident-responder.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
