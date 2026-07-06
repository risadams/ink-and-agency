# Domain Language & Glossary

This document defines the terminology used in the agent collection to ensure consistency across documentation, ADRs, and agent definitions.

## Core Concepts

### Agent
A specialized AI assistant configured with domain expertise, capability constraints (tools), and a model assignment. Agents are stored as markdown files with YAML frontmatter in numbered category folders. Each agent has a unique name that becomes its identifier in Claude Code.

Agents are **deep domain specialists** focused on complete ownership of work areas (e.g., backend development, security auditing, data engineering). They handle long-running tasks, architectural decisions, and complex problem-solving.

**Related concept:** Skills (which are focused prompt extensions; see [Agents ↔ Skills Integration](#agents--skills-integration) below).

### Skill
A reusable prompt extension that enhances Claude with structured techniques for specific tasks. Skills are stored in `~/.claude/skills/` and discovered automatically by Claude Code.

Skills are **focused capabilities** that solve discrete, often cross-cutting problems (code review, writing quality, planning frameworks). A skill might be invoked repeatedly within an agent's workflow, or used standalone for one-off tasks.

**Key difference from agents:**
- **Agent:** Owns a domain; has persistence; specialized model and tools
- **Skill:** Solves a focused problem; invoked during workflow; prompt-based technique

**See also:** [Agents ↔ Skills Integration](#agents--skills-integration) and [INTEGRATION.md](INTEGRATION.md).

### Category
A numbered folder (01–10) that groups agents by domain responsibility. Categories are stable, hierarchical containers. New agents belong in existing categories first; new categories should be rare and require ADR decision.

**Valid categories:**
- `01-core-development` — Full-stack, backend, frontend, mobile, desktop, API design, architecture
- `02-language-specialists` — Language/framework experts (Python, TypeScript, Go, etc.)
- `03-infrastructure` — DevOps, cloud, Kubernetes, databases, networking, security ops
- `04-quality-security` — Testing, code review, security auditing, compliance, performance
- `05-data-ai` — Data engineering, ML, AI, analytics, optimization
- `06-developer-experience` — Tooling, build, CLI, documentation, DX, MCP, refactoring
- `07-specialized-domains` — Blockchain, IoT, fintech, gaming, healthcare, niche tech
- `08-business-product` — Product, project management, business analysis, sales, legal, scrum
- `09-meta-orchestration` — Multi-agent coordination, workflow orchestration, state management
- `10-research-analysis` — Research, data analysis, trend analysis, academic literature

### Frontmatter
YAML metadata block (lines 1–6 of each agent file) that defines the agent's identity and constraints:

```yaml
---
name: agent-name                 # Unique identifier; kebab-case; auto-discovered by Claude Code
description: "..."              # When to invoke this agent; discovered during agent selection
tools: Read, Write, Edit, ...    # Comma-separated capabilities (see Tool Permissions below)
model: sonnet                    # Model alias (see Model Assignment below)
---
```

**Required fields:** `name`, `description`, `tools`  
**Optional fields:** `model` (defaults to `sonnet`)

### Tool Permissions
Agents declare which Claude Code tools they can invoke. Tool categories determine role type and cost model.

**Read-only tools** (reviewers, auditors, analysts):
- `Read, Grep, Glob` — Can inspect code and structure without modifying

**Research tools** (additional for analysts, documentation writers):
- `Read, Grep, Glob, WebFetch, WebSearch` — Can fetch external docs and web content

**Code-writing tools** (developers, architects):
- `Read, Write, Edit, Bash, Glob, Grep` — Can modify code and run terminal commands

**Documentation tools:**
- `Read, Write, Edit, Glob, Grep, WebFetch, WebSearch` — Full authoring capability

**Decision:** Tool permissions are assigned per agent role and cannot be customized per instance.

### Model Assignment
Claude Code uses model aliases to balance cost and capability for agent workloads.

- **`haiku`** — Lightweight, fast, cost-efficient. Use for: straightforward agents (ceremonial facilitation, simple analysis), high-volume parallelizable tasks.
- **`sonnet`** — Balanced capability. Use for: most developers and specialists (default).
- **`opus`** — Highest capability. Use for: complex orchestration, code review, advanced architecture, multi-step reasoning.

**Default:** `sonnet` (assumed if not specified in frontmatter)

**Decision:** Model assignment is project-wide policy, not per-agent negotiation. Mismatches are ADR violations.

### Seam
A clear boundary where agent capabilities and constraints are declared. The seam is the frontmatter + agent description. Changes to agents should not require changes to discovery, governance, or CI/CD—the interface enforces invariants.

**Discovery seam:** Categories → Agent catalog (main README) → Individual agent frontmatter  
**Governance seam:** Frontmatter validation (tool/model/name constraints)  
**Composition seam:** Inter-agent communication protocols (defined in individual agents' Communication Protocol sections)

### Locality
Changes to one agent should not ripple across the collection. Frontmatter consistency is achieved through linting, not manual sync. Category READMEs are generated from agent metadata, not maintained by hand.

### Leverage
What callers (Claude Code users) get from the deep interface:
- Discovery without reading every file
- Trust that agents meet quality/consistency standards
- Fast agent selection via categories and descriptions

What maintainers (contributors) get:
- No need to manually update indexes or documentation
- Immediate CI/CD feedback on violations
- Clear patterns for adding agents

---

## Agents ↔ Skills Integration

Agents and Skills are complementary systems that work together in the Ink and Agency ecosystem. Understanding their relationship is key to composing complex workflows.

### When to Use Each

**Use an Agent when:**
- You need complete ownership of a domain
- The task spans multiple turns or requires state
- You need a persistent specialist across workflows
- Building, architecting, or debugging systems
- The task is complex enough to warrant a specialized assistant

**Use a Skill when:**
- You're solving a focused, discrete problem
- The same technique applies across many contexts
- You need a structured framework or template
- The task is quick or one-off
- You're augmenting another agent's capabilities

### Integration Patterns

1. **Agent → Skill:** An agent invokes a skill during its workflow
   - Example: Backend developer agent invokes code-review skill for validation
   
2. **Skill → Agent:** A skill recommends or delegates to an agent for deeper work
   - Example: Writing-humanize skill suggests content-quality-editor agent for comprehensive audits

3. **Composition:** Multiple agents and skills chain together for complex workflows
   - Example: Product manager agent uses assumption-mapping skill, delegates to business-analyst agent, then uses backlog-grooming skill

### Metadata: Declaring Relationships

Agents can declare related skills in their frontmatter using the `related-skills` field:

```yaml
related-skills:
  - code-review
  - architecture-review
```

Similarly, skills can declare related agents in their frontmatter using `related-agents`:

```yaml
related-agents:
  - code-reviewer
  - security-auditor
```

### Finding Integration Details

For complete integration guidance, see **[INTEGRATION.md](INTEGRATION.md)**.

---

## Naming Conventions

### Agent Names
- **Format:** kebab-case, lowercase, unique within the collection
- **Pattern:** `{role}-{specialty}` (e.g., `backend-developer`, `code-reviewer`)
- **Collisions:** Not allowed. Check existing agents before naming.
- **Examples:** `python-pro`, `devops-engineer`, `accessibility-tester`, `multi-agent-coordinator`

### Category Folder Names
- **Format:** `NN-category-name` where `NN` is 01–10 (zero-padded)
- **Immutable:** Category numbers never change; use ADR to justify new categories.

### File Structure
```
agents/
  01-core-development/
    agent-name.md
    README.md
  02-language-specialists/
    agent-name.md
    README.md
  ...
  CONTEXT.md              (this file)
  CLAUDE.md               (governance & contribution workflow)
  README.md               (auto-generated index)
  docs/adr/
    ADR-0001-*.md
    ADR-0002-*.md
    ...
  scripts/
    lint-agents.ps1       (validation)
```

---

## Consistency Standards

### Agent File Standards
1. **Alphabetical order:** Agents within a category are sorted alphabetically by filename
2. **Frontmatter validation:** All required fields present, no typos in tool/model names
3. **Description clarity:** Descriptions are action-oriented ("Use when…") not vague ("A Python expert")
4. **Model justification:** Model assignment must align with role type (see ADR-0002)
5. **Tool minimalism:** Agents declare only tools they actually use

### Category README Standards
Each category README includes:
- Emoji header with brief role description
- "When to Use" section with concrete scenarios
- Bullet list of all agents in the category with descriptions
- Guidance on when to create new agents vs. new categories

**Example structure:**
```markdown
# Category Name

## 🎯 When to Use Category Description Subagents

[Use case scenarios]

## 📋 Available Subagents

### [**agent-name**](agent-name.md) - Brief specialty

[One-sentence description and use guidance]

**Use when:** [Specific scenarios]
```

### Main README Standards
The main README auto-generates from category metadata and includes:
- Project overview (what this is)
- Quick selection guide (table of all categories)
- Full agent index (by category)
- Contributing guidelines (reference to CLAUDE.md)
- Links to CONTEXT.md and ADRs

---

## ADR Conventions

Architectural Decision Records (docs/adr/) capture *why* the codebase is shaped the way it is. When proposing a new agent, category, or policy, check existing ADRs first to avoid re-litigating decisions.

**ADR naming:** `ADR-NNNN-hyphenated-title.md`

**Existing ADRs:**
- ADR-0001: Category taxonomy (why 10 categories, when to add new ones)
- ADR-0002: Model assignment policy (when to use haiku/sonnet/opus)
- ADR-0003: Tool permissions rules (which roles get which tools)
- ADR-0004: Frontmatter invariants (required fields, validation rules)

See `docs/adr/` for full decision history.

---

## References

For contributing a new agent, see CLAUDE.md.  
For architectural decisions, see docs/adr/.  
For quick agent lookup, see the main README or Claude Code's agent selection UI.
