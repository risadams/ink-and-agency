# sprint-snapshot — Reference

Detailed contracts that would push `SKILL.md` past 200 lines. Source-of-truth for the canvas layout, JSONL schema, and the matching cascade.

## Canvas layout

Direct port of `Get-Jira-Sprint-Planner.ps1` (lines 80-1037). All coordinates are pixels; positive Y goes down. Coordinates can be negative — Obsidian's canvas extends infinitely. Stick to multiples of 10 for cleaner snap-to-grid.

### Layout constants (PS lines 88-110)

| Constant | Value | Notes |
| :--- | --: | :--- |
| `leftMargin` | 50 | Left edge of all primary content |
| `topMargin` | 50 | Top edge of sprint-overview row |
| `headerHeight` | 120 | Sprint title node |
| `sectionHeaderHeight` | 100 | Section header (Team Members / Sprint Board / Off-Team) |
| `columnHeaderHeight` | 160 | Column heading nodes (TO DO / IN PROGRESS / IN REVIEW / DONE) |
| `teamMemberHeight` | 160 | Team member card |
| `issueCardHeight` | 280 | Single issue card |
| `detailCardHeight` | 360 | Sprint Details / Capacity Tracking cards |
| `verticalSpacing` | 80 | Between same-column issue cards (effective: 80 + 40 = 120) |
| `horizontalSpacing` | 100 | Between board columns |
| `headerToContentSpacing` | 50 | Between a header and its first content row |
| `sectionSpacing` | 150 | Between major sections (overview → team → board) |
| `teamMemberRowSpacing` | 220 | Vertical row pitch in team-member grid |
| `colWidth` | 280 | Sprint-board column width |
| `colSpacing` | `colWidth + horizontalSpacing` = 380 | Center-to-center distance between columns |
| `cardSpacingVertical` | `verticalSpacing + 40` = 120 | Vertical pitch between issue cards |

### Groups (PS lines 226-548)

Five groups, in the order the PS script creates them. Each is a `type: "group"` node added to the `nodes` array (in the JSON Canvas spec, groups are nodes; the PS script tracks them separately as `canvas.groups` for convenience but Obsidian reads them from `nodes`).

| Group ID | Title | Color | Purpose |
| :--- | :--- | :--- | :--- |
| `sprint-header-group` | Sprint Overview | `6` (purple) | Top-row summary cards |
| `team-members-group` | Team Members | `1` (red) | Roster grid with workload counts |
| `sprint-board-group` | Sprint Board | `4` (green) | Kanban columns + issue cards |
| `right-sidebar-group` | Additional Information | `5` (cyan) | Summary table, future risks/impediments |
| `off-team-group` | Off-Team Members | `3` (yellow) | Assignees not on the roster |

### Sprint Overview row (PS lines 234-329)

Three side-by-side cards at `y = topMargin`:

| Node ID | x | y | width | height | color | Content |
| :--- | --: | --: | --: | --: | :-: | :--- |
| `sprint-details-header` | 50 | 50 | 400 | 120 | 5 | `# Sprint <Sprint> Planning` |
| `sprint-details` | 50 | 50 + 120 + 50 = 220 | 400 | 360 | 6 | Sprint dates, duration, capacity, generated timestamp |
| `capacity-tracking` | 50 + 840 = 890 | 50 | 300 | 360 | 3 | Capacity / committed / remaining + last + avg velocity. Updated in Phase 4 with real `committed` value. |
| `velocity-trend` | 890 | 50 + 360 + 80 = 490 | 300 | 260 | 6 | Trend arrows (↗️ / ↘️ / →) computed from `last` vs `avg`. Updated in Phase 4. |

`sprint-details-header` text: literally `# Sprint <N> Planning` where `<N>` is the sprint number. PS script extracts from JQL via regex (`Sprint\s*=\s*(\d+)`); we use the explicit `Sprint` parameter (no regex needed).

`sprint-details` text format:

