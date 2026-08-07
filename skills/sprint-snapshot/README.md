# Sprint Snapshot

Point-in-time snapshot of a scrum team's current sprint board. The skill captures Jira state into the user's Obsidian vault as three artifacts — a visual canvas, a markdown summary, and an append-only JSONL trend log — so a sprint's progress can be reviewed at any moment, compared across phases, and forecast over time.

## Why this exists

Sprints get reported on at the end. By then, the early-week signals — re-planning churn, carry-over surprises, scope creep — have been smoothed over by the team and lost. A snapshot taken five times a sprint (start, end of each week, sprint close) captures those signals as they happen so the scrum master, the team, and stakeholders can see the trajectory rather than just the destination. The JSONL trend log makes that history queryable: velocity per phase, carry-over rate per sprint, scope-creep frequency per increment.

This skill is a Claude Code port of an existing PowerShell script (`Sprint-Planner.ps1` + `Get-Jira-Sprint-Planner.ps1`). It produces the same canvas the PS script produces, plus the markdown summary and JSONL log the PS script never had.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "snapshot the sprint"
  - "sprint snapshot"
  - "capture sprint state"
  - "sprint planner"
  - "scrum board snapshot"
- Running the slash command: `/sprint-snapshot [Team] [--inc N] [--sprint N] [--phase "week 1"] [--as-of YYYY-MM-DD]`

## What it does

The skill resolves team config from memory, loads the per-sprint config note, queries Jira for the team's current sprint (with optional `--as-of` historical filter), buckets issues by status, matches assignees against the team roster, and writes three artifacts side by side. The canvas reproduces the PS script's layout exactly — sprint overview, team workload grid, kanban columns, off-team sidebar, and a summary table. The companion markdown is a single-page summary suitable for embeds or grep. The JSONL trend log is one row per snapshot, append-only, designed for forecasting and dashboards.

### Inputs

- **`Team`** — defaults to memory (`reference_default_scrum_team.md`); otherwise prompted. Single team per run.
- **`Inc` / `Sprint`** — defaults to the latest from the vault folder structure; otherwise prompted.
- **`Phase`** — auto-derived from today vs the sprint config's start_date (`start` / `week 1` / `week 2` / `week 3` / `end`). Override with `--phase "week 1.5"` for mid-week re-planning snapshots.
- **`AsOf`** — optional ISO date. Adds `updated <= "<date>"` to the JQL so the snapshot reflects historical Jira state.

### Outputs (per run, all written to `{vault}\Scrum Teams\<Team>\Scrum 📅\INC <N>\Sprint <N>\`)

- **`<phase>.canvas`** — JSON Canvas spec; the visual sprint board
- **`<phase>.md`** — companion markdown summary (frontmatter + summary table + per-member workload + velocity trend)
- **`_snapshots.jsonl`** — one JSON line appended per snapshot; the trend log (never overwritten)

### External systems used

- Jira (read only — `jira_search`, `jira_get_issue`)

## How to use it

A typical session looks like this:

```text
You: /sprint-snapshot Aurora --inc 28 --sprint 2

Skill: Snapshotting Aurora Sprint 2 (INC 28) — phase: week 1 (day 5 of 21).
       Effective JQL: project = PROJ AND labels in (aurora,dev_common,...)
                       AND Sprint in openSprints() AND Sprint not in futureSprints()

       Found 24 issues. Matched 8 of 9 roster members; 1 off-team assignee.

       === Aurora Sprint 2 (INC 28) snapshot — phase: week 1 ===
       Issues:     24 total / 6 done (25%) / 4 in review / 6 in progress / 8 to do
       Points:     62.5 total / 15 done / 11 in review / 15.5 in progress / 21 to do
       Unassigned: 3 tickets (8 pts)
       Capacity:   80.8 (committed 62.5, remaining 18.3)
       Saved:      [week 1.canvas] / [week 1.md] / _snapshots.jsonl (+1 row, 4 total)
```

## Getting the most out of it

