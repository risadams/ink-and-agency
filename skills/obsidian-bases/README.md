# Obsidian Bases

Create and edit Obsidian Bases (`.base` files) — database-like views over your vault built from YAML. The skill handles filters (and/or/not, nested), formulas (date arithmetic, conditionals, string formatting), property display configuration, summary aggregations (Average, Sum, Min/Max), and four view types (table, cards, list, map). It catches the common YAML and Duration-math errors that quietly break a base.

## Why this exists

Bases let you point a query at a slice of your vault and render it as a table, gallery, or list — Notion-style views without leaving Obsidian. The cost is YAML: easy to write, easy to break with an unquoted colon or a missing `if()` guard around a date. The hardest debugging problem is silent failure (a formula resolves to nothing because a property is empty on some notes). This skill produces valid bases on the first try, and when you ask it to extend an existing base, it knows the quoting rules and the Duration-type pitfalls so the changes don't introduce new failures.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "create a Bases file"
  - "make a table view of my notes"
  - "build a card gallery for my reading list"
  - "add a formula to this base"
- Working with any `.base` file (the skill activates automatically when one is in context)

## What it does

The skill creates and edits `.base` files in valid YAML, supporting filters (string expressions or nested and/or/not), formulas (with the proper Duration-type access patterns), property display configuration, summary aggregations, and four view types. It validates against the most common pitfalls — unquoted special characters, double-quote-in-double-quote formulas, Duration math without field access, missing `if()` null guards. It does **not** modify the notes themselves, only the base file describing how to view them.

### Inputs

- **Description of desired view** — what notes to show, what fields, what aggregations.
- **Optional vault context** — folders, tags, properties already in use.

### Outputs

- A `.base` file with valid YAML, ready to open in Obsidian.

### External systems used

- Local filesystem (read/write `.base` files; read frontmatter from `.md` files when scoping)
- Obsidian (the `.base` file renders inside the Obsidian app — the skill itself is filesystem-only)

## How to use it

A typical session looks like this:

```text
You: create a base for my reading list. Show books I haven't finished yet,
     ordered by date added. Card view with cover image.

Skill: Writing reading-list.base:

       filters:
         and:
           - file.hasTag("book")
           - 'status != "done"'
       properties:
         author:
           displayName: Author
         status:
           displayName: Status
       views:
         - type: cards
           name: "To Read"
           order:
             - cover
             - file.name
             - author
             - status
           groupBy:
             property: status
             direction: ASC

       Saved. Open in Obsidian — it should render immediately.
       (If your book notes don't have a `cover` property, the cards
       will still show but without images. Add `cover: filename.png`
       to frontmatter and it'll appear.)
```

## Getting the most out of it

- **Start with a single view, add more later.** A base with one well-tuned table beats a base with four half-tuned views. Bases support multiple views per file — add the second one once the first is right.
- **Use formulas for derived display fields.** Instead of computing "days until due" in your head, define `days_until_due: 'if(due, (date(due) - today()).days, "")'` and let the table show it. The `if()` guard prevents errors on notes without a due date.
- **Group by status or tag.** `groupBy` is the fastest way to make a table feel like a kanban board. Pair with `direction: ASC` for predictable ordering.
- **Embed bases in notes.** `![[my-base.base#View Name]]` embeds a specific view into a regular markdown note. Useful for project pages that want a live task list inline.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Modify the notes themselves.** Bases are queries, not editors. Updating a property requires editing the underlying note's frontmatter.
- ❌ **Use Duration values directly in math.** Subtracting two dates returns a Duration, not a number. The skill writes `(now() - file.ctime).days` to access the numeric field, never `(now() - file.ctime).round(0)` (which silently fails).
- ❌ **Skip null guards on optional properties.** Formulas that reference a property which might be empty should wrap in `if(prop, ..., "")`. Otherwise the formula evaluates to an error on those notes.
- ❌ **Use double-quoted formulas containing double quotes.** YAML breaks. The skill always wraps formula expressions in single quotes when they contain double quotes inside.

