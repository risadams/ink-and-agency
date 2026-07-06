# Obsidian Charts — Examples

End-to-end scenarios for charting common Obsidian data patterns. Each example shows the source data, the codeblock, and notes on what to tune.

---

## 1. Weekly mood tracker (inline literal)

**Use when:** Small hand-tracked data that lives in one note, not worth a table.

````markdown
## This week

```chart
type: line
title: Mood + Energy this week
labels: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
series:
  - title: Mood
    data: [3, 4, 2, 5, 4, 6, 6]
  - title: Energy
    data: [5, 4, 3, 4, 5, 7, 6]
tension: 0.3
beginAtZero: true
yMax: 10
legend: true
legendPosition: bottom
width: 90%
```
````

**Tune:** Drop `tension` to 0 for a jagged line. Set `fill: true` for area fill.

---

## 2. Sprint burndown from a markdown table (table link)

**Use when:** The data is already a table in the same note. The most common pattern.

````markdown
## Sprint 28 burndown

| Day | Remaining SP | Ideal |
| - | - | - |
| 1 | 42 | 42 |
| 2 | 40 | 38 |
| 3 | 38 | 34 |
| 4 | 35 | 30 |
| 5 | 30 | 26 |
| 6 | 28 | 22 |
| 7 | 24 | 18 |
| 8 | 20 | 14 |
| 9 | 15 | 10 |
| 10 | 8 | 6 |
^burndown

```chart
type: line
id: burndown
layout: columns
beginAtZero: true
tension: 0
yTitle: Story points
xTitle: Sprint day
width: 100%
```
````

**Why `layout: columns`:** Each *column* (Remaining SP, Ideal) is one series; the first column (Day) becomes the x-axis labels.

**Tune:** Add `bestFit: true` + `bestFitNumber: 0` to project the actual burn rate. Swap to `type: bar` if you want bars instead of lines.

---

## 3. Reading rating distribution (cross-file table)

**Use when:** The source data lives in a different note (e.g., a master tracker) and you want the chart somewhere else (e.g., a year-in-review).

In `2026 Books.md`:

````markdown
| Stars | Count |
| - | - |
| 5 | 6 |
| 4 | 14 |
| 3 | 11 |
| 2 | 4 |
| 1 | 1 |
^ratings-2026
````

In `Year in Review 2026.md`:

````markdown
```chart
type: bar
id: ratings-2026
file: 2026 Books
layout: columns
beginAtZero: true
yTitle: Books read
xTitle: Stars
indexAxis: x
```
````

**Tune:** Set `indexAxis: y` to make it a horizontal bar chart.

---

## 4. Tag distribution doughnut (Dataviewjs)

**Use when:** You need to compute the chart data from a query — here, counting how many notes use each tag.

````markdown
```dataviewjs
const tags = {};
for (const p of dv.pages('"Journal"')) {
  for (const t of (p.file.tags ?? [])) {
    tags[t] = (tags[t] ?? 0) + 1;
  }
}

const sorted = Object.entries(tags).sort((a, b) => b[1] - a[1]).slice(0, 10);

window.renderChart({
  type: 'doughnut',
  data: {
    labels: sorted.map(([t]) => t),
    datasets: [{ data: sorted.map(([, c]) => c) }]
  },
  options: {
    plugins: { legend: { position: 'right' } }
  }
}, this.container);
```
````

**Tune:** Change `slice(0, 10)` to control how many tags you chart. Swap `type: 'doughnut'` to `'polarArea'` for variable-radius slices.

---

## 5. Daily-note word-count trend (Dataviewjs, time series)

**Use when:** You want to plot a metric across daily notes and have the x-axis respect actual dates.

````markdown
```dataviewjs
const notes = dv.pages('"📅"')
  .where(p => p.file.day)
  .sort(p => p.file.day);

window.renderChart({
  type: 'line',
  data: {
    labels: notes.map(p => p.file.day.toFormat('yyyy-LL-dd')).array(),
    datasets: [{
      label: 'Estimated words',
      data: notes.map(p => Math.round(p.file.size / 5)).array(),
      tension: 0.2,
      fill: true
    }]
  },
  options: {
    scales: {
      x: { type: 'time', time: { unit: 'day' } },
      y: { beginAtZero: true }
    }
  }
}, this.container);
```
````

**Note:** `scales.x.type: 'time'` requires Chart.js's date adapter — bundled with the plugin. If dates render as plain category labels, drop the `time` config and use plain string labels.

---

## 6. Project status horizontal bar (frontmatter aggregate)

**Use when:** You want a status summary across project notes that have a `status` property in their frontmatter.

