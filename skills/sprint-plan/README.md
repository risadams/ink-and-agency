# Sprint Plan

Convert the start-of-sprint canvas into a planning markdown report — committed scope, capacity vs commitment (split into carry-over from the previous sprint vs new work), key observations, and risks. Written into the team's vault folder, date-stamped per run, with the council's analysis grounded in the actual snapshot data.

## Why this exists

A sprint plan written from the team's vibes after planning meeting tends to omit the things the team didn't think to mention — the carry-over they're already committed to, the in-review overhead they've forgotten about, the gap between this sprint's commitment and the trailing velocity. This skill reads the actual `start.canvas` snapshot and the previous sprint's `end.canvas` and produces a plan that explicitly accounts for both, then runs a clarity-council session that has to cite ticket keys for every claim it makes. The output is a single page that the SM can hand to the team or paste into a stakeholder doc without rewriting.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "sprint plan"
  - "sprint planning report"
  - "convert sprint plan to markdown"
  - "draft a sprint plan"
- Running the slash command: `/sprint-plan [Team] [--inc N] [--sprint N] [--no-council]`

## What it does

The skill locates the current sprint's `start.canvas`, reads the previous sprint's `end.canvas` (or best-available fallback), derives the carry-over set, applies the team's overhead/wedge/in-review rules from `_team-rules.md`, runs a clarity-council session (statistics-expert + scrum-master + product-owner) for observations and risks, and writes a date-stamped markdown report. The report has both a by-status and a by-member view, a dedicated carry-over section with WIP-saturation risk, and council-authored observations and risks where every claim cites a `JIRA:KEY`.

### Inputs

- **`Team`** — defaults to memory; otherwise prompted.
- **`Inc` / `Sprint`** — defaults to the latest in the vault; otherwise prompted.
- **`Personas`** — defaults to `statistics-expert,scrum-master,product-owner`; pass `--no-council` to fall back to direct LLM analysis.

### Outputs (written to `{vault}\Scrum Teams\<Team>\Scrum 📅\INC <N>\Sprint <N>\reports\`)

- **`sprint-plan-YYYY-MM-DD.md`** — the planning report for that day
- **`sprint-plan-latest.md`** — single-line wikilink pointer to the newest dated file (canonical target for dashboards and `.base` files)

### Re-run semantics

- **Same-day re-run** → overwrites today's `sprint-plan-YYYY-MM-DD.md` silently. The newer run reflects the latest snapshot data.
- **Different-day re-run** → writes a new dated file. Prior days are preserved as historical record of how the plan looked at that point in time.

This is the *opposite* of `sprint-snapshot`'s overwrite-prompt rule because the planning report is a daily refresh; snapshots are phase-locked records.

### External systems used

- None directly. Reads the canvas and JSONL produced by `sprint-snapshot` plus the per-sprint and per-team config notes in the vault.

## How to use it

A typical session looks like this:

```text
You: /sprint-plan Aurora --inc 28 --sprint 2

Skill: Loaded start.canvas (snapshot_at 2026-04-01T09:14:00-04:00).
       Carry-over base: Sprint 1/end.canvas (snapshot_at 2026-03-31T17:42:00-04:00).
       Carry-over from Sprint 1: 4 tickets (11 pts) — 1 in-progress, 2 in-review, 1 to-do.
       Council deliberating (statistics-expert + scrum-master + product-owner)...

       === Aurora Sprint 2 (INC 28) — Sprint Plan ===
       Tickets / Points: 24 / 62.5  (4 tickets / 11 pts carry-over 🔄)
       Capacity:         80.8 (committed 62.5; velocity-relevant 47.5)
       Carry-over share: 11 / 47.5 = 23% of velocity-relevant commit
       Carry-over WIP:   3 of 24 tickets start already-WIP (12%) — within tolerance
       Saved:            [sprint-plan-2026-04-01.md] / [sprint-plan-latest.md] → updated pointer
```

## Getting the most out of it

- **Run it the morning after sprint planning.** That's when `start.canvas` is freshest and the team's commitment hasn't drifted yet.
- **Re-run if scope changes during the first day or two.** Same-day re-runs overwrite silently; you get an updated report without polluting the history.
- **Treat carry-over as a planning input, not a surprise.** The skill's "all unclosed items carry over" assumption matches the team's actual practice. If the team intentionally de-scoped a carry-over item, the skill flags it for confirmation rather than failing.
- **Read the council's risks before the team does.** The `statistics-expert` will flag commit-vs-velocity mismatches with prediction intervals; the `scrum-master` will flag WIP saturation; the `product-owner` will flag stale-priority carry-over. Address what's real before publishing.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Run without a `start.canvas`.** Refuses and prompts to invoke `sprint-snapshot --phase start` first. Don't fabricate a planning baseline.
- ❌ **Modify the canvas, JSONL, or config notes.** Read-only across all of them.
- ❌ **Overwrite prior days' planning reports.** Per-day filenames preserve history; the skill never touches yesterday's file.
- ❌ **Accept council output without ticket citations.** Re-prompts the council if a persona makes ticket-specific claims without `JIRA:KEY`.
- ❌ **Run multi-team in one invocation.** Single team only in v1.

