# Agent-Skill Integration Graph

A complete reference of all agent↔agent and agent↔skill relationships, organized by domain.

**Last updated:** [Auto-generated during Wave 0]  
**Maintenance:** Update frontmatter `related-skills` and `related-agents` fields in agent and skill files. This reference is populated as waves progress.

---

## Overview

- **153 agents** across 11 categories (00–10)
- **50 public skills** across multiple domains
- **Relationships:** Mapped below as waves complete
- **Status:** Wave 0 infrastructure in place; waves 1–7 will populate this graph

---

## Integration Status by Wave

| Wave | Target Files | Status | Completion |
|------|--------------|--------|-----------|
| 0 | Governance + linting | ✅ Complete | 100% |
| 1 | 15 orchestration agents | ✅ Complete | 100% |
| 2 | 19 core dev + language specialists | ✅ Complete | 100% |
| 3 | 35 quality/infrastructure agents | 🟡 In Progress | 23% (8 agents) |
| 4 | 29 data/AI/specialized agents | 🟡 In Progress | 14% (4 agents) |
| 5 | 33 business/DX agents | 🟡 In Progress | 12% (4 agents) |
| 6 | 12 research/analysis agents | ⏳ Ready to bulk-update | 0% |
| 7 | 50 skills | 🟡 In Progress | 16% (8 skills) |

---

## By Domain (Placeholder - Populates During Waves)

### 00-Council (3 agents, 1 skill)

**Agents:**
- council-single-persona
- council-multi-persona
- council-iterative

**Skill:**
- clarity-council

**Relationships:**
```
[Populated in Wave 1]
```

### 01-Core Development (12 agents)

**Agents:** [List populates in Wave 2]

**Related Skills:** [Populated in Wave 2]

---

## Circular Dependencies

**Status:** None detected. Graph is acyclic (validated by linting).

---

## Orphans (No Declared Relationships)

**Status:** [TBD after waves complete]

Isolated skills/agents that don't reference others (OK by design; some skills are standalone).

---

## High-Cardinality Nodes (>6 Related Items)

| Node | Type | Count | Justification |
|------|------|-------|---------------|
| clarity-council | Skill | [TBD] | Central decision engine; invoked across all domains |
| good-morning | Skill | [TBD] | Morning orchestrator; high-level entry point |
| [TBD] | ... | ... | ... |

---

## By Invocation Pattern

### Star Topology (Central Hub)
Hub invokes spokes; spokes don't invoke hub.

- **clarity-council** ← all decision-making skills [Wave 7]
- **good-morning** ← sprint/daily workflow [Wave 7]
- **sprint-snapshot** ← daily/weekly orchestrators [Wave 7]

### Mesh Topology (Peer Group)
Peers invoke each other.

- **Writing domain:** writing-* skills interconnected [Wave 7]
- **Obsidian domain:** obsidian-* skills interconnected [Wave 7]
- **Issue domain:** issue-* skills as peer group [Wave 7]

### DAG Topology (Directed Acyclic Graph)
Strict ordering; no back-edges.

- **good-morning → sprint-snapshot → daily-standup-prep → daily-briefing** [Wave 7]

---

## How to Update This Graph

1. Edit the agent or skill frontmatter to add/remove `related-skills` or `related-agents`
2. Run the linting script to validate changes
3. Regenerate this file:
   ```powershell
   .\scripts\gen-integration-graph.ps1
   ```
4. Commit the changes

---

## Notes

- This file will be auto-regenerated as waves complete
- Populate domains in order of wave completion
- Keep cardinality analysis updated for future optimization
- High-cardinality nodes (>6 related items) should have justification in their agent/skill files
