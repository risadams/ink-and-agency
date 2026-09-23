# Daily Standup Prep — Sprint Pulse (Phase 4.5)

Read when `IncludeSprintPulse` is on (the default; `--no-sprint-pulse` turns it off). Produces the three pulse placeholders consumed by Phase 6.

Skip entirely if `IncludeSprintPulse` is off — substitute empty strings for the three pulse placeholders in Phase 6.

**Step 1 — Daily sprint snapshot.** Invoke the `sprint-snapshot` skill via `Skill` for the current team with `--phase "daily"`. This writes `daily.canvas` + `daily.md` to the team's current sprint folder (overwriting yesterday's `daily.*` is fine — the trend record lives in `_snapshots.jsonl`) and appends a row to that JSONL trend log. The JSONL is the burndown's data source. If `sprint-snapshot` fails (Jira down, sprint config missing, etc.), surface the failure in the console summary, render `_Sprint pulse unavailable — daily snapshot failed._` for `{{burndown_chart}}`, leave the other two pulse placeholders empty, and continue. Never fabricate trend data.

**Step 2 — Read trend data.** Read the team's `_snapshots.jsonl` from `{{output_root}}\<TeamTitleCase>\Scrum 📅\INC {Inc}\Sprint {Sprint}\_snapshots.jsonl`. Parse the rows for the current sprint only (filter by `inc` + `sprint`). Extract `(snapshot_at, remaining, totals.points, by_status.done.points)` per row. Also pull `capacity`, `velocity.last`, and `velocity.avg3` from the most recent row. If the JSONL has fewer than 2 rows for this sprint, the burndown will be a single point — note this in the rendered output, do not fake additional data points.

**Step 3 — Run clarity-council.** Invoke the `clarity-council` skill via `Skill` with three personas: `infographics-expert`, `statistics-expert`, `scrum-master`. Pass the parsed JSONL trend rows, sprint config (`StartDate`, `EndDate`, `Capacity`, `LastSprintVelocity`, `AvgVelocityLast3`), the day count (`day X of 21`), and the current matched-activity summary from Phase 4 as the council's shared context. Ask each persona for a tightly scoped artifact:

