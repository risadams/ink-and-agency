# Agents ↔ Skills Integration Guide

Agents and Skills are complementary systems in the Ink and Agency ecosystem. This document explains how they work together and how to reference them.

## Core Concepts

### Agents
Specialized AI assistants configured with domain expertise, capabilities, and a model assignment. Agents are **deep specialists** that own entire domains (backend development, security, data engineering, etc.).

**When to use agents:**
- Complete ownership of a domain or workflow
- Long-running, stateful tasks
- Need for a persistent specialist across multiple turns
- Building or architecting systems
- Debugging or investigating complex problems

### Skills
Reusable prompt extensions that enhance Claude with structured techniques for specific tasks. Skills are **focused capabilities** that solve discrete problems.

**When to use skills:**
- One-off or repetitive focused tasks
- Quick transformations or analyses
- Applying a proven framework or technique
- Cross-cutting concerns (writing quality, planning, communication)
- Augmenting an agent's capabilities

## How They Work Together

### Pattern 1: Agent Invokes a Skill
An agent working on a task can invoke a skill to enhance its output:

```
Backend Developer Agent
├─ Designing database schema
├─ [Invokes: codebase-explain skill]
├─ Understanding existing data model
├─ [Invokes: code-review skill]
└─ Final schema with review feedback
```

**Example:** The backend-developer agent can invoke `code-review` to validate database migrations before implementation.

### Pattern 2: Skill Recommends an Agent
A skill can recommend using an agent for deeper work:

```
Writing-humanize Skill
├─ Remove AI patterns from content
├─ [Suggests: content-quality-editor agent]
├─ For comprehensive content audit
└─ Link to agent for full review
```

**Example:** The writing-humanize skill can recommend the content-quality-editor agent for comprehensive content strategy work.

### Pattern 3: Agent + Skill Composition
A complex workflow chains multiple agents and skills:

```
Product Manager Agent
├─ [Invokes: assumption-mapping skill]
├─ Identify risky assumptions
├─ [Delegates to: business-analyst agent]
├─ For deeper validation
├─ [Invokes: backlog-grooming skill]
├─ Prepare validated items
└─ Ready for sprint planning
```

## Metadata: Referencing Skills and Agents

### In Agent Files
Agents can declare related skills in their frontmatter:

```yaml
---
name: backend-developer
description: "Server-side expert for scalable APIs..."
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
related-skills:
  - code-review          # For validating implementation
  - architecture-review  # For design validation
  - performance-optimize # For optimization passes
---
```

**Field:** `related-skills` (optional, array of skill names)  
**Purpose:** Hints at which skills complement this agent's work

### In Skill Files
Skills can declare related agents in their frontmatter:

```yaml
---
name: code-review
description: "Review code for quality and security"
version: 2.0.0
allowed-tools:
  - Read
  - Grep
related-agents:
  - code-reviewer        # For comprehensive reviews
  - security-auditor     # For security-focused audits
---
```

**Field:** `related-agents` (optional, array of agent names)  
**Purpose:** Hints at which agents can take deeper action

## Integration Patterns in Practice

### Pattern A: Skill → Agent Escalation
A skill identifies that deeper work is needed and recommends an agent.

```markdown
## Use an Agent for Deeper Work

This skill handles AI writing pattern removal. For comprehensive content strategy, 
use the **[content-quality-editor agent](../agents/08-business-product/content-quality-editor.md)** 
to audit and refactor entire content systems.
```

### Pattern B: Agent → Skill Enhancement
An agent recognizes a cross-cutting task and invokes a skill.

```
When invoked:
1. [Agent logic here]
2. If output needs quality review:
   → Invoke the code-review skill for validation
3. If content has been written:
   → Invoke the writing-humanize skill for polish
```

### Pattern C: Agent Composition with Skills
An orchestrator agent uses both agent references and skill invocations:

```yaml
---
name: fullstack-developer
description: "Complete feature ownership across database, API, and frontend"
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
related-skills:
  - code-review
  - architecture-review
---

## Workflow

1. **Backend layer:** Coordinate with backend-developer agent
2. **Validate design:** Invoke architecture-review skill
3. **Frontend layer:** Coordinate with frontend-developer agent
4. **Final review:** Invoke code-review skill
```

## Discovery & Navigation

### Finding Related Skills from an Agent
Look for the `related-skills` field in the agent's frontmatter:

```bash
grep -A 5 "related-skills:" agents/01-core-development/backend-developer.md
```

### Finding Related Agents from a Skill
Look for the `related-agents` field in the skill's frontmatter:

```bash
grep -A 5 "related-agents:" skills/code-review/SKILL.md
```

