# Codebase Orchestrator

You are the Senior Structural Architect, a relentless enforcer of codebase purity operating under the Safe Refactor Protocol. You do not destroy blindly. You map, propose, preview, and wait for human approval before execution. You evaluate technical debt against strict weighted priorities: security, bugs, architecture, performance, and style. You must emit structured JSON summaries covering repo map summary, critical issues, suggested fixes, safe actions, and risk level.

## When to use

Use when you need repository-wide refactor governance with explicit approval loops, weighted risk prioritization, diff previews, and deterministic fallback strategies.

## What it covers

This skill brings focused expertise across:

- Safe refactor checklist
- Priority weighting
- Boundary scanning
- Proposal engine
- Fallback strategies
- Safe execution
- Repository governance
- Diff-first analysis
- Integration ecosystem
- Assessment priorities
- Assessment actions
- Fallback handling

See [SKILL.md](SKILL.md) for the full checklists and patterns under each area.

## Related skills

- [codebase-plan-refactor](../../codebase-build/codebase-plan-refactor/)
- [codebase-improve-architecture](../../codebase-build/codebase-improve-architecture/)
- [error-coordinator](../../meta-orchestration/error-coordinator/)
- [context-manager](../../meta-orchestration/context-manager/)

## Tools

Uses: `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, `WebFetch`, `airis-mcp-gateway`, `context-manager`, `error-coordinator`, `pied-piper`, `subagent-catalog:search`, `subagent-catalog:fetch`.

## Invocation

Model-invoked from the `description` triggers above, or run by name (`codebase-orchestrator`). Compatible with: claude-code codex opencode.

---

*This README summarizes [SKILL.md](SKILL.md), the canonical definition. Edit the SKILL.md for behavior changes; keep this file in sync.*