```markdown
## Sprint Details

**Start:** {SprintStartDate}
**End:** {SprintEndDate}
**Duration:** {N} days
**Capacity:** {SprintCapacity} story points

Generated: {YYYY-MM-DD HH:mm}
```

Duration = `(EndDate - StartDate).TotalDays`, rounded.

`capacity-tracking` text format (initial; updated in Phase 4):

```markdown
## Capacity Tracking

**Total Capacity:** {SprintCapacity} points
**Committed:** {totalStoryPoints} points
**Remaining:** {SprintCapacity - totalStoryPoints} points

**Velocity (Last 3 Sprints):**
- Previous: {LastSprintVelocity} points
- Average: {AvgVelocityLast3} points
```

Append a warning line if `totalStoryPoints > AvgVelocityLast3 * 1.2`:

```markdown

⚠️ **Warning:** Committed points are {N}% higher than average velocity.
```

`velocity-trend` text format (Phase 4 final state):

```markdown
## Velocity Trend

This sprint's committed: **{totalStoryPoints}** points
Last sprint: **{LastSprintVelocity}** points
3-sprint average: **{AvgVelocityLast3}** points

Trend: ↗️ Increasing       ← if last > avg
Trend: ↘️ Decreasing       ← if last < avg
Trend: → Stable            ← if last == avg
```

Trend line is omitted when `LastSprintVelocity == 0`.

### Team Members section (PS lines 331-434)

Header at `y = topMargin + detailCardHeight + sectionSpacing + 260` = `50 + 360 + 150 + 260` = **820**.

| Node ID | x | y | width | height | Content |
| :--- | --: | --: | --: | --: | :--- |
| `team-header` | 50 | 820 | 300 | 100 | `# Team Members` |

Member cards in a 5-column grid starting at `y = 820 + 100 + 50` = **970**:

- Card width: 220
- Card horizontal pitch: 250 (`cardSpacing`)
- Card vertical pitch: 220 (`teamMemberRowSpacing`)
- Card height: 160 (`teamMemberHeight`)
- Color: `1` (red)
- Group: `team-members-group`

Card content (Phase 4 final, after workload aggregation):

```markdown
[[@First Last]]

**Tasks:** {ticketCount}
**Points:** {pointCount}
```

`pointCount` formatting: integer if whole (`5`), one decimal if not (`5.5`). Same rule as PS lines 836-841.

### Sprint Board section (PS lines 436-520)

Positioned at `sprintBoardY = teamMemberY + teamMemberSectionHeight + sectionSpacing` where `teamMemberSectionHeight = sectionHeaderHeight + headerToContentSpacing + (rows * teamMemberRowSpacing)`. For a 9-member team: 1 row of 5, 1 row of 4 → `rows = 2` → height = `100 + 50 + 440 = 590` → board Y = `820 + 590 + 150 = 1560`.

| Node ID | x | y | width | height | color | Content |
| :--- | --: | --: | --: | --: | :-: | :--- |
| `sprint-board-header` | 50 | 1560 | 300 | 100 | (none) | `# Sprint Board` |
| `todo-unassigned-column` | 50 | 1560 + 100 + 50 = 1710 | 280 | 160 | 4 | `## TO DO\n(Unassigned)` |
| `todo-assigned-column` | 50 + 380 = 430 | 1710 | 280 | 160 | 4 | `## TO DO\n(Assigned)` |
| `in-progress-column` | 50 + 760 = 810 | 1710 | 280 | 160 | 3 | `## IN PROGRESS` |
| `in-review-column` | 50 + 1140 = 1190 | 1710 | 280 | 160 | 2 | `## IN REVIEW` |
| `done-column` | 50 + 1520 = 1570 | 1710 | 280 | 160 | 1 | `## DONE` |

### Issue cards (PS lines 781-808)

Each issue becomes one card stacked vertically below the appropriate column header. First card Y = column-header Y + `columnHeaderHeight + verticalSpacing` = `1710 + 160 + 80 = 1950`. Each subsequent card adds `issueCardHeight + cardSpacingVertical = 280 + 120 = 400` to the running Y for that column.

