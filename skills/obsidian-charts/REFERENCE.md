# Obsidian Charts — Full Reference

Companion to [SKILL.md](SKILL.md). Covers every parameter, the renderChart JS API, multi-series patterns, styling, and troubleshooting in depth.

## Chart types

| Type | Best for | Notes |
|---|---|---|
| `bar` | Category comparison | Use `indexAxis: y` for horizontal bars; `stacked: true` for stacked |
| `line` | Trends over a continuous axis | Combine with `time:` for date axes; `tension` smooths the curve |
| `pie` | Parts of a whole (few categories) | One series only; `data` length = `labels` length |
| `doughnut` | Same as pie | Same constraints; visually distinct |
| `radar` | Multi-attribute comparison | Each label is an axis; series are overlapping polygons |
| `polarArea` | Magnitude across categories | Like pie but with variable radius per slice |

## All `chart` codeblock parameters

### Data

| Key | Type | Description |
|---|---|---|
| `type` | string | One of the chart types above. Required. |
| `labels` | list | X-axis (or category) labels. Required unless using `id:`. |
| `series` | list of `{title, data}` | Each entry is one dataset. Required unless using `id:`. |

### Table linking (Chart from Table, v3.3.0+)

| Key | Type | Description |
|---|---|---|
| `id` | string | Block ID of a markdown table (`^myid`). Replaces `labels`/`series`. |
| `file` | string | Note basename containing the table. Defaults to the current note. |
| `layout` | `rows` \| `columns` | How to interpret the table. `rows` = one series per row; `columns` = one series per column. |
| `select` | list | Filter to specific rows/columns by header name. |

### Axes

| Key | Type | Description |
|---|---|---|
| `beginAtZero` | bool | Force y-axis to start at 0. |
| `xMin` `xMax` | number/date | X-axis bounds. |
| `yMin` `yMax` | number/date | Y-axis bounds. |
| `xTitle` `yTitle` | string | Axis titles. |
| `indexAxis` | `x` \| `y` | Set to `y` for horizontal bar charts. |
| `time` | string | Treat labels as dates with this unit: `millisecond`, `second`, `minute`, `hour`, `day`, `week`, `month`, `quarter`, `year`. |

### Styling

| Key | Type | Description |
|---|---|---|
| `width` | string | CSS width (`80%`, `600px`). |
| `tension` | number | 0–1, line smoothing. |
| `fill` | bool | Fill area under line. |
| `stacked` | bool | Stack series in bar/line. |
| `labelColors` | bool | Colour labels to match series. |
| `transparency` | number | 0–1, series fill transparency. |
| `legend` | bool | Show legend. |
| `legendPosition` | `top` \| `bottom` \| `left` \| `right` | |
| `title` | string | Chart title above the plot. |

### Trend / best fit

| Key | Type | Description |
|---|---|---|
| `bestFit` | bool | Draw linear trend line. |
| `bestFitTitle` | string | Label for the trend line. |
| `bestFitNumber` | number | Index of the series the trend is computed from. |

## Inline literal — full example

````markdown
```chart
type: line
title: Weekly mood
labels: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
series:
  - title: Mood
    data: [3, 4, 2, 5, 4, 6, 6]
  - title: Energy
    data: [5, 4, 3, 4, 5, 7, 6]
tension: 0.3
fill: false
beginAtZero: true
yMax: 10
legend: true
legendPosition: bottom
width: 90%
```
````

## Table linking — full example

````markdown
| Month | Revenue | Cost | Profit |
| - | - | - | - |
| Jan | 10 | 7 | 3 |
| Feb | 14 | 9 | 5 |
| Mar | 12 | 11 | 1 |
| Apr | 18 | 13 | 5 |
^q1-financials

```chart
type: bar
id: q1-financials
layout: columns
select: [Revenue, Cost]
stacked: false
beginAtZero: true
yTitle: USD (k)
width: 80%
```
````

`layout: columns` means each *column* in the table becomes a series. The first column (`Month`) is automatically used as labels. `select` filters which value columns are plotted.

### Cross-file table reference

````markdown
```chart
type: line
id: q1-financials
file: 2026 Financials
layout: columns
time: month
```
````

