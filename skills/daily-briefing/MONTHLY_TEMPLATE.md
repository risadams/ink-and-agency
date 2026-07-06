# Monthly Note — Template

Each daily run of the `daily-briefing` skill regenerates the monthly rollup. Like the weekly note, the auto-managed region is delimited by HTML comment markers; user content outside survives regeneration.

## File location

`📅/YYYY/YYYY-M{MM}.md`

- `YYYY` = calendar year (Pittsburgh local)
- `MM` = zero-padded calendar month (`01`–`12`)
- File lives in the **year folder**, *not* in a month subfolder (this differs from daily and weekly notes)
- Example: May 2026 → `📅/2026/2026-M05.md`

## Week selection

List the ISO weeks whose **Monday** falls within the month, plus **one trailing week** for forward visibility. This matches the existing convention (4 in-month Mondays + 1 trailing = 5 weeks).

- May 2026 Mondays: May 4 (W19), May 11 (W20), May 18 (W21), May 25 (W22) → list W19, W20, W21, W22, **W23** (trailing)
- March 2024 Mondays: Mar 4 (W10), Mar 11 (W11), Mar 18 (W12), Mar 25 (W13) → list W10, W11, W12, W13, **W14** (trailing)

If a month has 5 in-month Mondays (rare — e.g., Dec 2025), still add one trailing week → 6 entries that month.

## Template

```markdown
<!-- begin:auto-managed by daily-briefing skill -->
### Monthly Review

[[YYYY-M{prev}]] <== <button class="date_button_today">This Month</button> ==> [[YYYY-M{next}]]

---

#### 🎯 Month at a glance

- {{2-4 bullets: top themes, key milestones, deadlines, big meetings rolled up across the month's weeks}}

#### 📊 Month shape

![[Weekly Rollups.base#Recent weeks]]
![[Scrum Team Activity.base#By team]]

#### 📅 Weekly rollup

Each week may include a `👥 Teams active:` sub-bullet listing the distinct **Team — INC / Sprint** combinations that appeared in any team daily note that week. List each team only once per week (collapse Mon–Fri occurrences). Omit the line entirely for weeks with no team notes.

- [[YYYY-W{NN1}]] *(Mon DD – Fri DD)*
  - 👥 Teams active: {{Team}} ({{INC}} / {{Sprint}}) · {{Team2}} ({{INC2}} / {{Sprint2}})
  - {{week-at-a-glance bullets pulled from this weekly note's auto-managed section}}
- [[YYYY-W{NN2}]] *(Mon DD – Fri DD)*
  - 👥 Teams active: {{...}}
  - {{...}}
- [[YYYY-W{NN3}]] *(Mon DD – Fri DD)*
  - {{...}}
- [[YYYY-W{NN4}]] *(Mon DD – Fri DD)*
  - {{...}}
- [[YYYY-W{NN5}]] *(Mon DD – Fri DD)*  *(forward look)*
  - {{...}}

*Rollup generated {{YYYY-MM-DD HH:MM}} America/New_York from weekly notes that exist for this month. Weeks with no weekly note yet show no items.*

<!-- end:auto-managed -->

## Notes

{{user-authored content — preserved across regenerations}}
```

## Navigation rules

- Previous/next month wraps across years: `2026-M01`'s prev is `[[2025-M12]]`; `2026-M12`'s next is `[[2027-M01]]`.
- Always use the `<button class="date_button_today">This Month</button>` exactly — it's a vault-specific CSS class.

## Rollup logic

For each week in the selection:

1. Compute the weekly note path: `📅/YYYY/MM/YYYY-W{NN}.md` where `MM` = month of that week's Monday (this may differ from the month of the monthly note for the trailing week).
2. If the file exists, `Read` it and extract the bullets under the `#### 🎯 Week at a glance` section.
3. If those bullets exist, render them as child bullets under the week's link in the monthly rollup. If empty or missing, leave the week with no children.
4. Compute and append the date range `*(Mon DD – Fri DD)*` next to each week link for at-a-glance scanning.
5. **Team activity rollup** — for each Mon–Fri date in the week, `Glob("Scrum Teams/**/YYYY-MM-DD.md")` and parse `team`, `INC`, `sprint` from each path. Collapse to the distinct **Team — INC / Sprint** set for the week (a team that posts notes Mon–Fri appears once). Render as a single `👥 Teams active:` sub-bullet at the top of the week's section in the form `Team (INC / Sprint) · Team2 (INC / Sprint)`. Omit for weeks with no team notes.

For the **Month at a glance** section:

- Synthesize 2-4 themes from the aggregated weekly summaries — recurring people, repeated initiatives, large milestones, deadline clusters
- This is the executive-level view; don't restate every weekly bullet

## Preservation rule

Same as weekly: before writing, `Read` the existing monthly file (if any). Capture everything **after** the `<!-- end:auto-managed -->` marker and append verbatim. If markers are missing on an existing monthly note (e.g., the legacy hand-edited format), prompt via `AskUserQuestion` before overwriting — the user may have built up notes there.