## Examples

### Example: Carry-over dominates the sprint

```text
You: /sprint-plan Aurora

Skill: Carry-over from Sprint 1: 7 tickets (28 pts) — 3 in-progress, 4 in-review.
       Carry-over share: 28 / 47.5 = 59% of velocity-relevant commit.
       Carry-over WIP: 7 of 18 tickets start already-WIP (39%) — over tolerance.
       Council flagged: this sprint is mostly finishing prior work; new commit is 19.5 pts vs
       trailing-3 average velocity of 58 pts. Statistics-expert: with 70% confidence, expect
       new-commit completion of 12-22 pts; carry-over completion 22-28 pts; total 34-50 pts.
       Risk: PI Confidence may drop if carry-over recurs at this rate.
```

The skill makes the carry-over surplus explicit so the team can have the conversation about whether it's a one-off or a pattern.

### Example: Clean sprint with healthy mix

```text
You: /sprint-plan Aurora

Skill: Carry-over from Sprint 1: 2 tickets (5 pts) — both in-review, expected to close early.
       Carry-over share: 5 / 47.5 = 11% — well within range.
       Council: statistics-expert notes commit (62.5) is 8% above 3-sprint avg (58); within
       normal variance. Scrum-master notes balanced load across team. Product-owner notes
       2 dependencies on Borealis team — wedge accounting will reveal if they slip.
```

A short, low-flag report. The value is in the explicit "no major risks" verdict rather than absence of report.

## Internals

The skill follows a 7-phase workflow (with a Phase 2.5 specifically for carry-over derivation):

1. **Resolve config** — vault, team, inc/sprint, sprint config, team rules
2. **Load `start.canvas`** + JSONL row for the start phase
3. **Phase 2.5** — locate previous sprint's `end.canvas` (with fallback chain), derive the carry-over set, sub-classify by previous-end status
4. **Convert canvas to markdown** — by-status and by-member views, carry-over rows annotated with 🔄
5. **Apply team rules** — overhead-adjusted capacity, in-review overhead exclusion, wedge ticket detection, carry-over capacity math, WIP-saturation risk
6. **Run clarity-council** — observations + risks; statistics-expert addresses carry-over share, scrum-master addresses WIP risk, product-owner addresses stale-priority
7. **Render and write** — date-stamped report; update `sprint-plan-latest.md` pointer
8. **Console summary** — issue/point breakdown, carry-over stats, council status, saved paths

Key constraints:

- **Read-only.** Reads canvas, JSONL, sprint config, team rules. Never modifies any.
- **Carry-over assumption is unconditional.** All unclosed items from the previous sprint's end snapshot are treated as carried into this sprint.
- **Same-day re-runs overwrite silently.** Different-day runs create new dated files; prior days untouched.
- **Council citations mandatory.** Every ticket-specific claim must reference `JIRA:KEY`.

See [SKILL.md](SKILL.md) for the full workflow contract.

## FAQ

**Q: What if there's no previous sprint (Sprint 1 of a new INC)?**
A: The skill sets `carry_over: not_applicable` in the frontmatter and skips the carry-over section. No warning — this is expected for the first sprint of an increment.

**Q: What if the previous sprint had no `end.canvas` captured?**
A: Falls back in order: `week 3.canvas` → `week 2.canvas` → `week 1.canvas`. If none exists, sets `carry_over: unavailable`, renders the report without the section, and adds a callout near the top so the SM sees the gap.

**Q: A carry-over ticket was re-estimated between sprints. What number do you use?**
A: The current sprint's `start.canvas` value (the new estimate). The carry-over table notes the change explicitly: `prev: 3 pts → now: 5 pts`.

**Q: Why date-stamped output instead of phase-stamped like sprint-snapshot?**
A: Snapshots are phase-locked records (one per phase boundary). Planning reports are daily refreshes — multiple per day are normal as scope clarifies. The date-stamp pairs naturally with that cadence.

**Q: Can I add visuals (burndown, carry-over Sankey, capacity bar) to the report?**
A: Add `infographics-expert` to the council via `--personas` and the council will include SVG/Mermaid output that can be embedded in the report body. The persona consults `statistics-expert` for uncertainty rendering.

## Related skills

- **[sprint-snapshot](../sprint-snapshot/)** — produces the `start.canvas` this skill consumes; **run first** if missing
- **[sprint-sos-report](../sprint-sos-report/)** — sibling weekly comparison report; same `_team-rules.md`
- **[sprint-review](../sprint-review/)** — sibling end-of-sprint stakeholder report; reuses scaffolding
- **[clarity-council](../clarity-council/)** — Phase 5 delegates to it; statistics-expert is load-bearing for capacity-vs-velocity reasoning
- **[obsidian-markdown](../obsidian-markdown/)** — used when extending the report template with callouts, dataview, embeds
- **[obsidian-vault](../obsidian-vault/)** — used for batch wikilink verification (>15 names)
- **[obsidian-bases](../obsidian-bases/)** — use to aggregate sprint plans across an INC into a dashboard
- **[daily-standup-prep](../daily-standup-prep/)** — pattern parent for vault-write conventions and identity matching

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow Claude follows)
