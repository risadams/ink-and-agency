# Obsidian Vault

Search, create, and manage notes across an Obsidian vault using shell tools (find, grep, Glob, Grep). The skill assumes a flat vault structure organized by index notes and wikilinks rather than folders, and supports common housekeeping workflows: finding backlinks, building index notes, surfacing unlinked mentions, detecting near-duplicate or misspelled tags.

## Why this exists

Obsidian's GUI is excellent for individual-note work and weak for vault-level operations. Finding all notes that mention a concept without using a wikilink, listing every tag and spotting near-duplicates, building an index note that aggregates everything tagged a certain way — these are shell-shaped problems. This skill knows the conventions of a flat-vault setup (Title Case names, no organizational folders, index notes for aggregation) and provides ready-to-run shell recipes for the housekeeping work that keeps the vault tidy.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "find notes about X in my vault"
  - "build an index note for {topic}"
  - "find unlinked mentions of {Note}"
  - "find duplicate or misspelled tags"
- Working with files inside a vault (the skill activates when context indicates a vault)

## What it does

The skill provides shell recipes (find, grep, Glob, Grep) for common vault operations: search by filename or content, create new notes following Title Case + wikilink-at-bottom conventions, find related notes via backlink search, build index notes (lists of `[[wikilinks]]`), find untagged references (note titles mentioned in prose without `[[ ]]` wrapping), and find duplicate or misspelled tags. It assumes the vault root is the git repository root (`git rev-parse --show-toplevel`). It does **not** modify notes through Obsidian (use [obsidian-cli](../obsidian-cli/) for that) — it operates directly on the filesystem.

### Inputs

- **Search term, note title, or operation description** — free-form.
- **Vault root** — auto-detected via `git rev-parse --show-toplevel`.

### Outputs

- Search results, new notes created, or housekeeping reports (untagged mentions, tag duplicates).

### External systems used

- Local filesystem (read/write `.md` files in the vault)
- git (for vault root detection)

## How to use it

A typical session looks like this:

```text
You: find notes that mention "rate limit" in my vault

Skill: VAULT=$(git rev-parse --show-toplevel)
       grep -rl "rate limit" "$VAULT" --include="*.md"

       Returns:
       Projects/Atlas.md
       Architecture/API gateway.md
       2026-04-22.md
       Reading/Distributed Systems.md

You: build an index note for everything I have on async work

Skill: VAULT=$(git rev-parse --show-toplevel)
       grep -rl -i "async" "$VAULT" --include="*.md" \
         | xargs -I {} basename {} .md \
         | sort -u

       Found 7 notes. Creating Async Index.md:

       # Async Index

       Notes related to async work patterns and tooling.

       - [[Async standup retrospective]]
       - [[Async vs sync decision tree]]
       - [[Documentation-first culture]]
       - [[Meeting cancellation criteria]]
       - [[Slack thread anti-patterns]]
       - [[Tuesday async planning experiment]]
       - [[Why I stopped attending]]

       Saved.
```

## Getting the most out of it

- **Use Title Case for everything.** The convention isn't aesthetic — it makes wikilinks unambiguous and case-insensitive matches reliable. `[[Project Atlas]]` works whether you typed it as `[[project phoenix]]` or `[[PROJECT PHOENIX]]` only if the file is `Project Atlas.md`.
- **Add wikilinks at the bottom of every note.** A "See also" or "Related" section at the bottom is the cheapest way to make backlinks useful. Notes without outbound links become orphans.
- **Build index notes lazily.** Create one when you have ~5 notes on a topic and you're losing track. Don't pre-build index notes for topics you might cover.
- **Run the unlinked-mentions sweep monthly.** Authors forget wikilinks all the time. The recipe in the skill catches mentions of note titles that aren't wrapped in `[[ ]]` so you can backfill.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Use folders for organization.** The vault convention is flat. Use index notes and links instead. Folders create cognitive overhead and break wikilink discoverability.
- ❌ **Modify notes through Obsidian's API.** The skill operates on the filesystem directly. For app-aware operations (daily-note appending, property setting), use [obsidian-cli](../obsidian-cli/).
- ❌ **Bulk-rename without checking backlinks.** Renaming a note breaks every wikilink to it unless you use Obsidian's rename feature (which updates links). Shell-based rename is fast but dangerous — use it only when you've verified there are no inbound links.
- ❌ **Treat tags as a substitute for links.** Tags categorize; wikilinks connect. A note with 10 tags and no wikilinks is harder to navigate than a note with 2 tags and 5 wikilinks.