## Examples

### Example: Daily-notes index

```yaml
filters:
  and:
    - file.inFolder("Daily Notes")
    - '/^\d{4}-\d{2}-\d{2}$/.matches(file.basename)'

formulas:
  word_estimate: '(file.size / 5).round(0)'
  day_of_week: 'date(file.basename).format("dddd")'

properties:
  formula.day_of_week:
    displayName: "Day"
  formula.word_estimate:
    displayName: "~Words"

views:
  - type: table
    name: "Recent Notes"
    limit: 30
    order:
      - file.name
      - formula.day_of_week
      - formula.word_estimate
      - file.mtime
```

A regex-filtered view that only matches `YYYY-MM-DD` filenames in the Daily Notes folder, with a computed day-of-week column.

### Example: Task tracker with priority labels

```yaml
filters:
  and:
    - file.hasTag("task")

formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
  priority_label: 'if(priority == 1, "High", if(priority == 2, "Medium", "Low"))'

views:
  - type: table
    name: "Active Tasks"
    filters:
      and:
        - 'status != "done"'
    order:
      - file.name
      - status
      - formula.priority_label
      - due
      - formula.days_until_due
    groupBy:
      property: status
      direction: ASC
    summaries:
      formula.days_until_due: Average
```

Note the nested `if()` for priority labels and the `if()` guard on `days_until_due` — both are required to handle notes that lack the relevant property.

## Internals

The skill follows this workflow per request:

1. **Create the file** with a `.base` extension and valid YAML.
2. **Define scope** via `filters` (single string, or recursive and/or/not).
3. **Add formulas** for computed display values.
4. **Configure views** — table, cards, list, or map — with `order` specifying display columns.
5. **Validate** — YAML syntax, formula references, quoting rules, Duration-type access patterns.
6. **Test in Obsidian** — render the file; check for YAML errors.

Three property types:

- **Note properties** — from frontmatter: `note.author` or just `author`.
- **File properties** — `file.name`, `file.mtime`, `file.size`, `file.tags`, `file.backlinks`, etc.
- **Formula properties** — computed values: `formula.my_formula`.

Four view types: **table** (rows + columns + summaries), **cards** (gallery), **list** (simple), **map** (requires lat/lng + Maps plugin).

Key constraints:

- **Single quotes around formulas with double quotes** — `'if(done, "Yes", "No")'`.
- **Quote special-character strings** — values containing `:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `` ` `` need quoting.
- **Always `.days` (or `.hours`, etc.) on Duration types** before applying number functions.

## FAQ

**Q: Where do I put the .base file?**
A: Anywhere in the vault — the location doesn't affect what it queries. Many people put bases at the root or in a `_bases/` folder.

**Q: Can a base modify my notes?**
A: No. Bases are read-only queries. To bulk-update notes (e.g., set `status: done` on many tasks), use the Obsidian Properties view or [obsidian-cli](../obsidian-cli/).

**Q: How do I sort by a formula?**
A: Sorting in views is done via the `order` and `groupBy` fields. Formula sorting works the same as property sorting — reference the formula by `formula.name`.

**Q: My base shows "(empty)" for some rows.**
A: That's the formula or property being undefined on those notes. Wrap formulas in `if()` guards, or accept that rows without the property will be blank.

**Q: Can I use bases as task lists?**
A: Yes — see the task tracker example. Filter by `file.hasTag("task")` and `status != "done"`, then group by status. Pair with [obsidian-markdown](../obsidian-markdown/) for the underlying task syntax.

## Related skills

- **[obsidian-vault](../obsidian-vault/)** — for creating the underlying notes that bases query.
- **[obsidian-markdown](../obsidian-markdown/)** — for writing the frontmatter properties that bases filter and display.
- **[obsidian-cli](../obsidian-cli/)** — for bulk-modifying properties across many notes (something bases can't do).

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full schema, syntax, examples)
- **[references/](references/)** — Complete functions reference (`FUNCTIONS_REFERENCE.md`)
