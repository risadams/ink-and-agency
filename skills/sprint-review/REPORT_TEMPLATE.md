# sprint-review — Sprint review report (the SM's standard template — keep its shape so it pastes into Confluence)

Fill every `{{placeholder}}` from the run's data; keep section order and frontmatter keys. Rules for when and where to write it are in [SKILL.md](SKILL.md).

```markdown
---
team: {{team}}
increment: {{inc}}
sprint: {{sprint}}
report_type: sprint-review
generated: {{YYYY-MM-DD HH:mm}}
start_snapshot: "[[start.canvas]]"
end_snapshot: "[[end.canvas]]"
sprint_config: "[[_sprint]]"
team_rules: "[[../../_team-rules]]"
committed_points: {{n}}
delivered_points_velocity_relevant: {{n}}
commitment_met: {{true|false}}
commitment_ratio_vr: {{0.xx}}
sprint_velocity_raw: {{n}}
sprint_velocity_velocity_relevant: {{n}}
avg_velocity_last_3: {{n}}
scope_creep: {{true|false}}
scope_creep_delta: {{n}}
carry_over_tickets: {{n}}
carry_over_points: {{n}}
council_personas: [{{persona list or "none"}}]
---

> Generated {{generated}} from `start.canvas` ({{start_snapshot_at}}) → `end.canvas` ({{end_snapshot_at}}).

### **Scrum Master**

[{{scrum_master_name}}]({{scrum_master_confluence_url}})

### Summary of Sprint Accomplishments

{{Phase 5 — Summary of Sprint Accomplishments}}

### Feature Demos

{{auto-extracted: list of completed tickets whose issuetype is "Feature" or whose labels include "demo". If none detected, leave a placeholder line: "_No Feature-type tickets completed this sprint — confirm with PO before publishing._"}}

### Significant customer meetings

_To be filled in by the Scrum Master before publishing._

### Status

{{Phase 5 — Status}}

### Did team meet their Sprint Commitment?

{{Phase 5 — Did team meet their Sprint Commitment?}}

Confidence level in team meeting their PI Commitment

{{Phase 5 — Confidence level in team meeting their PI Commitment}}

### Impediments

{{Phase 5 — Impediments}}

### Retro learnings (durable)

{{Phase 5 — Retro learnings (durable)}}
---

## Appendix — Quantitative summary

| Metric | Value |
| :--- | --: |
| Committed (raw / velocity-relevant) | {{n}} / {{n}} pts |
| Delivered (raw / velocity-relevant) | {{n}} / {{n}} pts |
| Sprint velocity (raw / velocity-relevant) | {{n}} / {{n}} pts |
| 3-sprint avg velocity | {{n}} pts |
| Commitment ratio (velocity-relevant) | {{0.xx}} ({{commitment_threshold}} threshold → {{met/missed}}) |
| Wedge consumed | {{n}} pts (verdict: {{balanced/creep}}) |
| Scope added | {{n}} pts ({{n}} tickets) |
| Carry-over | {{n}} tickets ({{n}} pts) |

## Appendix — Carry-over candidates

| Ticket | Owner | Points | Status at sprint end | Suggested action |
| :--- | :--- | --: | :--- | :--- |
| JIRA:PROJ-1234 | [[@First Last]] | 3 | IN PROGRESS | Carry to next sprint |

## Appendix — Embedded snapshots

- ![[start.canvas]]
- ![[end.canvas]]
```
