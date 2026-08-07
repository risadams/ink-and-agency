# Sprint Scrum-of-Scrums Report

End-of-week scrum-of-scrums report comparing two sprint snapshots. Surfaces what changed (scope, status transitions, per-member workload), runs team-specific rules (overhead, wedge balancing, in-review overhead), and produces a clarity-council analysis with key findings, observations, trouble areas, and trends.

## Why this exists

The weekly scrum-of-scrums is where multiple teams report up to a release-train engineer or program manager. The report has to fit on a screen, lead with what changed and why, and surface the issues that need cross-team attention without burying them in raw data. Composing that report by hand from a Jira board is slow and the SM tends to under-report churn (because it makes the team look unstable) or over-report polish (because the next-week plan looks better than the actual progress). This skill reads the actual snapshot data, applies the team's documented rules to separate noise from signal (wedge consumption isn't scope creep; in-review overhead isn't stuck work), and produces a report grounded in numbers the council can defend.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "scrum of scrums"
  - "sos report"
  - "weekly sprint report"
  - "sprint progress report"
- Running the slash command: `/sprint-sos-report [Team] [--from <phase>] [--to <phase>] [--new-info "..."] [--no-council]`

## What it does

The skill picks two sprint snapshots (auto-detected as the most-recent two by `snapshot_at`, or explicit via `--from` / `--to`), diffs them across five sets (added / removed / status-moved / re-estimated / reassigned), applies the team rules from `_team-rules.md` (wedge balancing, in-review overhead, overhead-adjusted velocity), runs a clarity-council session for findings and trends, and writes a markdown report into the sprint folder. The `--new-info` flag passes free-text context (e.g. "added 2 devs mid-week") to the council so its findings reflect the SM's local knowledge.

### Inputs

- **`Team`** — defaults to memory; otherwise prompted.
- **`Inc` / `Sprint`** — defaults to the latest in the vault; otherwise prompted.
- **`From` / `To`** — defaults to the second-newest and newest snapshots in the sprint folder by `snapshot_at`. Override with `--from "week 1" --to "week 1.5"` for re-planning churn comparisons.
- **`NewInfo`** — free-text context the SM adds (e.g. "added 2 devs, +10 pts capacity") — passed to the council and included in the report header.
- **`Personas`** — defaults to `statistics-expert,scrum-master,product-owner`; pass `--no-council` to fall back to direct LLM analysis.

### Outputs

- **`{vault}\Scrum Teams\<Team>\Scrum 📅\INC <N>\Sprint <N>\reports\sos-<to-phase>.md`** — the SoS report; phase label preserved literally (e.g. `sos-week 1.md`, `sos-week 1.5.md`)

### External systems used

- None directly. Reads snapshots and config notes from the vault.

## How to use it

A typical session looks like this:

```text
You: /sprint-sos-report Aurora --new-info "Added 2 devs mid-week, +10 pts capacity"

Skill: Comparing Aurora Sprint 2 — week 1 (2026-04-08) → week 2 (2026-04-15).
       Council deliberating (statistics-expert + scrum-master + product-owner)...

       === Aurora Sprint 2 (INC 28) — Scrum-of-Scrums Report ===
       Velocity:     8 pts done this period (velocity-relevant 8; raw 11 incl. 3 pts overhead)
       Scope:        +5 pts added, 4 pts wedge consumed → balanced ✅
       WIP shift:    +3 pts in-progress, -2 pts in-review
       Saved:        [sos-week 2.md](Scrum Teams/Aurora/Scrum 📅/INC 28/Sprint 2/reports/sos-week 2.md)
```

## Getting the most out of it

- **Run it after each weekly snapshot.** The report is most useful the same day the snapshot is captured — that's when the team can act on findings.
- **Use `--new-info` for context the snapshot can't see.** Capacity changes mid-sprint, blocker resolutions, vacation / on-call rotations, dependency unblocks. The council weighs these in its analysis.
- **Capture a `week 1.5` snapshot when re-planning happens mid-week.** Then run `--from "week 1" --to "week 1.5"` to get a churn-specific report. The phase label is preserved literally so your filenames stay legible.
- **Don't skip wedge accounting.** When `_team-rules.wedge.ticket_key` is set and the wedge ticket is on the board, the wedge verdict (`balanced ✅` vs `⚠️ scope creep — Δ N pts beyond wedge`) is what the SM uses to defend scope to the RTE. Keep the wedge ticket convention current.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Run with only one snapshot.** Refuses and prompts to capture a fresh snapshot first. There's no comparison without two points.
- ❌ **Compare a snapshot against itself.** Refuses and asks for a different pair.
- ❌ **Modify Jira, the canvases, or the JSONL.** Read-only across all of them.
- ❌ **Accept council velocity forecasts without prediction intervals.** The statistics-expert's `Output Requirements` enforce this; the skill re-prompts if violated.
- ❌ **Silently overwrite a prior SoS report.** Same overwrite-prompt rule as `sprint-snapshot`.

## Examples

### Example: Mid-week re-planning

