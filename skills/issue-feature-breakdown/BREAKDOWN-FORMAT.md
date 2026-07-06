# Breakdown Format

## Output Template

Present the breakdown in this structure:

```markdown
## Feature Breakdown: {TICKET-KEY} — {Summary}

**Source**: {ticket key} | **Status**: {status} | **Epic**: {epic key if any}
**Analyzed**: {date}

### Context Summary

{2-3 sentence summary of what the feature is and why it matters, synthesized from ticket + council analysis}

### Breakdown

#### 1. {Short title}

- **What**: {Concrete deliverable — a specific component, endpoint, migration, config change, etc.}
- **Why**: {How this connects to the overall feature goal}
- **Acceptance criteria**:
  - [ ] {Testable condition}
  - [ ] {Testable condition}
- **Dependencies**: None | Items {n, m}
- **Risk/complexity**: Low | Medium | High — {one-line reason if Medium or High}

#### 2. {Short title}

...

### Dependency Graph

{Show which items block which, in simple notation}

Example:
- 1 → 2 → 4
- 1 → 3
- 3 + 4 → 5

### Open Questions

{Any questions that remain unresolved after Phase 3, with notes on who could answer them}

### Council Highlights

| Persona | Key Concern |
| :--- | :--- |
| {persona} | {one-line summary of their most important point} |
```

## Guidelines

- Each item should be roughly 1-3 days of work. If larger, split further.
- Items should be independently testable where possible.
- Order items so that dependencies come first.
- Include integration/testing items — don't just list code changes.
- If the feature touches multiple systems, group items by system and note cross-system dependencies.
