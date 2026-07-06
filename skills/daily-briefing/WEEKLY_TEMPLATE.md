# Weekly Note — Template

Each daily run of the `daily-briefing` skill regenerates the weekly rollup. The auto-managed region is delimited by HTML comment markers so any user-added content outside that region survives regeneration.

## File location

`📅/YYYY/MM/YYYY-W{NN}.md`

- `YYYY` = ISO week-year (may differ from calendar year for late-Dec / early-Jan weeks)
- `NN` = zero-padded ISO week number (`01`–`53`)
- `MM` = month folder = month of the **Monday** of that week
- Example: Monday May 4, 2026 is in ISO week 19 of 2026 → `📅/2026/05/2026-W19.md`

## ISO week rules

- Week starts **Monday**, ends Sunday.
- Week 01 contains the year's first Thursday (equivalently, January 4th).
- Days near year boundaries can belong to the previous/next ISO week-year. Compute the week-year from ISO rules, not from the calendar year of the date.
- Workweek for the rollup = **Monday through Friday** (matches existing vault convention; Sat/Sun omitted).

## Template

```markdown
<!-- begin:auto-managed by daily-briefing skill -->
### Weekly Review

[[YYYY-W{prev}]] <== This Week ==> [[YYYY-W{next}]]

[[YYYY-MM-D{Mon-day}]] ==> [[YYYY-MM-D{Fri-day}]]

#### 🎯 Week at a glance

- {{2-4 bullets: top focus items, big meetings, deadlines, themes for the week}}

#### 📊 Week shape

![[Daily Notes Dashboard.base#This Week]]
![[Scrum Team Activity.base#Recent activity]]

#### 📋 Open TODOs (rolled up from daily notes)

Each day's section may include a `👥 Teams:` sub-bullet listing the scrum-team daily notes for that date — use the full-path wikilink with a short display alias and append `(INC / Sprint)` inline. Omit the `👥 Teams:` line for any day with no team notes.

- [[YYYY-MM-D{Mon-day}]] *(Mon)*
  - 👥 Teams: [[Scrum Teams/{{Team}}/Scrum 📅/{{INC}}/{{Sprint}}/YYYY-MM-D{Mon-day-iso}|{{Team}}]] ({{INC}} / {{Sprint}}) · [[…|{{Team2}}]] ({{INC}} / {{Sprint}})
  - [ ] {{open todo from Monday's daily note}}
  - [ ] {{...}}
- [[YYYY-MM-D{Tue-day}]] *(Tue)*
  - 👥 Teams: [[…|{{Team}}]] ({{INC}} / {{Sprint}})
  - [ ] {{open todo from Tuesday's daily note}}
- [[YYYY-MM-D{Wed-day}]] *(Wed)*
  - [ ] {{...}}
- [[YYYY-MM-D{Thu-day}]] *(Thu)*
  - [ ] {{...}}
- [[YYYY-MM-D{Fri-day}]] *(Fri)*
  - [ ] {{...}}

*Rollup generated {{YYYY-MM-DD HH:MM}} America/New_York from daily notes that exist for this week. Days with no daily note yet show no items.*

<!-- end:auto-managed -->

## Notes

{{user-authored content goes here — preserved across regenerations}}
```

## Rollup logic

For each weekday Mon–Fri of the current ISO week:

1. Compute the date and the corresponding daily-note path: `📅/YYYY/MM/YYYY-MM-D{DD}.md`.
2. If the file exists, `Read` it and extract every `- [ ]` line (unchecked tasks only — skip `- [x]`).
3. Preserve the original task text including any `[[wikilinks]]`, `#tags`, and dates.
4. List them under the day's section. If no daily note exists for that day, leave the day with no child bullets (don't insert "(no items)" — the empty space is signal).
5. Skip any task that is also surfaced in another day's note (deduplicate by exact text match) — keep the earliest occurrence.
6. **Team daily notes** — for each weekday, also `Glob("Scrum Teams/**/YYYY-MM-DD.md")` (plain ISO date, no `D` prefix). For each match, parse `team`, `INC`, and `sprint` from the path (segment after `Scrum Teams/`, then segments under `Scrum 📅/`). Render a single `👥 Teams:` sub-bullet at the top of the day's section listing each team as `[[full/path/YYYY-MM-DD|Team]] (INC / Sprint)`, separated by ` · `. Omit the line entirely for days with no team notes.

For the **Week at a glance** section:

- Pull from the *Executive Summary* of today's daily note (just-generated)
- Add any cross-day themes obvious from the rollup (e.g., "3 meetings with [[@Person]] this week")
- Cap at 4 bullets — this is the high-level focus, not a full restatement

## Preservation rule

Before writing, `Read` the existing weekly file (if any). Extract everything **after** the `<!-- end:auto-managed -->` marker and append it verbatim to the new content. If the markers are missing (e.g., user manually edited an older weekly note), prompt via `AskUserQuestion` before overwriting.
