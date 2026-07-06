# Jira Comment Template — Release Note

Use this template to render the Phase 4/5 release note as a Jira comment in **Jira wiki markup** (not GitHub-flavored markdown). Replace every `{placeholder}`. Keep the AI disclaimer panel at the bottom verbatim.

---

## Format reference (markdown → Jira wiki markup)

| Markdown | Jira wiki markup |
| :--- | :--- |
| `# H1` | `h1. H1` |
| `## H2` | `h2. H2` |
| `### H3` | `h3. H3` |
| `**bold**` | `*bold*` |
| `_italic_` | `_italic_` |
| `` `inline code` `` | `{{inline code}}` |
| ``` ```block``` ``` | `{code}block{code}` |
| `- item` | `* item` |
| `[text](url)` | `[text\|url]` |
| Horizontal rule | `----` |

Panels:

```
{panel:title=Title|borderColor=#ccc|bgColor=#f4f5f7}
content
{panel}

{info}info content{info}
{note}note content{note}
{warning}warning content{warning}
```

---

## Template body — paste into the comment

```
h2. Release Note — {Headline}

{1–3 plain-language sentences: what changed for the user and why it matters.}

*Affects:* {fix version / product area, or omit the line if unknown}
{*Action required:* {concrete step} — include ONLY for breaking changes / deprecations / migrations; omit otherwise}

----

{panel:title=⚠ AI-generated draft|borderColor=#ffab00|bgColor=#fffae6|titleBGColor=#fff0b3}
This release note was drafted by an AI from the ticket context and related merge requests. Treat it as a *draft for review* — verify the wording, scope, and fix version against the actual change before publishing it to customers.
{panel}
```

---

## Notes for the rendering agent

1. **Omit empty lines.** Drop the `*Affects:*` line if the version is unknown; drop `*Action required:*` unless it's a breaking change, deprecation, or migration.
2. **Keep the disclaimer panel exactly as shown** — same title, colors, wording. It maps to Atlassian's standard "warning" palette.
3. **No preamble or sign-off.** Start at the `h2.` heading, end at the disclaimer panel.
4. **Plain language only** for customer/operator audiences — no ticket keys, branch names, or internal class/module names in the body. (Developer-audience notes may include them.)
5. **No icons or emoji in the release note** — keep the `h2.` heading and body plain text. (The `⚠` in the disclaimer panel title is fixed chrome and stays.)
6. **Escape literal pipes** as `\|`.
7. This template is for the **comment** path only. If writing into a Release Notes *field* instead, post the plain-text note **without** the disclaimer panel — fields are not comments.
