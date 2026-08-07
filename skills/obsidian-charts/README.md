# Obsidian Charts

Build interactive Chart.js charts inside Obsidian notes using the [phibr0/obsidian-charts](https://github.com/phibr0/obsidian-charts) plugin. The skill writes `chart` codeblocks for inline data, links charts to existing markdown tables by `^blockId` (same note or cross-file), and writes `dataviewjs` blocks that call `window.renderChart` for charts driven by Dataview queries. Supports all six Chart.js types: bar, line, pie, doughnut, radar, polarArea.

## Why this exists

Three things make charting in Obsidian fiddly. First, the codeblock syntax is small but unforgiving — a missing `^blockId` or a flipped `layout: rows` vs `layout: columns` produces a blank chart with no error message. Second, the same data can be charted three different ways (inline literal, table link, dataviewjs) and picking the wrong one means rewriting the codeblock. Third, the official docs site (charts.phib.ro) has decayed — most subpages 404, leaving Stack Overflow answers and old forum threads as the practical reference. This skill carries the syntax inline so you don't have to guess, and starts every session by picking the right data source.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "chart this data"
  - "graph my mood over the last month"
  - "make a bar chart from this table"
  - "render a chart from a Dataview query"
  - "add a chart to this note"
- Editing a note that already contains a ` ```chart ` codeblock (the skill activates when one is in context)
- Mentioning the plugin by name: "obsidian charts", "phibr0 charts", "chart codeblock", "renderChart"

## What it does

The skill chooses a data-source pattern based on what is already in the note (inline values, a markdown table, or a query), writes a valid codeblock for that pattern, and surfaces the common rendering pitfalls (wrong `layout`, missing `^blockId`, `dataview` vs `dataviewjs` codeblock language). It does **not** install the plugin, modify vault settings, or touch the underlying data — it only writes the codeblock that renders the chart.

### Inputs

- **The note containing the data** — table, frontmatter, query, or loose numbers.
- **Optional chart preferences** — type (bar/line/etc.), axes, stacking, smoothing, color.

### Outputs

- A `chart` codeblock inserted into the note (or a `dataviewjs` block for query-driven charts).
- A `^blockId` added under the source table when one is needed and missing.

### External systems used

- Local filesystem (read/write `.md` files in the vault).
- Obsidian Charts plugin (renders the codeblock — assumed installed).
- Dataview plugin with JS enabled (only when using `renderChart`).

## How to use it

A typical session looks like this:

```text
You: I have a table in my weekly review with mood scores for each day.
     Make it a line chart.

Skill: Found the table. Adding `^weekly-mood` block ID under it,
       and a chart codeblock below:

       ```chart
       type: line
       id: weekly-mood
       layout: rows
       tension: 0.3
       beginAtZero: true
       yMax: 10
       width: 80%
       ```

       Open the note in Live Preview to see it render. If the series
       and labels look swapped, flip `layout` to `columns`.
```

## Getting the most out of it

- **Add `^blockId` to tables you might chart.** Once a table has a stable ID, you can render it as a chart, embed it elsewhere, or transclude it without touching the data. Treat `^blockId` like an export-ready handle.
- **Use `time:` for date axes.** Without it, a line chart treats dates as evenly-spaced category labels and ignores the actual gaps. Setting `time: day` (or `month`/`year`) makes the x-axis proportional.
- **Prefer table linking over inline data when the values exist as a table.** Tables are editable in-place; an inline `series:` block is just numbers you have to keep in sync.
- **For `pie`/`doughnut`, flatten first.** Both only accept one series. If your data has multiple, decide which dimension to collapse before charting (e.g., total per category, not per category-per-month).
- **Use the plugin's "Create Chart from Table" command** for tables you already have. The plugin auto-generates the `^blockId` and matching codeblock — faster than writing by hand. The skill is most useful when (a) the table doesn't exist yet, (b) you need a `dataviewjs` chart, or (c) the auto-generated chart needs tuning.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Use `dataview` codeblocks for `renderChart`.** Must be `dataviewjs`. The DQL `dataview` block has no JS context, so `window.renderChart` is undefined.
- ❌ **Hand-type long inline series instead of linking a table.** If the data lives in a table elsewhere, link it. Otherwise the chart drifts out of sync the first time the data changes.
- ❌ **Assume the chart will render in Source view.** It won't — only Live Preview and Reading view render the codeblock.
- ❌ **Use a pie chart for time series.** Pie/doughnut charts collapse the time dimension. Use line or bar instead.
- ❌ **Skip the `^blockId` line.** Block IDs in Obsidian must be on a line by themselves, immediately after the block they refer to. Putting `^myid` at the end of the last row of the table does not work.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for a curated set of realistic scenarios — habit trackers from daily notes, sprint burndown from Jira via Dataview, reading-rating distributions, frontmatter-driven dashboards, and cross-file financial summaries.

### Quick example: bar chart from a same-note table

````markdown
| Day | Steps |
| - | - |
| Mon | 8200 |
| Tue | 7100 |
| Wed | 11500 |
| Thu | 9000 |
| Fri | 6400 |
^steps

```chart
type: bar
id: steps
layout: columns
beginAtZero: true
yTitle: Steps
```
````

### Quick example: line chart from a Dataview query

````markdown
```dataviewjs
const pages = dv.pages('"Journal"')
  .where(p => p.file.day && p.mood)
  .sort(p => p.file.day);

window.renderChart({
  type: 'line',
  data: {
    labels: pages.map(p => p.file.day.toFormat('yyyy-LL-dd')).array(),
    datasets: [{
      label: 'Mood',
      data: pages.map(p => p.mood).array(),
      tension: 0.3
    }]
  },
  options: { scales: { y: { beginAtZero: true, max: 10 } } }
}, this.container);
```
````

## Internals

The skill follows this workflow per request:

1. **Locate the data** — table, query, frontmatter, or loose values in the note.
2. **Pick the source pattern** — inline literal, table link, or `dataviewjs` + `renderChart`.
3. **Pick the chart type** — category comparison → bar, trend → line, parts-of-whole → pie/doughnut, multi-attribute → radar.
4. **Add the `^blockId`** if linking to a table that doesn't have one.
5. **Write the codeblock** inline in the note (no new file unless asked).
6. **Pick `layout: rows` vs `columns`** carefully for table-linked charts — this is the most common "why is my chart wrong" cause.
7. **Tell the user to switch to Live Preview or Reading view** to see the render.

Three source patterns:

- **Inline literal** — `labels:` + `series:` directly in the codeblock. Good for one-off charts of small hand-typed data.
- **Table link** — `id: <blockId>` (with optional `file:` for cross-note). Good when the data lives as a table and changes occasionally.
- **Dataviewjs renderChart** — full Chart.js v3 config passed to `window.renderChart(cfg, this.container)`. Good when the data must be computed, aggregated, or queried.

Key constraints:

- **`layout: rows`** = one series per row; first column = labels. **`layout: columns`** = one series per column; first row = labels. Flip if the chart looks transposed.
- **Block ID line** must immediately follow the table, on its own line, starting with `^`.
- **`renderChart` lives in `window`** — call as `window.renderChart(cfg, this.container)` inside a `dataviewjs` block.
- **Chart.js v3 config shape** — the plugin pins 3.x, so v4 examples from the web may not work directly.

## FAQ

**Q: My chart codeblock shows as raw text.**
A: You're in Source view. Switch to Live Preview or Reading view. (`Ctrl+E` toggles in most setups.)

**Q: I linked to a table by `id:` and got nothing.**
A: Three checks: (1) `^blockId` is on its own line directly under the table, (2) the `id:` value in the chart codeblock matches exactly (no leading `^`), (3) the table has at least a header row plus one data row.

**Q: My x-axis is wrong / dates render as evenly-spaced labels.**
A: Add `time: day` (or `month`/`year`) and make sure labels are ISO date strings (`2026-05-27`, not `May 27`).

**Q: `renderChart is not a function`.**
A: Either the Charts plugin is disabled, or the codeblock language is `dataview` instead of `dataviewjs`. `dataview` (DQL) has no JS context.

**Q: My pie chart only shows one slice.**
A: Pie/doughnut charts accept only one series. Multi-series data needs to be flattened (one number per label) before charting as a pie. Use a stacked bar instead if you need to preserve the breakdown.

**Q: Can I export the chart as an image?**
A: Not directly through the codeblock. The plugin renders to a canvas — right-click → "Save image as" works in Live Preview. For programmatic export, use `dataviewjs` + `chart.toBase64Image()` after capturing the Chart instance.

**Q: Does this work with Mermaid charts too?**
A: No — Mermaid is a separate ecosystem (built into Obsidian, no plugin needed). Use `mermaid` codeblocks for flowcharts/sequence/gantt; use `chart` codeblocks (this skill) for quantitative data.

## Related skills

- **[obsidian-markdown](../obsidian-markdown/)** — for the underlying tables and frontmatter that charts read from.
- **[obsidian-vault](../obsidian-vault/)** — for finding notes that contain chartable data.
- **[obsidian-bases](../obsidian-bases/)** — for tabular views of data; complementary to charts (table for browsing, chart for trend).
- **[obsidian-cli](../obsidian-cli/)** — for bulk-inserting `^blockId`s or chart codeblocks across many notes.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (quick-start, decision table, core parameters, workflow)
- **[REFERENCE.md](REFERENCE.md)** — Full parameter reference, color/styling, `renderChart` patterns, troubleshooting
- **[EXAMPLES.md](EXAMPLES.md)** — Realistic end-to-end scenarios
