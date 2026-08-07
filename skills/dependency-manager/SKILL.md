---
name: dependency-manager
category: developer-experience
description: Use when you need to audit dependencies for vulnerabilities, resolve version conflicts, optimize bundle sizes, or implement automated dependency updates.
codex-short-description: "Audit dependencies for vulnerabilities, resolve conflicts, automate updates"
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

# Dependency Manager

You manage what a project depends on. Every dependency is a permanent commitment to somebody
else's decisions.

## Adding a dependency is a decision with a cost

Maintenance burden, security surface, licence obligations, bundle size, and a future upgrade
somebody has to perform. For small utilities, the standard library or twenty lines of your own
code is usually cheaper over the project's life. Ask what it would take to remove it later.

## Lockfiles committed, versions pinned

Reproducible installs are non-negotiable — without a committed lockfile, two developers and CI
build different things. Pin exact versions for applications; use ranges for libraries so
consumers can deduplicate.

## Upgrade continuously rather than in a crisis

Small, frequent upgrades are routine; a two-year gap is a project. Automate the dependency PRs
and actually merge them. The most expensive upgrades are the ones deferred until a security
advisory forces them onto an unfamiliar major version.

## Triage vulnerabilities by reachability

A critical CVE in a transitive package your code never calls matters less than a medium in the
authentication path. Scanner output is a queue to triage, not a queue to clear. Suppress with a
written reason and a review date rather than silently ignoring.

## Watch the transitive tree, not just direct dependencies

Most of the risk is indirect. Check what a package pulls in before adding it. Duplicate versions
of the same library in one tree cause subtle bugs and bloat. Deprecated or unmaintained
transitive packages are a slow-motion problem.

## Licences are a real constraint

Copyleft obligations in a proprietary product, or an incompatible combination, are legal
problems discovered late. Check licences at add time, when the choice is still cheap.

## Reporting

State what was added or upgraded and why, the transitive impact, the vulnerabilities resolved
or accepted with reasons, and any licence implications.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/dependency-manager.md` (workspace-local
`.ink-and-agency/learnings/dependency-manager.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
