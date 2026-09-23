# Issue Suggest Component — Bulk Mode

Read when invoked with no ticket key or with a project key only. The single-mode suggestion bar,
constraints, and evidence rubric in [SKILL.md](SKILL.md) still apply to every ticket.

```text
Bulk Progress:
- [ ] Phase B1: Resolve project + create scratch folder + load components
- [ ] Phase B2: Fetch open tickets (highest key first, cap 250)
- [ ] Phase B3: Per-ticket loop: light context + suggest + confirm
- [ ] Phase B4: Write rolling report
- [ ] Phase B5: Final summary + cleanup decision
```

### Phase B1 — Setup

1. Project key resolved from memory (`reference_jira_default_project.md` → `**Default Jira project key:**`). If memory is empty, prompt via `AskUserQuestion` and save the answer there. Accept per-invocation override.
2. Create scratch folder `C:\temp\issue-suggest-component-{PROJECT}-{YYYYMMDD-HHMM}\` and tell the user the path once.
3. Load existing components via `jira_get_project_components`.
4. Initialize `report.md` in the scratch folder with a header.

### Phase B2 — Fetch tickets

JQL: `project = {KEY} AND statusCategory != Done ORDER BY key DESC`

Paginate `jira_search` with `max_results: 100` until you reach 250 issues or the project is exhausted, whichever comes first. Persist the harvested list to `tickets.json` in the scratch folder.

For each ticket capture only what's needed for triage: `key`, `summary`, `description` (first 1500 chars), `components`, `labels`, `priority`, `created`, plus any remote links to Confluence/GitLab.

### Phase B3 — Per-ticket loop

For each ticket, **light depth only**:

1. Use the already-fetched description + remote links. Do **not** call `jira_get_comments` or `jira_get_changelog` per ticket — too expensive across 250 tickets.
2. For Confluence/GitLab links already on the ticket, fetch **only the first link of each kind** (cap one Confluence page + one MR per ticket).
3. Skip code search entirely in bulk mode.
4. Run the same Phase 4 proposal logic. If there is **nothing to suggest**, log it to the report as `no-change` and move to the next ticket without prompting the user.
5. If there are suggestions, present them and ask via `AskUserQuestion` with options:
   - **Apply suggestions** (default if all are existing components)
   - **Skip this ticket**
   - **Stop the run**
   For new-component proposals, do the two-step new-component flow from Phase 5.

Append the outcome (applied / skipped / stopped / no-change) to `report.md` after each ticket. This protects the report if the run is interrupted.

### Phase B4 — Rolling report format

```markdown
# Component Suggestion Sweep — {PROJECT}

**Started:** {YYYY-MM-DD HH:MM} · **Tickets scanned:** {N of 250} · **Project:** {KEY}

## Results

### {KEY-9999} — {summary}
- **Status:** applied · **Added:** `comp-a`, `comp-b` · **New created:** `comp-b`
- Evidence: {one-line summary of the strongest evidence}

### {KEY-9998} — {summary}
- **Status:** no-change · current components look correct.

### {KEY-9997} — {summary}
- **Status:** skipped · user declined.

...

## Summary
- Applied: {n}
- Skipped: {n}
- No-change: {n}
- New components created: {n} ({list})
- New components recommended (manual): {n} ({list})
```

### Phase B5 — Final summary + cleanup

Print a one-screen summary of the totals. Ask via `AskUserQuestion` whether to keep or remove the scratch folder:
- **Keep** *(default)* — leave the report on disk for review.
- **Remove** — delete the scratch folder.

If the run aborted with an error, **always keep** the scratch folder and surface the path: *"Partial state retained at {path}."*
