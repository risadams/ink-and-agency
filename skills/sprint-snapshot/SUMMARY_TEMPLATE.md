# sprint-snapshot — Companion markdown summary

Fill every `{{placeholder}}` from the run's data; keep section order and frontmatter keys. Rules for when and where to write it are in [SKILL.md](SKILL.md).

```markdown
---
team: {{team}}
increment: {{inc}}
sprint: {{sprint}}
phase: {{phase}}
snapshot_date: {{YYYY-MM-DD HH:mm}}
as_of: {{as_of_or_blank}}
total_tickets: {{n}}
total_story_points: {{n}}
percent_done_tickets: {{n}}
percent_done_points: {{n}}
canvas: "[[{{phase}}.canvas]]"
---
# Sprint {{sprint}} — {{phase}} snapshot

> Captured {{YYYY-MM-DD HH:mm}} (Pittsburgh){{ as_of? " — as-of " + as_of : "" }}

## Sprint Summary

| Metric | Value |
| :--- | --: |
| Total Tickets | … |
| Total Story Points | … |
| Tickets Done / Open / In Review / In Progress / To Do | … |
| Unassigned Tickets / Points | … |
| % Tickets Done / % Points Done | … |
| Tickets With Points / Without Points | … |
| Points Done / In Review / In Progress / To Do | … |
| Capacity / Committed / Remaining | … |
| Last sprint velocity / 3-sprint avg | … |

## Per-member workload

| Member | Tickets | Points | % of capacity |
| :--- | --: | --: | --: |
| [[@First Last]] | … | … | … |

## Off-team workload

(only rendered if non-empty)

## Velocity trend

(↗️ Increasing / ↘️ Decreasing / → Stable — port of PS lines 305-317)
```
