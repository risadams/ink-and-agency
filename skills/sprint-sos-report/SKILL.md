---
name: sprint-sos-report
description: End-of-week scrum-of-scrums report comparing two sprint snapshots and surfacing key findings, observations, trouble areas, and trends. Auto-detects which two snapshots to compare (most-recent two by snapshot_at) with `--from`/`--to` overrides for re-planning churn comparisons (e.g. compare `week 1` vs a mid-week `week 1.5`). Applies team-specific overhead, wedge-balancing, and in-review overhead rules from `_team-rules.md`. Auto-runs a clarity-council session (statistics-expert + scrum-master + product-owner). Use when user says "scrum of scrums", "sos report", "weekly sprint report", "sprint progress report", or invokes /sprint-sos-report.
related-agents:
  - scrum-master
  - project-manager
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
  - AskUserQuestion
  - Skill
related-skills:
  - sprint-snapshot
  - sprint-plan
loop-eligible: false

---

# Sprint Scrum-of-Scrums Report

Weekly progress report for scrum-of-scrums. Compares two sprint snapshots, applies team-specific rules, and produces a markdown report with findings, trends, and trouble areas. Read-only on Jira (uses already-captured snapshots). Writes one report file into the sprint folder.

This skill is the Claude port of the user's "Scrum of Scrums" prompt template. It expects [sprint-snapshot](../sprint-snapshot/SKILL.md) has produced at least two snapshots in the target sprint folder. Pairs naturally with [sprint-plan](../sprint-plan/SKILL.md) (start-of-sprint) and [sprint-review](../sprint-review/SKILL.md) (end-of-sprint).

## Quick start

```text
/sprint-sos-report                                          → Aurora, current sprint, latest two snapshots
/sprint-sos-report Borealis                                     → single team
/sprint-sos-report Aurora --from "week 1" --to "week 2"     → explicit comparison
/sprint-sos-report Aurora --from "week 1" --to "week 1.5"   → mid-week re-planning churn
/sprint-sos-report Aurora --new-info "Added 2 devs, +10 pts capacity, churn from re-plan"
/sprint-sos-report Aurora --no-council                      → skip clarity-council
```

## Parameters

| Param | Default | Notes |
| :--- | :--- | :--- |
| `Team` | from memory or prompt | Same source as sprint-snapshot |
| `Inc` | latest from `Scrum 📅/INC <N>/` | |
| `Sprint` | latest from `INC <N>/Sprint <N>/` | |
| `From` | second-newest snapshot | By `snapshot_at` in `_snapshots.jsonl` |
| `To` | newest snapshot | By `snapshot_at` |
| `NewInfo` | empty | Free-text context the SM adds (e.g. "added 2 devs", "11.3 blockers identified") — passed to the council and included in the report header |
| `Personas` | `statistics-expert,scrum-master,product-owner,knowledge-manager` | `--no-council` disables |

## Workflow

```text
- [ ] Phase 1: Resolve config + load _sprint.md + _team-rules.md
- [ ] Phase 2: Pick the two snapshots (auto or explicit) + load both canvases + JSONL rows
- [ ] Phase 3: Diff the snapshots (added / removed / moved-status / changed-points / wedge delta)
- [ ] Phase 4: Apply team rules (overhead-adjusted velocity, in-review overhead, wedge balancing)
- [ ] Phase 5: Run clarity-council (findings + trends + trouble areas) unless --no-council
- [ ] Phase 6: Render and write the report
- [ ] Phase 7: Console summary
```

### Phase 1 — Config

