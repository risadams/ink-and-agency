# ADR-0002: Model Assignment Policy

**Status:** Accepted  
**Date:** 2026-06-17  
**Deciders:** Cost & Capability Review

## Context

Claude Code exposes three model tiers with different costs and capabilities:
- **haiku:** Fast, cheap, low-complexity reasoning
- **sonnet:** Balanced (cost-capability sweet spot)
- **opus:** Expensive, highest reasoning capability

Agent frontmatter specifies a model assignment. Without policy, assignments become arbitrary: Why is the "code-reviewer" opus but "backend-developer" sonnet? This question shouldn't require per-agent negotiation.

## Decision

We adopt **model assignment rules** based on role complexity and parallelism:

| Model | Role Pattern | Rationale |
|-------|--------------|-----------|
| **haiku** | Lightweight, parallelizable, ceremonial | ✓ Scrum master, data analysts, simple script generation, high-volume tasks (e.g., issue triage sweep) |
| **sonnet** | Standard developer, specialist | ✓ Default for: backend devs, frontend devs, language specialists, infrastructure engineers, security auditors. Most agents. |
| **opus** | High-complexity reasoning, coordination | ✓ Code reviewers, architects, multi-agent coordinators, complex debugging, design decisions under ambiguity |

### Assignment Rules

1. **Start with sonnet** (the default)
2. **Upgrade to opus if:**
   - Agent makes architectural decisions (code-reviewer, architect-reviewer, microservices-architect)
   - Agent orchestrates other agents (multi-agent-coordinator, workflow-orchestrator)
   - Agent handles ambiguous, multi-step reasoning (debugger, error-detective, chaos-engineer)
3. **Downgrade to haiku if:**
   - Agent role is ceremonial/structured (scrum-master facilitating standups, sprint-snapshot gathering data)
   - Agent is used in high-volume parallelizable sweeps (issue triage for 100+ tickets)
   - Agent generates boilerplate with light reasoning (readme-generator, test-automator for simple cases)

### Examples

```yaml
# ✅ Correct assignments
---
name: backend-developer
model: sonnet        # Standard developer—use default
---

---
name: code-reviewer
model: opus          # Makes architectural judgments, reviews security; needs reasoning
---

---
name: scrum-master
model: haiku         # Facilitates ceremonies; parallelizable across teams
---

---
name: python-pro
model: sonnet        # Language specialist; default is correct
---

---
name: multi-agent-coordinator
model: opus          # Orchestrates agents; high reasoning complexity
---
```

## Consequences

### Benefits
- ✅ Cost-justified per role pattern (avoid overspending on simple agents)
- ✅ Predictable inference latency (users know haiku is fastest)
- ✅ No per-agent negotiation; policy is consistent

### Trade-offs
- ⚠️ Some agents near boundaries might feel misjudged (e.g., "performance-engineer" could argue for opus). Policy errs toward sonnet for developers.
- ⚠️ Model capabilities may evolve; review this ADR if haiku/sonnet/opus characteristics change.

## Related ADRs
- ADR-0001: Category taxonomy (orthogonal concern; affects role complexity assessment)
- ADR-0003: Tool permissions (orthogonal concern; both constrain agent scope)
- ADR-0004: Frontmatter invariants (requires `model` field to be validated against this policy)
