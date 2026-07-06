---
name: issue-estimate-sp
description: >
  Estimate story points for a Jira ticket using historical data and multi-persona scrum poker.
  Use when user says "estimate this ticket", "how many points", "story point estimate",
  "estimate [TICKET-KEY]", or invokes /issue-estimate-sp. Read-only — never modifies the ticket.
allowed-tools:
  - Read
  - Agent
  - Skill
  - mcp__atlassian__jira_get_issue
  - mcp__atlassian__jira_get_comments
  - mcp__atlassian__jira_get_changelog
  - mcp__atlassian__jira_search
  - mcp__atlassian__confluence_search
related-agents:
  - scrum-master
  - project-manager
  - mcp__atlassian__confluence_get_page
  - mcp__atlassian__jira_get_epic_issues
related-skills:
  - clarity-council
loop-eligible: false

---

# Estimate

Estimate story points for a Jira ticket via context gathering and a scrum-poker council session.
This is a **read-only** operation. Never update the ticket.

## Input

- `ticket_key` (required) — e.g. `ABC-12345`

## Workflow

```text
Estimate Progress:
- [ ] Step 1: Gather ticket context from Jira
- [ ] Step 2: Gather related context (feature, linked tickets, Confluence)
- [ ] Step 3: Load reference data for calibration
- [ ] Step 4: Run scrum-poker council session
- [ ] Step 5: Present estimate with rationale
```

### Step 1: Gather ticket context

Use the Atlassian MCP (read-only) to collect:

1. **Issue details** — `jira_get_issue` with the ticket key. Extract: summary, description, issue type, priority, labels, components, current story points (if any), acceptance criteria.
2. **Comments** — `jira_get_comments` for team discussion and context.
3. **Changelog** — `jira_get_changelog` to see if story points were previously set, changed, or debated.

### Step 2: Gather related context

1. **Parent feature/epic** — if the issue has a Feature Link or Epic Link, fetch it with `jira_get_issue` to understand the broader scope.
2. **Linked tickets** — follow issue links (blocks, relates-to, split-from) to understand dependencies and prior work. Limit to 3-5 most relevant links.
3. **Confluence context** — if the ticket references Confluence pages or has remote links, fetch up to 2 pages for additional design/requirements context using `confluence_get_page`.
4. **Similar completed tickets** — search for recently closed tickets with similar labels (components are rarely populated — only 8% of tickets have them). Use team labels (`emerald`, `pyrite`, `obsidian`) and category labels (`POAM`, `sp-candidate`, `spTooling`, `documentation`) for matching. Example JQL: `project = {PROJECT} AND labels in ({TEAM_LABEL}) AND status in (Done) AND "Story Points" is not EMPTY ORDER BY resolutiondate DESC` (limit 5). Also check for keyword-similar tickets using a text search on the summary.

### Step 3: Load reference data

Read [REFERENCE_DATA.md](REFERENCE_DATA.md) to calibrate the estimate against historical actuals. This file contains:
- Representative tickets at each Fibonacci level with actual flow times
- Known estimation biases in the project (8 documented biases)
- Summary keyword anchors (e.g. "smoke" = always 1, "STIG" = typically 3-5)
- Team estimation profiles by label
- Guidance on when to adjust estimates up or down

**Quick-check the keyword anchors first.** If the ticket summary contains a strong keyword signal (e.g. "smoke test", "upgrade", "investigate"), use the keyword table as a starting point before the full council session.

Use this data to ground the council's discussion in empirical reality, not just gut feel.

### Step 4: Run scrum-poker council session

Invoke the **clarity-council** skill with the following configuration:

```
user_problem: "Estimate story points for {TICKET_KEY}: {SUMMARY}"

context: |
  {Paste the gathered ticket description, acceptance criteria, and key details}
  
  Related context:
  {Feature/epic summary if available}
  {Key linked ticket summaries}
  
  Reference calibration:
  {Summary of relevant reference data from REFERENCE_DATA.md — 
    include the representative tickets at the 2-3 most likely SP levels}

desired_outcome: >
  A Fibonacci story point estimate (1, 2, 3, 5, 8, 13, or 21) with rationale.
  Each persona should independently "play a card" (pick a number),
  then the group synthesizes to a final recommendation.

constraints:
  - 1 story point ≈ 1 business day of flow time (In Progress to Done)
  - Use only Fibonacci values: 1, 2, 3, 5, 8, 13, 21
  - Account for coordination overhead, not just coding effort
  - Investigation/prototype tickets tend to resolve faster than estimated
  - Consider review queue time as part of the estimate
  - This is READ ONLY — do not modify the ticket

selected_personas:
  - scrum-master
  - tech-lead
  - senior-developer
  - qa-engineer

depth: standard
```

**Persona overrides for scrum poker:**


- **scrum-master**: Focus on historical velocity, team capacity, and whether this fits cleanly into a sprint. Compare against reference data for similar tickets. Watch for estimation anti-patterns (artificial splitting, optimism bias).
- **tech-lead**: Focus on technical complexity, unknowns, dependencies, and coordination tax. Flag if this crosses team boundaries or requires environment access.
- **senior-developer**: Focus on implementation effort — lines of code, number of files, testing complexity, review burden. Be concrete about what "done" looks like.
- **qa-engineer**: Focus on test coverage needed, edge cases, regression risk, and validation effort. Flag if testing requires a deployed environment or special access.

### Step 5: Present estimate

Format the output as:

```markdown
## Story Point Estimate: {TICKET_KEY}

**Recommended: {N} story points**

### Scrum Poker Results

| Persona | Card Played | Key Reasoning |
|---------|-------------|---------------|
| Scrum Master | {N} | {one sentence} |
| Tech Lead | {N} | {one sentence} |
| Senior Developer | {N} | {one sentence} |
| QA Engineer | {N} | {one sentence} |

### Why {N} points

{2-3 sentences synthesizing the council's reasoning. Reference the closest
comparable ticket from REFERENCE_DATA.md if one exists.}

### Risk factors

- {bullet list of things that could push the estimate higher}

### Comparable tickets

| Ticket | Summary | Est. SP | Actual Days |
|--------|---------|---------|-------------|
| {key} | {summary} | {sp} | {days} |

> **Note:** This estimate was generated from historical data and persona analysis.
> It has not been written to the ticket. Discuss with your team before committing.
```

