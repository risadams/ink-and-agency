# CLAUDE.md — Governance & Contribution Guide

This file documents governance, standards, and contribution workflow for the Claude Code agent collection.

## 🎯 Quick Links

- **[README.md](README.md)** — Main index & agent discovery
- **[CONTEXT.md](CONTEXT.md)** — Domain vocabulary & consistency standards
- **[INTEGRATION.md](INTEGRATION.md)** — How agents work with skills
- **[INTEGRATION-EXAMPLES.md](INTEGRATION-EXAMPLES.md)** — Practical integration patterns
- **[docs/adr/](docs/adr/)** — Architectural Decision Records
  - [ADR-0001: Category Taxonomy](docs/adr/ADR-0001-category-taxonomy.md)
  - [ADR-0002: Model Assignment Policy](docs/adr/ADR-0002-model-assignment-policy.md)
  - [ADR-0003: Tool Permissions Framework](docs/adr/ADR-0003-tool-permissions-framework.md)
  - [ADR-0004: Frontmatter Invariants](docs/adr/ADR-0004-frontmatter-invariants.md)

## Project Overview

This is a curated collection of 150+ Claude Code subagent definitions—specialized AI assistants for specific development tasks. Subagents are markdown files with YAML frontmatter that Claude Code discovers and loads automatically.

All agents follow strict governance rules to ensure consistency, discoverability, and predictable behavior.

## Repository Structure

```text
.github/
  workflows/
    lint-agents.yml        # CI/CD validation on PR/push
CONTEXT.md                 # Domain vocabulary & consistency standards
CLAUDE.md                  # This file
README.md                  # Main agent index (auto-generated)
docs/
  adr/
    ADR-0001-*.md         # Category taxonomy decision
    ADR-0002-*.md         # Model assignment policy
    ADR-0003-*.md         # Tool permissions framework
    ADR-0004-*.md         # Frontmatter invariants
scripts/
  lint-agents.ps1         # Local validation script
01-core-development/      # Backend, frontend, fullstack, mobile, etc.
02-language-specialists/  # Language/framework experts (TypeScript, Python, etc.)
03-infrastructure/        # DevOps, cloud, Kubernetes, etc.
04-quality-security/      # Testing, security auditing, code review
05-data-ai/               # ML, data engineering, AI specialists
06-developer-experience/  # Tooling, documentation, DX optimization
07-specialized-domains/   # Blockchain, IoT, fintech, gaming
08-business-product/      # Product management, business analysis
09-meta-orchestration/    # Multi-agent coordination
10-research-analysis/     # Research and analysis specialists
```

## Subagent File Format & Frontmatter

Each subagent file requires YAML frontmatter with these fields:

```yaml
---
name: agent-name                                    # Required: kebab-case, unique, ≤50 chars
description: "Use when X..."                        # Required: action-oriented, 10-200 chars
tools: Read, Write, Edit, Bash, Glob, Grep        # Required: comma-separated valid tools
model: sonnet                                       # Optional: haiku, sonnet, or opus (default: sonnet)
---

You are a [role description]...

[Agent-specific guidance, patterns, checklists]

## Communication Protocol
[How to invoke this agent, what responses to expect]

## Development Workflow
[Implementation approach and patterns]
```

### Frontmatter Requirements (ADR-0004)

| Field | Required | Format | Rules |
|-------|----------|--------|-------|
| `name` | ✓ | kebab-case | Unique; lowercase; alphanumeric + hyphens; ≤50 chars |
| `description` | ✓ | String | Action-oriented ("Use when…"); 10-200 chars |
| `tools` | ✓ | List | Comma-separated valid tools; must match one of the tool profiles (see ADR-0003) |
| `model` | ✗ | Enum | `haiku`, `sonnet`, or `opus`; defaults to `sonnet` |

### Frontmatter Extensions: Loop Method (ADR-0005)

The Loop Method adds three new optional frontmatter fields to enable:
1. **Skill Integration:** Declare which skills this agent invokes or recommends
2. **Agent Composition:** Declare collaboration with other agents
3. **Self-Improvement:** Support for iterative quality loops

#### New Fields