Card metadata:

| Field | Value |
| :--- | :--- |
| `id` | `issue-{KEY}` (e.g. `issue-PROJ-1234`) |
| `type` | `text` |
| `width` | 280 (`colWidth`) |
| `height` | 280 (`issueCardHeight`) |
| `group` | `sprint-board-group` |
| `color` | by status: `Open` → 4, `In Progress` → 3, `In Review` → 2, `Done` → 1, default → 6 |

Card content (port of PS lines 783-786, with `JIRA:` plugin convention added):

```markdown
## [{KEY}] {Summary truncated to ~80 chars}

JIRA:{KEY}

**Assignee:** {DisplayName or "Unassigned"}
**Points:** {storyPoints display}
**Type:** {issuetype.name}
```

Truncation rule: if `summary.length > 80`, truncate at 77 chars and append `…`. Don't truncate inside a word — back up to the last whitespace.

### Edges (PS lines 810-822)

For every issue with a matched assignee (team or off-team), add one edge:

```json
{
  "id": "edge-{KEY}-to-{assigneeNodeId}",
  "fromNode": "issue-{KEY}",
  "fromSide": "right",
  "toNode": "{assigneeNodeId}",
  "toSide": "left"
}
```

Unassigned issues (`assignee == null`) get **no edge** — they live in the TO DO (Unassigned) column with no visual link to anyone.

### Off-team members section (PS lines 522-548, 670-727)

Right of the sprint board, starting at `x = leftMargin + colSpacing*5 + horizontalSpacing` = `50 + 1900 + 100` = **2050**. Y starts at `sprintBoardY` and the section header sits at `offTeamY = sprintBoardY + sectionHeaderHeight + headerToContentSpacing + sectionSpacing` = `1560 + 100 + 50 + 150 = 1860`.

Header (only emitted if at least one off-team assignee was seen):

| Node ID | x | y | width | height | Content |
| :--- | --: | --: | --: | --: | :--- |
| `off-team-header` | 2050 | 1860 | 350 | 100 | `# Off-Team Members` |

Off-team member cards in a 2-column grid below:

- Card width: 180
- Card horizontal pitch: 200 (`offMemberSpacing`)
- Card vertical pitch: 220 (`teamMemberRowSpacing`)
- Card height: 160
- Color: `3` (yellow)
- Group: `off-team-group`

Card content (Phase 4 final):

```markdown
[[@First Last]]

**Tasks:** {ticketCount}
**Points:** {pointCount}
```

### Sprint Summary table (PS lines 964-1008)

One large card on the right sidebar at `(rightSidebarX = 2050, rightSidebarY = sprintBoardY = 1560)`. Width 400, height 700, color `5`, group `right-sidebar-group`. Content is the same `## Sprint Summary` table written to the companion `.md` (Phase 6). Single source of truth: render once, embed in both places.

### Canvas dimensions (PS lines 186-208)

After all nodes are placed, walk every node and compute:

```text
maxX = max(node.x + node.width + 100  for all nodes)
maxY = max(node.y + node.height + 100 for all nodes)
```

Set the canvas `width` and `height` to `max(MinWidth, maxX)` / `max(MinHeight, maxY)` where `MinWidth = 2000`, `MinHeight = 2500`. JSON Canvas spec doesn't require this, but Obsidian uses it as the initial viewport — without it the canvas opens zoomed-out at the origin and the user has to pan.

### Collision detection

The PS script implements `Get-SafePosition` (lines 112-166) which slides nodes right then down on overlap. **The Claude version skips this.** All positions in this spec are pre-computed to be collision-free for the documented team sizes (≤ 15 members) and issue counts (≤ 100). If a future team exceeds these, the canvas may visually overlap — log a warning but emit anyway. Re-implementing the PS sliding algorithm in JS is out of scope for v1.

## `_snapshots.jsonl` schema

Append-only. One JSON object per line, no surrounding array. UTF-8, LF line endings.

### Required fields

