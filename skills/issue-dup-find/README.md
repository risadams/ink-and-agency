# Issue Duplicate Finder

Read-only scan of every open issue in a Jira project to surface likely duplicate pairs. The skill clusters candidates, scores them with semantic comparison, and returns a markdown report with probability bands and one-sentence evidence per pair — without ever linking, transitioning, or commenting on a ticket.

## Why this exists

Backlogs accumulate dupes faster than anyone wants to admit. The same bug gets re-reported by three customers; a refactor RFC quietly resurfaces six months later under a new title. Periodic dedupe sweeps catch these before they fragment discussion across two tickets, but the sweep itself is the chore — nobody wants to spend an afternoon eyeballing 400 open issues. This skill compresses the eyeballing into a single command and surfaces *why* each pair looks like a duplicate, so the reviewer can act on confidence rather than gut.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "find duplicates"
  - "duplicate check"
  - "dedupe issues"
  - "find duplicate tickets in PROJ"
- Running the slash command: `/issue-dup-find` (with optional project key, e.g. `/issue-dup-find ABC`)

## What it does

The skill paginates every open issue in the target project, clusters candidate pairs to avoid an O(n²) blowup, semantically scores each pair, and renders a grouped markdown report. It uses the Atlassian Jira MCP for reads and the local filesystem for a per-run scratch folder that holds intermediate state. It does **not** link tickets, transition status, post comments, or modify any ticket field.

### Inputs

- **Project key** — string, optional. Resolved from memory (`reference_jira_default_project.md`) when omitted. If memory has no entry, the skill prompts once and saves the answer for next time. Override per-invocation via `/issue-dup-find ABC` or "find duplicates in PROJ".
- **Output destination** — optional. Chat by default; pass a file path to also write the report to disk.

### Outputs

- A grouped markdown **Duplicate Scan Report** in chat with anchor issues, ranked candidate dupes, probability bands, and one-sentence evidence per pair.
- *Optional*: the same report written to a file on disk.
- A scratch folder at `C:\temp\issue-dup-find-{PROJECT}-{YYYYMMDD-HHMM}\` containing `issues.json`, `pairs.json`, and `scores.jsonl` for resume-after-failure (auto-cleaned on success).

### External systems used

- Jira (read only — `jira_search`, `jira_get_issue`)
- Local filesystem (scratch folder + optional report write)

## How to use it

A typical session looks like this:

```text
You: find duplicates in WEB

Skill: Project: WEB · Output: chat only · Scratch: C:\temp\issue-dup-find-WEB-20260512-1015\
       [Phase 1] Fetched 287 open issues...
       [Phase 2] Formed 94 candidate pairs across 41 clusters.
       [Phase 3] Scoring 94 pairs in batches of 25...

       # Duplicate Issue Scan — WEB
       **Scanned:** 287 open issues · **Pairs evaluated:** 94 · **Reported:** 11
       **Read-only — no tickets modified**

       ## Suspected duplicates

       ### WEB-7634 — Checkout button silently fails on Safari
       | Possible duplicate | Probability | Reason |
       | --- | --- | --- |
       | WEB-7890 — Cart submit no-op on Safari 17 | High (88%) | Same affected component; Safari-only; both reference cart-button.tsx. |
       ...

       Scratch folder removed.
```

## Getting the most out of it

- **Run it monthly, not before every release.** The point is to spot drift — running it every day produces noise. A scheduled monthly sweep catches accumulation without becoming a chore.
- **Start with the High band.** The report is sorted by probability. Anything ≥80% is usually worth acting on; Medium pairs warrant a glance; Low pairs are mostly false positives kept in for completeness.
- **Cite the evidence when linking.** When you do go link a pair manually in Jira, paste the report's one-sentence reason into the link comment. Future readers will thank you.
- **Pre-filter with components or labels for big projects.** If your project has >500 open issues, scope the scan first by talking to the skill: "find duplicates in PROJ with the auth-service component" (the skill will narrow JQL accordingly).

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Auto-link or close duplicates.** The output is a report, period. The skill never touches a ticket field. If you want to link a pair, do it manually in Jira after reviewing.
- ❌ **Find duplicates of *closed* tickets.** Only open issues are scanned. A reopened complaint of an old bug won't surface as a dupe of the closed one.
- ❌ **Detect cross-project duplicates.** One project per run. If the same bug is filed in two projects, run the skill in each and reconcile manually.
- ❌ **Replace ticket-grooming judgment.** Probability bands are heuristics. A 92% pair might be two genuinely distinct bugs that share a component and a keyword. Read the evidence sentence before acting.

## Examples

### Example: Default project sweep

```text
You: find duplicates