| Field | Required | Type | Rules | Example |
|-------|----------|------|-------|---------|
| `related-skills` | No | Array[string] | Comma-separated skill names; must exist; 0-5 typical | `related-skills: [code-review, codebase-explain]` |
| `related-agents` | No | Array[string] | Comma-separated agent names; must exist; 0-3 typical | `related-agents: [backend-developer, database-architect]` |
| `loop-eligible` | No | Boolean | Default: `false`. Only `true` for orchestration agents (09-*) | `loop-eligible: false` |

#### Validation Rules

- **Existence check:** Both `related-skills` and `related-agents` values must correspond to actual files in the repo
- **No self-reference:** An agent cannot list itself in `related-agents` or `related-skills`
- **No circular chains:** Linting detects and rejects A→B→A patterns
- **Cardinality bounds:** >6 related items require ADR justification
- **Type correctness:** `related-skills` must be skill names; `related-agents` must be agent names

See [INTEGRATION.md](INTEGRATION.md) for delegation patterns and [INTEGRATION-GRAPH.md](INTEGRATION-GRAPH.md) for the complete reference graph.

### Valid Tool Permissions (ADR-0003)

Agents must use one of these standard tool profiles:

- **Read-Only:** `Read, Grep, Glob` (reviewers, auditors)
- **Research:** `Read, Grep, Glob, WebFetch, WebSearch` (analysts, researchers)
- **Development:** `Read, Write, Edit, Bash, Glob, Grep` (developers, architects)
- **Documentation:** `Read, Write, Edit, Glob, Grep, WebFetch, WebSearch` (technical writers)
- **Orchestration:** `Read, Write, Edit, Glob, Grep` (coordinators)

**Non-standard profiles require ADR justification.**

### Model Assignment Policy (ADR-0002)

| Model | Use For | Examples |
|-------|---------|----------|
| `haiku` | Lightweight, parallelizable tasks | scrum-master, data-analyst in batch mode |
| `sonnet` | Standard developers & specialists | backend-developer, python-pro (default) |
| `opus` | Complex reasoning & orchestration | code-reviewer, multi-agent-coordinator |

## File Organization

1. **Location:** Agent must be in a valid category folder (01–10)
2. **Filename:** Must match the `name` field (e.g., `backend-developer.md`)
3. **Ordering:** Agents within a category must be in alphabetical order
4. **Uniqueness:** Agent names must be unique across all categories

## Validation & Quality Assurance

### Local Validation

Before committing, run the linting script:

```powershell
.\scripts\lint-agents.ps1 -Verbose
```

The script validates:
- ✓ YAML frontmatter completeness & correctness
- ✓ Filename matches `name` field
- ✓ Valid category location
- ✓ Alphabetical ordering within category
- ✓ Unique agent names
- ✓ Valid `model` values (haiku/sonnet/opus)
- ✓ Valid tool permissions against profiles
- ✓ Description clarity & length

### Loop Method Validation

The linting script validates Loop Method fields (ADR-0005):

```powershell
.\scripts\lint-agents.ps1 -Verbose
```

Checks:
- ✓ `related-skills` values are valid skill names (exist in skills/)
- ✓ `related-agents` values are valid agent names (exist in agents/)
- ✓ No circular reference chains (A→B→C→A rejected)
- ✓ No self-references
- ✓ If `loop-eligible: true`, agent is in 09-meta-orchestration
- ✓ Cardinality warnings if >6 related items

### CI/CD Validation

GitHub Actions runs linting on every PR and push:
- Workflow: [.github/workflows/lint-agents.yml](.github/workflows/lint-agents.yml)
- Failures block merges
- Comments on PR with results

### Code Review Checklist

When reviewing new agents or changes, verify:

- ✓ **Category choice** — Is this the right category? Use ADR-0001 decision tree
- ✓ **Model justification** — Does the model assignment follow ADR-0002?
- ✓ **Tool minimalism** — Are all declared tools actually used?
- ✓ **Description clarity** — Is it action-oriented and specific?
- ✓ **ADR compliance** — Does it contradict any existing ADRs?
- ✓ **Linting passes** — CI/CD validation successful?

## Contributing a New Agent

### Step 1: Choose the Category

Use the decision tree in [ADR-0001](docs/adr/ADR-0001-category-taxonomy.md) to find the right category. If no category fits, you may need to propose a new one (rare—requires ADR).

### Step 2: Check for Duplicates

```powershell
# Search for similar agent names
Get-ChildItem -Path . -Filter "*.md" -Recurse | Select-String -Pattern "^name:" | Select-Object Filename, Line
```

