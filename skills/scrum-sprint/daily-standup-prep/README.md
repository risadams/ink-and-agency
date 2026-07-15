# Daily Standup Prep

Generate a **per-team standup report** by gathering the last N days of activity across Jira, GitLab, Confluence, and a local Git repo, mapping it to team members from a roster CSV, and rendering one markdown file per team into the Obsidian vault. Each report carries a Mermaid kanban, a randomized talking order, and a **sprint pulse** — a daily-tagged snapshot plus a clarity-council burn-up chart, forecast, and scrum-master suggestions. Read-only across every external system; the only writes land in the vault's `Scrum Teams/` tree.

## Why this exists

Standup prep is repetitive, cross-system busywork: chase who touched what in Jira, which MRs and pipelines moved in GitLab, which Confluence pages changed, which commits landed — then attribute all of it to the right person and lay it out consistently. Done by hand it's slow and error-prone (the same person is `jdoe` in GitLab, `Doe, John` in Jira, and `John Doe <john@…>` in Git). This skill is a faithful Claude Code port of a battle-tested PowerShell script (`Get-Standup-Report.ps1`) — same inputs, same template, same identity-matching cascade, same output layout — with a sprint pulse added on top so the standup shows not just *what happened* but *whether the sprint is on track*.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "daily standup prep" / "generate standup" / "standup report"
  - "scrum prep"
- Running the slash command: `/daily-standup-prep [teams] [--days N] [--inc N] [--sprint N] [--no-gitlab] [--no-confluence] [--no-sprint-pulse]`

## What it does

For each team in the run, the skill executes a seven-phase pipeline: **(1)** resolve config from memory and load the roster CSV; **(2)** compute the lookback window and auto-build JQL; **(3)** gather Jira/GitLab/Confluence/Git activity in parallel; **(4)** match every activity record to a team member via an 8-strategy identity cascade and flag who has activity; **(4.5)** run the sprint pulse — delegate a `daily`-tagged snapshot to `sprint-snapshot`, then a `clarity-council` of infographics-expert + statistics-expert + scrum-master for a burn-up chart, forecast, and suggestions; **(5)** render each section (talking order, kanban, per-member activity blocks); **(6)** substitute the vault's Standup template and write the file (never overwriting silently); **(7)** print a per-team console summary. Everything external is read-only.

### Inputs

- **Team name(s)** — one or more, e.g. `Pyrite,Onyx`. Defaults to `Pyrite`.
- **Window + sprint** — `--days` (default 2), `--inc` (default 25), `--sprint` (default 1); JQL is auto-built if not supplied.
- **Section toggles** — `--no-gitlab`, `--no-confluence`, `--no-sprint-pulse`, etc. — each skips gather + fetch and substitutes an empty placeholder.
- **A roster CSV per team** — `FullName,Email,Alias,Role,Flags`, maintained in the vault's `_rosters/` dir (bootstrapped from the PS repo on first run).

### Outputs

- **One markdown file per team** at `{{vault_root}}\Scrum Teams\<Team>\Scrum 📅\INC {n}\Sprint {n}\YYYY-MM-DD.md`, populated from the user's Standup template.
- **A daily sprint snapshot** (`daily.canvas` + `daily.md`) and an appended row in the sprint's `_snapshots.jsonl` trend log (written by `sprint-snapshot`).
- **A per-team console summary** — members loaded, issues/commits/activities matched, sprint-pulse status, saved path.

### External systems used

- **Jira / Confluence** (`mcp__atlassian__*`) — issues, changelogs, comments, pages. Read-only.
- **GitLab** (`mcp__gitlab-mcp__*`) — MRs, discussions, pipelines across the group. Read-only.
- **Local Git repo** — `fetch` + `log` only, never checkout/pull/merge.
- **The Obsidian vault** — the only write target (`Scrum Teams/`); the template is read-only.
- **[sprint-snapshot](../../scrum-sprint/sprint-snapshot/)** and **[clarity-council](../../clarity-council/)** — own the sprint pulse; never reimplemented inline.

## How to use it

A typical session looks like this:

```text
You: /daily-standup-prep Pyrite --days 3

Skill: Gathering Pyrite standup for window 2026-05-11 → 2026-05-14 (3-day lookback).
       Phase 1 ✓ config resolved, roster loaded (11 members)
       Phase 3 ✓ Jira 27 scanned, GitLab 6 projects, Confluence 4 pages, 41 commits
       Phase 4 ✓ matched to members via identity cascade
       Phase 4.5 — delegating daily snapshot to sprint-snapshot...
                 → +1 trend row; clarity-council burn-up + forecast + suggestions
       Phase 6 — file exists for today. Overwrite / Append / Skip?

You: overwrite

Skill: === Pyrite standup report ===
       Team members loaded: 11
       Jira issues included: 9 (of 27 scanned)
       Git commits matched: 23 · GitLab: 6 · Confluence: 2
       Sprint pulse: snapshot=ok · trend rows=4 · council=ok
       Saved: [2026-05-14.md]
```

## Getting the most out of it

