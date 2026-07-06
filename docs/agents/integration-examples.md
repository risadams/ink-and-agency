# Agents + Skills: Integration Examples

This document shows practical examples of how agents and skills work together in the Ink and Agency ecosystem.

## Example 1: Backend Development Workflow

**Scenario:** Building a new REST API endpoint with database schema changes.

```
Start: Backend Developer Agent
├─ 1. Understand existing schema
│  └─ Invokes: codebase-explain skill
│     → "Show me the database layer structure"
├─ 2. Design new endpoint and schema
│  └─ Implementation from scratch
├─ 3. Validate implementation
│  └─ Invokes: code-review skill
│     → "Review this API implementation for security and performance"
├─ 4. Understand integration points
│  └─ Invokes: codebase-explain skill
│     → "Show me all services that import from the data layer"
└─ End: Production-ready implementation with validation feedback
```

**Related metadata:**
```yaml
name: backend-developer
related-skills:
  - code-review
  - codebase-explain
```

---

## Example 2: Content & Writing Workflow

**Scenario:** Writing product documentation that needs polish and comprehensive audit.

```
Start: Writing Session
├─ 1. Write initial draft (human or AI-assisted)
│  └─ First pass complete
├─ 2. Remove AI patterns
│  └─ Invokes: writing-humanize skill
│     → "This sounds too robotic. Make it more natural."
├─ 3. Full content audit needed?
│  └─ Suggests: content-quality-editor agent
│     → "For comprehensive documentation strategy and structure review"
└─ Result: Human-written quality content with strategic guidance
```

**Related metadata:**
```yaml
name: writing-humanize
related-agents:
  - content-quality-editor
  - ai-writing-auditor
```

---

## Example 3: Fullstack Feature Development

**Scenario:** Building a new user-facing feature across backend, API, and frontend.

```
Start: Fullstack Developer Agent
├─ 1. Design database layer
│  └─ Backend-specialist work
│  └─ Invokes: code-review skill
│     → "Validate schema design"
├─ 2. Implement API endpoints
│  └─ Backend-specialist work
│  └─ Invokes: code-review skill
│     → "Security and performance review"
├─ 3. Build frontend components
│  └─ Frontend-specialist work
│  └─ Invokes: codebase-explain skill
│     → "Show me component architecture patterns"
├─ 4. Final comprehensive review
│  └─ Invokes: code-review skill
│     → "End-to-end feature validation"
└─ End: Production-ready feature across all layers
```

**Related metadata:**
```yaml
name: fullstack-developer
related-skills:
  - code-review
  - codebase-explain
  - codebase-improve-architecture
```

---

## Example 4: Code Review & Investigation

**Scenario:** Comprehensive code review finds architectural concerns.

```
Start: Code Reviewer Agent (doing full review)
├─ 1. Understand current architecture
│  └─ Invokes: codebase-explain skill
│     → "Show me module dependencies"
├─ 2. Identify churn patterns
│  └─ Invokes: codebase-churn skill
│     → "Which files change most frequently?"
├─ 3. Deeper architectural concerns?
│  └─ Suggests: architect-reviewer agent
│     → "For systematic design evaluation and refactoring recommendations"
└─ Result: Review findings + architectural guidance if needed
```

**Related metadata:**
```yaml
name: code-reviewer
related-skills:
  - codebase-explain
  - codebase-churn
```

---

## Example 5: Planning & Project Coordination

**Scenario:** Product manager planning a quarter of work with technical validation.

```
Start: Project Planning
├─ 1. Map assumptions
│  └─ Invokes: assumption-mapping skill
│     → "What assumptions are we making?"
├─ 2. Get deep analysis
│  └─ Delegates to: business-analyst agent
│     → "Validate these assumptions against market data"
├─ 3. Prepare backlog
│  └─ Invokes: backlog-grooming skill
│     → "Refine stories for sprint readiness"
├─ 4. Project oversight needed?
│  └─ Coordinates with: project-manager agent
│     → "Track timeline, risks, and stakeholder communication"
└─ Result: Validated roadmap with refined, sprintable work
```

---

## How to Discover Related Skills/Agents

### From an Agent
Look in the agent's frontmatter for `related-skills`:

```bash
# Find all related skills for backend-developer
grep -A 5 "related-skills:" ~/.claude/agents/01-core-development/backend-developer.md

# Output:
# related-skills:
#   - code-review
#   - codebase-explain
```

### From a Skill
Look in the skill's frontmatter for `related-agents`:

```bash
# Find all related agents for writing-humanize
grep -A 5 "related-agents:" ~/.claude/skills/writing-humanize/SKILL.md

# Output:
# related-agents:
#   - content-quality-editor
#   - ai-writing-auditor
```

---

## Integration Patterns in Prose

When documenting how an agent or skill relates to another system, use one of these patterns:

### Pattern A: Agent → Skill Enhancement

```markdown
## Implementation Approach

When invoked:

1. Implement the core feature
2. [If code quality validation needed]
   → Invoke the **code-review** skill to validate implementation
3. [If architectural context unclear]
   → Invoke the **codebase-explain** skill to understand existing patterns
4. Return final implementation with feedback
```

### Pattern B: Skill → Agent Escalation

```markdown
## For Deeper Work

This skill removes AI writing patterns from individual passages.

**Need comprehensive content strategy?**  
Use the **[content-quality-editor agent](../agents/08-business-product/content-quality-editor.md)** 
to refactor entire content systems, develop style guides, and establish editorial processes.
```

### Pattern C: Recommendation in README

```markdown
### Related Skills

This agent often works with:
- **code-review** — For validating implementation quality
- **codebase-explain** — For understanding existing code patterns
- **codebase-improve-architecture** — For design improvements

See **[INTEGRATION.md](INTEGRATION.md)** for more composition patterns.
```

---

## Best Practices

### Do

✅ **Keep related lists short** — Include only direct, clear relationships  
✅ **Document the handoff** — Explain why one invokes the other  
✅ **Test the flow** — Verify agents and skills actually exist and work together  
✅ **Update both sides** — If agent A uses skill B, mention it in both frontmatter  
✅ **Use descriptive comments** — "For validation" is better than just "code-review"

### Don't

❌ **Don't create circular references** — Agent A → Skill B → Agent A  
❌ **Don't reference non-existent systems** — Every link should resolve  
❌ **Don't make every skill related to every agent** — Only direct relationships count  
❌ **Don't bury recommendations** — Make escalation paths visible and explicit  
❌ **Don't update frontmatter without prose** — Always document the relationship in narrative text

---

## Future: Auto-Generated Integration Map

In the future, an `INTEGRATION-MAP.md` could be auto-generated from frontmatter:

```markdown
| Agent | Skill | Direction | Purpose |
|-------|-------|-----------|---------|
| backend-developer | code-review | → | Validate API implementation |
| backend-developer | codebase-explain | → | Understand existing patterns |
| code-reviewer | codebase-explain | → | Context before review |
| code-reviewer | codebase-churn | → | Identify unstable areas |
| writing-humanize | content-quality-editor | ← | Escalate for audit |
| ...
```

This would serve as a cross-repository discovery tool.

---

**Last Updated:** 2026-06-17  
**Status:** Examples ready for reference
