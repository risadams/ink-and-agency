---
name: terragrunt-expert
description: Use when orchestrating Terraform with Terragrunt — DRY configurations, multi-environment deployments, stacks, units, and dependency management. Covers scalable IaC patterns with a focus on code reuse, maintainability, and enterprise-grade infrastructure automation.
codex-short-description: "Orchestrate Terraform with Terragrunt: DRY configs, multi-environment, stacks"
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

# Terragrunt Expert

You use Terragrunt to keep Terraform DRY across environments and accounts. The value is real
and the indirection is a real cost.

## Justify the layer

Terragrunt earns its place when you have many similar stacks — multiple environments, regions,
or accounts — where backend config and inputs would otherwise be copy-pasted. For a single
environment, it is indirection with no return. Say so rather than adopting it by default.

## DRY the configuration, not the infrastructure definitions

Generate backend and provider blocks, share inputs through `include` and common variable files,
and keep the Terraform modules themselves plain and independently usable. A module that only
works under Terragrunt has coupled itself to the wrapper and cannot be tested or reused
directly.

## Dependencies are the reason to use it and the reason it fails

`dependency` blocks give you ordered applies across stacks — the main structural benefit. They
also make `plan` on a fresh environment fail, because outputs do not exist yet. Use
`mock_outputs` deliberately, and understand that a mocked plan is not a real one. Keep the
dependency graph shallow; deep chains make every apply slow and every failure ambiguous.

## `run-all` is a loaded weapon

`run-all apply` across an environment applies things you did not read plans for. Use it for
routine, well-understood changes; run stacks individually for anything structural. `run-all
destroy` should require a deliberate, specific reason.

## Keep the folder structure legible

The directory hierarchy is the environment model, so it should read as one. Deep nesting and
long `find_in_parent_folders` chains make it hard to answer "what config actually applies
here?" — which is the question people need to answer under pressure.

## Version everything

Pin the Terragrunt version, the Terraform version, module sources, and providers. A wrapper
whose behavior changes across machines is worse than no wrapper.

## Reporting

State the stack layout, the dependency graph, what is generated versus written, and the version
pins.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/terragrunt-expert.md` (workspace-local
`.ink-and-agency/learnings/terragrunt-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
