#!/usr/bin/env python3
"""
codebase-churn: Generate an SVG treemap showing per-file churn from git history.

Tile area  = lines changed (added + deleted)
Tile color = number of commits touching the file (log-scale heatmap)

Pure Python 3 stdlib. Run from inside a git repo, or pass -C PATH.
"""

import argparse
import math
import re
import subprocess
import sys
from collections import defaultdict
from html import escape


# ---------- git log ingestion -------------------------------------------------

def run_git_log(repo_path, since=None, until=None, paths=None):
    cmd = [
        "git", "-C", repo_path, "log",
        "--numstat",
        "--no-renames" if False else "-M",  # let git mark renames; we normalize
        "--pretty=format:__COMMIT__%H",
    ]
    if since:
        cmd += ["--since", since]
    if until:
        cmd += ["--until", until]
    if paths:
        cmd += ["--"] + list(paths)
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, check=True,
            encoding="utf-8", errors="replace",
        )
    except FileNotFoundError:
        sys.exit("git not found on PATH")
    except subprocess.CalledProcessError as e:
        sys.exit(f"git log failed: {e.stderr.strip() or e}")
    return result.stdout


RENAME_BRACES = re.compile(r"\{([^{}]*) => ([^{}]*)\}")


def normalize_path(path):
    """Collapse 'a/{old => new}/b' rename notation to the new path."""
    def sub(m):
        return m.group(2)
    out = RENAME_BRACES.sub(sub, path)
    while "//" in out:
        out = out.replace("//", "/")
    return out.strip()


def parse_log(output):
    current_commit = None
    for line in output.split("\n"):
        line = line.rstrip("\r")
        if not line:
            continue
        if line.startswith("__COMMIT__"):
            current_commit = line[len("__COMMIT__"):]
            continue
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        added_s, deleted_s, path = parts
        if added_s == "-" or deleted_s == "-":
            continue  # binary
        try:
            added = int(added_s)
            deleted = int(deleted_s)
        except ValueError:
            continue
        yield normalize_path(path), added, deleted, current_commit


def aggregate(entries, exclude_patterns=None):
    stats = defaultdict(lambda: {"commits": set(), "added": 0, "deleted": 0})
    excludes = [re.compile(p) for p in (exclude_patterns or [])]
    for path, added, deleted, sha in entries:
        if any(rx.search(path) for rx in excludes):
            continue
        s = stats[path]
        s["commits"].add(sha)
        s["added"] += added
        s["deleted"] += deleted
    out = []
    for p, s in stats.items():
        churn = s["added"] + s["deleted"]
        if churn <= 0:
            continue
        out.append({
            "path": p,
            "commits": len(s["commits"]),
            "added": s["added"],
            "deleted": s["deleted"],
            "churn": churn,
        })
    return out


# ---------- squarified treemap (Bruls, Huijing, van Wijk 2000) ---------------

def squarify(items, x, y, w, h):
    items = sorted(items, key=lambda i: -i["value"])
    total = sum(i["value"] for i in items)
    if total <= 0 or not items or w <= 0 or h <= 0:
        return []
    scale = (w * h) / total
    scaled = [{**i, "value": i["value"] * scale} for i in items]
    rects = []
    _layout(scaled, x, y, w, h, rects)
    return rects


def _worst(row, side):
    if not row or side <= 0:
        return float("inf")
    s = sum(r["value"] for r in row)
    if s <= 0:
        return float("inf")
    rmax = max(r["value"] for r in row)
    rmin = min(r["value"] for r in row)
    if rmin <= 0:
        return float("inf")
    s2 = s * s
    side2 = side * side
    return max(side2 * rmax / s2, s2 / (side2 * rmin))


def _layout(items, x, y, w, h, out):
    row = []
    i = 0
    side = min(w, h)
    while i < len(items):
        if w <= 0 or h <= 0:
            return
        candidate = row + [items[i]]
        if _worst(row, side) >= _worst(candidate, side):
            row = candidate
            i += 1
        else:
            x, y, w, h = _emit_row(row, x, y, w, h, out)
            row = []
            side = min(w, h)
    if row:
        _emit_row(row, x, y, w, h, out)


