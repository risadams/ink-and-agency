# Skills ↔ Agents Integration Guide

Skills and Agents are complementary systems in the Ink and Agency ecosystem. This document explains how they work together and how to reference them.

## Core Concepts

### Skills
Reusable prompt extensions that enhance Claude with structured techniques for specific tasks. Skills are **focused capabilities** that solve discrete problems.

**When to use skills:**
- One-off or repetitive focused tasks
- Quick transformations or analyses
- Applying a proven framework or technique
- Cross-cutting concerns (writing quality, planning, communication)
- Augmenting an agent's capabilities

### Agents
Specialized AI assistants configured with domain expertise, capabilities, and a model assignment. Agents are **deep specialists** that own entire domains (backend development, security, data engineering, etc.).

**When to use agents:**
- Complete ownership of a domain or workflow
- Long-running, stateful tasks
- Need for a persistent specialist across multiple turns
- Building or architecting systems
- Debugging or investigating complex problems

## How They Work Together

### Pattern 1: Skill Recommends an Agent
A skill can suggest using an agent for deeper or broader work:

```
Writing-humanize Skill
├─ Remove AI patterns from content
├─ [Suggests: content-quality-editor agent]
├─ For comprehensive content audit
└─ Link to agent for full review
```

**Example:** The writing-humanize skill can recommend the content-quality-editor agent for comprehensive content strategy work.

### Pattern 2: Agent Invokes a Skill
An agent working on a task can invoke a skill to enhance its output:

```
Backend Developer Agent
├─ Designing database schema
├─ [Invokes: code-review skill]
├─ Validate implementation
├─ [Invokes: codebase-explain skill]
└─ Final schema with context
```

**Example:** The backend-developer agent can invoke the code-review skill to validate database migrations before implementation.

### Pattern 3: Skill + Agent Composition
A complex workflow chains multiple skills and agents:

```
Planning Workflow
├─ [Invokes: sprint-plan skill]
├─ Organize work
├─ [Delegates to: project-manager agent]
├─ For comprehensive oversight
├─ [Invokes: backlog-grooming skill]
├─ Prepare validated items
└─ Ready for team coordination
```

## Metadata: Referencing Agents and Skills

### In Skill Files
Skills can declare related agents in their frontmatter:

```yaml
---
name: writing-humanize
description: "Remove AI writing patterns"
version: 2.6.0
allowed-tools:
  - Read
  - Write
  - Edit
related-agents:
  - content-quality-editor    # For comprehensive content audit
  - ai-writing-auditor        # For AI pattern detection
---
```

**Field:** `related-agents` (optional, array of agent names)  
**Purpose:** Hints at which agents can take deeper action

### In Agent Files
Agents can declare related skills in their frontmatter:

```yaml
---
name: content-quality-editor
description: "Comprehensive content quality specialist"
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
related-skills:
  - writing-humanize          # For AI pattern removal
  - writing-tone-check        # For tone calibration
  - writing-social-script     # For message composition
---
```

**Field:** `related-skills` (optional, array of skill names)  
**Purpose:** Hints at which skills complement this agent's work

## Integration Patterns in Practice

### Pattern A: Skill → Agent Escalation
A skill identifies that deeper work is needed and recommends an agent.

In the skill's README or closing section:

```markdown
## Need Deeper Work?

This skill removes AI writing patterns from individual passages. If you need 
**comprehensive content strategy and auditing**, use the 
**[content-quality-editor agent](../agents/08-business-product/content-quality-editor.md)** 
to refactor entire content systems.
```

### Pattern B: Agent → Skill Enhancement
An agent recognizes a cross-cutting task and invokes a skill during its workflow.

In the agent's prompt:

```
## Workflow

When invoked:
1. Implement the backend feature
2. [If writing API documentation]
   → Invoke the writing-humanize skill for polish
3. [If modifying existing code]
   → Invoke the code-review skill for validation
4. Return final implementation with review notes
```

### Pattern C: Agent Composition with Skills
An orchestrator agent uses both agent references and skill invocations:

```yaml
---
name: fullstack-developer
description: "Build complete features end-to-end"
related-skills:
  - code-review
  - architecture-review
---

## Implementation Pattern

1. **Backend layer** — Use backend-developer agent
2. **Validation** — Invoke architecture-review skill
3. **Frontend layer** — Use frontend-developer agent
4. **Polish** — Invoke code-review skill
5. **Documentation** — Invoke writing-humanize skill
```

## Discovery & Navigation

### Finding Related Agents from a Skill
Look for the `related-agents` field in the skill's frontmatter:

```bash
grep -A 5 "related-agents:" writing-humanize/SKILL.md
```

### Finding Related Skills from an Agent
Look for the `related-skills` field in the agent's frontmatter:

```bash
grep -A 5 "related-skills:" agents/08-business-product/content-quality-editor.md
```

### Cross-Reference Documentation
Both integration guides should be referenced:

- **From Skills:** Link to [Agents INTEGRATION.md](../agents/INTEGRATION.md)
- **From Agents:** Link to [Skills INTEGRATION.md](../skills/INTEGRATION.md)

## Governance Rules

### When to Add a Related Agent/Skill

1. **Direct dependency** — One system calls the other by name
2. **Workflow handoff** — Natural escalation from skill to agent or vice versa
3. **Complementary expertise** — The systems address the same problem domain
4. **Documented recommendation** — The relationship is explicitly documented in prose
5. **Bi-directional awareness** — Both systems acknowledge each other (recommended but not required)

### When NOT to Add a Related Agent/Skill

1. **Too distant** — The relationship is tangential or speculative
2. **Not yet implemented** — Don't reference skills/agents that don't exist
3. **Unclear value** — No clear workflow benefit to the user
4. **Generic** — Every skill isn't related to every agent

## Updating Skills for Agent Integration

### Quick Integration Checklist

- [ ] Add `related-agents` field to skill frontmatter (if applicable)
- [ ] Document agent relationships in the skill's README
- [ ] Create a prose section explaining when to escalate to an agent
- [ ] Link to the agent's location (relative path preferred)
- [ ] Validate that agent actually exists and is relevant
- [ ] Consider whether agent should reciprocate with `related-skills`

### Example: Adding Agent References to a Skill

```yaml
---
name: code-review
description: "Review code for quality and security"
version: 2.0.0
allowed-tools:
  - Read
  - Grep
  - Glob
related-agents:
  - code-reviewer
  - security-auditor
  - performance-engineer
---
```

Then in the skill's README:

```markdown
## For Deeper Reviews

This skill provides structural code review guidance. For **comprehensive reviews 
with active refactoring**, use the **[code-reviewer agent](../agents/04-quality-security/code-reviewer.md)**.

For **security-focused audits**, see the **[security-auditor agent](../agents/04-quality-security/security-auditor.md)**.
```

## Future Work

- [ ] Auto-generate `INTEGRATION-MAP.md` from frontmatter across both repos
- [ ] Update skill invocation UI to suggest related agents
- [ ] Create a joint discovery index for "find agent or skill that does X"
- [ ] Build skill composition templates for agents
- [ ] Develop skill→agent escalation workflows
- [ ] Document common composition patterns

---

## See Also

- **[Agents INTEGRATION.md](../agents/INTEGRATION.md)** — Agent perspective on integration
- **[Agents README.md](../agents/README.md)** — Agent discovery and selection
- **[Skills README.md](README.md)** — Skill discovery and usage

---

**Last Updated:** 2026-06-17  
**Status:** Integration framework ready for adoption
