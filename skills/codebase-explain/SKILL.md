---
name: codebase-explain
description: Tell the agent to explain code with broader context and a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
related-agents:
  - architect-reviewer
  - code-reviewer
related-skills:
  - request-refactor-plan
loop-eligible: false

---

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

