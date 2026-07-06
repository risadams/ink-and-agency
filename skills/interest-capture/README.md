# Interest Capture

A speed-first stash for hyperfixations and rabbit-hole ideas. A new project, topic, or "wait, what if I..." just lit up in your brain. Chasing it means losing today; ignoring it means the idea rattles around for hours stealing attention or vanishes by lunch. This skill captures the idea fast, files it into the Obsidian vault inbox with the bare minimum frontmatter to find it later, and sends you back to what you were doing.

## Why this exists

ADHD and autistic brains generate ideas in bursts that are uncorrelated with whether the moment is convenient. The standard advice ("write it down somewhere") fails in practice for two reasons: the writing-down ritual takes long enough that the brain treats it as an excuse to engage with the idea (now you're 45 minutes deep), or it's so cursory that the idea is unrecoverable when you come back to it. The fix is a fixed-shape note that's complete enough to resume from later, captured in under a minute, with no engagement loop. The skill takes the idea, fills the note, files it, returns one line, and exits.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "stash this"
  - "capture this"
  - "don't let me forget"
  - "I just thought of..."
  - "side quest"
  - "hyperfixation"
  - "rabbit hole I don't have time for"
- Running the slash command: `/interest-capture`

The skill runs **inline only** — no council, no clarifying questions beyond one if needed. Speed is the whole point.

## What it does

The skill writes a single Obsidian note with fixed frontmatter (captured timestamp, status=stashed, hyperfixation tag plus 1-2 topic tags) and a fixed body shape: the idea (one paragraph in the user's words), why it lit up (one sentence — the trigger), and a single concrete next step if the user ever comes back to it. Files into the Obsidian vault inbox folder. Returns one line — the link to the new note and tags — and exits. If a related note already exists in the vault, the skill appends a "Re-surfaced YYYY-MM-DD" section to it instead of creating a duplicate.

### Inputs

- **The idea** — one line is enough; longer is fine.

### Outputs

- A markdown note in the Obsidian inbox folder.
- One line to the user with the link and tags.

### External systems used

- **Obsidian vault** — write the note into the inbox folder via [obsidian-vault](../obsidian-vault/).
- **Filesystem fallback** — if no Obsidian vault is configured, writes to `~/captures/`.

## How to use it

A typical session looks like this:

```text
You: stash this — what if hyperfocus-recovery had a "guess my
     re-entry point from cursor position in editor" mode?

Skill: (writes the note immediately, no follow-up questions)

       **Captured:** [[2026-05-19-hyperfocus-recovery-cursor-mode]]
       — `#hyperfixation #hyperfocus-recovery #ide-integration`.
       Back to what you were doing.
```

That's the whole interaction. The full note in the vault looks like:

```markdown
---
captured: 2026-05-19 14:23
status: stashed
tags:
  - hyperfixation
  - hyperfocus-recovery
  - ide-integration
---

# Hyperfocus recovery cursor-position mode

## The idea
What if hyperfocus-recovery had a mode that guessed re-entry point
from cursor position in the editor, in addition to the git artifacts
it already uses? The cursor often sits exactly on the next thing
you were about to type.

## Why it lit up
Was reading the hyperfocus-recovery SKILL.md and noticed the
"open editor file" gathering step is currently the weakest — it
captures the file but not the position.

## Next concrete step if I come back to this
Spike a script that reads cursor position from the active IDE
(VSCode protocol, or .swp file fallback for vim) and prints it.
That's the proof-of-concept; integration into the skill comes
after.

## Linked
- [[hyperfocus-recovery]]
```

## Getting the most out of it

- **Trigger it the moment the idea lands.** The longer you sit with the idea before capturing, the more your brain commits to engaging with it.
- **Don't refine the idea while capturing.** "The idea" section is whatever you said. Refinement happens later, if at all. Capturing is for not-losing-it, not for crystallizing it.
- **Trust the "back to what you were doing" exit.** The skill doesn't follow up. Don't either — go back to the task you were on.
- **Multiple ideas at once = multiple captures.** If three things light up, run the skill three times. One idea per note is the rule.
- **Re-run the skill on related ideas.** It'll detect the existing note and append a "Re-surfaced" entry instead of creating a duplicate, which gives you a useful timestamp of "this keeps coming back."

## Anti-patterns

- ❌ **Engaging with the idea.** No "that's interesting because..." in the skill output. The skill captures and exits.
- ❌ **Asking clarifying questions beyond one.** If the dump is unclear, ask one question at most. Otherwise capture verbatim and let the user refine later.
- ❌ **Suggesting next steps beyond the one in the note.** The single "next concrete step" field is enough.
- ❌ **Offering to research, expand, or sketch.** The skill is a stash, not a workshop.
- ❌ **Producing a summary back to the user.** The note *is* the summary. The user only needs the confirmation line.
- ❌ **Calling [clarity-council](../clarity-council/) or any other skill.** Latency kills the use case.

## Examples

### Example: A research-y rabbit hole during deep work

```text
You: don't let me forget — I want to understand how Rust's async
     runtimes differ (tokio vs async-std vs smol) because I've
     been hand-waving it for years

Skill:

       **Captured:** [[2026-05-19-rust-async-runtimes-comparison]]
       — `#hyperfixation #rust #async-runtimes`.
       Back to what you were doing.
```

Note body:

```markdown
# Rust async runtimes comparison

## The idea
Understand how Rust's async runtimes differ (tokio vs async-std
vs smol) — I've been hand-waving the distinction for years.

## Why it lit up
[unspecified — captured at user's prompt]

## Next concrete step if I come back to this
Read the architecture pages for each runtime back-to-back, take
notes on (1) executor model, (2) task scheduling, (3) IO backend.
That's the spike. Decide after whether to write up.

## Linked
(none)
```

The "why it lit up" field is left as `[unspecified]` when the user didn't say — better than guessing.

### Example: A duplicate idea (re-surfacing)

```text
You: I keep thinking about building a CLI for the Obsidian vault
     that does the same things as obsidian-cli but for fish shell
     specifically

Skill: (detects existing note, appends re-surface entry)

       **Re-surfaced:** [[2026-03-12-fish-shell-obsidian-cli]]
       (also captured 2026-03-12, 2026-04-08). This is the third
       time. Worth considering whether to actually do it.
```

The "third time" callout is a soft signal — without judging, the skill makes recurrence visible.

### Example: User actually wants to act on it now

```text
You: capture this — wait, actually I want to do this now.

Skill: (routes to task-initiation)

       That's not a capture, that's a start. Routing to
       /task-initiation — answer the three questions there and
       you'll have the first action.
```

The skill recognizes the boundary: capture is for *not* acting; if the user wants to act, that's a different skill.

## Internals

The skill is deliberately minimal in interaction shape:

| Step | Latency budget |
|---|---|
| Optional one question | <5s |
| Write the note | <5s |
| Return confirmation line | <1s |

The fixed note shape (frontmatter + four mandatory sections) is the durable interface — it ensures the note is recoverable later regardless of which conversation produced it.

Duplicate detection runs a search against the vault for existing notes tagged `#hyperfixation` with overlapping topic terms before creating a new note. On match, appends a `## Re-surfaced YYYY-MM-DD` entry to the existing note rather than creating a duplicate.

Filesystem layout: notes go to the Obsidian inbox folder (typically `📥 Inbox/` based on the user's vault convention from memory). Filename: `YYYY-MM-DD-{kebab-title}.md`.

Hard constraints: no clarifying questions beyond one; no engagement with the idea; no expansion or research; no summary back to user beyond the one confirmation line; no council; exit immediately after writing.

## FAQ

**Q: What if the idea is half-baked?**
A: That's the use case. Capture it half-baked. Refinement is later work, if ever. The "next concrete step" field is your hook for the future-you who might come back.

**Q: What if I have ten ideas in a burst?**
A: Run the skill ten times. One idea per note. The recurrence becomes searchable later.

**Q: Does the skill ever surface old captures to me?**
A: No — that's [obsidian-vault](../obsidian-vault/)'s job (and a future "review my hyperfixations" skill, not built yet). Interest-capture only writes.

**Q: Can I capture to a different folder?**
A: Yes — pass the target folder when invoking. Default is the vault inbox.

**Q: What if I don't use Obsidian?**
A: The skill falls back to writing the file to `~/captures/` and tells you the path. The note shape is identical.

## Related skills

- **[task-initiation](../task-initiation/)** — for when capture isn't the right answer because you actually want to act on the idea now.
- **[hyperfocus-recovery](../hyperfocus-recovery/)** — sibling for the reverse case: returning to a thread you already started.
- **[obsidian-vault](../obsidian-vault/)** — the underlying vault writer; interest-capture is a thin layer that fills in fixed-shape metadata.
- **[writing-fragments](../writing-fragments/)** — when the burst of ideas is specifically writing material rather than project ideas.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (note shape, latency targets, filesystem layout)
