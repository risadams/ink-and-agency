---
name: clarity-council
description: Facilitates structured single-persona or multi-persona consultation for strategy, product, engineering, operations, and risk decisions. Use when the user requests a council, multiple perspectives, persona advice, tradeoff analysis, or iterative clarification and debate.
related-agents:
  - council-single-persona
  - council-multi-persona
  - council-iterative
related-skills:
  - grill-me
  - idea-generate
loop-eligible: false
recurrence-hint: on-demand
---

# Clarity Council: Agent-Based System

This skill routes to three specialized agents in the `${CLAUDE_PLUGIN_ROOT}/agents/00-council/` folder. Use the appropriate agent based on your decision-making need.

## When to use

Use this system when you need any of the following:
- Quick expert opinion from one persona
- Multiple expert viewpoints with synthesis
- Iterative decision-making with clarifications
- Structured tradeoff analysis

Do not use for pure factual lookup with no decision component.

## Which Agent to Use?

### Single Expert Perspective
**Agent**: `council-single-persona`  
**When**: You need focused advice from one expert (quick, 10–15 min)  
**Example**: "As a senior-architect, should we migrate to microservices?"

### Multiple Expert Synthesis
**Agent**: `council-multi-persona`  
**When**: A decision needs multiple viewpoints synthesized (20–30 min)  
**Example**: "Convene a council on Kubernetes adoption."

### Iterative Decision-Making
**Agent**: `council-iterative`  
**When**: You need multi-turn iteration with clarifications (30–60 min, 3–5 turns)  
**Example**: "Run a council on team restructuring. I'll iterate."

## Agent Invocation

Simply invoke the appropriate agent directly:

```
/council-single-persona
  As a product-owner, should we ship this quarter?

/council-multi-persona
  Convene a council on whether to adopt TypeScript.

/council-iterative
  Run a council on payment processor selection. I'll iterate.
```

See the full documentation at `${CLAUDE_PLUGIN_ROOT}/docs/agents/00-council.md` and `${CLAUDE_PLUGIN_ROOT}/docs/agents/00-council-index.md`.

## Output templates

Use these structures exactly unless the user asks for a different format.

### Single persona output

```markdown
summary: <short answer>
advice:
- <point>
assumptions:
- <assumption>
questions:
- <question>
next_steps:
- <action>
confidence: <low|medium|high>
```

### Multi-persona output

```markdown
responses:
- persona: <name>
  summary: <short answer>
  advice:
  - <point>
  assumptions:
  - <assumption>
  questions:
  - <question>
  next_steps:
  - <action>
  confidence: <low|medium|high>

synthesis:
  agreements:
  - <point>
  conflicts:
  - <point>
  risks_tradeoffs:
  - <point>
  next_steps:
  - <action>
```

### Multi-turn discussion output

```markdown
status: <needs_clarification|in_progress|completed>
message: <short user-facing response>
nextAction: <what is needed next>
output:
  <single-persona or multi-persona structure>
state:
  sessionId: <id>
  turn: <number>
  history:
  - <compact turn summary>
```

## Reference Files

Agent documentation:
- `${CLAUDE_PLUGIN_ROOT}/docs/agents/00-council.md` — Comprehensive guide to all agents
- `${CLAUDE_PLUGIN_ROOT}/docs/agents/00-council-index.md` — Quick navigation and decision tree
- `${CLAUDE_PLUGIN_ROOT}/agents/00-council/council-single-persona.md` — Single expert agent
- `${CLAUDE_PLUGIN_ROOT}/agents/00-council/council-multi-persona.md` — Multi-expert synthesis agent
- `${CLAUDE_PLUGIN_ROOT}/agents/00-council/council-iterative.md` — Iterative decision agent

Persona library:
- [${CLAUDE_PLUGIN_ROOT}/references/council-personas/PERSONAS.md](${CLAUDE_PLUGIN_ROOT}/references/council-personas/PERSONAS.md) — Full persona index
- [${CLAUDE_PLUGIN_ROOT}/references/council-personas/GROUPS.md](${CLAUDE_PLUGIN_ROOT}/references/council-personas/GROUPS.md) — Pre-made persona panels
- [${CLAUDE_PLUGIN_ROOT}/references/council-personas/*.md](${CLAUDE_PLUGIN_ROOT}/references/council-personas/) — Individual persona contracts (35+ total)

## Quality checks

Before finalizing a response:
- ensure recommendations tie to stated constraints
- separate assumptions from facts
- include at least one concrete next step
- include at least one explicit risk or tradeoff for non-trivial decisions
- keep terminology consistent with persona names in [${CLAUDE_PLUGIN_ROOT}/references/council-personas/PERSONAS.md](${CLAUDE_PLUGIN_ROOT}/references/council-personas/PERSONAS.md)