- **Snapshot at the same cadence every sprint.** Five snapshots per sprint (start / end of weeks 1, 2, 3 / end) is what the trend log assumes. Skipping weeks creates gaps that make forecasting noisier.
- **Capture an `--as-of <sprint-start-date>` snapshot at kickoff.** This freezes the planning baseline so later reports can compare actual progress vs what was committed.
- **Treat `_team-rules.md` as load-bearing.** The downstream `sprint-plan`, `sprint-sos-report`, and `sprint-review` skills all read it for overhead members, the wedge ticket convention, and in-review overhead exceptions. Set it up once per team and keep it current.
- **Don't hand-edit the JSONL.** It's append-only by design. If a row is wrong, fix the underlying snapshot and re-run; the new row will reflect the corrected data and the old row stays as historical record.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Modify Jira.** Read-only — never transitions issues, never posts comments, never reassigns.
- ❌ **Overwrite `_snapshots.jsonl`.** The whole point is point-in-time history; mutating it defeats forecasting.
- ❌ **Hand-author the canvas JSON.** Phase 5 delegates to the `obsidian-canvas` skill so node IDs, validation, and the JSON Canvas spec are handled correctly.
- ❌ **Run multi-team in one invocation.** Single team per run by design — multi-team means looping the skill with different `Team` arguments.
- ❌ **Use `--as-of` to invent state.** If a date is in the future or before the sprint started, the skill rejects rather than silently defaulting.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for the cadence walkthrough (5 snapshots per sprint with PS-script invocation parity), backfill patterns, the first-run bootstrap, and trend-tracking examples.

## Internals

The skill follows an 8-phase workflow:

1. **Resolve config** + load roster + load/create per-sprint config note (`_sprint.md`)
2. **Auto-derive phase** + build effective JQL (with optional `AsOf`)
3. **Fetch Jira issues** (single `jira_search` call, max 200 results)
4. **Match assignees** to roster + bucket by status (TO DO assigned/unassigned, IN PROGRESS, IN REVIEW, DONE)
5. **Render canvas** — delegates to `obsidian-canvas` for ID generation, JSON shape, validation
6. **Render companion markdown** — delegates to `obsidian-markdown` if extending
7. **Append trend row** to `_snapshots.jsonl` — never rewrites
8. **Console summary** — issue count, point breakdown, capacity vs committed, saved paths

Key constraints:

- **Read-only across Jira.** No write API calls.
- **Append-only on `_snapshots.jsonl`.** Never overwrite or compact.
- **Never overwrite an existing canvas or markdown summary silently.** Always confirm via prompt.
- **`JIRA:KEY` for issue references** (Obsidian Jira plugin convention) — not wikilinks.
- **`customfield_10106` for Story Points** — the user's confirmed Jira field ID. Configurable via memory if it changes.

See [SKILL.md](SKILL.md) for the full workflow contract and [REFERENCE.md](REFERENCE.md) for the canvas layout spec, JSONL schema, and `_team-rules.md` schema.

## FAQ

**Q: What if my team isn't named in the rosters folder?**
A: Place a `<Team>.csv` at `{vault}\Scrum Teams\_rosters\<Team>.csv` matching the headerless schema (`FullName,Email,Alias,Role,Flags`). The skill reuses the format from `daily-standup-prep`.

**Q: Can I snapshot a previous sprint after the fact?**
A: Yes. Use `--as-of <date>` with the date you want to reflect. The JQL adds `updated <= "<date>"` so the result reflects Jira state at that point. Useful for backfilling missed snapshots.

**Q: What happens if my sprint has more than 100 issues or my team has more than 15 members?**
A: The canvas layout is pre-computed for ≤ 100 issues and ≤ 15 members. Beyond that, cards may visually overlap (the skill skips the PS script's collision-detection algorithm). The JSONL and markdown summary are unaffected.

**Q: Why JSONL instead of CSV or a single JSON array?**
A: Append-only without rewriting the whole file — the trend log can grow forever without risk of corrupting prior history. CSV is awkward for the nested per-status structure; a JSON array would force a full rewrite on every append.

## Related skills

- **[sprint-plan](../sprint-plan/)** — start-of-sprint planning report; consumes `start.canvas` and the previous sprint's `end.canvas`
- **[sprint-sos-report](../sprint-sos-report/)** — weekly scrum-of-scrums report; compares any two snapshots
- **[sprint-review](../sprint-review/)** — end-of-sprint stakeholder report; compares `start.canvas` to `end.canvas`
- **[obsidian-canvas](../obsidian-canvas/)** — Phase 5 delegates to it for canvas authoring
- **[obsidian-markdown](../obsidian-markdown/)** — Phase 6 delegates when extending the markdown template
- **[obsidian-vault](../obsidian-vault/)** — used for batch wikilink verification
- **[daily-standup-prep](../daily-standup-prep/)** — pattern parent for vault-write conventions, roster CSV format, identity matching
- **[clarity-council](../clarity-council/)** — future "sprint health" persona session over the JSONL trend log

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow Claude follows)
- **[REFERENCE.md](REFERENCE.md)** — Canvas layout spec, `_snapshots.jsonl` schema, `_team-rules.md` schema (shared with all sprint-* skills), PS-script line mapping
- **[EXAMPLES.md](EXAMPLES.md)** — Invocation parity with the PS script, first-run bootstrap, trend-tracking patterns
