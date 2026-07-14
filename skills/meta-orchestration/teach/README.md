# Teach

Turn the current directory into a **stateful teaching workspace** and teach the user a topic across many sessions. The skill treats learning as a long-lived project with its own artifacts — a mission, reference sheets, resources, learning records, and a growing library of self-contained HTML lessons — rather than a one-shot explanation. Every lesson is grounded in *why* the user wants to learn the topic, sized to fit working memory, and built for long-term retention over the illusion of fluency.

## Why this exists

Most "explain this to me" interactions optimise for the wrong thing: fluency (in-the-moment understanding that feels like mastery and evaporates by next week) instead of storage strength (durable, retrievable knowledge). They're also ungrounded — the user gets abstract explanations with no line back to the real-world goal that made them curious. This skill fixes both. It anchors everything to a written **mission**, refuses to trust the model's parametric knowledge (resources first, always cited), and designs lessons around *desirable difficulty* — retrieval practice, spacing, interleaving — so the learning sticks. The workspace persists, so a topic can be developed over weeks, with each session picking up exactly where the last left off.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "teach me X"
  - "I want to learn about Y"
  - "help me get good at Z over time"
- Running the slash command: `/teach`

> **Note:** This skill sets `disable-model-invocation: true` — it runs only when the user explicitly asks. It won't auto-trigger mid-task, because starting a multi-session teaching workspace is a deliberate commitment, not something to fall into.

## What it does