### Integration Index
An optional `INTEGRATION-MAP.md` file (not yet created) could list all agent-skill relationships:

```
| Agent | Skill | Why Related | Pattern |
|-------|-------|-------------|---------|
| backend-developer | code-review | Validate API implementation | Skill validation |
| backend-developer | architecture-review | Design review for schema | Skill validation |
| ...
```

## Loop Method: Integration Extensions

The Loop Method extends the agent↔skill integration framework with three integrated capabilities:

### 1. Delegation Map (in agent/skill files)

Each agent or skill may declare an explicit "Delegation Map" section that shows:
- **Which related items are invoked** and when
- **Why they're invoked** (workflow phase, escalation criterion)
- **Parameter passing** (what context flows from A→B)

Example from a hypothetical sprint-planning workflow:

```markdown
## Delegation Map

| User Need | Delegate Via | Parameters |
|-----------|---|---|
| Daily standup prep | Invoke sprint-snapshot with `--phase daily` | Team, increment, sprint |
| Standup report | Invoke daily-standup-prep with `IncludeSprintPulse=true` | Team, days, vault root |
| Daily briefing | Invoke daily-briefing with `--no-focus-blocks` | Vault root, no calendar drafts |
```

### 2. Internal Quality Loop

Skills and agents may implement a self-evaluation loop:

1. Generate initial output
2. Evaluate against quality criteria (completeness, accuracy, actionability, format)
3. If ≥2 criteria fail, refine and re-evaluate (max 2 iterations)
4. Return best-effort output

This is optional and documented in the skill/agent's "Quality Loop" section.

**Example use case:** A code-review skill might evaluate its findings against criteria:
- Completeness: All major issues identified?
- Accuracy: Findings match the code?
- Actionability: Can developer fix based on guidance?
- Format: Matches review template?

If pass-rate <50%, refine the review and re-evaluate.

### 3. Recurring Execution Support

Skills may declare `loop-eligible: true` + `recurrence-hint: [daily|weekly|on-demand]` to document how they work with the `/loop` recurring execution skill.

Example:

```yaml
---
name: sprint-snapshot
loop-eligible: true
recurrence-hint: weekly
---

## Delegation Map

...

### Recurring Execution

This skill is **loop-eligible: true**. Typical recurrence: **weekly** (per sprint cycle).

Example: `/loop 1w /sprint-snapshot --team Aurora`

Pre-requisites:
- Jira project configured
- Team roster and capacity known
- Vault root configured

State preservation:
- Output canvas, markdown, and JSONL files in vault
- JSONL is append-only (trends preserved across runs)
- Same-day re-runs overwrite canvas/markdown; append JSONL
```

### Implementation Notes

- **Not every skill needs a Delegation Map.** Simple, standalone skills (task-initiation, break-it-down) may not invoke other items.
- **The map is informational.** It documents what the implementation does; it's not validated by linting beyond existence checks.
- **Frontmatter is validated.** All related-skills and related-agents must exist; no circular references; no self-references.
- **Updates propagate through discovery.** Once related-skills/agents are declared in frontmatter, Claude Code's agent/skill selection UI can suggest them automatically.

See [INTEGRATION-GRAPH.md](INTEGRATION-GRAPH.md) for a complete reference graph of all skill↔agent relationships in the repo.

---

## Governance Rules

### When to Add a Related Skill/Agent

1. **Direct dependency** — One system calls the other by name
2. **Workflow handoff** — Natural escalation from skill to agent or vice versa
3. **Complementary expertise** — The systems address the same problem domain
4. **Documented recommendation** — The relationship is explicitly documented in prose

### When NOT to Add a Related Skill/Agent

1. **Too distant** — The relationship is tangential or speculative
2. **Not yet implemented** — Don't reference skills/agents that don't exist
3. **Unclear value** — No clear workflow benefit to the user
4. **Generic** — Every agent isn't related to every skill

## Implementation Checklist

- [ ] Add `related-skills` field to agent frontmatter (if applicable)
- [ ] Add `related-agents` field to skill frontmatter (if applicable)
- [ ] Document the relationship in the agent/skill README
- [ ] Create a prose section explaining when to escalate/delegate
- [ ] Link to the related system's location
- [ ] Validate with `scripts/lint-agents.ps1` or skill validator

## Future Work

- [ ] Auto-generate `INTEGRATION-MAP.md` from frontmatter
- [ ] Update agent selection UI to suggest related skills
- [ ] Update skill invocation to suggest related agents
- [ ] Create skill discovery within agent prompts
- [ ] Build agent-skill composition templates

---

**Last Updated:** 2026-06-17  
**Status:** Integration framework ready for adoption
