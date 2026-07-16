---
name: codebase-explain
description: Tell the agent to explain code with broader context and a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
related-skills:
  - codebase-plan-refactor
loop-eligible: false

compatibility: claude-code codex opencode
---

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

This skill learns across invocations — the full contract is
[SELF-EVOLVE.md](../../SELF-EVOLVE.md). **Start:** read the learnings
journal — `~/.ink-and-agency/learnings/codebase-explain.md` and/or the workspace-local
`.ink-and-agency/learnings/codebase-explain.md` — if present, and apply its guidance.
**End:** self-evaluate the results; optionally ask the user for feedback (never
block on it); append signal-bearing learnings to the journal (user-global when
the sandbox allows writing there, workspace-local otherwise); route
skill-improvement ideas per the contract's tiers — edit the canonical source
when one is present, never the plugin cache.

<!-- self-evolve:end -->