def _emit_row(row, x, y, w, h, out):
    row_total = sum(r["value"] for r in row)
    if row_total <= 0:
        return x, y, w, h
    if w >= h:
        strip_w = row_total / h
        cy = y
        for item in row:
            ih = item["value"] / strip_w if strip_w > 0 else 0
            out.append((item, x, cy, strip_w, ih))
            cy += ih
        return x + strip_w, y, w - strip_w, h
    else:
        strip_h = row_total / w
        cx = x
        for item in row:
            iw = item["value"] / strip_h if strip_h > 0 else 0
            out.append((item, cx, y, iw, strip_h))
            cx += iw
        return x, y + strip_h, w, h - strip_h


# ---------- color scale -------------------------------------------------------

_STOPS = [
    (0.00, (44, 123, 182)),    # cool blue   = stable
    (0.33, (171, 217, 233)),   # pale blue
    (0.66, (253, 174, 97)),    # orange
    (1.00, (215, 25, 28)),     # red         = volatile
]


def color_for(commits, vmin, vmax):
    if vmax <= vmin:
        t = 0.0
    else:
        # log scale because commit counts are heavily skewed
        t = (math.log(commits + 1) - math.log(vmin + 1)) / \
            (math.log(vmax + 1) - math.log(vmin + 1))
        t = max(0.0, min(1.0, t))
    for i in range(len(_STOPS) - 1):
        t0, c0 = _STOPS[i]
        t1, c1 = _STOPS[i + 1]
        if t <= t1:
            local = (t - t0) / (t1 - t0) if t1 > t0 else 0
            r = int(c0[0] + (c1[0] - c0[0]) * local)
            g = int(c0[1] + (c1[1] - c0[1]) * local)
            b = int(c0[2] + (c1[2] - c0[2]) * local)
            return f"rgb({r},{g},{b})"
    return "rgb(215,25,28)"


# ---------- SVG render --------------------------------------------------------

def render_svg(rects, width, height, vmin_c, vmax_c, title):
    header = 60
    footer = 50
    total_h = height + header + footer
    p = []
    p.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="0 0 {width} {total_h}" width="{width}" height="{total_h}" '
        f'font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif">'
    )
    p.append('<rect width="100%" height="100%" fill="#fafafa"/>')
    p.append(
        f'<text x="14" y="24" font-size="16" font-weight="600" fill="#111">'
        f'{escape(title)}</text>'
    )
    p.append(
        f'<text x="14" y="44" font-size="11" fill="#555">'
        f'Area = lines changed (added + deleted) &#xb7; '
        f'Color = commit count (log scale)</text>'
    )

    for item, x, y, w, h in rects:
        if w < 0.5 or h < 0.5:
            continue
        path = item["path"]
        commits = item["commits"]
        churn = item["churn"]
        added = item["added"]
        deleted = item["deleted"]
        fill = color_for(commits, vmin_c, vmax_c)
        title_text = (
            f"{path}\n"
            f"Commits: {commits}\n"
            f"Lines changed: {churn} (+{added} / -{deleted})"
        )
        p.append('<g>')
        p.append(f'<title>{escape(title_text)}</title>')
        p.append(
            f'<rect x="{x:.2f}" y="{y + header:.2f}" '
            f'width="{w:.2f}" height="{h:.2f}" '
            f'fill="{fill}" stroke="#ffffff" stroke-width="1"/>'
        )
        if w > 60 and h > 14:
            label = path.rsplit("/", 1)[-1]
            max_chars = max(1, int(w / 6.5))
            if len(label) > max_chars:
                label = label[: max_chars - 1] + "…"
            p.append(
                f'<text x="{x + 4:.2f}" y="{y + header + 13:.2f}" '
                f'font-size="11" fill="#111" pointer-events="none">'
                f'{escape(label)}</text>'
            )
        if w > 90 and h > 30:
            sub = f"{commits}c · {churn}Δ"
            p.append(
                f'<text x="{x + 4:.2f}" y="{y + header + 27:.2f}" '
                f'font-size="10" fill="#222" pointer-events="none">'
                f'{escape(sub)}</text>'
            )
        p.append('</g>')

    # legend
    legend_y = header + height + 20
    p.append(
        f'<text x="14" y="{legend_y}" font-size="11" fill="#555">'
        f'commits per file:</text>'
    )
    lx = 130
    bar_w = 4
    bars = 60
    for i in range(bars):
        t = i / (bars - 1)
        commits_at = vmin_c + t * (vmax_c - vmin_c)
        fill = color_for(commits_at, vmin_c, vmax_c)
        p.append(
            f'<rect x="{lx + i * bar_w}" y="{legend_y - 12}" '
            f'width="{bar_w}" height="14" fill="{fill}"/>'
        )
    p.append(
        f'<text x="{lx}" y="{legend_y + 14}" font-size="10" fill="#555">'
        f'{vmin_c}</text>'
    )
    p.append(
        f'<text x="{lx + bars * bar_w - 24}" y="{legend_y + 14}" '
        f'font-size="10" fill="#555">{vmax_c}</text>'
    )

    p.append('</svg>')
    return "\n".join(p)