```json
{
  "snapshot_at":  "ISO 8601 with offset, e.g. 2026-04-08T09:14:00-04:00",
  "as_of":        "YYYY-MM-DD or null if snapshot reflects 'now'",
  "phase":        "start | week 1 | week 2 | week 3 | end",
  "team":         "TitleCase team name",
  "inc":          28,
  "sprint":       2,
  "capacity":     80.8,
  "committed":    62.5,
  "remaining":    18.3,
  "totals":       { "tickets": 24, "points": 62.5 },
  "by_status": {
    "todo":        { "tickets": 8,  "points": 21,  "assigned": 5, "unassigned": 3 },
    "in_progress": { "tickets": 6,  "points": 15.5 },
    "in_review":   { "tickets": 4,  "points": 11 },
    "done":        { "tickets": 6,  "points": 15 }
  },
  "unassigned":   { "tickets": 3, "points": 8 },
  "tickets_with_points":    20,
  "tickets_without_points": 4,
  "velocity":     { "last": 55, "avg3": 58 },
  "off_team_count": 1
}
```

### Optional fields (add as the skill grows)

| Field | Purpose |
| :--- | :--- |
| `per_member` | `{ "First Last": { "tickets": N, "points": N } }` — enables per-person trend lines |
| `risks` | Free-text list — populated when the skill gains a risks/impediments section |
| `forecast` | `{ "burn_rate_pts_per_day": N, "projected_done_at": "YYYY-MM-DD" }` — for the forecasting feature |
| `jql` | The exact effective JQL used — useful for retroactive debugging if a label set changes mid-sprint |

### Why JSONL and not JSON

Forecasting and trend tools want one row per snapshot, append-only, no risk of corrupting prior history. JSON arrays require rewriting the whole file on every append; JSONL doesn't. Same reasoning Obsidian's daily-notes ecosystem uses for activity logs.

## Identity matching cascade