- **infographics-expert** → render an **Obsidian Charts plugin** burn-up chart following the **exact shape below**. The chart uses a `chart` code fence (Chart.js backend via the `obsidian-charts` community plugin, which must be installed in the vault). Burn-up (not burn-down) is the canonical shape because it visualizes scope changes explicitly — your sprints regularly take +20–40 pts of scope creep, which burn-down folds into a misleading "remaining" line.

  **Burn-up chart contract** (must be followed verbatim; no creative reinterpretation):

  1. **Determine actual data points.** From the JSONL trend rows, build a list `samples = [(day_n, scope_points, done_points), …]` where `day_n` is integer days since `StartDate` (Pittsburgh local, `day_0 = StartDate`), `scope_points = totals.points`, `done_points = by_status.done.points`. Sort by `day_n`. De-duplicate by `day_n` keeping the latest `snapshot_at` per row.
  2. **Build the x-axis.** Full sprint range — `x_axis = list(range(0, sprint_length_days + 1))` where `sprint_length_days = (EndDate - StartDate).days`. The x-axis always spans day 0 → day `sprint_length_days`, regardless of how far into the sprint we are.
  3. **Build the actual scope series.** For each `day_n` in `x_axis`:
     - If `day_n ≤ today_n` AND a sample exists for `day_n`: use the sample's `scope_points`.
     - If `day_n ≤ today_n` AND no sample exists (weekend/holiday/gap): carry forward the previous day's `scope_points` value (last-known wins).
     - If `day_n > today_n` (future): emit `null`.
  4. **Build the actual done series.** Same logic as scope, but using `done_points`. Day 0 defaults to `0` if no sample exists.
  5. **Build the pinned scope series** (visually distinct future segment). For each `day_n` in `x_axis`:
     - If `day_n < today_n`: emit `null`.
     - If `day_n ≥ today_n`: emit today's actual `scope_points`. (The series starts at today's point so the line connects visually from the actual series.)
  6. **Build the pinned done series.** Same logic as pinned scope, but using `done_points`.
  7. **Build the capacity reference series.** Constant `Capacity` across all `len(x_axis)` days.
  8. **Y-axis bounds.** `y_min = 0`, `y_max = ceil(max(all actual scope values + [Capacity]) * 1.1)` so the highest point isn't flush with the top edge.
  9. **Title.** None at the chart level (the markdown heading carries it). Set the surrounding section heading to `### Burn-up`.
  10. **Validate before emitting.** Confirm all five series have length `len(x_axis)`; confirm `null` is used (not `None` / `NaN` / empty string) for future-day gaps in the "actual" series and past-day gaps in the "pinned" series; confirm every non-null value is finite and inside `[y_min, y_max]`. If any check fails, do not emit the chart — emit a one-line markdown note explaining what failed, and surface it so the run can be debugged.

  **Reference template** (substitute the computed values; this is the only acceptable shape):

  ````markdown
  ### Burn-up

  ```chart
  type: line
  labels: ["0","1","2",...,"<sprint_length_days>"]
  series:
    - title: "Scope (actual)"
      data: [<scope values for days 0..today_n; null for days today_n+1..end>]
    - title: "Done (actual)"
      data: [<done values for days 0..today_n; null for days today_n+1..end>]
    - title: "Scope (pinned — no future data)"
      data: [<null for days 0..today_n-1; today's scope repeated for days today_n..end>]
    - title: "Done (pinned — no future data)"
      data: [<null for days 0..today_n-1; today's done repeated for days today_n..end>]
    - title: "Capacity (<Capacity> pts)"
      data: [<Capacity repeated len(x_axis) times>]
  tension: 0.2
  width: 100%
  labelColors: false
  fill: false
  beginAtZero: true
  bestFit: false
  yTitle: "Points"
  xTitle: "Sprint day (0 = <StartDate>, <sprint_length_days> = <EndDate> close)"
  yMin: 0
  yMax: <y_max>
  ```

  **Reading the chart**:

  - **Solid lines (days 0–<today_n>)** = actual snapshot data. <One-sentence summary of scope trajectory: trim, creep, what drove changes>. Done climbs ~<observed pts/day> pts/day average.
  - **Past gaps** (if any: weekend/holiday days with no snapshot) are carry-forward — value held from the previous day.
  - **Pinned lines (days <today_n>–<sprint_length_days>)** = today's values held flat, NOT a forecast. The visible gap between Scope (<today_scope>) and Done (<today_done>) at day <sprint_length_days> = ~<gap> pts that would land in next sprint at observed cadence.
  - **Capacity (<Capacity> pts)** = horizontal reference; scope is currently <+/-N> vs capacity.
  - **What it would take to close the sprint**: done line would need to climb +<gap> pts in <days_remaining> days (~<required pts/day> pts/day) — <compare to historical velocity>. <Sprint N+1 carry-over recommendation if gap > observed-cadence × days-remaining>.
  ````

  Chart.js (via the `obsidian-charts` plugin) renders each series in a distinct color, so the "actual" and "pinned" segments are visually different even though they share the chart. The `null` values create true gaps in the line, so past/future are visually separate. **Do not** add `chartjs:` style overrides unless the user explicitly asks — the default rendering is the canonical shape.

  **Plugin dependency.** The `chart` code fence requires the `obsidian-charts` community plugin enabled in the vault (folder: `{{vault_root}}/.obsidian/plugins/obsidian-charts/`). On first run, verify via `Glob` that the plugin folder exists. If missing, surface a one-line warning in the console summary and emit the chart anyway — Obsidian will render the raw YAML as a code block until the plugin is installed, which is recoverable. Do not fall back to Mermaid `xychart-beta` — the historical shape is inferior and the user has explicitly chosen Charts plugin going forward.

  **Single-sample case.** If only one trend row exists, day 0 acts as the implicit second point: Scope (actual) = `[<sample.scope>, ..., null after sample.day_n]`, Done (actual) = `[0, ..., <sample.done>, ..., null after sample.day_n]`. The pinned series start at sample.day_n. Caption appends: `_First snapshot at day <N> — trend will fill in over coming days._`
- **statistics-expert** → produce a single-paragraph forecast: project end-of-sprint completed points using simple linear extrapolation from the trend, compare against `Capacity` and `velocity.avg3`, and state a confidence band (e.g. "tracking 5pts under commit, ±3pts based on 3-sprint variance"). Hard cap: ≤4 sentences. No charts — words only. Must explicitly call out if the trend data is too sparse to forecast (≤2 rows).
- **scrum-master** → 1–3 actionable suggestions for the team based on the day's matched activity (Phase 4) + the snapshot bucket counts. Examples: "two tickets in In Review for >3 days — chase reviewers", "Ada has no activity tracked in 2 days — confirm not blocked", "WIP at 8 vs limit 5 — pull from Ready before starting new". Bullet list. No vague platitudes — each suggestion names a ticket, person, or measurable signal.

**Step 4 — Capture artifacts.** Store the three council outputs as the strings `{{burndown_chart}}` (the **Obsidian Charts `chart` code fence including its ` ```chart ` opening and closing ` ``` ` fences**, followed by the "Reading the chart" markdown block — see infographics-expert contract above), `{{forecast_note}}` (the statistics-expert paragraph, plain markdown), and `{{scrum_suggestions}}` (the bullet list, plain markdown). These feed Phase 6. The placeholder name `{{burndown_chart}}` is retained for template-backward-compatibility — its content is a burn-up chart per the v2 contract. The vault-side Standup template at `{{vault_root}}/🗃Templates/Standup.md` does not need to change; the substitution drops the new chart shape into the existing slot.