On first invocation the skill establishes (or resumes) a teaching workspace in the current directory, made of a fixed set of files (see [Internals](#internals)). It insists on understanding the **mission** first — questioning the user on *why* they want to learn the topic when `MISSION.md` is empty — because ungrounded knowledge feels abstract and gives no basis for choosing what to teach next. It gathers high-trust **resources** before teaching (never parametric knowledge), then produces **lessons**: short, beautiful, self-contained HTML files, each teaching one tightly-scoped thing in the user's zone of proximal development, each citing sources, each recommending a primary source and reminding the user their agent is their teacher. It splits deliberately between **knowledge** (acquired — difficulty is the enemy) and **skills** (drilled through tight feedback loops — difficulty is the tool), builds a reusable **component library** in `./assets/` so lessons look like one course, and captures non-obvious insights as numbered **learning records** that drive future sessions.

### Inputs

- **A topic** — what the user wants to learn. Can be knowledge-heavy (theoretical physics) or skills-heavy (yoga); the skill weights its approach accordingly.
- **A mission** — the real-world reason behind the interest. Elicited by questioning if not already in `MISSION.md`.
- **Optional: stated preferences** — how the user likes to be taught; recorded in `NOTES.md`.

### Outputs

- **`./lessons/NNNN-*.html`** — the primary deliverable: beautiful, short, self-contained lessons, numbered and incrementing.
- **`./reference/*.html`** — compressed reference material (cheat sheets, algorithms, glossaries) built to print well and be revisited.
- **`MISSION.md`**, **`RESOURCES.md`**, **`NOTES.md`** — the mission, the vetted resource list, and working notes on user preferences.
- **`./learning-records/NNNN-*.md`** — ADR-style records of what was learned and key insights, used to calculate the zone of proximal development.
- **`./assets/*`** — a shared, reusable component library (stylesheet first) so lessons look like one consistent course.

### External systems used

- **A local web browser** — lessons and reference docs are HTML; the skill opens them via a CLI command where possible.
- **Web / resource access** — to gather and vet high-trust primary sources before teaching.
- **High-reputation communities** — the skill points the user toward forums, classes, or groups where real-world practice builds wisdom (respecting a preference not to join).

## How to use it

A typical first session looks like this:

```text
You: teach me Rust ownership

Skill: Before any lesson — what's the mission? Ownership makes most sense
       taught toward something concrete. What do you want to *do* with Rust?

You: rewrite a hot path in our Python service as a native extension.

Skill: [writes MISSION.md grounding everything in "native extension for a
       hot path"; gathers resources into RESOURCES.md — the Rust Book's
       ownership chapter, the nomicon, cited]

       Lesson 0001 — "Move semantics, seen through a function call"
       ~5 min, one tangible win: predict whether a value is still usable
       after you pass it. Opening it now.

       [writes ./assets/lesson.css + ./lessons/0001-move-semantics.html,
        opens it, ends with a retrieval quiz and a link to the Rust Book]

Skill: When you're back, we'll interleave borrowing. Logged a learning
       record so next session picks up at your ZPD.
```

## Getting the most out of it

- **Answer the mission questions honestly.** The mission grounds every lesson. "I'm just curious" produces abstract lessons; "I need to ship X" produces sharp ones.
- **Come back.** The workspace is built for spacing — returning after a gap *is* the retention mechanism, not a failure to finish.
- **Do the retrieval, don't just read.** For skills, the difficulty is the point. Skipping the quiz to "just read the answer" trades storage strength for a fluency illusion.
- **Tell it how you learn.** Preferences go in `NOTES.md` and shape every future lesson — "I hate analogies," "show me the code first," "keep lessons under 3 minutes."
- **Revisit the reference docs, not the lessons.** Lessons are consumed once; reference sheets are the compressed essence you return to. Treat them as the durable output.
- **Let the mission evolve.** As skills grow, the reason may shift — that's normal. The skill confirms before rewriting `MISSION.md` and logs a learning record.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Teach before the mission is clear.** Ungrounded lessons feel abstract and give no basis for sequencing. If `MISSION.md` is empty, the first job is questioning the user, not lecturing.
- ❌ **Trust parametric knowledge.** Claims come from vetted resources with citations. "I'm pretty sure it works like…" is exactly what the resources-first rule forbids.
- ❌ **Write long lessons.** Working memory is small. A lesson that overflows it teaches nothing; each lesson is one tightly-scoped win, completable fast.
- ❌ **Optimise for fluency.** In-the-moment understanding feels like mastery and disappears. Design for storage strength via retrieval, spacing, interleaving.
- ❌ **Inline what a future lesson would reuse.** Reusable pieces go in `./assets/` as components. Duplicating a widget or style across lessons breaks the "one course" look.
- ❌ **Give clues in quiz formatting.** Every answer option is the same length (words and, ideally, characters) so layout leaks nothing.

## Internals

The workspace is a fixed set of files, each with a documented format:

| Artifact | Role | Format |
| :--- | :--- | :--- |
| `MISSION.md` | *Why* the user is learning — grounds all teaching | [MISSION-FORMAT.md](MISSION-FORMAT.md) |
| `RESOURCES.md` | Vetted high-trust resources to ground lessons | [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md) |
| `./learning-records/NNNN-*.md` | ADR-style records of insights; drive the ZPD | [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md) |
| `./reference/*.html` | Compressed reference sheets; a glossary is essential | [GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md) |
| `./lessons/NNNN-*.html` | The primary teaching unit — one scoped win each | — |
| `./assets/*` | Reusable components shared across lessons | — |
| `NOTES.md` | User teaching preferences and working notes | — |

The teaching model rests on three pillars — **knowledge** (from trusted, cited resources; difficulty is the enemy), **skills** (drilled through tight feedback loops; difficulty is the tool), and **wisdom** (real-world practice, delegated to communities). The core distinction driving lesson design is **fluency strength** (in-the-moment recall) vs **storage strength** (long-term retention), with lessons deliberately engineered for the latter via retrieval practice, spacing, and interleaving. Every lesson sits in the user's **zone of proximal development** — challenged "just enough" — computed from their learning records and mission.

## FAQ

**Q: Why does it insist on a mission before teaching?**
A: Without the real-world reason, lessons are abstract and there's no basis for choosing what to teach next. The mission is what makes a lesson feel relevant and lets the skill judge the zone of proximal development.

**Q: Why HTML lessons instead of chat?**
A: Lessons are meant to be beautiful, self-contained, and revisitable — clean typography the user returns to. HTML also carries interactive widgets (quizzes, simulators) that chat can't.

**Q: What's the difference between a lesson and a reference doc?**
A: A lesson teaches one thing once and is rarely reopened. A reference doc is the compressed essence — a cheat sheet or glossary — designed to be returned to often and to print well.

**Q: Why must quiz answers all be the same length?**
A: Formatting leaks information. If the correct answer is visibly longer or shorter, the user pattern-matches on shape instead of recalling — defeating the retrieval practice.

**Q: Does it run automatically when I mention learning something?**
A: No. It sets `disable-model-invocation: true`, so it starts only when you explicitly invoke it — spinning up a multi-session workspace is a deliberate act.

**Q: Can the mission change over time?**
A: Yes, and it's expected as skills grow. The skill confirms with you before updating `MISSION.md` and logs a learning record capturing the change.

## Related skills

- **[research](../../meta-orchestration/research/)** — delegate deeper source-gathering to a background agent when a topic needs more vetted resources than a lesson pass turns up.
- **[grill-me](../../research-analysis/grill-me/)** — the questioning discipline the mission-elicitation step mirrors; useful for pinning down a fuzzy learning goal.
- **[obsidian-vault](../../obsidian/obsidian-vault/)** — if the user prefers their learning notes and records living in an Obsidian vault rather than a bare workspace directory.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (teaching philosophy, workspace, lesson design)
- **[MISSION-FORMAT.md](MISSION-FORMAT.md)** — Format for `MISSION.md`
- **[RESOURCES-FORMAT.md](RESOURCES-FORMAT.md)** — Format for `RESOURCES.md`
- **[LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md)** — Format for numbered learning records
- **[GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md)** — Format for glossary/reference documents