- **Keep the roster CSVs current.** Identity matching is only as good as the roster — a missing alias means that person's commits go unattributed. The CSVs live in the vault's `_rosters/` so they're easy to maintain in one place.
- **Let the sprint pulse run.** The burn-up chart is the difference between "here's what happened" and "here's whether we'll make the commit." Skip it (`--no-sprint-pulse`) only when Jira is down or you genuinely just want the activity log.
- **Run it multi-team in one invocation.** `Pyrite,Onyx` loops the whole pipeline per team and writes one file each — cheaper than two separate runs.
- **Trust the degraded modes.** If GitLab or Confluence is unreachable, the report still generates with a `_<system> unavailable_` note in that section rather than failing the whole run.
- **Add the pulse placeholders to your template once.** The three sprint-pulse slots (`{{burndown_chart}}`, `{{forecast_note}}`, `{{scrum_suggestions}}`) are no-ops if your Standup template doesn't reference them — add a `## Sprint Pulse` block to see them rendered.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Modify any external state.** No issue transitions, no comments, no MR approvals, no page edits, no git checkout/pull. Read-only is a hard rule.
- ❌ **Overwrite a standup file silently.** An existing file for today always triggers an Overwrite / Append / Skip prompt.
- ❌ **Fabricate data when a system is down.** A failed MCP call surfaces in the summary and renders a `_unavailable_` note — never invented activity or trend rows.
- ❌ **Reimplement the sprint pulse inline.** The daily snapshot must come from `sprint-snapshot` and the burn-up/forecast/suggestions from `clarity-council`'s three pinned personas — inlining bypasses the constraints (chartjunk rules, confidence bands) that make those artifacts trustworthy.
- ❌ **Write broken wikilinks.** A team member gets a `[[@First Last]]` link only when the vault has their person note; otherwise plain text, to keep the graph clean.
- ❌ **Edit the past.** The `_snapshots.jsonl` trend log is append-only; past rows are never rewritten (past `daily.*` files may be overwritten — the trend record is the JSONL).

## Internals

The seven-phase pipeline runs per team; see [REFERENCE.md](REFERENCE.md) for the full algorithm and formatter contracts, and [EXAMPLES.md](EXAMPLES.md) for parity with the source PowerShell script.

| Phase | Does |
| :--- | :--- |
| 1. Config + roster | Resolve every `{{placeholder}}` from memory; load roster into member records |
| 2. Window + JQL | Compute the lookback window (Pittsburgh local); auto-build JQL if none given |
| 3. Gather (parallel) | Jira issues/changelogs/comments, GitLab MRs/pipelines, Confluence pages, Git log |
| 4. Match | 8-strategy identity cascade `(email, displayName, username)` → flag `HasActivity` |
| 4.5. Sprint pulse | `sprint-snapshot --phase daily` → read `_snapshots.jsonl` → `clarity-council` (burn-up + forecast + suggestions) |
| 5. Render | Talking order, Mermaid kanban, per-member activity blocks |
| 6. Substitute + write | Fill the vault Standup template; confirm before overwrite |
| 7. Summary | Per-team console block |

**Config resolution** pulls vault root, Jira project, Confluence space, GitLab base + group, template path, and roster dir from memory files — never from args. An `<unset>` value prompts once (with the PS-script default recommended) and persists the answer.

**The burn-up chart** (not burn-down) is the canonical shape: it visualizes scope changes explicitly, so scope creep shows as a rising scope line rather than hiding in a misleading "remaining" curve. Its contract in Phase 4.5 is followed verbatim — actual vs pinned series, capacity reference, `null` gaps for future/past days — and rendered via the `obsidian-charts` plugin's `chart` code fence.

## FAQ

**Q: Is anything written to Jira/GitLab/Confluence?**
A: No. Every external call is read-only. The only writes are markdown files in the vault's `Scrum Teams/` tree and the append-only JSONL trend log.

**Q: How does it know which activity belongs to whom?**
A: An 8-strategy cascading matcher (see [REFERENCE.md](REFERENCE.md#identity-matching-cascade)) matches each record by email, display name, and username against the roster — because the same person has different identifiers in each system.

**Q: Why a burn-up chart instead of a burn-down?**
A: Sprints here regularly take +20–40 pts of scope mid-sprint. Burn-down folds that into the "remaining" line and lies; burn-up shows scope and done as separate climbing lines so creep is visible.

**Q: What if I don't have the sprint-pulse placeholders in my template?**
A: The substitution still runs cleanly — the placeholders are no-ops. The skill notes it once so you can add a `## Sprint Pulse` block if you want the chart rendered.

**Q: Where do the roster CSVs live?**
A: In the vault's `Scrum Teams/_rosters/<Team>.csv`. On first run the skill offers to copy them from the source PowerShell repo so you maintain them in one place going forward.

**Q: Can I run it for several teams at once?**
A: Yes — `Pyrite,Onyx` loops the whole pipeline per team and writes one file each, with per-team status in the final summary.

## Related skills

- **[sprint-snapshot](../../scrum-sprint/sprint-snapshot/)** — owns the Phase 4.5 daily snapshot and the `_snapshots.jsonl` trend schema; always delegated, never reimplemented.
- **[clarity-council](../../clarity-council/)** — owns the Phase 4.5 pulse council (infographics-expert + statistics-expert + scrum-master).
- **[daily-briefing](../../exec-function/daily-briefing/)** — the personal (Outlook-driven) sibling; both run on the same morning and share the vault-root resolution pattern.
- **[good-morning](../../scrum-sprint/good-morning/)** — the wrapper that runs this skill (with sprint pulse) as one phase of a three-skill morning chain.
- **[obsidian-markdown](../../obsidian/obsidian-markdown/)** / **[obsidian-vault](../../obsidian/obsidian-vault/)** / **[obsidian-bases](../../obsidian/obsidian-bases/)** — the canonical references for extending the template, verifying wikilinks in bulk, or building a standup dashboard.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (seven-phase per-team pipeline, config resolution, rules)
- **[REFERENCE.md](REFERENCE.md)** — Identity-matching cascade, roster CSV schema, per-section formatter contracts
- **[EXAMPLES.md](EXAMPLES.md)** — Invocation parity with the source PowerShell script
