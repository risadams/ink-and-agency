# Daily Briefing

Personal daily briefing assistant. Pulls the last 24 hours (or longer, if there's a gap from a weekend or vacation) of email and calendar from Outlook, summarizes today's schedule, surfaces open action items, proposes focus blocks, and writes the briefing into the user's Obsidian vault as a daily note. Cascades updates to weekly and monthly rollup notes.

## Why this exists

The first hour of the workday is often consumed by triage: reading 30 emails, scanning today's meetings for conflicts, hunting for action items in yesterday's threads, deciding what to focus on. Most of that work is mechanical and patterns repeat day-to-day. This skill compresses the triage into one chat turn and produces a structured daily note that becomes the day's working document — a single artifact that captures the briefing, the proposed focus blocks, and lives in your knowledge graph alongside everything else. Backfill behavior handles weekends, alternating Fridays off, and longer breaks gracefully — one consolidated catch-up briefing instead of four separate gaps.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "daily briefing"
  - "morning briefing"
  - "daily standup prep"
- Running the slash command: `/daily-briefing`

## What it does

The skill detects how long since the last daily note (handles backfill from gaps), pulls inbox and calendar from that window plus today's schedule, triages email into Action Required / FYI / Awaiting Reply, analyzes today's schedule for conflicts/back-to-back stretches/prep gaps/free blocks, discovers vault link conventions for people and team notes, renders the daily note from a template, saves it to the Obsidian vault, cascades updates to weekly and monthly rollup notes, and proposes focus blocks. It does **not** mark emails read, modify Outlook items, or create calendar blocks without explicit user approval.

### Inputs

- **Implicit**: current Outlook inbox and calendar; the user's Obsidian vault.

### Outputs

- A daily note saved to the Obsidian vault.
- Updated weekly rollup note.
- Updated monthly rollup note.
- *Optional*: calendar focus-block drafts (only with user approval per block).

### External systems used

- Outlook (read; calendar drafts are write but require approval)
- Local filesystem (writes daily/weekly/monthly notes to the Obsidian vault)
- Obsidian vault (the notes render in Obsidian)

## How to use it

A typical session looks like this:

```text
You: daily briefing

Skill: Backfilling since 2026-05-07 (Thu) — 4-day window.

       (Fetched 47 emails, 12 calendar events from window;
        today: 5 meetings, 2 free blocks)

       Saved to: 📅/2026/05/2026-05-D11.md
       Updated: 📅/2026/05/2026-W19.md
       Updated: 📅/2026/2026-M05.md

       ## Executive summary
       - 4-day backfill: 2 customer escalations need response by EOD
       - Today: 5 meetings, no lunch gap, prep needed for 2pm design review
       - 47 emails: 8 action-required, 32 FYI, 7 awaiting reply
       - Recommended focus blocks: 9:30-10:45 (deep work), 1:30-2:00 (design prep)

       Calendar focus-block proposals:
       | Time | Block | Purpose |
       | --- | --- | --- |
       | 9:30-10:45 | Focus | Atlas design doc revisions |
       | 1:30-2:00 | Prep | Read Atlas design doc before 2pm review |

       Add either to the calendar?

You: just the prep block.

Skill: Created tentative meeting draft 1:30-2:00 PM "Prep — Atlas
       design review." Open in Outlook to confirm.
```

## Getting the most out of it

- **Run it as the very first thing each morning.** The skill assumes "I haven't seen what came in overnight" — running it after you've already replied to half the inbox produces a less useful briefing.
- **Engage the focus-block proposals.** The proposals are based on free time + open action items. Approving them turns the briefing into a calendar that defends your attention.
- **Keep the daily note open during the day.** It's a working document. Add notes as you go; the next morning's briefing will respect your edits (the auto-managed region is scoped).
- **Let the cascade run.** Daily → weekly → monthly updates happen automatically. Don't run the skill three times to "force" the cascade — it happens once per invocation.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Mark emails read or modify Outlook state.** Read-only against Outlook. The triage is for your eyes; the actions are yours to take.
- ❌ **Overwrite an existing daily note silently.** If today's note already exists, the skill asks: overwrite, append a new section (e.g., "Afternoon update — 14:30"), or skip.
- ❌ **Create calendar blocks without approval.** Focus-block proposals are presented; each requires explicit approval before a draft is created.
- ❌ **Run on a stale Outlook MCP.** If the Outlook MCP isn't responsive, the skill stops and tells you. Better to know the briefing wasn't generated than to receive a fabricated one.

## Examples

### Example: Standard 24-hour briefing

```text
You: daily briefing

Skill: Window: last 24 hours.
       Pulled 12 emails, 3 calendar events; today has 4 meetings.

       Saved to: 📅/2026/05/2026-05-D12.md

       ## Executive summary
       - 1 action-required email from Casey (Atlas design feedback by 3pm)
       - Today's day is open after 11am — good shape for deep work
       - No conflicts, no back-to-back stretches

       ## Today's schedule
       9:00 — Standup
       9:30 — 1:1 with Riley
       10:30 — Atlas design review
       2:30 — Customer call (external — prep recommended)

       ## Action items
       - [ ] Reply to Casey re: Atlas design feedback
       - [ ] Prep notes for 2:30 customer call
       - [ ] Follow up on Morgan's question about the Q3 roadmap

       Focus block proposal: 11:00–12:30 (deep work block before lunch).
       Add it?

You: yes.
```

The standard daily case is fast and produces a single consolidated artifact.

### Example: Backfill after a long weekend

```text
You: daily briefing

Skill: Backfilling since 2026-05-09 (Fri) — 3-day window (Fri PM through
       Sun, plus today).

       Pulled 38 emails, 4 calendar events from the gap; today has 6 meetings.

       ## Executive summary
       - 3-day catch-up: 2 emails need response today
       - Today is meeting-heavy — only 1 free block (3-4pm)
       - 1 cancelled meeting (2pm Atlas review moved to Friday)
       ...
```

Backfill mode collapses multiple days into one consolidated note with the window labeled explicitly.

### Example: Today's note already exists (re-run mid-day)

```text
You: refresh the briefing — I want to add the afternoon

Skill: Today's note exists at 📅/2026/05/2026-05-D12.md.
       Options:
       1. Overwrite (replaces existing morning briefing)
       2. Append "## Afternoon update — 14:30" section
       3. Skip the save (just show inline)

You: append.

Skill: Pulling email + calendar since 09:00 this morning...
       Appended afternoon section to today's note.
       Updated weekly rollup.
```

Same-day re-runs use append-mode by default to preserve the morning briefing.

## Internals

The skill follows a 9-step workflow:

1. **Determine briefing window** — find the most recent prior daily note (Glob + parse filename `YYYY-MM-DDD.md`). Window = `last_run_date 06:00` → now. Cap at 14 days; fall back to 24h if no recent note.
2. **Gather data in parallel** — `outlook_get_inbox_emails(since=<window_start>)`, `outlook_get_calendar_events(start=<window_start>, end=<now>)`, `outlook_get_calendar_events(start=<today 00:00>, end=<today 23:59>)`.
3. **Triage email** — Action Required / FYI / Awaiting Reply.
4. **Analyze today's schedule** — conflicts, back-to-back stretches, prep gaps, free blocks ≥45min, no-lunch flag.
5. **Discover vault link conventions** — Glob for canonical person notes (`🤼 Team/**/@*.md`) and team daily notes (`Scrum Teams/**/YYYY-MM-DD.md`); build a name→wikilink-target map.
6. **Render the report** — uses [REPORT_TEMPLATE.md](REPORT_TEMPLATE.md); saves to vault path `📅/YYYY/MM/YYYY-MM-DDD.md` (literal `D` prefix on day component only).
7. **Update weekly rollup** — uses [WEEKLY_TEMPLATE.md](WEEKLY_TEMPLATE.md); auto-managed region between markers; preserves user-added content outside.
8. **Update monthly rollup** — uses [MONTHLY_TEMPLATE.md](MONTHLY_TEMPLATE.md); cascades from weekly notes.
9. **Propose focus blocks** — map open action items + prep needs onto free blocks; user approves per block before any calendar draft is created.

Key constraints:

- **Read-only against Outlook.** Calendar drafts only on user approval.
- **Vault writes scoped to `📅/`** — never modifies other vault folders.
- **Never overwrite a daily note silently.** Always confirm.
- **Auto-managed region only on weekly/monthly notes.** Preserves user content outside markers.
- **Wikilinks only when targets exist** — broken links pollute the graph.
- **Pittsburgh local time** for all date math (America/New_York).
- **Privacy guard** — emails with subjects containing "confidential", "personal", "HR", or "legal" surface as "private email from <sender>" only.

## FAQ

**Q: Why the literal `D` prefix on daily-note filenames?**
A: It distinguishes personal daily notes (`YYYY-MM-DDD.md`) from team daily notes (`YYYY-MM-DD.md` under `Scrum Teams/`) so wikilinks resolve unambiguously.

**Q: What if the Outlook MCP is unavailable?**
A: The skill stops and tells you. It will not fabricate a briefing.

**Q: Does it work across multiple vaults?**
A: It writes to one vault — the path resolved from memory (`reference_obsidian_vault.md` → `**Vault root:**`). For multi-vault setups, update that memory entry to point at the primary vault, or override on first prompt.

**Q: What about all-day events?**
A: Treated as context (e.g., "PTO," "company holiday"), not as schedule blockers — unless they're marked as `out_of_office`.

**Q: Can I customize the briefing template?**
A: Yes — edit [REPORT_TEMPLATE.md](REPORT_TEMPLATE.md). The skill reads the template at runtime; changes apply to the next briefing.

**Q: How does the cascade work?**
A: Daily updates → re-render weekly note (preserving user content) → re-render monthly note (preserving user content). Auto-managed regions are scoped via comment markers.

## Related skills

- **[obsidian-vault](../obsidian-vault/)** — for searching across the daily/weekly/monthly notes the briefing produces.
- **[obsidian-bases](../obsidian-bases/)** — the briefing references base files (`Daily Notes Dashboard.base`, `Weekly Rollups.base`) that render embedded views in the daily note.
- **[obsidian-markdown](../obsidian-markdown/)** — for the Obsidian-flavored markdown syntax inside the templates.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow, paths, rules)
- **[REPORT_TEMPLATE.md](REPORT_TEMPLATE.md)** — Daily briefing template
- **[WEEKLY_TEMPLATE.md](WEEKLY_TEMPLATE.md)** — Weekly rollup template + ISO-week math
- **[MONTHLY_TEMPLATE.md](MONTHLY_TEMPLATE.md)** — Monthly rollup template + week-selection logic