## Examples

### Example: Find all notes that mention a concept without linking it

```bash
VAULT=$(git rev-parse --show-toplevel)

# All notes containing the literal title "Project Atlas"
grep -rln "Project Atlas" "$VAULT" --include="*.md" \
  | while read file; do
      # Check each match — is it inside [[ ]] or not?
      grep -n "Project Atlas" "$file" \
        | grep -v "\[\[Project Atlas\]\]" \
        | grep -v "\[\[Project Atlas|" \
        | sed "s|^|$file:|"
    done
```

This catches mentions in prose that should probably be wikilinks but aren't.

### Example: Audit tags for near-duplicates

```bash
VAULT=$(git rev-parse --show-toplevel)

# All unique tags with counts
grep -roh '#[A-Za-z0-9_/-]\+' "$VAULT" --include="*.md" \
  | sort | uniq -c | sort -rn | head -30

# Returns:
#   142 #project
#    87 #review
#    54 #reading
#     3 #Reading           <-- case duplicate of #reading
#     2 #projet            <-- typo of #project
#     1 #reveiw            <-- typo of #review
```

The low-count tags at the bottom are usually typos of high-count ones. Fix manually with grep + sed, or via [obsidian-cli](../obsidian-cli/).

### Example: Find a note's backlinks

```bash
VAULT=$(git rev-parse --show-toplevel)

grep -rl "\\[\\[Project Atlas\\]\\]" "$VAULT" --include="*.md"

# Returns notes that link to [[Project Atlas]]:
# 2026-05-12.md
# Async Index.md
# Q3 Planning.md
# Architecture/API gateway.md   (legacy folder structure — should move to root)
```

A weekly backlink sweep on the most active notes surfaces orphaned references.

## Internals

The skill follows shell-recipe patterns rather than a phased workflow:

- **Resolve vault root**: `VAULT=$(git rev-parse --show-toplevel)` — assumes the vault is a git repo.
- **Search by filename**: `find "$VAULT" -name "*.md" | grep -i "keyword"`.
- **Search by content**: `grep -rl "keyword" "$VAULT" --include="*.md"`.
- **Build index note**: search for related notes, extract titles, format as a wikilink list with H1 + description + `- [[wikilink]]` lines.
- **Find untagged references**: list all note titles, search for each, exclude lines wrapped in `[[ ]]`.
- **Find duplicate/misspelled tags**: `grep -roh '#[A-Za-z0-9_/-]\+'`, sort/uniq/count, look for case duplicates and low-frequency entries.

Conventions:

- **Flat vault** — no organizational folders.
- **Title Case** for all note names.
- **Index notes** for aggregation (`Reading Index.md`, `Project Atlas Index.md`).
- **Wikilinks at the bottom** of every note for outbound discovery.

## FAQ

**Q: What if my vault isn't a git repo?**
A: Set `VAULT` manually: `VAULT=~/Documents/MyVault` and use that everywhere. Or `cd` into the vault and use `.` as the root.

**Q: Can I use this with a folder-organized vault?**
A: Yes — the recipes work with folders. The conventions in the skill recommend flat structure, but the searches work against any layout.

**Q: How is this different from obsidian-cli?**
A: This skill uses pure filesystem tools (grep, find) and works whether Obsidian is open or not. obsidian-cli requires a running Obsidian instance and uses Obsidian's internal APIs for things like daily-note operations.

**Q: How do I clean up tag duplicates after finding them?**
A: Either manually (`grep -l '#oldtag' | xargs sed -i 's/#oldtag/#newtag/g'`) or via obsidian-cli for app-aware updates that preserve case in YAML frontmatter properly.

**Q: Why title case?**
A: Stable matching. Mixed-case filenames lead to wikilink ambiguity (`[[project]]` vs `[[Project]]` vs `[[PROJECT]]`). Pick one convention — Title Case is the most readable.

## Related skills

- **[obsidian-markdown](../obsidian-markdown/)** — for the syntax inside the notes this skill creates and searches.
- **[obsidian-cli](../obsidian-cli/)** — for app-aware operations (daily notes, properties, plugin reloading) when Obsidian is running.
- **[obsidian-bases](../obsidian-bases/)** — for query-driven views (table/card/list) over the notes managed here.
- **[obsidian-canvas](../obsidian-canvas/)** — for visual layouts of notes and links.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (vault conventions + shell recipes)