# ---------- CLI ---------------------------------------------------------------

DEFAULT_EXCLUDES = [
    r"(^|/)package-lock\.json$",
    r"(^|/)yarn\.lock$",
    r"(^|/)pnpm-lock\.yaml$",
    r"(^|/)Cargo\.lock$",
    r"(^|/)Gemfile\.lock$",
    r"(^|/)poetry\.lock$",
    r"(^|/)go\.sum$",
    r"(^|/)composer\.lock$",
    r"(^|/)node_modules/",
    r"(^|/)vendor/",
    r"(^|/)dist/",
    r"(^|/)build/",
    r"\.min\.(js|css)$",
    r"\.map$",
]


def main():
    ap = argparse.ArgumentParser(
        description="Generate an SVG treemap of file churn from git history.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("-C", "--repo", default=".", help="Repo path (default: cwd)")
    ap.add_argument("--since", help='git log --since (e.g. "6 months ago", "2025-01-01")')
    ap.add_argument("--until", help='git log --until')
    ap.add_argument("--top", type=int, default=200, help="Top N files (default 200)")
    ap.add_argument("--exclude", action="append", default=[],
                    help="Regex to exclude (repeatable)")
    ap.add_argument("--no-default-excludes", action="store_true",
                    help="Disable built-in lockfile/vendor excludes")
    ap.add_argument("--width", type=int, default=1400)
    ap.add_argument("--height", type=int, default=900)
    ap.add_argument("-o", "--output", default="churn-treemap.svg",
                    help="SVG output path (default churn-treemap.svg)")
    ap.add_argument("--report", help="Optional markdown report output path")
    ap.add_argument("paths", nargs="*", help="Optional path filters for git log")
    args = ap.parse_args()

    excludes = ([] if args.no_default_excludes else list(DEFAULT_EXCLUDES)) + args.exclude

    print("Reading git history...", file=sys.stderr)
    log = run_git_log(args.repo, since=args.since, until=args.until,
                      paths=args.paths or None)
    entries = list(parse_log(log))
    if not entries:
        sys.exit("No commit history found (or no text-file changes in window).")
    print(f"Parsed {len(entries):,} file-commit entries.", file=sys.stderr)

    files = aggregate(entries, exclude_patterns=excludes)
    if not files:
        sys.exit("No files left after exclude filters.")
    files.sort(key=lambda f: -f["churn"])
    files = files[: args.top]
    print(f"Rendering {len(files)} files.", file=sys.stderr)

    items = [{"value": f["churn"], **f} for f in files]
    rects = squarify(items, 0, 0, args.width, args.height)

    commit_counts = [f["commits"] for f in files]
    vmin_c, vmax_c = min(commit_counts), max(commit_counts)

    title = f"Code churn — top {len(files)} files"
    if args.since or args.until:
        title += f" ({args.since or 'first commit'} → {args.until or 'now'})"
    svg = render_svg(rects, args.width, args.height, vmin_c, vmax_c, title)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"Wrote {args.output}", file=sys.stderr)

    if args.report:
        lines = [
            "# Codebase churn report",
            "",
            f"Top {len(files)} files by lines changed.",
            "",
            f"Window: {args.since or 'first commit'} → {args.until or 'now'}",
            "",
            "| Rank | File | Commits | + | - | Churn |",
            "| ---: | :--- | ---: | ---: | ---: | ---: |",
        ]
        for i, fx in enumerate(files, 1):
            lines.append(
                f"| {i} | `{fx['path']}` | {fx['commits']} | "
                f"{fx['added']} | {fx['deleted']} | {fx['churn']} |"
            )
        with open(args.report, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print(f"Wrote {args.report}", file=sys.stderr)


if __name__ == "__main__":
    main()
