# Good Morning

A single-command **morning kickoff wrapper** that runs the user's three morning skills in order — `sprint-snapshot` (daily tag), an out-of-office digest, `daily-standup-prep` (with sprint burndown), and `daily-briefing` (report-only, no focus blocks) — then prints one summary of everything written. It owns no business logic of its own; every artifact is produced by a delegated skill. The point is to type one command instead of four, and have the whole chain run unattended.

## Why this exists

The morning routine is three or four separate skills that always run in the same order, with the same overwrite answers, feeding each other's output (the standup's burndown reads the snapshot's trend row; the OOO digest flows into both the standup's capacity read and the briefing's FYIs). Running them by hand means four invocations, four overwrite prompts, and manually carrying the OOO data between them. This wrapper collapses that into one command that auto-continues between phases, answers its own overwrite prompts, and re-runs idempotently — so "good morning" reliably produces the same complete set of artifacts every day without babysitting.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "good morning"
  - "morning routine" / "start my day" / "kick off my day"
- Running the slash command: `/good-morning [team] [--skip-snapshot] [--skip-calendar] [--skip-standup] [--skip-briefing]`

## What it does

The wrapper runs four phases **strictly sequentially** (never parallel — Phase 2 depends on Phase 1's JSONL trend row). **Phase 1** delegates a `daily`-tagged snapshot to `sprint-snapshot`. **Phase 1.5** fetches the team's Confluence Team Calendar ICS, parses who's out during the window (attributing via the `CN=` field, merging adjacent PTO ranges, honoring the exclusive-`DTEND` rule), and forwards that OOO digest into the next two phases. **Phase 2** delegates to `daily-standup-prep` with the sprint pulse on. **Phase 3** delegates to `daily-briefing` for the daily report + weekly + monthly rollups, but skips the focus-block proposal. **Phase 4** prints a one-line-per-artifact summary, runs belt-and-suspenders repair checks on the daily note (mandatory sections, action-item post-filter), and adds a `personal-assistant` "Next actions" block. It auto-continues between phases and auto-answers its own overwrite prompts; it stops only for a hard Phase-1 failure or a genuinely blocking sub-skill question it can't answer for the user.

### Inputs

- **Team name(s)** and any sprint args (`--inc`, `--sprint`, `--days`) — forwarded verbatim to whichever sub-skill recognizes them.
- **Skip flags** — `--skip-snapshot`, `--skip-calendar`, `--skip-standup`, `--skip-briefing` (the only args the wrapper itself consumes).
- **Config from memory** — vault root, default team, Jira project, team-calendar ICS URL. All *read*; the wrapper writes no memory.

### Outputs

- **Phase 1:** `daily.canvas` + `daily.md` + one appended `_snapshots.jsonl` trend row.
- **Phase 1.5:** an in-memory OOO digest (never written to the vault) forwarded to Phases 2 and 3.
- **Phase 2:** the per-team standup report(s) with burn-up chart.
- **Phase 3:** three notes — daily report, weekly rollup, monthly rollup.
- **Phase 4:** a console summary with clickable vault links, any repair notes, and a `## Next actions` block.

### External systems used

- **[sprint-snapshot](../sprint-snapshot/)**, **[daily-standup-prep](../daily-standup-prep/)**, **[daily-briefing](../daily-briefing/)** — the three delegated skills that do the actual work.
- **Confluence Team Calendar (ICS)** — fetched read-only for the OOO digest.
- **[clarity-council](../clarity-council/)** (single mode, `personal-assistant`) — the Phase 4 "Next actions" pass.
- Transitively: Jira, GitLab, Outlook, and the Obsidian vault, all via the delegated skills.

## How to use it

A typical session looks like this:

```text
You: good morning

Skill: Phase 1 — sprint-snapshot --phase daily (overwrite in place)... ✓ +1 trend row
       Phase 1.5 — team calendar: John Doe PTO 6/22→7/3, Parrott PTO→6/23 (2 out, +1 other)
       Phase 2 — daily-standup-prep --include-sprint-pulse... ✓ burndown on-track
       Phase 3 — daily-briefing, steps 1–6, skip focus blocks... ✓ daily+weekly+monthly

       === Good morning — 2026-05-18 ===
       ✓ Snapshot:  [daily.canvas] [daily.md]           (+1 trend row)
       ✓ OOO:       John Doe (PTO→7/3), Parrott (PTO→6/23)  (2 out, +1 unattributed)
       ✓ Standup:   [Aurora 2026-05-D18.md]             (burndown ↘ on-track)
       ✓ Briefing:  [2026-05-D18.md] [2026-W20.md] [2026-M05.md]  (12 unread, 4 meetings)

       ## Next actions
       - Reply to the schema-freeze thread before 2pm (blocking the migration ticket)
       - Review MR !412 — two others are stacked on it
       - Confirm coverage for John Doe's in-flight ticket (OOO through 7/3)
```

## Getting the most out of it

- **Just invoke it and let it run.** The whole point is unattended execution. It auto-answers overwrite prompts and auto-continues between phases — don't sit and confirm each step.
- **Re-run it freely.** It's idempotent: same-day re-runs overwrite artifacts in place (the JSONL trend log is the only append-only exception). If a phase failed the first time, run it again.
- **Configure the team-calendar ICS once.** The OOO digest is high-value — it's what catches a vacation the schedule view misses. Add the URL to `reference_team_calendar_ics.md` so Phase 1.5 stops skipping.
- **Use the skip flags for partial mornings.** Already ran `/sprint-snapshot` manually? `--skip-snapshot`. Calendar feed down and you don't want the warning noise? `--skip-calendar`.
- **Read the Next actions block.** Because Phase 3 runs report-only (no focus blocks), the `personal-assistant` pass is where "what should I do next" lives — that's the actionable output, not just the artifact links.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Run phases in parallel.** Phase 2's burndown reads Phase 1's JSONL row; the order is load-bearing. Always sequential.
- ❌ **Pause for acknowledgment between phases.** No "shall I continue?", no mid-flight summaries. The user opted into the whole chain by invoking it.
- ❌ **Propose focus blocks or create calendar drafts.** Phase 3 is deliberately report-only; block-scheduling belongs to standalone `/daily-briefing` (step 9).
- ❌ **Auto-answer the briefing's action-item prompts.** The stale-carryover and recently-closed re-surface prompts are genuine user decisions — forwarded as-is, never silently answered "still open."
- ❌ **Continue past a Phase-1 failure.** A missing snapshot breaks Phase 2's burndown, so a hard Phase-1 failure aborts the wrapper (Phases 2/3 may degrade gracefully; Phase 1 may not).
- ❌ **Report someone back from OOO a day early.** `DTEND` is exclusive (RFC 5545) — the last day out is `DTEND − 1`. Getting this wrong is the calendar-parsing failure mode to avoid.
- ❌ **Write memory.** All config is read from existing keys; the wrapper creates no memory files.

## Internals

Four phases, run sequentially with auto-continue:

| Phase | Delegates to | Produces |
| :--- | :--- | :--- |
| 1. Snapshot | `sprint-snapshot --phase daily` | `daily.canvas` + `daily.md` + JSONL trend row |
| 1.5. OOO digest | Confluence Team Calendar ICS (inline parse) | in-memory digest → forwarded to Phases 2 & 3 |
| 2. Standup | `daily-standup-prep` (sprint pulse on) | per-team report + burn-up chart |
| 3. Briefing | `daily-briefing` (steps 1–6, skip step 9) | daily + weekly + monthly notes |
| 4. Summary | `clarity-council` (personal-assistant) | console summary + repairs + Next actions |

**The ICS parse in Phase 1.5 is load-bearing and easy to get wrong** — the SKILL documents the rules verbatim: unfold line continuations first; treat `DTEND` as exclusive; attribute via the `CN="Last, First"` field (not `SUMMARY`, which is usually a bare `PTO`); merge adjacent same-person ranges; window-filter against the sprint end date. Getting attribution wrong is what once let a week-long PTO go unsurfaced.

**Phase 4 carries three belt-and-suspenders passes** that re-verify the delegated skills' own guarantees: a daily-note section-completeness check (the burndown chart silently vanished from four consecutive notes before this existed), an action-item post-filter (demotes FYIs that slipped through as `- [ ]` items), and the personal-assistant Next-actions pass (restores the "what to do next" signal that `--no-focus-blocks` removes). If any repair fires on more than one run, that's a signal the upstream skill's checklist needs tightening.

## FAQ

**Q: What does the wrapper actually do itself?**
A: Almost nothing — it orchestrates. It consumes only the four skip flags; everything else is forwarded to sub-skills, and every artifact is produced by a delegated skill. Its value is ordering, auto-continue, auto-overwrite, OOO plumbing, and the Phase-4 safety nets.

**Q: Why does Phase 3 skip focus blocks?**
A: Because `/good-morning` is meant to produce artifacts unattended, and focus-block proposals + meeting drafts are interactive, calendar-mutating decisions. The `personal-assistant` Next-actions block gives the "what next" signal without touching the calendar.

**Q: Is it safe to run twice in one morning?**
A: Yes — it's idempotent. Same-day artifacts are overwritten in place; only the JSONL trend log is append-only.

**Q: What happens if the team calendar is unreachable?**
A: Phase 1.5 is best-effort. It skips with a `⚠ Phase 1.5 skipped: <reason>` line in the summary and the other phases run unchanged — OOO data is high-value but not load-bearing.

**Q: When does the whole thing stop early?**
A: Only for a hard Phase-1 failure (aborts — the snapshot is a prerequisite) or a genuinely blocking sub-skill question the wrapper can't answer for the user (e.g. a missing roster with no source path, or the briefing's action-item decisions). Everything else auto-continues.

**Q: Can I run just part of the routine?**
A: Yes — `--skip-snapshot`, `--skip-calendar`, `--skip-standup`, `--skip-briefing` each drop a phase, and the summary notes which phases ran.

## Related skills

- **[sprint-snapshot](../sprint-snapshot/)** — Phase 1; the daily snapshot and JSONL trend row every later phase depends on.
- **[daily-standup-prep](../daily-standup-prep/)** — Phase 2; the per-team standup report with sprint pulse.
- **[daily-briefing](../daily-briefing/)** — Phase 3; the Outlook-driven daily report + rollups (run report-only here).
- **[clarity-council](../clarity-council/)** — the Phase 4 `personal-assistant` pass that produces the Next-actions block.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (four-phase sequential wrapper, ICS parse rules, Phase-4 safety nets)
