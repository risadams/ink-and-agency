# sprint-plan — Planning report

Fill every `{{placeholder}}` from the run's data; keep section order and frontmatter keys. Rules for when and where to write it are in [SKILL.md](SKILL.md).

```markdown
---
team: {{team}}
increment: {{inc}}
sprint: {{sprint}}
report_type: sprint-plan
generated: {{YYYY-MM-DD HH:mm}}
source_canvas: "[[start.canvas]]"
sprint_config: "[[_sprint]]"
team_rules: "[[../../_team-rules]]"
total_tickets: {{n}}
total_points: {{n}}
velocity_relevant_points: {{n}}
carry_over_points: {{n}}
new_commit_points: {{n}}
carry_over_pct: {{0.xx}}
capacity: {{n}}
prior_sprint_end_canvas: "[[../../Sprint {{prev_sprint}}/end.canvas]]"
council_personas: [{{persona list or "none"}}]
---
# Sprint {{sprint}} Plan — {{team}} (INC {{inc}})

> Captured from `start.canvas` at {{snapshot_at}}. Generated {{generated}}.
> Carry-over derived from `Sprint {{prev_sprint}}/end.canvas` ({{prev_end_snapshot_at_or_"unavailable"}}).

## Sprint at a glance

| Metric | Value |
| :--- | --: |
| Capacity | {{capacity}} pts |
| Committed | {{committed}} pts |
| Velocity-relevant (excl. in-review overhead) | {{velocity_relevant}} pts |
| ↳ Carry-over from Sprint {{prev_sprint}} | {{carry_over_points}} pts ({{carry_over_pct}}%) |
| ↳ New commit this sprint | {{new_commit_points}} pts |
| Last sprint velocity | {{last_velocity}} pts |
| 3-sprint avg velocity | {{avg_velocity}} pts |
| Tickets committed | {{n}} ({{carry_over_ticket_count}} carry-over 🔄) |
| Unassigned | {{n}} ({{n}} pts) |

{{capacity_warning_if_committed_>_avg_velocity_*_1.2}}

## Carry-over from Sprint {{prev_sprint}}

> All unclosed items from the previous sprint are assumed to carry into this one.

| | Key | Summary | Prev. status | Now | Owner | Pts |
| :-: | :--- | :--- | :--- | :--- | :--- | --: |
| 🔄 | JIRA:PROJ-1100 | … | IN REVIEW | IN REVIEW | [[@First Last]] | 2 |
| 🔄 | JIRA:PROJ-1107 | … | IN PROGRESS | TO DO (Assigned) | [[@First Last]] | 5 |
…

**Carry-over WIP risk:** {{carry_over_in_progress + carry_over_in_review}} of {{total_tickets}} tickets ({{xx%}}) start the sprint already-WIP. {{flag_if_>30%}}

**Stale-priority check:** the council has flagged carry-over items that may no longer be the right priority (see Risks).

{{Phase 3 by-status block}}

{{Phase 3 by-member block}}

## Wedge & Overhead

- Wedge ticket: `JIRA:{{wedge_key}}` ({{wedge_points}} pts reserved)
- Overhead members: {{list with effective vs nominal}}
- In-review overhead items (excluded from velocity): {{list}}

{{Phase 5 Infographics block — Mermaid charts per "Charts required" spec}}

{{Phase 5 Key Observations block}}

{{Phase 5 Risks block}}

## Next snapshots

This report covers the **start** snapshot. Recommended cadence:
- `/sprint-snapshot {{team}}` at end of each sprint week (auto-detects phase)
- `/sprint-sos-report {{team}}` at end of weeks 1, 2, 3
- `/sprint-review {{team}}` at sprint close
```
