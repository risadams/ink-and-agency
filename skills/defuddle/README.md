# Defuddle

Extract clean readable markdown from web pages using the Defuddle CLI. Strips navigation, ads, sidebars, cookie banners, and other clutter — leaving the article body. Use instead of WebFetch for standard web pages: smaller token footprint, cleaner output, faster downstream processing.

## Why this exists

Web pages are mostly chrome. A 2,000-word article comes wrapped in 50KB of navigation, ads, related-articles widgets, newsletter signup modals, and CSS scaffolding. Feeding that into a model wastes tokens and degrades output (the chrome competes for attention with the actual content). Browser-side reader views solve this for humans; this skill solves it for agent workflows. The CLI does the chrome stripping in one command, and the markdown output is ready for downstream processing — humanizing, summarization, citation extraction, whatever the next step is.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "fetch and clean this URL"
  - "extract the article from {url}"
  - "defuddle this page"
  - "read this web article cleanly"
- Whenever the user gives a URL to a standard web page

Skip this skill when:

- The URL ends in `.md` (already markdown — use WebFetch directly)
- The URL points at a structured API endpoint (use a fetch tool)
- The URL points at a PDF (use a PDF reader instead)

## What it does

The skill runs the `defuddle` CLI against a URL with `--md` for markdown output, optionally piping to a file or extracting specific metadata properties (title, description, domain). The output is a clean markdown document with the article body and minimal chrome. It does **not** modify the source page or persist anything beyond the optional output file.

### Inputs

- **URL** — required.
- **Optional `-o` path** — write to file instead of stdout.
- **Optional `-p` property** — extract specific metadata (`title`, `description`, `domain`).

### Outputs

- Markdown content (default with `--md`), JSON (with `--json`, includes both HTML and markdown), HTML (no flag), or a metadata value (with `-p`).

### External systems used

- `defuddle` CLI (install via `npm install -g defuddle`)
- Web (fetches the URL)
- Local filesystem (optional output file)

## How to use it

A typical session looks like this:

```text
You: fetch and clean https://example.com/blog/why-async-standups-failed

Skill: defuddle parse https://example.com/blog/why-async-standups-failed --md

       Returns ~1,200 words of clean markdown:

       # Why Async Standups Failed

       For six months we ran our daily standup as an async update in
       Slack instead of a 15-minute call. By month three, three problems
       had compounded...

       (Article body without nav, ads, or related-posts widgets.)
```

## Getting the most out of it

- **Always pass `--md`.** The default HTML output is rarely what you want for downstream model consumption. Markdown is smaller, cleaner, and more parsable.
- **Save to file for long articles.** If you're processing a 5,000-word essay through multiple steps (summarize, extract citations, humanize), `defuddle parse <url> --md -o article.md` once and Read from disk multiple times beats fetching three times.
- **Use `-p title`/`-p description` for citation work.** When you only need the title and source domain (not the body), `-p title` and `-p domain` get you the metadata without paying for the full body.
- **Pair with writing skills.** Defuddled output is clean enough to feed directly into [writing-shape](../writing-shape/) or [writing-fragments](../writing-fragments/) as raw material for an article that synthesizes multiple sources.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Use it on `.md` URLs.** Already markdown. WebFetch directly avoids the round-trip through HTML→markdown conversion.
- ❌ **Use it on paywalled content.** Defuddle fetches what's publicly visible. Articles behind a paywall come back as the preview, not the full text.
- ❌ **Use it on JS-heavy SPAs that need a real browser.** Defuddle parses static HTML. Pages that hydrate the article body via client-side JavaScript may return an empty body — fall back to a headless browser approach in those cases.
- ❌ **Use it for structured data extraction.** Defuddle is for prose. Tables, schema.org metadata, and structured data are better extracted by purpose-built scrapers.

## Examples

### Example: Fetch and read inline

```text
You: read https://example.com/articles/distributed-locks-considered-harmful

Skill: defuddle parse https://example.com/articles/distributed-locks-considered-harmful --md

       Returns:

       # Distributed Locks Considered Harmful

       The first time you reach for a distributed lock, it solves your
       problem. The second time, you wonder if there's a better pattern.
       The third time, you should be reading this article.

       (Continues for ~2,000 words of clean prose.)
```

### Example: Save to file for multi-step processing

```text
You: pull https://example.com/research/2024-async-work-survey and save
     to ~/research/async-survey.md, then summarize the key findings

Skill: defuddle parse https://example.com/research/2024-async-work-survey \
         --md -o ~/research/async-survey.md

       Saved 4,200 words to ~/research/async-survey.md.

       Reading the saved file...

       Key findings:
       - 67% of teams adopting async standups report improved focus.
       - 28% report worse alignment, mostly attributed to lack of
         shared visibility tools.
       - The 5% with no change tend to be small co-located teams.
```

The save-then-process pattern avoids re-fetching for each downstream step.

### Example: Extract just the title

```text
You: I just need the title of https://example.com/blog/post-slug
     for a citation

Skill: defuddle parse https://example.com/blog/post-slug -p title

       "Post Title Goes Here"
```

For metadata-only needs, `-p` returns just the property without parsing the body.

## Internals

The skill is essentially a wrapper around the `defuddle` CLI:

```bash
defuddle parse <url> [options]
```

Output formats:

| Flag | Format |
|------|--------|
| `--md` | Markdown (preferred for agent workflows) |
| `--json` | JSON with both HTML and markdown plus metadata |
| (none) | Raw HTML |
| `-p <name>` | Specific metadata property (`title`, `description`, `domain`) |

Optional flags:

- `-o <path>` — write to file instead of stdout
- `-p <property>` — extract only the named property

Installation:

```bash
npm install -g defuddle
```

Key constraints:

- **Static HTML parsing.** SPAs requiring JS may return empty bodies.
- **Public content only.** Paywalled articles return previews.
- **No browser emulation.** Use a headless browser tool when full JS rendering is required.

## FAQ

**Q: How does Defuddle compare to WebFetch?**
A: WebFetch returns the raw page (or fetched-and-summarized content depending on the agent's processing). Defuddle returns just the article body in clean markdown. For prose articles, Defuddle is leaner. For structured data or non-article pages, WebFetch is more flexible.

**Q: What if the page renders fine in a browser but Defuddle returns nothing?**
A: The page likely uses client-side rendering. Try a headless browser approach (Puppeteer, Playwright) instead.

**Q: Can I batch-process multiple URLs?**
A: Yes — call `defuddle parse` for each URL. There's no built-in batching, but it's trivial to script in shell.

**Q: Does it follow redirects?**
A: Yes, by default.

**Q: What about non-English content?**
A: Defuddle is language-agnostic for content extraction (it removes chrome based on HTML structure, not language). The markdown output preserves the original language.

## Related skills

- **[writing-shape](../writing-shape/)** — defuddled articles make excellent raw material; pipe the output as input.
- **[writing-fragments](../writing-fragments/)** — for mining ideas from a defuddled article into a fragment file before shaping.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (CLI usage, output formats)
