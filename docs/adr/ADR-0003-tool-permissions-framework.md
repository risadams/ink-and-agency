# ADR-0003: Tool Permissions Framework

**Status:** Accepted  
**Date:** 2026-06-17  
**Deciders:** Capability & Security Review

## Context

Claude Code tools enable different capabilities (file inspection, code editing, terminal access, web fetching). Agents declare which tools they use via the `tools:` frontmatter field. Without policy, tool assignment becomes chaotic: Why does one code-reviewer have `Write` but another doesn't? Can a developer accidentally get `WebSearch` when they shouldn't?

Tool permissions are **security and capability boundaries**—they should be predictable and defensible.

## Decision

We establish **role-based tool permission profiles**. All agents in a role type must use the same profile (exceptions require ADR justification).

### Standard Profiles

#### Profile: Read-Only (Reviewers, Auditors, Analyzers)
**Tools:** `Read, Grep, Glob`

**Role examples:** code-reviewer, security-auditor, architect-reviewer, accessibility-tester, qa-expert

**Rationale:**
- Can inspect code and project structure
- Cannot modify files, run commands, or access external sources
- Provides feedback & observations only
- Safe for high-volume analysis

#### Profile: Research (Analysts, Writers)
**Tools:** `Read, Grep, Glob, WebFetch, WebSearch`

**Role examples:** research-analyst, scientific-literature-researcher, trend-analyst, data-analyst

**Rationale:**
- Everything in Read-Only
- Plus external research (fetch URLs, search web)
- Cannot modify code or run commands
- Safe for gathering external insights

#### Profile: Development (Developers, Architects)
**Tools:** `Read, Write, Edit, Bash, Glob, Grep`

**Role examples:** backend-developer, frontend-developer, python-pro, golang-pro, devops-engineer, microservices-architect

**Rationale:**
- Can modify code (`Write`, `Edit`)
- Can run terminal commands (`Bash`)
- No external web access (avoid surprises)
- Trusted to make architectural changes

#### Profile: Documentation (Writers, Technical Authors)
**Tools:** `Read, Write, Edit, Glob, Grep, WebFetch, WebSearch`

**Role examples:** documentation-engineer, readme-generator, api-documenter

**Rationale:**
- Everything in Development
- Plus external research (`WebFetch`, `WebSearch`)
- Fetch docs to embed or cite
- Write comprehensive guides with current references

#### Profile: Orchestration (Coordinators, Supervisors)
**Tools:** `Read, Write, Edit, Glob, Grep` (or role-specific subsets)

**Role examples:** multi-agent-coordinator, workflow-orchestrator, context-manager

**Rationale:**
- Can read and write (coordinate state)
- Can edit (update shared work)
- May restrict `Bash` if orchestrator doesn't run commands directly
- Typically Development profile or a variant

### Assignment Rules

1. **Determine role type** (read the agent description)
2. **Pick the profile that matches**
3. **Do not mix profiles** (e.g., don't add `WebSearch` to a developer unless justified by ADR)
4. **Use `Bash` sparingly** (only if agent needs to run shell commands; Development and Orchestration profiles include it)

### Exception Process

If an agent truly needs a non-standard profile:
1. Document the reason in the agent's **Communication Protocol** section
2. List the exception in an ADR (e.g., "error-detective gets `WebSearch` to check error databases")
3. Note in frontmatter comments if helpful

**Example exception:**
```yaml
---
name: error-detective
description: "..."
tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch  # Non-standard: WebSearch to check bug dbs & error forums
model: opus
---
```

## Current Tool Inventory

Claude Code provides these tools (not exhaustive):

| Tool | Category | Use |
|------|----------|-----|
| Read | File I/O | Read file contents |
| Write | File I/O | Create new files |
| Edit | File I/O | Modify file contents |
| Bash | Execution | Run shell commands |
| Glob | File I/O | Search filesystem by pattern |
| Grep | File I/O | Text search in files |
| WebFetch | Web | Fetch URL content |
| WebSearch | Web | Search the web |

(Profiles combine these into coherent capability sets.)

## Consequences

### Benefits
- ✅ Predictable permissions per role (no surprises)
- ✅ Security-conscious (read-only agents can't accidentally modify code)
- ✅ Easy to audit (check profile membership)
- ✅ Onboarding clear (new agent? Pick a profile)

### Trade-offs
- ⚠️ Some agents might want flexible profiles (e.g., "code-reviewer who needs WebSearch for vulnerability databases"). Use ADR exception process.
- ⚠️ Adding new tools to Claude Code requires review of this policy.

## Related ADRs
- ADR-0002: Model assignment (orthogonal concern; model and tools are independent constraints)
- ADR-0004: Frontmatter invariants (requires `tools:` to validate against this profile list)
