# ADR-0001: Category Taxonomy

**Status:** Accepted  
**Date:** 2026-06-17  
**Deciders:** Architecture Review

## Context

The agent collection must organize 100+ specialized AI assistants into discoverable, maintainable groups. Without stable categories, new agents create chaos: Where does a "Python DevOps engineer" go—02-language-specialists or 03-infrastructure? How do we prevent category proliferation?

## Decision

We adopt a **10-category taxonomy** that is:
- **Immutable:** Numbers 01–10 never change; adding a category requires a new ADR
- **Domain-first:** Categories reflect responsibility domains, not tech stacks
- **Orthogonal:** An agent belongs in exactly one primary category, chosen by dominant responsibility

### The 10 Categories

| # | Name | Domain | Primary Use |
|---|------|--------|-------------|
| 01 | core-development | Full-stack, backend, frontend, mobile, desktop, architecture | Building applications |
| 02 | language-specialists | Language/framework expertise (Python, TypeScript, Go, etc.) | Language-specific problems |
| 03 | infrastructure | DevOps, cloud, Kubernetes, databases, networking, ops security | Running systems |
| 04 | quality-security | Testing, code review, security auditing, compliance, performance | Quality gates & security |
| 05 | data-ai | Data engineering, ML, AI, analytics, LLM optimization | Data-driven work |
| 06 | developer-experience | Tooling, build, CLI, documentation, DX, MCP, refactoring | Developer productivity |
| 07 | specialized-domains | Blockchain, IoT, fintech, gaming, healthcare, niche tech | Vertical-specific expertise |
| 08 | business-product | Product, project management, business analysis, sales, legal, scrum | Business & delivery |
| 09 | meta-orchestration | Multi-agent coordination, workflow, state management | Agent-to-agent work |
| 10 | research-analysis | Research, data analysis, trend analysis, academic literature | Discovery & insight |

### Decision Rule: Where Does a New Agent Go?

Use this tree:

```
Is the agent a language/framework specialist?
  YES → 02-language-specialists
  NO  → Is the agent primarily about infrastructure/ops/deployment?
    YES → 03-infrastructure
    NO  → Is the agent primarily about testing/security/compliance?
      YES → 04-quality-security
      NO  → Is the agent primarily about data/ML/analytics?
        YES → 05-data-ai
        NO  → Is the agent primarily about tooling/DX/CLI/documentation?
          YES → 06-developer-experience
          NO  → Is the agent primarily about a vertical domain (blockchain, gaming, healthcare)?
            YES → 07-specialized-domains
            NO  → Is the agent primarily about coordinating multiple agents?
              YES → 09-meta-orchestration
              NO  → Is the agent primarily about research or analysis?
                YES → 10-research-analysis
                NO  → Is the agent primarily about business, product, or project management?
                  YES → 08-business-product
                  NO  → → 01-core-development (catch-all for general app development)
```

### When to Create a New Category

A new category is justified only if:
1. **Orthogonality fails:** An agent genuinely doesn't fit any of the 10 existing categories
2. **Volume emerges:** The category would contain ≥5 agents (to avoid sparse folders)
3. **Governance overhead is worth it:** Cross-category discovery, separate READMEs, linting rules

**Burden of proof:** New categories require ADR proposal and architecture review approval.

## Consequences

### Benefits
- ✅ Stable categorization prevents churn
- ✅ Clear decision tree avoids disputes
- ✅ Immutable category numbers ensure long-term discovery stability
- ✅ Sparse categories are acceptable (e.g., 07-specialized-domains may have 3 agents)

### Trade-offs
- ⚠️ Agent X in category Y feels wrong if you focus on its secondary expertise (e.g., "blockchain-developer" in 07 instead of 02-language-specialists for the Solidity language part). Acceptable; primary responsibility wins.
- ⚠️ Adding a new category requires approval process. This is intentional; categories are governance, not convenience.

## Related ADRs
- ADR-0004: Frontmatter invariants (agents declare which category they're in via folder location)
