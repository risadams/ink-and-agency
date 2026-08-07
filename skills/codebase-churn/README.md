# Codebase Churn

Generate an interactive SVG treemap of file churn from a git repository's history. Each tile sizes by total lines changed; color encodes commit frequency on a log scale (blue = stable, red = volatile). The big-and-red tiles are usually where bugs live, where refactors are overdue, and where new contributors get lost first.

## Why this exists

Bug-prone code follows a pattern: it changes often, it changes a lot per change, and nobody on the team is quite sure why. That pattern is in the git log if you know how to look — but `git log --stat | sort -k1 -n | head` doesn't communicate it the way a treemap does. Visual area + color makes the hot spots leap off the page in five seconds, and it makes the *absence* of hot spots a useful signal too. Stable code has earned its place; volatile code has earned a closer look.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "show me churn"
  - "where do we change the most"
  - "find unstable areas of the codebase"
  - "find refactor candidates"
- Running the slash command: `/codebase-churn`

## What it does

The skill runs a Python script (`scripts/churn_treemap.py`) against a git repository, parses `git log --numstat` output, and renders an SVG treemap with hover tooltips. Optionally, it also writes a markdown report listing the top files by total lines changed and commit count. It does **not** modify the repository, push branches, or call out to any external service — pure local read against `git log`.

### Inputs

- **Working directory** — the script reads from the current directory by default. Override with `-C path/to/repo`.
- **Time window** — `--since "6 months ago"` and `--until "2026-01-01"` to scope the analysis.
- **Top N files** — `--top 100` to limit the treemap (default 200).
- **Excludes** — `--exclude REGEX` (repeatable). Default excludes lockfiles, `node_modules/`, `dist/`, `*.min.*`.
- **Subpaths** — positional args forwarded to `git log -- ...`.

### Outputs

- **`-o churn-treemap.svg`** — interactive SVG treemap; open in a browser to hover for path/commits/lines.
- **`--report churn-report.md`** — optional markdown table of the top files, ranked by total lines changed.

### External systems used

- Local git (read only — `git log --numstat`)
- Local filesystem (writes the SVG and optional report)

## How to use it

A typical session looks like this:

```text
You: show me churn for the web-checkout repo

Skill: From the repo root:
       python3 ~/.claude/skills/codebase-churn/scripts/churn_treemap.py \
         -C ~/repos/web-checkout \
         -o churn-treemap.svg --report churn-report.md

       [run]
       Wrote churn-treemap.svg (143 KB).
       Wrote churn-report.md.

       Top 5 hottest files (lines changed × commit count):
       1. src/checkout/cart-button.tsx — 4,212 lines, 89 commits
       2. internal/payments/charge.go — 3,108 lines, 71 commits
       3. src/api/users.ts — 2,940 lines, 64 commits
       4. auth/middleware.py — 1,802 lines, 53 commits
       5. notifications-worker/queue.go — 1,612 lines, 47 commits

       Open the SVG in a browser to see the full treemap.
```

## Getting the most out of it

- **Compare windows.** Run once with no `--since`, then again with `--since "3 months ago"`. Files that were calm but are now hot deserve a closer look — recent volatility usually precedes bugs.
- **Filter by subpath.** When the whole-repo treemap is overwhelming, scope to a subdirectory: `python3 ... src/checkout/`. The relative volatility within a subsystem is often more actionable.
- **Snapshot reports.** Save `--report` output to disk after each major refactor. Comparing month-over-month tells you whether the refactor actually lowered churn or just moved it.
- **Read the cool tiles too.** Big-and-blue (stable) is its own signal: code that changed once during a rewrite and then settled. Verify it has tests; if not, add them while the area is quiet.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Tell you which file to refactor.** Churn is a heuristic. A consistently-volatile file might be doing critical work well; a stable file might be untouchable legacy. Use the treemap to *generate* candidates, not to commit to them.
- ❌ **Detect hot spots inside binary files.** `git log --numstat` reports `-` for binary files; they're skipped. If the volatility is in a `.png` or a generated `.pb` file, the treemap won't see it.
- ❌ **Substitute for code review.** A red tile means "look here" — it doesn't mean "rewrite this." The actual decision needs a human reading the file.
- ❌ **Account for blame coverage.** Two engineers committing 50 small fixes each looks the same as one engineer rewriting it twice. If team distribution matters to you, layer `git shortlog` analysis on top.