Skill: Project: MYPROJ (from memory) · Scanning...

       # Duplicate Issue Scan — MYPROJ
       **Scanned:** 156 open · **Reported:** 7

       ### ABC-1042 — Auth token refresh loop in mobile clients
       | Possible duplicate | Probability | Reason |
       | --- | --- | --- |
       | ABC-1287 — iOS users redirected to login every 30 min | High (91%) | Both report the 30-minute interval and stack-trace bottoms in token-refresh.swift. |
```

The default project is configurable in `reference_jira_default_project.md` (memory). Override per-call by passing a project key.

### Example: Save the report to disk

```text
You: dedupe issues in PROJ and save to C:\temp\proj-dupes.md

Skill: ...generates report...
       Wrote report to C:\temp\proj-dupes.md
       Scratch folder removed.
```

When a path is provided, the report is also written to disk; the on-screen rendering is unchanged.

## Internals

The skill follows a 6-phase workflow:

1. **Fetch open issues** — paginates `jira_search` until exhausted; persists to `issues.json` for resume.
2. **Cluster candidate pairs** — groups by shared component, overlapping label, or ≥3 shared significant tokens in summary; deduplicates pairs across clusters; persists to `pairs.json`.
3. **Semantic comparison** — scores each pair into High (80-100%), Medium (50-79%), Low (25-49%), or drop (<25%); writes to `scores.jsonl` in batches of 25 for durable progress.
4. **Render report** — groups by anchor issue (lower issue number wins), sorts within group by probability descending, caps at 5 reported pairs per anchor.
5. **Optional file write** — only if user supplied a path or accepts the prompt to save.
6. **Cleanup scratch folder** — removes intermediate state on success; retains it on error so the user can inspect partial state or resume.

Key constraints:

- **Read-only across Jira.** Zero write tools allowed against the Jira MCP.
- **No artificial pair cap.** All clustered candidate pairs are scored — large projects cost more tokens but produce complete reports.
- **Existing duplicate links are excluded.** Already-known dupes don't pollute the report.

## FAQ

**Q: Where does the default project key come from?**
A: From memory — `reference_jira_default_project.md` → `**Default Jira project key:**`. Update that memory entry to change the permanent default. Pass any other project key on the command line to override per-call.

**Q: How does it avoid an O(n²) explosion on big projects?**
A: Phase 2 clusters issues by shared component, label, or summary tokens before forming pairs. Two issues only become a candidate pair if they share at least one strong signal — most pairs in a 500-issue project never get scored.

**Q: What if I find a duplicate the report missed?**
A: That's a clustering miss — usually because the two issues didn't share components, labels, or summary keywords. File it as feedback; the clustering rules in Phase 2 are tunable.

**Q: Can I scope the scan to a single component or label?**
A: Yes — phrase the request explicitly ("find duplicates in WEB with the checkout component"). The skill narrows the JQL and scans only the matching subset.

**Q: How long does a typical run take?**
A: Roughly one minute per 50 open issues. A 500-issue project takes ~10 minutes, mostly in Phase 3.

## Related skills

- **[issue-suggest-component](../issue-suggest-component/)** — pair these on a backlog-grooming day. Run the dupe finder first, then suggest components on whatever survives.
- **[issue-triage](../issue-triage/)** — when the scan flags a likely dupe but you're unsure which is the canonical ticket, triage both. The signal-gathering will surface the deeper context.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