````markdown
```dataviewjs
const counts = {};
for (const p of dv.pages('"Projects"').where(p => p.status)) {
  counts[p.status] = (counts[p.status] ?? 0) + 1;
}

const labels = Object.keys(counts);
const data = Object.values(counts);
const colors = {
  active: '#4caf50',
  blocked: '#f44336',
  done: '#9e9e9e',
  planning: '#2196f3'
};

window.renderChart({
  type: 'bar',
  data: {
    labels,
    datasets: [{
      label: 'Projects',
      data,
      backgroundColor: labels.map(l => colors[l] ?? '#999')
    }]
  },
  options: {
    indexAxis: 'y',
    scales: { x: { beginAtZero: true, ticks: { precision: 0 } } },
    plugins: { legend: { display: false } }
  }
}, this.container);
```
````

**Tune:** `precision: 0` forces integer ticks on the count axis.

---

## 7. Multi-axis comparison radar (inline literal)

**Use when:** Comparing two or more things on the same set of dimensions — e.g., skill self-assessment, product feature comparison.

````markdown
```chart
type: radar
title: Skill self-assessment
labels: [Backend, Frontend, DevOps, Testing, Design, Writing]
series:
  - title: Now
    data: [8, 4, 6, 7, 3, 6]
  - title: Goal Q3
    data: [8, 7, 7, 8, 5, 7]
fill: true
transparency: 0.3
legend: true
width: 70%
```
````

**Tune:** Drop `fill: true` for just outlines. Bump `transparency` down for more saturated colors.

---

## 8. Stacked time-spent chart (table link, stacked bar)

**Use when:** Tracking how time is split across categories per period.

````markdown
| Week | Deep work | Meetings | Email | Misc |
| - | - | - | - | - |
| W18 | 12 | 14 | 5 | 9 |
| W19 | 18 | 10 | 4 | 8 |
| W20 | 10 | 18 | 6 | 6 |
| W21 | 15 | 12 | 5 | 8 |
^time-split

```chart
type: bar
id: time-split
layout: columns
stacked: true
beginAtZero: true
yTitle: Hours
width: 100%
legendPosition: bottom
```
````

**Tune:** Drop `stacked: true` to see categories side-by-side instead. Add `indexAxis: y` for a horizontal stacked bar.

---

## 9. Best-fit trend line (table link with bestFit)

**Use when:** You want to project where a noisy series is headed.

````markdown
| Month | Subscribers |
| - | - |
| Jan | 120 |
| Feb | 135 |
| Mar | 142 |
| Apr | 158 |
| May | 167 |
| Jun | 175 |
| Jul | 192 |
| Aug | 205 |
^subs

```chart
type: line
id: subs
layout: columns
tension: 0.2
beginAtZero: true
bestFit: true
bestFitTitle: Trend
bestFitNumber: 0
width: 100%
```
````

**Note:** `bestFitNumber: 0` means "compute the trend from the first series". Increment for additional series.

---

## 10. Grouped bar from two separate sources (Dataviewjs)

**Use when:** Comparing two datasets with the same x-axis but different sources — e.g., committed vs delivered story points per sprint, from two different tables or query results.

````markdown
```dataviewjs
// Pretend these come from two different sources
const sprints = ['S26', 'S27', 'S28', 'S29', 'S30'];
const committed = [40, 42, 38, 45, 41];
const delivered = [36, 40, 39, 38, 42];

window.renderChart({
  type: 'bar',
  data: {
    labels: sprints,
    datasets: [
      { label: 'Committed', data: committed, backgroundColor: '#90caf9' },
      { label: 'Delivered', data: delivered, backgroundColor: '#66bb6a' }
    ]
  },
  options: {
    scales: { y: { beginAtZero: true, title: { display: true, text: 'Story points' } } }
  }
}, this.container);
```
````

**Tune:** Set both datasets to the same `stack: 'a'` to stack them. Add a third "remaining" dataset to visualize over/under-delivery.

---

## When to use which pattern

| If your data is... | Use... | Why |
|---|---|---|
| 3–10 numbers you typed by hand | Inline literal | Fastest, no plumbing |
| A markdown table in the same note | Table link with `id:` | Stays in sync as you edit the table |
| A table in another note | Table link with `id:` + `file:` | Single source of truth, chart anywhere |
| The result of a Dataview query | `dataviewjs` + `renderChart` | DQL alone can't render Chart.js |
| Frontmatter values across notes | `dataviewjs` + `renderChart` | Need JS to walk + aggregate |
| Counted/grouped data | `dataviewjs` + `renderChart` | Aggregation belongs in code, not a table |
| A long time series (>50 points) | `dataviewjs` + `renderChart` | Inline series would dominate the note |
