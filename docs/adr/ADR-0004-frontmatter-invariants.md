# ADR-0004: Frontmatter Invariants & Validation

**Status:** Accepted  
**Date:** 2026-06-17  
**Deciders:** Quality & Governance Review

## Context

Each agent file starts with YAML frontmatter that declares its identity and constraints. Without validation rules, frontmatter becomes inconsistent:
- Typos in model names (`sonnet` vs `sonette`)
- Missing required fields (`description` omitted)
- Invalid tool names (`WebFecth` instead of `WebFetch`)
- Agents out of alphabetical order within a category
- Name collisions or unsafe characters

This creates friction for discovery, tooling, and governance.

## Decision

We establish **frontmatter invariants** and an automated validation script (lint-agents.ps1) to enforce them.

### Required Fields

Every agent MUST declare:

```yaml
---
name: agent-name                    # Required; unique kebab-case identifier
description: "When to use this..."  # Required; action-oriented, ≥10 words
tools: Read, Write, Edit, ...       # Required; comma-separated valid tools
---
```

**Validation rules:**

| Field | Format | Rules | Example |
|-------|--------|-------|---------|
| `name` | kebab-case | Unique within collection; no spaces/underscores; matches filename | `backend-developer` |
| `description` | String | Action-oriented ("Use when…"); ≥10 words; ≤150 chars | `"Use when building server-side APIs…"` |
| `tools` | Comma-list | Space-separated valid tools (see ADR-0003) | `Read, Write, Edit, Bash, Glob, Grep` |
| `model` | Enum | Optional; defaults to `sonnet`; valid: `haiku`, `sonnet`, `opus` | `sonnet` |

### Optional Fields

Agents MAY declare:

```yaml
model: sonnet                       # Optional; defaults to "sonnet"
```

### File-Level Rules

- **Filename:** Must match `name` field (e.g., `backend-developer.md` for `name: backend-developer`)
- **Location:** Must be in a valid category folder (`01-core-development/`, `02-language-specialists/`, etc.)
- **Ordering:** Agents within a category MUST be alphabetically sorted by filename
- **Uniqueness:** `name` must be unique across all categories (no duplicates)

### Tool Validation

Valid tools are:
- `Read` — File reading
- `Write` — File creation
- `Edit` — File modification
- `Bash` — Shell commands
- `Glob` — Filesystem pattern search
- `Grep` — Text search
- `WebFetch` — URL fetching
- `WebSearch` — Web search

Tools MUST match a valid profile (see ADR-0003). Linter warns if profile is non-standard.

### Name Validation

Agent names must:
- Be lowercase kebab-case (alphanumeric + hyphens only)
- Not start or end with hyphens
- Be ≤50 characters
- Avoid collision with existing names
- Match the filename (minus `.md` extension)

### Validation Workflow

1. **Pre-commit hook** (optional): Runs `scripts/lint-agents.ps1` locally before commit
2. **CI/CD check** (GitHub Actions): Runs linter on PR; blocks merge if violations found
3. **Manual check** (code review): Human reviews alignment with ADRs (e.g., category choice, model assignment rationale)

### Lint Script Output

```powershell
# lint-agents.ps1
# Checks all agents and reports violations

# Example output:
[ERROR] 02-language-specialists/python-pro.md: "model" field is invalid: "python" (expected: haiku, sonnet, opus)
[ERROR] 03-infrastructure/devops.md: Filename doesn't match name field: "devops-engineer"
[WARNING] 01-core-development/backend-develeoper.md: Out of alphabetical order (comes after "backend-developer")
[ERROR] 04-quality-security/code-reviewer.md: Duplicate name found in 01-core-development/code-reviewer.md
[OK] All agents validated: 0 errors, 0 warnings
```

## Consequences

### Benefits
- ✅ Automated enforcement (no manual checks)
- ✅ Immediate PR feedback (catch errors before merge)
- ✅ Consistent metadata (makes discovery reliable)
- ✅ Low friction for contributors (linter tells you exactly what to fix)

### Trade-offs
- ⚠️ Requires linting script maintenance if Claude Code tools change
- ⚠️ Strict rules might feel excessive, but consistency is worth it

## Related ADRs
- ADR-0001: Category taxonomy (location in folder structure is validated here)
- ADR-0002: Model assignment (model field validated against policy)
- ADR-0003: Tool permissions (tools field validated against profile list)
