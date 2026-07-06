# Sprint Review

End-of-sprint stakeholder report comparing the planning baseline (`start.canvas`) to the close-of-sprint state (`end.canvas`). Produces a markdown report fitting the standard SM template (Scrum Master, Sprint Accomplishments, Feature Demos, Customer Meetings, Status, Sprint Commitment, PI Confidence, Impediments) so it pastes cleanly into Confluence.

## Why this exists

The end-of-sprint stakeholder report follows a fixed template. Drafting it from the Jira board takes the SM 30-60 minutes per sprint per team — pulling commitment numbers, computing velocity-relevant metrics, identifying carry-over candidates, framing Impediments, and writing the PI Confidence verdict. Most of that is mechanical comparison work the SM is happy to delegate, plus a few load-bearing judgment calls (was the commitment met? what's the PI confidence?) that benefit from a clarity-council second opinion. This skill does the mechanical part end-to-end and gives the council the data it needs to make the judgment calls defensible.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "sprint review"
  - "end of sprint report"
  - "sprint stakeholder report"
  - "sprint close report"
- Running the slash command: `/sprint-review [Team] [--inc N] [--sprint N] [--commitment-threshold 0.85] [--no-council]`

## What it does

The skill reads `start.canvas` (the planning baseline) and `end.canvas` (the close state), diffs them across the same five sets `sprint-sos-report` uses plus `completed` / `not_completed`, applies the team rules (wedge balancing, in-review overhead, overhead-adjusted velocity), computes commitment ratios at the configurable threshold, runs a clarity-council session with assignments matching the template's section structure, and writes a markdown report formatted to drop directly into the SM's Confluence template.

### Inputs

- **`Team`** — defaults to memory; otherwise prompted.
- **`Inc` / `Sprint`** — defaults to the latest in the vault; otherwise prompted.
- **`From` / `To`** — defaults to `start` and `end`; rarely overridden.
- **`CommitmentThreshold`** — defaults to `0.85`. `delivered_velocity_relevant / committed_velocity_relevant ≥ threshold` → "commitment met".
- **`Personas`** — defaults to `statistics-expert,scrum-master,product-owner`; pass `--no-council` to fall back to direct LLM analysis.
- **`ScrumMaster` / `ConfluenceUserUrl`** — default to a memory file; prompted on first run, then persisted.

### Outputs

- **`{vault}\Scrum Teams\<Team>\Scrum 📅\INC <N>\Sprint <N>\reports\sprint-review.md`** — the stakeholder report; sections mirror the SM template exactly so it pastes into Confluence as-is

### External systems used

- None directly. Reads canvases and config notes from the vault.

## How to use it

A typical session looks like this:

```text
You: /sprint-review Aurora --inc 28 --sprint 2

Skill: Comparing start (2026-04-01) → end (2026-04-21).
       Council deliberating (statistics-expert + scrum-master + product-owner)...

       === Aurora Sprint 2 (INC 28) — Sprint Review ===
       Committed:        62.5 pts raw / 47.5 pts velocity-relevant
       Delivered:        58 pts raw / 43 pts velocity-relevant
       Commitment:       0.91 (vr) ≥ 0.85 → MET ✅
       Sprint velocity:  43 pts (vr); avg-3 was 58 → ↘️ below trend
       Scope:            +8 pts added; 6 pts wedge consumed → ⚠️ +2 pts scope creep
       Carry-over:       3 tickets (8 pts)
       Saved:            [sprint-review.md](Scrum Teams/Aurora/Scrum 📅/INC 28/Sprint 2/reports/sprint-review.md)
```

## Getting the most out of it

- **Capture both `start.canvas` and `end.canvas`.** The skill refuses to run without a `start.canvas` (the planning baseline is mandatory). It can fall back if `end.canvas` is missing, but the report will warn that it's not a true sprint-end snapshot.
- **Review the council's PI Confidence verdict before publishing.** The statistics-expert grounds it in the trailing-5-sprint window with a calibrated probability — but the SM may have qualitative context (team morale, dependency risk, upcoming PTO) that warrants overriding. The verdict is a recommendation, not a commitment.
- **Fill in `Significant customer meetings` manually.** The skill has no source for that data; it's always rendered as an italicized placeholder so the SM sees it before publishing.
- **Verify `Feature Demos` auto-extraction.** The heuristic looks for `issuetype: Feature` and `labels: demo`. It's best-effort — review before the demo, refine the placeholder if the wrong tickets were flagged.
- **Use the Appendix tables to defend the headline numbers.** The Quantitative summary and Carry-over candidates tables are the receipts for the Status section. Stakeholders who push back on the commitment verdict can read the appendix.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Run without `start.canvas`.** The planning baseline is mandatory. Refuses and surfaces the expected path.
- ❌ **Modify Jira, the canvases, or any config notes.** Read-only across all of them.
- ❌ **Reorder, rename, or skip template sections.** The SM's Confluence template has fixed section names; the skill keeps them verbatim so paste-and-publish works.
- ❌ **Invent customer meetings or feature demos.** Both render as italicized placeholders if the data isn't available.
- ❌ **Accept council PI Confidence verdicts without trailing-window grounding.** The statistics-expert must reference the trailing-5-sprint `end` rows in the JSONL log; if the window has < 3 prior rows, the verdict is labeled "low-data".

## Examples

### Example: Commitment met, below trend

```text
You: /sprint-review Aurora

Skill: ...
       Commitment: 0.91 vr ratio ≥ 0.85 → MET ✅
       Velocity: 43 pts vr vs avg-3 of 58 → ↘️ below trend
       Council:
         Sprint Accomplishments: PROJ-1234 (mobile checkout) and PROJ-1240 (analytics
           dashboard) shipped — both tied to OKR 2.1.
         PI Confidence: Medium. Two consecutive sprints below trailing-3 average; if
           pattern continues, end-of-PI commitment of 232 pts is at risk (current
           projection: 198-220 pts at 70% confidence).
         Impediments: PROJ-1300 blocked on auth-service migration (3 sprints running);
           recommend escalating to RTE for cross-team prioritization.
```

### Example: Commitment missed, scope creep

```text
You: /sprint-review Aurora

Skill: ...
       Commitment: 0.78 vr ratio < 0.85 → MISSED ❌
       Scope: +14 pts added; 6 pts wedge consumed → ⚠️ +8 pts scope creep
       Council:
         Status: scope creep contributed to the commitment miss (8 pts beyond wedge
           accounts for ~13% of committed). Without the unplanned scope, vr ratio would
           have been 0.92.
         PI Confidence: Low. Three sprints into the PI; commitment missed in two.
           Statistics-expert: P(meeting PI commitment) = 35% with current pattern.
         Impediments: scope-acceptance discipline — recommend PO-team retro on the
           three new stories accepted mid-sprint (PROJ-1450, PROJ-1451, PROJ-1452).
```

A defensible report that surfaces the cause without scapegoating.

## Internals

The skill follows a 7-phase workflow:

1. **Resolve config** — vault, team, inc/sprint, sprint config, team rules, SM identity (`reference_default_scrum_master.md`)
2. **Locate canvases** — `start.canvas` (mandatory) + `end.canvas` (with fallback chain to latest week-N if missing); load JSONL rows
3. **Diff** — five sets + `completed` + `not_completed`; per-status point flow at sprint boundary
4. **Apply team rules** — velocity-relevant velocity, sprint commitment math, wedge final accounting, carry-over identification, in-review overhead exception
5. **Run clarity-council** — Sprint Accomplishments (product-owner leads) + Status (statistics-expert leads) + Sprint Commitment verdict + PI Confidence (statistics-expert calibration with trailing-5 window) + Impediments (scrum-master leads)
6. **Render template-shaped report** — section headers verbatim from SM template; appendices for Quantitative summary, Carry-over candidates, embedded snapshots
7. **Console summary** — commitment verdict, velocity vs trend, scope verdict, carry-over volume, saved path

Key constraints:

- **Read-only.** Reads canvases, JSONL, sprint config, team rules. Never modifies any.
- **Template fidelity mandatory.** Section headers, ordering, and placeholders must match the SM template exactly so it pastes cleanly into Confluence.
- **`Significant customer meetings` is always a placeholder** — the SM fills it in.
- **`Feature Demos` is best-effort heuristic** with placeholder fallback. Never invents.
- **Both raw and velocity-relevant numbers reported when they differ.** Never silently uses one over the other.
- **Statistics-expert calibration is load-bearing for PI Confidence.** Skill re-prompts if the verdict isn't grounded in the trailing-window.

See [SKILL.md](SKILL.md) for the full workflow contract.

## FAQ

**Q: What if the trailing-5-sprint window has fewer than 3 prior `end` rows?**
A: The PI Confidence section uses what's available and labels the prediction as "low-data". After ~3-5 sprints in a new INC, calibration becomes meaningful.

**Q: Can I publish the report directly without SM review?**
A: Don't. The placeholder lines (`Significant customer meetings`, possibly `Feature Demos`) need SM input. The PI Confidence verdict often needs SM context the council can't see. Treat the output as a strong first draft, not a final.

**Q: What counts as commitment met?**
A: Default: `delivered_velocity_relevant / committed_velocity_relevant ≥ 0.85`. Configurable via `--commitment-threshold`. The skill reports both raw and velocity-relevant ratios when they differ.

**Q: How does it handle in-review overhead items still in IN REVIEW at sprint end?**
A: The team rule says these are *expected* to close on the sprint end date. If any are still IN REVIEW at end, the skill flags them in Impediments — that's a process deviation worth surfacing.

**Q: Can the report include visuals (burndown, commitment-vs-actual bar, velocity sparkline)?**
A: Yes — stakeholder-facing reports almost always benefit. Add `infographics-expert` to the council via `--personas`. They consult statistics-expert for uncertainty rendering and product-owner for chart titles, then produce SVG/Mermaid embedded directly in the report body.

**Q: What if I haven't captured `end.canvas` yet?**
A: The skill prompts to either run `sprint-snapshot --phase end` first or fall back to the latest available phase (with a warning written into the report header that it's not a true end snapshot).

## Related skills

- **[sprint-snapshot](../sprint-snapshot/)** — captures `start.canvas` and `end.canvas`; **run `--phase start` at sprint kickoff and `--phase end` at sprint close**
- **[sprint-plan](../sprint-plan/)** — sibling start-of-sprint planning report; the council's PI Confidence here is informed by patterns flagged earlier
- **[sprint-sos-report](../sprint-sos-report/)** — sibling weekly comparison reports; their `Trends` sections feed PI Confidence reasoning
- **[clarity-council](../clarity-council/)** — Phase 5 delegates; statistics-expert load-bearing for commitment ratios + PI Confidence; product-owner leads Accomplishments; scrum-master leads Impediments
- **[obsidian-markdown](../obsidian-markdown/)** — used when extending the report template with callouts, dataview, embeds
- **[obsidian-vault](../obsidian-vault/)** — used for batch wikilink verification (>15 names)
- **[obsidian-bases](../obsidian-bases/)** — use to aggregate reviews across an INC (commitment ratio + carry-over per sprint); strong forecasting input
- **[daily-standup-prep](../daily-standup-prep/)** — pattern parent

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow Claude follows)
