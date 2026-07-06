# issue-draft-release-notes

Draft a customer-facing **release note** for a Jira ticket from its context and related GitLab merge requests, run a quality pass, and (on opt-in) post it back to the ticket.

## What it does

Given a Jira ticket key, the skill:

1. **Gathers ticket context** — summary, description, type, fix version, comments, remote links.
2. **Finds related MRs** — by remote link and by ticket-key search; reads MR titles/descriptions/changed-files (diffs only when needed) to learn *what actually changed for the user*.
3. **Picks audience & type** — customer / operator / developer, and new-feature / enhancement / bug-fix / security / deprecation / breaking-change (asks if ambiguous).
4. **Drafts the note** — value-first, plain-language, one tight note per ticket (see [RELEASE-NOTE-FORMAT.md](RELEASE-NOTE-FORMAT.md)).
5. **Quality pass** — `/clarity-council` (Technical Writer + Product Owner + Customer Advocate) then `/writing-humanize`.
6. **Optional publish** — Jira comment (wiki markup + mandatory AI disclaimer) or a Release Notes field, only after explicit opt-in.

## Usage

```text
/issue-draft-release-notes SC2-1234
"draft a release note for SC2-1234"
"what changed in SC2-1234 — write it up for customers"
```

If you pass only a number, the default project key is read from memory (`reference_jira_default_project.md`).

## Read-only guarantee

Read-only across Jira, GitLab, and Confluence. The **only** write is in Phase 6 — a Jira comment or Release Notes field — and only after you explicitly choose to publish. Nothing is auto-posted.

## Edge cases

- **No MRs found** — drafts from ticket context alone and says so; if the context is too thin to describe a user-visible change, it stops rather than invent one.
- **Internal-only change** (refactor / CI / tests) — recommends *no customer note* and confirms before drafting anyway.
- **Breaking change / deprecation** — always adds an **Action required** line.
- **Security fix** — confirms the fix and area without publishing the vector.
- **Thin claims** — anything not traceable to the ticket or an MR is flagged for you to verify, not stated as fact.

## Related

- `mr-draft` — drafts the MR description (this skill consumes MRs; that one produces them).
- `issue-feature-breakdown`, `issue-triage` — same read-only Jira/MR context-gathering + council + opt-in-comment pattern.
