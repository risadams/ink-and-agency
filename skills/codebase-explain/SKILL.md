---
name: codebase-explain
description: Tell the agent to explain code with broader context and a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
related-skills:
  - codebase-plan-refactor
  - architect-reviewer
  - code-reviewer
loop-eligible: false

compatibility: claude-code codex opencode
---

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).