`file:` is the note basename without the `.md` extension.

## Dataviewjs `renderChart` API

The plugin exposes `window.renderChart(data, container)` globally when enabled. `data` is a [Chart.js v3 config object](https://www.chartjs.org/docs/3.9.1/) (the plugin pins Chart.js 3.x). The codeblock language **must be `dataviewjs`**, not `dataview`.

### Minimal example

````markdown
```dataviewjs
const cfg = {
  type: 'bar',
  data: {
    labels: ['A', 'B', 'C'],
    datasets: [{ label: 'Counts', data: [3, 7, 5] }]
  }
};
window.renderChart(cfg, this.container);
```
````

### Aggregating Dataview results

````markdown
```dataviewjs
const pages = dv.pages('#book').where(p => p.rating);

window.renderChart({
  type: 'bar',
  data: {
    labels: pages.map(p => p.file.name).array(),
    datasets: [{
      label: 'Rating',
      data: pages.map(p => p.rating).array(),
      backgroundColor: '#7e57c2'
    }]
  },
  options: {
    indexAxis: 'y',
    scales: { x: { beginAtZero: true, max: 5 } }
  }
}, this.container);
```
````

### Grouped / counted values

````markdown
```dataviewjs
const tags = {};
for (const p of dv.pages()) {
  for (const t of (p.file.tags ?? [])) {
    tags[t] = (tags[t] ?? 0) + 1;
  }
}
const labels = Object.keys(tags);
const data = Object.values(tags);

window.renderChart({
  type: 'doughnut',
  data: { labels, datasets: [{ data }] }
}, this.container);
```
````

### Multi-series time series

````markdown
```dataviewjs
const journals = dv.pages('"Journal"')
  .where(p => p.file.day && p.mood && p.energy)
  .sort(p => p.file.day);

const labels = journals.map(p => p.file.day.toFormat('yyyy-LL-dd')).array();

window.renderChart({
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: 'Mood',   data: journals.map(p => p.mood).array(),   tension: 0.3 },
      { label: 'Energy', data: journals.map(p => p.energy).array(), tension: 0.3 }
    ]
  },
  options: {
    scales: { y: { beginAtZero: true, max: 10 } }
  }
}, this.container);
```
````

## Colors

If colors are not specified, the plugin assigns from a default palette. Override per-dataset:

```yaml
series:
  - title: A
    data: [1, 2, 3]
    backgroundColor: '#ef5350'
    borderColor: '#c62828'
```

Or per-point (for `pie`/`doughnut`/`polarArea`, supply an array):

```js
datasets: [{
  data: [10, 20, 30],
  backgroundColor: ['#ef5350', '#42a5f5', '#66bb6a']
}]
```

## Conversion shortcut

The plugin adds the command **Charts: Create Chart from Table**. With the cursor on a markdown table, it auto-generates the `^blockId` and a matching `chart` codeblock. Tell the user to use this when they already have a table — it's faster than writing the codeblock by hand.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Codeblock shows as raw text | In Source view | Switch to Live Preview or Reading view |
| "Table not found" | `id:` doesn't match a `^blockId` | Confirm the `^blockId` is on its own line under the table and spelling matches |
| Series and labels swapped | Wrong `layout` | Flip `rows` ↔ `columns` |
| Empty chart | All values are null/non-numeric | Check the source data; for tables, the first row/column is always treated as headers |
| Dates render as evenly-spaced labels | No `time:` set | Add `time: day` (or month/year) and ensure labels are ISO date strings |
| `renderChart is not a function` | Charts plugin disabled, or wrong codeblock language | Enable plugin; use `dataviewjs`, not `dataview` |
| Chart too wide/narrow | Default width | Set `width: 80%` (or `600px`) |
| Trend line on wrong series | Default `bestFitNumber` is 0 | Set `bestFitNumber:` to the desired series index |
| Pie chart only shows one slice | Multiple series supplied | Pie/doughnut accept only one series — flatten the data first |

## References

- Plugin repo: https://github.com/phibr0/obsidian-charts
- Docs site: https://charts.phib.ro/
- Chart.js 3.x reference: https://www.chartjs.org/docs/3.9.1/