## Examples

### Example: Find recently-volatile code in the last quarter

```text
You: show me what's changed a lot in the last 3 months

Skill: python3 ~/.claude/skills/codebase-churn/scripts/churn_treemap.py \
         --since "3 months ago" \
         -o churn-3mo.svg --report churn-3mo.md

       Top 3 by recent volatility:
       1. src/checkout/cart-button.tsx — 1,422 lines, 31 commits since Feb
       2. internal/payments/charge.go — 980 lines, 18 commits since Feb
       3. config/feature-flags.json — 612 lines, 47 commits since Feb

       Notable: feature-flags.json has the most commits (47) but moderate
       line count — that's a "small + red" tile, often a fragile contract.
```

### Example: Compare subdirectories

```text
You: focus on the auth module only

Skill: python3 ~/.claude/skills/codebase-churn/scripts/churn_treemap.py \
         -o auth-churn.svg auth/

       Within auth/ (last 6 months):
       - middleware.py: 1,802 lines, 53 commits — refactor candidate
       - tokens.py: 412 lines, 8 commits — stable
       - session_store.py: 290 lines, 4 commits — stable
```

Scoping the analysis usually surfaces sharper insights than a whole-repo view.

## Internals

The skill follows this workflow:

1. **Parse git log** — runs `git log --numstat --format=...` over the requested window, parses added/deleted/path per commit.
2. **Normalize renames** — collapses `{old => new}` rename notation to the new path so churn aggregates correctly across renames.
3. **Aggregate** — sums lines changed and commit counts per file path; applies excludes; selects top N.
4. **Squarify** — uses the Bruls/Huijing/van Wijk squarified treemap algorithm to lay out tiles with aspect ratios near 1.
5. **Render** — writes SVG with hover tooltips; optionally writes markdown report.

Key constraints:

- **Pure Python 3 stdlib.** No `pip install` needed. The script is self-contained.
- **Binary files are skipped** — git reports `-` for their numstat.
- **Color is log-scaled** — a file with 100 commits isn't 10× the visual heat of a file with 10. Log scaling keeps the treemap readable when distributions are skewed.

## FAQ

**Q: Does churn predict bugs?**
A: It correlates with bug density in most large studies (e.g., Nagappan/Ball, Microsoft Research). It's not deterministic — but a file that changes weekly and has no tests is a higher-than-average risk.

**Q: Why log-scale color?**
A: Linear color makes one outlier (e.g., a file with 500 commits) wash out everything else. Log scaling preserves contrast across the long tail.

**Q: Can I exclude generated files?**
A: Yes — `--exclude` is repeatable. Default excludes already cover lockfiles, `node_modules/`, `dist/`, `*.min.*`. Add your own patterns for generated proto files, transpiled output, etc.

**Q: How long does it take on a big repo?**
A: A few seconds for a 5-year repo with 50K commits. The bottleneck is `git log` itself; rendering is sub-second.

**Q: Can I compare two repos?**
A: Run twice with `-o` pointing to different files, then visually compare. There's no built-in diff mode.

## Related skills

- **[codebase-improve-architecture](../codebase-improve-architecture/)** — once churn surfaces a hot file, this skill helps decide *what* to refactor it into. The two pair naturally.
- **[codebase-explain](../codebase-explain/)** — when a hot file is unfamiliar, get a high-level map first before diving in.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
- **[scripts/](scripts/)** — Python script `churn_treemap.py` and helpers