### Step 3: Create the Agent File

1. Create `XX-category/agent-name.md` (replace XX and agent-name)
2. Add YAML frontmatter with all required fields
3. **Loop Method (optional):** Add `related-skills`, `related-agents`, and `loop-eligible` fields if this agent invokes skills or collaborates with other agents
4. Write agent description (1-2 paragraphs)
5. Add "Communication Protocol" section (how to invoke, what responses to expect)
6. Add "Development Workflow" section (implementation approach)
7. **Loop Method (optional):** Add "Delegation & Skill Integration" section to document which skills/agents are invoked and why

### Step 4: Update Category README

Add an entry to `XX-category/README.md` in alphabetical order:

```markdown
### [**agent-name**](agent-name.md) - Short specialty

One-sentence description and guidance on when to use this agent.

**Use when:** Specific scenarios where this agent excels.
```

### Step 5: Validate Locally

```powershell
.\scripts\lint-agents.ps1 -Verbose
```

Fix any errors or warnings before proceeding.

### Step 6: Submit PR

1. Create a pull request with your changes
2. Include in commit message: `Adds [agent-name] to [XX-category]`
3. Reference relevant ADRs if needed (e.g., "ADR-0002: haiku model justified for batch processing")
4. CI/CD pipeline runs automatically; wait for green ✓

### Example PR Checklist

```markdown
- [ ] Agent name is unique
- [ ] Filename matches `name` field
- [ ] Category is correct (per ADR-0001)
- [ ] Model assignment justified (per ADR-0002)
- [ ] Tool profile is standard (per ADR-0003)
- [ ] Frontmatter passes linting
- [ ] Category README updated (alphabetically ordered)
- [ ] Local validation passes: `.\scripts\lint-agents.ps1`
- [ ] No duplicate agent names
```

## Domain Vocabulary

Before creating or reviewing agents, familiarize yourself with the domain language in [CONTEXT.md](CONTEXT.md):

- **Agent** — A subagent definition file with frontmatter
- **Category** — A numbered folder (01–10) grouping agents by domain
- **Frontmatter** — YAML metadata block defining agent identity & constraints
- **Tool Permissions** — Declare which Claude Code tools the agent can invoke
- **Seam** — Clear interface boundary where constraints are enforced
- **Locality** — Changes to one agent shouldn't ripple across the collection
- **Leverage** — What value the agent provides to users and maintainers

See [CONTEXT.md](CONTEXT.md) for full glossary.

## Architectural Decisions

This collection is governed by ADRs that record "why" decisions were made:

- **[ADR-0001: Category Taxonomy](docs/adr/ADR-0001-category-taxonomy.md)** — Why 10 categories; when to add new ones; decision tree for placement
- **[ADR-0002: Model Assignment Policy](docs/adr/ADR-0002-model-assignment-policy.md)** — When to use haiku/sonnet/opus; cost-capability tradeoff
- **[ADR-0003: Tool Permissions Framework](docs/adr/ADR-0003-tool-permissions-framework.md)** — Why role-based tool profiles; which roles get which tools
- **[ADR-0004: Frontmatter Invariants](docs/adr/ADR-0004-frontmatter-invariants.md)** — Validation rules; required fields; format standards

**When proposing new categories, models, tool permissions, or policies, check existing ADRs first.** If you need to override an ADR, create a new ADR explaining why (e.g., "ADR-0005: Override to add 11th category for X reason").

## Tool Assignment by Role Type

## Subagent Storage in Claude Code

|Type|Path|Scope|
|:-----|------------------|:------------------|
|Project|`.claude/agents/`|Current project only|
|Global|`~/.claude/agents/`|All projects|

Project subagents take precedence over global ones with the same name.

---

## Summary: Full Contribution Workflow

1. **Read [CONTEXT.md](CONTEXT.md)** — Learn domain vocabulary
2. **Review relevant ADRs** — Understand decisions for your domain
3. **Run linting locally** — `.\scripts\lint-agents.ps1 -Verbose`
4. **Submit PR with changes**
5. **Wait for CI/CD ✓** — GitHub Actions validates automatically
6. **Address feedback** — Code reviewers verify ADR compliance
7. **Merge** — Your agent is now discoverable in Claude Code

**For questions:** Check CONTEXT.md, read the relevant ADR, or open an issue.