Same resolution as `sprint-plan` Phase 1. `_team-rules.md` is **load-bearing here** — wedge balancing, in-review overhead exclusion, and overhead-adjusted velocity all depend on it. Bootstrap if missing (per [sprint-snapshot/REFERENCE.md](../sprint-snapshot/REFERENCE.md#bootstrap)).

### Phase 2 — Pick the snapshots

1. Read `{{output_root}}\_snapshots.jsonl`. Sort rows by `snapshot_at` desc.
2. If `--from` / `--to` were supplied:
   - Match each against the `phase` field. If no match, fall back to filename match (`<phase>.canvas`). If still no match, prompt with the available phases as options.
3. Otherwise pick `[0]` as `to` and `[1]` as `from`. If only one row exists, prompt: `Capture a fresh /sprint-snapshot first` / `Cancel`.
4. Echo the picked pair: *"Comparing Aurora Sprint 2 — `week 1` (2026-04-08) → `week 2` (2026-04-15)."*
5. Load both `<phase>.canvas` files. Parse issue cards exactly as `sprint-plan` Phase 3 (key, summary, assignee, points, status from card color or column position).

### Phase 3 — Diff the snapshots

Build five sets:

| Set | Definition |
| :--- | :--- |
| `added` | Tickets in `to` but not in `from` (by KEY) |
| `removed` | Tickets in `from` but not in `to` |
| `moved_status` | Tickets in both, status changed (e.g. TO DO → IN PROGRESS, IN REVIEW → DONE) |
| `changed_points` | Tickets in both, story points differ (`from.points != to.points`) |
| `assignee_changed` | Tickets in both, assignee differs |

Plus per-status point-flow:

```text
done.points (to)         - done.points (from)         = velocity delta this period
in_progress.points (to)  - in_progress.points (from)  = WIP delta
in_review.points (to)    - in_review.points (from)    = review queue delta
todo.points (to)         - todo.points (from)         = backlog drain
```

Compute per-member delta (tickets and points moved per person) for the workload-shift section.

### Phase 4 — Apply team rules

- **Wedge balancing** — let `Δadded = sum(added.points)`, `Δwedge = max(0, from.wedge_points - to.wedge_points)`. If `Δadded - Δwedge ≤ 0` → "scope balanced via wedge". Else → flag as scope creep with the delta in points and a list of the contributing tickets.
- **Velocity-relevant `done` points** — sum `done.points` from `to`, then **subtract** any DONE issue whose summary matches a `_team-rules.in_review_overhead.title_patterns` entry. This is the number reported as actual velocity for the period.
- **Overhead-adjusted member load** — for any overhead member, surface `nominal vs effective load` so the report doesn't read "X is 100% loaded" when they're intentionally overhead-only.
- **In-review overhead exception** — when computing the "stuck in review" call-out, exclude items matching the in-review overhead patterns. They are *expected* to sit in review until sprint close.
- **Zero-points policy** — `_team-rules.zero_points_policy: intentional` means do not flag 0-point items.

### Phase 5 — Clarity-council

Unless `--no-council`, invoke `clarity-council` via `Skill` with the personas list. Pass:

- The Phase 3 diff sets (added/removed/moved/changed/assignee)
- The Phase 4 derived numbers (velocity-relevant done, scope-creep verdict, per-member load deltas)
- Both `_snapshots.jsonl` rows (`from`, `to`) for raw context
- The trailing `_snapshots.jsonl` window (last 5 rows for trend context)
- The user's `--new-info` text if provided
- Their assignment: *"Produce five short markdown sections: `## Key Findings` (3-7 bullets), `## Observations` (3-5 bullets), `## Possible Trouble Areas` (3-7 bullets, each with severity High/Med/Low), `## Trends` (3-5 bullets — the statistics-expert leads here, with prediction intervals where relevant), and `## Knowledge to Capture` (1-3 bullets — owned by the knowledge-manager, each naming a concrete artifact to update: a runbook line, an ADR draft, a CONTEXT.md entry, or a wiki page; include the confidence that the learning generalises beyond this week). Cite issue keys (JIRA:KEY) for any specific ticket claim. Cite the `--new-info` context when relevant. Strict: no fluff; no knowledge-manager bullet without a target artifact."*

Specifically for the **statistics-expert**: they should compute and surface (1) period velocity vs avg, (2) carry-over rate (tickets in `to` that were also in `from` and not yet done), (3) projected end-of-sprint completion if the current pace holds, with a prediction interval. The persona's `Output Requirements` enforce the "no point estimate without uncertainty" rule.

### Phase 6 — Render and write

Output path: `{{output_root}}\reports\sos-<to-phase>.md`. Phase label is preserved literally (e.g. `sos-week 1.md`, `sos-week 1.5.md`). Same overwrite-prompt rule.

Template:

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

If extending with callouts, dataview, or trend charts, delegate to `obsidian-markdown`.

### Phase 7 — Console summary

```text
=== Aurora Sprint 2 (INC 28) — Scrum-of-Scrums Report ===
Comparing:    week 1 (2026-04-08) → week 2 (2026-04-15)
Velocity:     8 pts done this period (velocity-relevant 8; raw 11 incl. 3 pts overhead)
Scope:        +5 pts added, 4 pts wedge consumed → balanced ✅
WIP shift:    +3 pts in-progress, -2 pts in-review
Council:      statistics-expert + scrum-master + product-owner ✅
Saved:        [sos-week 2.md](Scrum Teams/Aurora/Scrum 📅/INC 28/Sprint 2/reports/sos-week 2.md)
```

## Rules

- **Read-only.** Read snapshots, JSONL, sprint config, team rules. Don't modify any of them; don't call Jira directly.
- **Always cite ticket keys.** Council and skill output must use `JIRA:KEY` for any ticket-specific claim. Reject council responses that fail this rule and re-prompt.
- **Wedge accounting is not optional** when `_team-rules.wedge.ticket_key` is set and present in both snapshots. Compute and report the verdict; the SM uses this to defend scope.
- **Velocity reported is always velocity-relevant** (excludes in-review overhead). Surface raw separately when it differs.
- **Statistics-expert forecasts must include a prediction interval.** Reject point-only velocity forecasts.
- **Never overwrite without confirmation.** Same prompt pattern as the rest of the sprint-* family.
- **Wikilink team members only when the vault note exists** (same `Glob` rule as siblings).

## Edge cases

- **Only one snapshot in the sprint folder** — prompt to capture a fresh one with `sprint-snapshot` first; do not run a single-snapshot "comparison".
- **`from` and `to` are the same snapshot** — refuse and ask for a different pair.
- **`_team-rules.md` missing** — bootstrap prompt; if user picks Skip, run with empty wedge/overhead but flag in console + frontmatter (`team_rules: missing`).
- **Wedge ticket missing from one or both snapshots** — fall back to "wedge accounting unavailable this period" warning; don't fail.
- **`--new-info` includes capacity changes mid-sprint** — capacity-vs-velocity warnings should explicitly account for the delta the SM described. (The council prompt passes the `--new-info` text verbatim so the personas can reason about it.)
- **Mid-week re-planning snapshot** (`week 1.5`) — supported by name. The user captures it via `/sprint-snapshot Aurora --phase "week 1.5"` and then runs `/sprint-sos-report Aurora --from "week 1" --to "week 1.5"`.
- **Council unavailable / `--no-council`** — degrade to direct-LLM analysis; mark `council_personas: [none]` in the frontmatter.

## Related skills

| Skill | Use it for |
| :--- | :--- |
| `sprint-snapshot` | Captures the snapshots this skill compares. **Run before this** at each phase boundary. |
| `sprint-plan` | Sibling — start-of-sprint planning report. Same `_team-rules.md` and `_sprint.md`. |
| `sprint-review` | Sibling — end-of-sprint stakeholder report. Reuses the same scaffolding and rules. |
| `clarity-council` | Phase 5 delegates to it. **statistics-expert** is load-bearing for velocity / carry-over / trend forecasting; the persona's "no point estimate without uncertainty" rule is enforced. Add **`infographics-expert`** to the council when the SoS report needs an embedded burndown / burnup / status-flow Mermaid diagram or a per-member delta bar — they consult statistics-expert for the prediction-interval render and produce the diagram source inline. Pull-list when visuals matter: `statistics-expert + scrum-master + product-owner + infographics-expert`. |
| `obsidian-markdown` | Use when extending the report template with callouts, dataview, embeds. |
| `obsidian-vault` | Use for batch wikilink verification (>15 names). |
| `obsidian-bases` | Use when the user wants a `.base` aggregating SoS reports across sprints — e.g. "show wedge consumption + scope-creep verdicts per sprint for Aurora this PI". |
| `daily-standup-prep` | Pattern parent for vault-write conventions and identity matching. |