Identical to `daily-standup-prep`. Use the cascade in [../daily-standup-prep/REFERENCE.md](../daily-standup-prep/REFERENCE.md#identity-matching-cascade) verbatim. Inputs available to the matcher per Jira issue:

- `assignee.emailAddress` (highest-confidence match key)
- `assignee.displayName` (fallback for matching)
- `assignee.name` (Jira username — feeds strategy 8)

If the cascade returns null, the assignee is **off-team** — it gets a yellow card in the off-team group, and its workload accumulates in `offTeamMembersWorkload` (separate from team workload totals on the sprint-overview cards).

## Pre-render validation

Before writing the canvas, the skill should verify:

1. Every node has unique `id`.
2. Every edge's `fromNode` and `toNode` reference an existing node `id`.
3. Every node's `(x + width, y + height)` is within `(canvas.width, canvas.height)` after dimension computation.
4. JSON parses cleanly (round-trip through `JSON.stringify` → `JSON.parse`).
5. No node text contains a literal `\\n` (must be `\n` — see [obsidian-canvas/SKILL.md](../obsidian-canvas/SKILL.md) "Newline pitfall").

`obsidian-canvas` enforces 1-2 and 4-5 by contract. The skill is responsible for 3 (compute via Phase 5 dimensions step).

## `_team-rules.md` (shared with sprint-plan / sprint-sos-report / sprint-review)

Per-team rules note at `{{vault_root}}\Scrum Teams\<Team>\_team-rules.md`. Holds the team-specific semantics that turn raw snapshot data into a meaningful report — overhead members, the wedge ticket convention, in-review overhead exceptions, and any other team-local capacity rules. Editable in Obsidian; read by `sprint-snapshot` (informational) and by every `sprint-*` reporting skill (load-bearing).

### Schema

```yaml
---
team: Aurora
overhead_members:
  - name: Alex Smith
    role: Documentation
    overhead_pct: 100
  - name: Jane Doe
    role: Scrum Master
    overhead_pct: 100
  - name: Jordan Lee
    role: Product Manager
    overhead_pct: 100
  - name: Alex P.
    role: Product Owner
    overhead_pct: 80
  - name: Sam R.
    role: Product Owner
    overhead_pct: 80
  - name: Taylor B.
    role: Product Owner
    overhead_pct: 80
wedge:
  ticket_key: PROJ-9999          # the team's recurring "Sprint Wedge" ticket
  default_points: 15            # nominal per-sprint reserve
  policy: |
    New items added mid-sprint must net against the wedge.
    Net consumption ≤ wedge → not scope creep.
    Net consumption > wedge → scope creep; flag in reports.
in_review_overhead:
  title_patterns:               # case-insensitive substring match on summary
    - "Product Owner - Sprint"
    - "Scrum Master - Sprint"
    - "Wedge"
    - "Release Management"
  policy: |
    Counts against capacity but NOT velocity.
    Fixed point values; expected to close on the sprint end date.
    Do not surface as "stuck in review" in reports.
zero_points_policy: intentional   # 0 means deliberate, not "missing estimate"
release_focus:                    # optional free-text priority guidance
  - "11.3 blockers"
---
# Aurora — team rules
Free-form notes about the team's working agreements, rotations, recurring
known overheads, and any context the SM wants future reports to apply.
```

### Resolution rules

- **Overhead members are matched against snapshot assignees** using the same identity cascade as `sprint-snapshot` Phase 4. Match by full name; if alias is needed, add the member to the roster CSV with the alias and the matcher will follow it. (The names above are illustrative — replace with your team's real members.)
- **Effective capacity per member** = `nominal_capacity × (1 - overhead_pct/100)`. Reports surface both the nominal and effective numbers.
- **`in_review_overhead` items are excluded from "stuck in review" callouts** but still counted in `committed` for capacity tracking. Velocity calculations (used by `sprint-sos-report` and `sprint-review`) **exclude** these items from `done.points`.
- **Wedge balancing** — when comparing two snapshots, sum the points of issues present in `to` but not in `from` (new in-sprint), then subtract any reduction in the wedge ticket's points between the two snapshots. If `Δnew - Δwedge ≤ 0` → not scope creep; > 0 → scope creep, flag with the delta.
- **`zero_points_policy: intentional`** means the report should never warn about 0-point items or suggest they need re-estimation. (If a future team uses 0 to mean "missing", they'd flip this to `missing` and the reports would warn.)

### Bootstrap

If `_team-rules.md` doesn't exist when a sprint-* skill runs, prompt once via `AskUserQuestion`:

> *"No `_team-rules.md` for `<Team>`. Create one with default overhead schema (you can edit later in Obsidian)?"* — options: `Create with defaults (recommended)`, `Skip — run without team rules (less accurate report)`, `Cancel`.

The `Create with defaults` option writes a stub with empty `overhead_members:` and `in_review_overhead:` lists and the wedge policy text, then opens the file's path in the console summary so the user can fill in the team-specific details.

## PS script line-mapping reference

For anyone debugging or extending: each Phase maps cleanly to a slice of the PS source.

| Phase | PS source lines | Description |
| :--- | :--- | :--- |
| 1 | `Sprint-Planner.ps1:30-78` + `Get-Jira-Sprint-Planner.ps1:21-72` | Param resolution, module imports |
| 2 | `Get-Jira-Sprint-Planner.ps1:551-571` | JQL builder + AsOf wrapper |
| 3 | `Get-Jira-Sprint-Planner.ps1:574` | Single `Search-JiraIssue` call |
| 4 | `Get-Jira-Sprint-Planner.ps1:603-823` | Issue loop: parse, match, bucket, accumulate |
| 5 | `Get-Jira-Sprint-Planner.ps1:80-808, 1021-1033` | Canvas construction + JSON serialization |
| 6 | (new) `Sprint Summary` table reformatted into a standalone .md | The PS script only embeds it in the canvas; we extract it for trend tooling |
| 7 | (new) | No PS equivalent — JSONL log is a Claude-skill-only addition |
| 8 | `Get-Jira-Sprint-Planner.ps1:893-903, 1035-1037` | Console summary |