```text
You: /sprint-snapshot Aurora --phase "week 1.5"           # capture the post-replan state
You: /sprint-sos-report Aurora --from "week 1" --to "week 1.5" --new-info "PO added 3 stories after demo feedback"

Skill: ...
       Scope:    +12 pts added, 4 pts wedge consumed → ⚠️ Scope creep — 8 pts beyond wedge
       Council:  product-owner: the 3 added stories are PROJ-1450, PROJ-1451, PROJ-1452.
                 PROJ-1452 is high-priority demo feedback; PROJ-1450/1451 could move to backlog.
                 Recommendation: confirm priority of PROJ-1450/1451 before week 2 standup.
```

### Example: Trouble-area surfacing

```text
You: /sprint-sos-report Aurora

Skill: Velocity: 4 pts done this period (target was 12).
       Council: statistics-expert: at current pace (4 pts/week), trailing-3 forecast for sprint
                end is 18 pts done vs 47.5 committed (38%). 70% prediction interval: 14-22 pts.
                Trouble area HIGH: 3 of 6 IN PROGRESS tickets have been IN PROGRESS since week 1
                without status change (PROJ-1234, PROJ-1235, PROJ-1240) — flow stuck.
                Trend: this is the second consecutive week velocity is below trailing-3 average.
                       If pattern holds, PI Confidence drops from High → Medium.
```

The skill won't tell the SM what to do, but it surfaces the pattern and the data so the SM can decide.

## Internals

The skill follows a 7-phase workflow:

1. **Resolve config** — vault, team, inc/sprint, sprint config, team rules
2. **Pick the snapshots** — auto (newest two by `snapshot_at`) or explicit via `--from` / `--to`; load both canvases + JSONL rows
3. **Diff** — five sets: added / removed / status-moved / re-estimated / reassigned; plus per-status point flow
4. **Apply team rules** — wedge balancing (added vs wedge consumption), velocity-relevant velocity (excludes in-review overhead), overhead-adjusted member load
5. **Run clarity-council** — findings + observations + trouble areas + trends; statistics-expert leads on velocity and forecasts (with prediction intervals)
6. **Render and write** — markdown report; same overwrite-prompt rule as siblings
7. **Console summary** — comparison window, velocity, scope, WIP shift, saved path

Key constraints:

- **Read-only across all systems.** Jira, canvases, JSONL, sprint config, team rules.
- **Wedge accounting mandatory** when the wedge ticket is set and present in both snapshots.
- **Velocity reported is always velocity-relevant** (excludes in-review overhead). Surfaces raw separately when it differs.
- **Statistics-expert forecasts must include a prediction interval.** Skill re-prompts otherwise.
- **`JIRA:KEY` for ticket-specific claims** — both in tables and council output.

See [SKILL.md](SKILL.md) for the full workflow contract.

## FAQ

**Q: What's the smallest comparison interval that makes sense?**
A: Any two snapshots with different `snapshot_at` values. Day-over-day works; same-day doesn't.

**Q: How does the wedge ticket work?**
A: The team designates one Jira ticket (e.g. "Sprint Wedge — INC 28 S2") as the placeholder for mid-sprint scope adjustments. New scope added during the sprint is "balanced" against reductions in the wedge ticket's points. As long as `Δadded ≤ Δwedge`, it's not scope creep. Configured in `_team-rules.md`.

**Q: What if `_team-rules.md` is missing?**
A: The skill prompts to bootstrap with defaults. If you skip, it runs with empty wedge/overhead but flags in the console + frontmatter that the report is less accurate.

**Q: Can I compare across sprints (e.g. Sprint 1 end vs Sprint 2 week 1)?**
A: Not in v1. The skill operates within a single sprint folder. For cross-sprint comparison, use `sprint-review` (compares within one sprint, start vs end) or query the JSONL trend log directly.

**Q: Can the report include visuals?**
A: Add `infographics-expert` to the council via `--personas`. They consult statistics-expert for uncertainty rendering and produce embedded SVG or Mermaid (burndown, status flow, per-member delta bar) inline in the report.

## Related skills

- **[sprint-snapshot](../sprint-snapshot/)** — captures the snapshots this skill compares; **run before this** at each phase boundary
- **[sprint-plan](../sprint-plan/)** — sibling start-of-sprint planning report; same `_team-rules.md` and `_sprint.md`
- **[sprint-review](../sprint-review/)** — sibling end-of-sprint stakeholder report; reuses scaffolding
- **[clarity-council](../clarity-council/)** — Phase 5 delegates; statistics-expert is load-bearing for velocity / carry-over / trend forecasting
- **[obsidian-markdown](../obsidian-markdown/)** — used when extending the report template with callouts, dataview, embeds
- **[obsidian-vault](../obsidian-vault/)** — used for batch wikilink verification (>15 names)
- **[obsidian-bases](../obsidian-bases/)** — use to aggregate SoS reports across sprints (e.g. wedge consumption + scope-creep verdicts per sprint)
- **[daily-standup-prep](../daily-standup-prep/)** — pattern parent

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow Claude follows)
