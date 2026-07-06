# Release Note Format

The output structure for a single-ticket release note. Keep it tight — a release note is read in seconds, not studied.

**No icons or emoji.** Release notes are plain text — never prefix headlines or lines with emoji/icons.

## Structure

```markdown
### {Headline — user-facing, one line}

{1–3 sentences in plain language describing what changed from the user's
point of view and why it matters.}

**Affects:** {fix version / product area, if known}
**Action required:** {only if the user must do something — migration, config
change, re-login, etc. Omit this line entirely when no action is needed.}
```

## Type & framing

| Type | Headline framing | Lead verb |
| :--- | :--- | :--- |
| New feature | What the user can now do | "You can now…" |
| Enhancement | What got better | "Improved…" / "Faster…" |
| Bug fix | The symptom that's gone | "Fixed an issue where…" |
| Security fix | What's hardened (no exploit detail) | "Resolved a security issue in…" |
| Deprecation | What's going away & when | "{X} is now deprecated…" |
| Breaking change | What changed & what breaks | "{X} now…; this changes…" |

## Rules

1. **No icons or emoji.** Plain-text headlines and body only.
2. **Value before mechanism.** Describe the outcome for the user, not the code path. "Reports now export to CSV" — not "Added a CsvExporter to the report service."
3. **One headline per ticket.** If the ticket bundled several user-visible changes, use a short bullet list under the headline rather than multiple headlines.
4. **Bug fixes describe the symptom**, not the root cause. The user experienced the symptom; they never saw the bug.
5. **Security notes stay vague on the vector.** Confirm it's fixed and what area; never publish a reproduction.
6. **Breaking changes & deprecations always carry an "Action required" line** with the concrete step and (for deprecations) the timeline.
7. **Plain language.** Strip ticket keys, branch names, class/module names, and internal acronyms unless the audience is explicitly *developer*.
8. **Cite the fix version** when known — it's the single most-asked question ("which release has this?").

## Examples

**New feature (end-user):**

```markdown
### Schedule reports to run automatically

You can now set any saved report to run on a daily, weekly, or monthly
schedule and have the results emailed to your team — no more running them
by hand.

**Affects:** v4.2
```

**Bug fix (end-user):**

```markdown
### Fixed dashboard widgets not loading after a session timeout

Resolved an issue where dashboard widgets would show a blank panel if you
left the page open past your session timeout. Widgets now reload cleanly
when your session is renewed.

**Affects:** v4.1.3
```

**Breaking change (operator):**

```markdown
### API tokens now expire after 90 days

Personal API tokens now expire 90 days after creation to meet security
policy. Long-lived integrations must rotate their tokens.

**Affects:** v5.0
**Action required:** Rotate any API tokens older than 90 days before
upgrading, or integrations using them will stop authenticating.
```

**Internal (no customer-facing note):**

> *Ticket SC2-1234 is an internal refactor with no user-visible change.
> No customer release note recommended.*
