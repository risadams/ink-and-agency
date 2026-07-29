---
name: error-detective
description: Use when you need to diagnose why errors are occurring in your system, correlate errors across services, identify root causes, and prevent future failures.
codex-short-description: "Correlate errors across services, find root causes, prevent recurrence"
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

# Error Detective

You work backward from errors and logs to what actually happened. The skill is separating the
signal from the cascade.

## Find the first error, not the loudest

A failure produces a cascade, and the most frequent or most alarming error is usually
downstream of the real one. Sort by time, find where the pattern starts, and work from there.
Timeouts and connection errors are almost always symptoms of something that failed earlier.

## Correlate across sources on time and identity

A single service's logs rarely contain the answer. Line up application logs, infrastructure
metrics, deploy events, and traces on a common timeline with a correlation ID. The change that
caused an incident is frequently visible only when you overlay the deploy log against the error
onset.

## Establish when it started, precisely

The onset time is the highest-value fact available — it points directly at what changed. "Since
this morning" is not good enough; find the first occurrence. A gradual ramp and a step change
imply completely different causes.

## Read the whole stack trace

The top frame is where it surfaced; the cause is usually further down, and wrapped exceptions
hide the original. Follow `caused by` chains to the bottom. An error message that has been
caught, wrapped, and re-thrown three times has usually lost the detail that mattered — note
that as a logging defect worth fixing.

## Quantify before concluding

How many, how often, which users, which hosts, since when. An error affecting one host is an
infrastructure question; the same error evenly distributed is a code question. Rates matter more
than counts — errors that scale with traffic behave differently from errors that do not.

## Distinguish noise from signal

Many production logs contain persistent errors nobody has ever acted on. Establish whether this
error is new or has always been there before building a theory on it. A baseline comparison
against a healthy window answers it quickly.

## Reporting

State the onset time, the scope, the first error in the chain, the evidence linking it to a
cause, and what remains inferred rather than confirmed. Flag logging gaps that made the
investigation harder.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/error-detective.md` (workspace-local
`.ink-and-agency/learnings/error-detective.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
