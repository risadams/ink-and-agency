# Issue Suggest Component

Suggest Jira components for a single ticket or sweep an entire project. The skill gathers evidence from the ticket, linked Confluence pages, and related GitLab MRs, conservatively proposes existing components (or recommends new ones), and confirms every change with the user before any modification — no surprise writes, no over-tagging.

## Why this exists

Components are the most-ignored field in Jira. Reporters skip them; assignees forget them; sprint reports come out useless because filtering by component returns 12 tickets out of 400 actually relevant. Manually backfilling components across a 200-ticket backlog is unbearable, but the cost of *not* doing it is filters that lie. This skill makes the backfill tractable: evidence-based suggestions, per-ticket confirmation, no over-tagging, optional bulk-mode sweep.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "suggest components"
  - "tag components for PROJ-1234"
  - "fix components"
  - "categorize tickets"
- Running the slash command:
  - `/issue-suggest-component PROJ-1234` (single mode — deep context)
  - `/issue-suggest-component` (bulk mode — sweep default project, max 250)
  - `/issue-suggest-component ABC` (bulk mode on project ABC)

## What it does

The skill operates in two modes. **Single mode** does a deep context gather (Jira + Confluence + GitLab including a targeted code search) and confirms each component change individually. **Bulk mode** loops over the highest-key-first 250 open tickets in the project, runs lighter context per ticket (no code search), and skips the prompt entirely on tickets where there's nothing to suggest. Both modes confirm before any write and require a two-step prompt for creating new components.

### Inputs

- **Ticket key** — single mode, e.g., `/issue-suggest-component PROJ-1234`.
- **Project key** — bulk mode, optional. Resolved from memory (`reference_jira_default_project.md`) when omitted. If that memory entry is missing, the skill prompts once and saves the answer for future runs. Override per-invocation via `/issue-suggest-component ABC`.

### Outputs

- **Single mode**: per-component confirmation prompts, then a single `jira_update_issue` call applying approved additions.
- **Bulk mode**: a rolling markdown report at `C:\temp\issue-suggest-component-{PROJECT}-{YYYYMMDD-HHMM}\report.md` with applied / skipped / no-change status per ticket, plus per-ticket prompts for tickets with suggestions.

### External systems used

- Jira (read; write only on per-component user approval)
- Confluence (read only)
- GitLab (read only — `list_merge_requests`, `get_merge_request`, `list_commits`, `search_project_code` in single mode only)
- Local filesystem (scratch folder + report in bulk mode)

## How to use it

A typical single-mode session looks like this:

```text
You: suggest components for WEB-7890

Skill: Currently set: (none)

       Proposed additions
       | Component | Status | Evidence |
       |---|---|---|
       | checkout-flow | existing | Description references cart-button.tsx; MR !4521 modified that file. |
       | payments-ui | NEW | "Apple Pay button" in summary; no existing component covers mobile wallet UI. |

       Add `checkout-flow`? (Yes / Skip)
You: yes
       Create new component `payments-ui`? (Yes / No)
You: yes
       Then add to ticket? (Yes / No)
You: yes

Skill: Updated WEB-7890. Final components: checkout-flow, payments-ui.
```

## Getting the most out of it

- **Run bulk mode quarterly, not weekly.** Weekly bulk runs on the same project produce diminishing suggestions and habituate you to clicking "skip." Quarterly is the right cadence for catching real drift.
- **Pre-create obvious components manually.** If you already know your project needs `auth-service`, `payments-ui`, `notifications-worker` — create them once in Jira before running bulk mode. The skill will then add them via single-step confirms instead of two-step new-component prompts.
- **Trust the conservative bar.** When the skill says "no change," it means the evidence didn't pass the bar. Don't tag a ticket just because the skill *might* be wrong — over-tagging is what makes filters useless in the first place.
- **Use single mode for the highest-priority tickets.** Single mode does a code search; bulk mode doesn't. For tickets you're about to schedule, the deeper signal is worth it.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Auto-apply suggestions without confirmation.** Every component addition requires explicit approval. New components require two confirmations (create + add). There's no `--yes` flag.
- ❌ **Remove existing components.** The skill never removes a component the user has set unless you explicitly ask for cleanup. Respect prior intent.
- ❌ **Modify any other ticket field.** Summary, description, labels, status, assignee, story points — all untouched. The skill only writes the `components` field.
- ❌ **Suggest components from "looks like it might fit."** The evidence rubric is conservative. If the only signal is "the assignee usually works on this component," the skill suggests nothing.

