---
name: issue-suggest-component
description: >
  Suggest Jira components for one ticket or sweep all open tickets in a
  project. Gathers context from Jira, Confluence, and GitLab, proposes a
  conservative set of existing components (or recommends new ones), and
  confirms with the user before any modification. Bulk mode default project
  key is read from memory (`reference_jira_default_project.md`); max 250
  tickets, highest key first. Use when user says "suggest components", "tag
  components", "fix components", "categorize tickets", or invokes
  /issue-suggest-component with or without a ticket key.
allowed-tools:
  - Read
  - Write
  - Bash
related-agents:
  - architect-reviewer
  - backend-developer
  - frontend-developer
  - AskUserQuestion
  - mcp__atlassian__discover_tools
  - mcp__atlassian__jira_get_issue
  - mcp__atlassian__jira_get_comments
  - mcp__atlassian__jira_get_changelog
  - mcp__atlassian__jira_get_remote_links
  - mcp__atlassian__jira_search
  - mcp__atlassian__jira_get_project_components
  - mcp__atlassian__jira_update_issue
  - mcp__atlassian__confluence_search
  - mcp__atlassian__confluence_get_page
  - mcp__gitlab-mcp__list_merge_requests
  - mcp__gitlab-mcp__get_merge_request
  - mcp__gitlab-mcp__list_commits
  - mcp__gitlab-mcp__search_project_code
loop-eligible: false

---

# Issue Suggest Component

Suggest a focused set of Jira components for a ticket — adding only what's clearly supported by evidence in the ticket, linked Confluence pages, and related GitLab activity. Confirm every change with the user.

## Two modes

| Trigger | Mode | Behavior |
| --- | --- | --- |
| `/issue-suggest-component PROJ-1234` | **Single** | Deep context gather + suggest + per-change confirm |
| `/issue-suggest-component` (no key) | **Bulk** | Loop highest-key-first, max 250 open tickets in the default project (resolved from memory: `reference_jira_default_project.md`) |
| `/issue-suggest-component ABC` (project key only) | **Bulk** | Same as bulk, override project |

If the input is ambiguous, ask once.

## Suggestion bar (read this first)

**Be conservative.** Suggesting nothing is acceptable and often correct. Only propose a component when there is **direct evidence** in the ticket text, comments, linked Confluence, or related MRs/commits. Do not infer from issue key alone, from the assignee, or from "tickets nearby usually have X."

## Constraints

- **Confirm before every write.** Adding existing components, removing components, and creating new components each require explicit user approval.
- **New components** require a second-level confirmation. The skill attempts creation via the Atlassian MCP; if no `create_component` tool is exposed (run `discover_tools` to check), surface the recommendation and instruct the user to create it manually in Jira.
- **Never remove** a component the user has set unless the user explicitly asks for cleanup.
- **No other ticket fields are modified** — never touch summary, description, labels, status, assignee, story points, or comments.

## Workflow — Single mode

```text
Single Progress:
- [ ] Phase 1: Resolve project + load existing components
- [ ] Phase 2: Gather ticket context (Jira)
- [ ] Phase 3: Pull related signals (Confluence + GitLab)
- [ ] Phase 4: Propose components with evidence
- [ ] Phase 5: Per-change confirm + apply
```

### Phase 1 — Project + existing components

1. Extract the project key from the ticket key (`PROJ-1234` → `PROJ`).
2. `jira_get_project_components` to load the canonical component list. Cache it for the session.

### Phase 2 — Ticket context

- `jira_get_issue` — summary, description, type, priority, status, **current components**, labels, fixVersion, environment.
- `jira_get_comments` — investigation notes and additional context users provided.
- `jira_get_remote_links` — Confluence pages, MR URLs, dashboards.
- `jira_get_changelog` — note prior component changes (someone may have removed a component intentionally — respect that signal).

### Phase 3 — Related signals

1. **Confluence** — for each remote link to Confluence (cap at 2), `confluence_get_page` and skim for system/component names. If no remote links exist, skip — do not invent searches.
2. **GitLab MRs** — for each remote link to a GitLab MR, `get_merge_request` and capture the file paths touched. These map most reliably to components.
3. **GitLab code search (single mode only)** — if there is a clear error string, function name, or stack frame in the ticket, run **one** `search_project_code` to locate the owning module(s). Skip if no high-signal token.

### Phase 4 — Propose components

For each candidate, write **one sentence** of evidence. Map evidence → component using the existing component list. Format:

```markdown
## Component suggestions for {KEY} — {summary}

**Currently set:** {list, or "none"}

### Proposed additions
| Component | Status | Evidence |
| --- | --- | --- |
| `auth-service` | existing | Stack trace in description references `auth/middleware.go`; MR !4521 touches that file. |
| `payments-ui` | **NEW** | Description mentions "checkout button"; no existing component covers the React checkout flow. |

### Suggested removals
_None._  (or list with reasoning)

### No change
_The ticket already has the right components._  (use this when applicable)
```

If you have nothing to suggest, say so plainly: *"No component changes proposed — current set looks correct given the available evidence."* Then stop.

### Phase 5 — Per-change confirm

For each proposed addition (existing component), ask via `AskUserQuestion`:
- **Add `{component}`** *(recommended default if evidence is strong)*
- **Skip**

For each proposed **new** component, ask a two-step question:
1. **Create new component `{name}`?** (Yes / No)
2. If yes, attempt creation via the Atlassian MCP. If no `create_component` tool exists, fall back: tell the user to create it manually in Jira and re-run the skill, then **skip** the addition for this ticket.

After confirmations, apply additions in **one** `jira_update_issue` call setting the `components` field to the union of existing + approved-new. Confirm to the user with the final list.

If the user rejects every suggestion, end with one line: *"No changes applied."*

## Workflow — Bulk mode

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

## Evidence rubric (for both modes)

| Signal | Weight |
| --- | --- |
| Stack trace / file path / function name in ticket → matches a known module | **Strong** |
| GitLab MR linked from ticket touches files in a known module | **Strong** |
| Confluence design doc linked from ticket explicitly names a system | **Strong** |
| Ticket summary contains a system/feature name that matches a component verbatim | **Medium** |
| Reporter or assignee historically works on a component | **Weak — do not use as primary evidence** |
| "Looks like it might fit" with no concrete signal | **Insufficient — do not suggest** |

When in doubt, suggest nothing. The cost of an over-tagged ticket is higher than an under-tagged one because it pollutes filters and reports.

