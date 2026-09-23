# sprint-sos-report — Scrum-of-scrums report

Fill every `{{placeholder}}` from the run's data; keep section order and frontmatter keys. Rules for when and where to write it are in [SKILL.md](SKILL.md).

```markdown
---
team: {{team}}
increment: {{inc}}
sprint: {{sprint}}
report_type: scrum-of-scrums
generated: {{YYYY-MM-DD HH:mm}}
from_snapshot: "[[{{from_phase}}.canvas]]"
to_snapshot: "[[{{to_phase}}.canvas]]"
sprint_config: "[[_sprint]]"
team_rules: "[[../../_team-rules]]"
period_velocity: {{n}}
avg_velocity: {{n}}
scope_creep: {{true|false}}
scope_creep_delta: {{n}}
council_personas: [{{persona list or "none"}}]
---
# Scrum-of-Scrums — {{team}} Sprint {{sprint}} ({{to_phase}})

> Comparing `{{from_phase}}` ({{from_snapshot_at}}) → `{{to_phase}}` ({{to_snapshot_at}}). Generated {{generated}}.

{{new_info_callout_if_provided}}

## Period at a glance

| Metric | From | To | Δ |
| :--- | --: | --: | --: |
| Total tickets | {{n}} | {{n}} | {{±n}} |
| Total points | {{n}} | {{n}} | {{±n}} |
| Done points (raw) | {{n}} | {{n}} | {{±n}} |
| Done points (velocity-relevant, excl. overhead) | {{n}} | {{n}} | {{±n}} |
| In-review points | {{n}} | {{n}} | {{±n}} |
| In-progress points | {{n}} | {{n}} | {{±n}} |
| To-do points | {{n}} | {{n}} | {{±n}} |
| Wedge points remaining | {{n}} | {{n}} | {{±n}} |

## Scope changes

- **Added this period:** {{n}} tickets ({{n}} pts) — {{list with JIRA:KEYs}}
- **Removed this period:** {{n}} tickets ({{n}} pts) — {{list}}
- **Wedge consumed:** {{n}} pts
- **Verdict:** {{"Scope balanced via wedge ✅" | "⚠️ Scope creep — Δ{{n}} pts beyond wedge"}}

## Status transitions

| Ticket | From | To | Pts |
| :--- | :--- | :--- | --: |
| JIRA:PROJ-1234 | TO DO | IN PROGRESS | 3 |
…

## Per-member workload delta

| Member | Tickets Δ | Points Δ | Notes |
| :--- | --: | --: | :--- |
| [[@First Last]] | +2 | +5 | … |
…
*(Overhead members shown with both nominal and effective load.)*

{{Phase 5 Key Findings}}
{{Phase 5 Observations}}
{{Phase 5 Possible Trouble Areas}}
{{Phase 5 Trends}}
{{Phase 5 Knowledge to Capture}}

## Embedded snapshots

- ![[{{from_phase}}.canvas]]
- ![[{{to_phase}}.canvas]]
```