## Examples

### Example: Bulk-mode sweep with mostly no-change

```text
You: suggest components

Skill: Project: MYPROJ (from memory) · Scratch: C:\temp\issue-suggest-component-MYPROJ-20260512-1430\
       Loaded 47 existing components. Fetching open tickets...
       250 tickets queued. Looping highest-key-first...

       MYPROJ-7890: applied (added checkout-flow)
       MYPROJ-7889: no-change
       MYPROJ-7888: no-change
       MYPROJ-7887: skipped — user declined
       ...
       (160 more no-change tickets)

       ## Summary
       Applied: 12 · Skipped: 3 · No-change: 235 · New created: 1
       Report: C:\temp\issue-suggest-component-MYPROJ-20260512-1430\report.md
       Keep scratch folder? (Yes / No)
```

The vast majority of tickets in a healthy project will be no-change — that's the signal the conservative bar is working.

### Example: New component requires two-step confirm

```text
You: suggest components for ABC-456

Skill: Proposed: `notifications-worker` (NEW) — only existing component
       covering background async work is `cron-jobs`, which doesn't fit.

       Create new component `notifications-worker`? (Yes / No)
You: yes
       Then add to ABC-456? (Yes / No)
You: yes

Skill: Created component `notifications-worker` in project ABC.
       Updated ABC-456. Final components: notifications-worker.
```

If the Atlassian MCP doesn't expose `create_component`, the skill falls back to recommending manual creation and skips the addition for this run.

## Internals

The skill follows a 5-phase workflow in single mode:

1. **Project + existing components** — extracts project key from ticket key; loads canonical component list once and caches.
2. **Ticket context** — issue, comments, remote links, changelog (changelog matters because removed components signal user intent to keep them off).
3. **Related signals** — Confluence pages from remote links, MR file paths from linked GitLab MRs, one targeted code search if a high-signal token exists.
4. **Propose components** — applies the evidence rubric, formats the proposal table with one-sentence evidence per candidate.
5. **Per-change confirm** — one `AskUserQuestion` per addition; new components get a two-step flow; final state applied via single `jira_update_issue`.

Bulk mode replaces phase 3's deep context with a "light" pass (no code search, capped at one Confluence + one MR per ticket) and adds a rolling-report-write phase. Tickets with nothing to suggest are logged silently to keep the run moving.

Key constraints:

- **Confirm before every write.** No `--yes` flag exists.
- **Conservative bar.** Strong evidence = stack trace, MR file paths, Confluence design doc. Weak evidence = reporter history. Insufficient evidence → suggest nothing.
- **Bulk cap of 250 tickets per run.** Keeps the run finite. Re-run if you have more.

## FAQ

**Q: Where does the bulk default project key come from?**
A: From memory — `reference_jira_default_project.md` → `**Default Jira project key:**`. Update that memory entry to change the permanent default. Override per-call by passing a different project key on the command line.

**Q: What if the Atlassian MCP doesn't support creating components?**
A: The skill checks via `discover_tools` and falls back to a recommendation: "create `notifications-worker` manually in Jira and re-run." For that ticket it skips the add.

**Q: Does it scan tickets in `Done` status?**
A: No. Bulk mode JQL is `statusCategory != Done`. Closed tickets are excluded from the sweep.

**Q: How is this different from issue-dup-find?**
A: Both sweep open issues in a project, both share the default project key from memory. Dup-find clusters issues looking for duplicates; this skill looks at each ticket independently and suggests categorization. Run dup-find first on a backlog grooming day, then this.

## Related skills

- **[issue-dup-find](../issue-dup-find/)** — pair these on a grooming day. Run dup-find first, then suggest components on the survivors.
- **[issue-triage](../issue-triage/)** — when component suggestions are unclear, triage may surface the deeper context that makes the right component obvious.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
