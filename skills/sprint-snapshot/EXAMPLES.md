# sprint-snapshot — Examples

Invocation parity with `<scripts-repo>\Sprint-Planner.ps1` and end-to-end walkthroughs of the typical sprint cadence.

## Cadence: 5 snapshots per sprint

The PS script's design intent is one snapshot at each phase boundary. The Claude skill auto-detects the phase from today's date — these examples mirror the PS-script invocations from the `Sprint-Planner.ps1` block comments.

### Day 1 (sprint kickoff)

```text
PS: .\Sprint-Planner.ps1 -Sprint 2 -Label "start" -StartDate "2026-04-01" -EndDate "2026-04-21" -AsOf "2026-04-01"

CC: /sprint-snapshot Aurora --inc 28 --sprint 2 --as-of 2026-04-01
```

The `--as-of` pin freezes the JQL `updated <=` clause so the snapshot reflects what the team committed to, not later edits. Phase auto-derives to `start` (day 0).

### Each Friday during the sprint

```text
PS: .\Sprint-Planner.ps1 -Sprint 2 -Label "week 1" -StartDate "2026-04-01" -EndDate "2026-04-21"

CC: /sprint-snapshot Aurora
```

If today is 2026-04-08 (day 7), phase auto-derives to `week 1`. No `--phase` override needed unless you want to label it differently (e.g. snapshotting on Tuesday but labelling it "week 1").

### End-of-sprint (retro / demo prep)

```text
PS: .\Sprint-Planner.ps1 -Sprint 2 -Label "end" -StartDate "2026-04-01" -EndDate "2026-04-21"

CC: /sprint-snapshot Aurora
```

Phase auto-derives to `end` when today ≥ `EndDate - 1`.

## Multi-sprint patterns

### "Show me every snapshot for INC 28 Sprint 2"

The vault layout makes this trivial — every snapshot lives in the same folder:

```text
Scrum Teams/
└── Aurora/
    └── Scrum 📅/
        └── INC 28/
            └── Sprint 2/
                ├── _sprint.md            ← config (capacity, dates, velocity)
                ├── _snapshots.jsonl      ← append-only trend log
                ├── start.canvas
                ├── start.md
                ├── week 1.canvas
                ├── week 1.md
                ├── week 2.canvas
                ├── week 2.md
                ├── week 3.canvas
                ├── week 3.md
                ├── end.canvas
                └── end.md
```

A future `obsidian-bases` view over `_snapshots.jsonl` produces the trend chart.

### Backfilling missed snapshots

If you forgot to snapshot at `week 1`:

```text
/sprint-snapshot Aurora --as-of 2026-04-08 --phase "week 1"
```

The `--phase` override forces the filename and JSONL `phase` field; the `--as-of` reproduces the JQL state from that day. Since `_snapshots.jsonl` is append-only, the backfilled row will appear *after* later snapshots — sort by `snapshot_at` (the actual time the row was written) vs `as_of` (the date the data reflects) when reading back.

## First-run bootstrap walkthrough

What happens the very first time you run `/sprint-snapshot Aurora --inc 28 --sprint 2`:

1. **Roster bootstrap.** `{{vault_root}}\Scrum Teams\_rosters\Aurora.csv` is missing. Skill prompts: *"Copy from `<scripts-repo>\bin\Teams\Aurora.csv`?"* — accept the recommended option.
2. **Sprint config bootstrap.** `{{output_root}}\_sprint.md` doesn't exist. Skill prompts for **start_date / end_date / capacity / last_sprint_velocity / avg_velocity_last_3** in a single `AskUserQuestion`. Recommended values match the PS script: capacity 80.8, last 55, avg 0. Skill writes `_sprint.md`.
3. **Label set bootstrap.** `reference_team_jira_labels.md` has no row for Aurora. Skill prompts: *"What Jira labels identify Aurora stories?"* — recommended `pyrite,dev_common,dev_feature,doc_feature` (PS script default). Skill writes the row to memory.
4. **Snapshot.** All resolved values flow through Phases 2-8. Three files written; one JSONL row appended.

Subsequent runs in the same sprint reuse `_sprint.md` and the memory rows — no prompts.

## Trend-tracking examples

### "How is committed-vs-actual trending across the sprint?"

Read `_snapshots.jsonl` and pull `(snapshot_at, committed, by_status.done.points)` per row. A simple plot of `done.points / committed` vs `snapshot_at` shows whether the team is converging on done or carrying scope.

### "Velocity forecast for the next sprint"

Across the last N sprints' `end` snapshots: pull `by_status.done.points`. Average to get the predicted next-sprint velocity. Compare to `_sprint.md`'s `capacity` field for the upcoming sprint to flag over-commitment.

### "Scrum-of-scrums one-pager"

For each team's most-recent snapshot:

- Open `<phase>.md` (the companion markdown summary) — it has the headline table.
- Embed the canvas via `![[<phase>.canvas]]` if the consumer wants the visual.
- Link to `_snapshots.jsonl` for the trend tail.

A future `obsidian-bases` dashboard could aggregate these across all teams in `Scrum Teams/*/Scrum 📅/INC <N>/` and render a per-team row.

## Output side-by-side comparison

What lands on disk after a single run vs the PS script:

| File | PS script | Claude skill |
| :--- | :--- | :--- |
| `<phase>.canvas` | ✅ | ✅ (delegated to obsidian-canvas) |
| `<phase>.md` | ❌ | ✅ (companion summary) |
| `_snapshots.jsonl` (append) | ❌ | ✅ (trend log) |
| `_sprint.md` (created on first run) | ❌ | ✅ (config note) |
| Console summary | ✅ (Write-Verbose) | ✅ (formatted block) |

The Claude skill is a strict superset of the PS script — anything you used the PS script for keeps working, plus you get markdown summaries and trend data the PS script never produced.
