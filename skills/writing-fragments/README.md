# Writing Fragments

A grilling session that mines the user for fragments — heterogeneous nuggets of writing (sharp sentences, vignettes, half-thoughts, claims, quotes) — and appends them to a single markdown file as raw material for a future article. No outlining, no structure, no thesis-pinning. Just excavation.

## Why this exists

Writers who try to outline before they have material end up with thin outlines. Writers who try to write paragraphs before they have phrasing end up with mushy paragraphs. The novelist's diary is the model: years of unstructured noticings that later get mined for raw material when you sit down to write something. This skill produces those noticings on demand. It treats writing like geology: collect heterogeneous samples first, sort them later. The bar is "is this a piece of good writing?" not "is this a self-contained argument?"

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "let's mine for fragments"
  - "I want to ideate before structuring"
  - "generate raw material"
  - "fragment session"
- Running the slash command: `/writing-fragments`

## What it does

The skill runs a free-flowing grilling session, catching fragments from the user's words, generating candidate fragments back, and appending them silently to a single markdown file separated by `---` horizontal rules. It explicitly does **not** propose outlines, structure, transitions, or a thesis — those are out of scope. The user can edit the file mid-session; the skill always re-reads before writing. When the user starts asking about structure, the skill stops and a different tool takes over.

### Inputs

- **Topic / area of interest** — free-form. The user describes what they're circling around.
- **File path** — optional. If not provided, the skill asks once and remembers.

### Outputs

- A single markdown file with one H1 working title and a series of fragments separated by `---`.

### External systems used

- Local filesystem (read/append the fragments file)

## How to use it

A typical session looks like this:

```text
You: I want to mine fragments about why I'm skeptical of meeting culture
Skill: What are you circling around? Don't structure it — just talk.

You: I keep noticing that the meetings I dread are the ones with no agenda
     but the meetings I'd cancel are the ones where the agenda is
     "discuss Q3 priorities."

Skill: Catching this:
       ---
       The meetings I dread have no agenda. The meetings I'd cancel have
       an agenda like "discuss Q3 priorities." It's a different problem.
       ---
       Adding that. Say more — what's the second one made of?

You: It's that the agenda is real but the meeting isn't necessary. The
     conversation could happen in a doc.

Skill: Three versions of the same idea — pick or reject:
       ---
       The Q3-priorities meeting fails because the agenda is real
       but the format is wrong. The conversation belongs in a doc.
       ---
       OR
       ---
       The cancellable meeting has a real topic and the wrong container.
       ---
       OR
       ---
       Some meetings have an agenda and shouldn't exist.
       ---

You: the third one is sharper.

Skill: Adding the third. Excavating: what made you believe this?
       Was there a specific meeting?

You: Tuesday's planning session. We spent 90 minutes saying things we
     could have written down in 5.

Skill: Catching the vignette:
       ---
       Tuesday's planning session: 90 minutes saying things we could
       have written down in 5. The doc would have been better. We'd
       have read each other's contributions in our own time and the
       conflicts would have surfaced in writing — sharper, asynchronous.
       ---
```

## Getting the most out of it

- **Ramble.** The skill catches fragments from your words, so the more you say (even contradictory things), the more there is to catch. Don't pre-edit your speech.
- **Reject mushy fragments.** When the skill offers three versions, pick the sharpest or reject all three. Mushy fragments produce mushy articles. Better to capture less but better.
- **Edit the file mid-session.** Reorder, delete, sharpen. The skill re-reads before every write. Your edits are preserved and inform what comes next.
- **Stop when you're tired, not when the file feels "done."** Fragment files don't have a done state. They have an "enough to start shaping" state. When you have ~20 fragments and feel one or two of them grabbing you as a starting move, you're ready.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Outline the article.** Out of scope. If you find yourself asking "what's the structure?" the session is over and a different tool takes over.
- ❌ **Pin down a thesis.** Same — out of scope. Fragments are pre-thesis. Forcing one early collapses the heterogeneity.
- ❌ **Produce finished prose.** Fragments are readable by the author, not by a cold reader. They don't need to define their terms or be self-contained.
- ❌ **Group or tag fragments.** No headings inside the body. No tags. Order is just the order they were added. Imposing structure is the next skill's job.

## Examples

### Example: A fragment file in mid-flight

```markdown
# meetings & meaning

The meetings I dread have no agenda. The meetings I'd cancel have an
agenda like "discuss Q3 priorities." It's a different problem.

---

Some meetings have an agenda and shouldn't exist.

---

Tuesday's planning session: 90 minutes saying things we could have
written down in 5. The doc would have been better.

---

> "Async is just synchronous with extra steps."

I disagree but I keep hearing this and the disagreement is the
interesting thing. Where does it come from?

---

- Meetings as social ritual
- Meetings as decision forcing function
- Meetings as performance of being important
- Meetings as the only place certain people can be heard

These hang together by feel.
```

Notice: no transitions, no order, no thesis. Just samples.

### Example: Pushing back on mushiness

```text
You: I think meetings are bad because they waste time.

Skill: That's mushy — "waste time" could mean any of three things and
       none of them are interesting. Sharper:
       1. The information density of an hour-long meeting is lower than
          a 5-minute doc.
       2. The decisions made in meetings happen because of who showed up,
          not because of who's most informed.
       3. Meetings train people to defer decisions until everyone is
          present, which makes the team async-illiterate.

       Which one (or none) is what you actually mean?

You: 3, but sharper.

Skill: ---
       Meetings train teams to be async-illiterate. Every problem
       waits for the next meeting because that's where the decisions
       happen. Then the team can't function when half is on PTO.
       ---
```

Pressure on quality is the point. Mushy in, mushy out.

## Internals

The skill follows a free-form loop, not a phased workflow:

1. **Read the file** if it exists; create with H1 working title if not.
2. **Open with "what are you circling around?"** Let the user ramble.
3. **Catch fragments** from their words. Capture verbatim or slightly sharpened.
4. **Generate candidate fragments** back at the user. Try things on. Offer 2-3 versions of an idea; let them pick or reject.
5. **Append silently** when fragments land. Mention in passing ("adding that").
6. **Press for more** — "say it three different ways," "what's the version you wouldn't say in public?", "what's the example that made you believe this?"
7. **Push on quality** — propose sharper rewrites of mushy fragments before appending.
8. **Re-read before every write** to preserve user edits.

File format: H1 title at top; fragments below separated by `---`. No headings inside body. No tags. Order is just the order they were added.

Key constraints:

- **No outlines, no structure, no thesis.** Out of scope.
- **Append-only.** Never overwrite (unless the user explicitly asks to edit a fragment in place).
- **The user's edits are first-class.** The file is alive between turns.

## FAQ

**Q: When is the session over?**
A: When the user starts asking structural questions ("how should I order these?"). The skill stops and a different tool takes over. The skill does not name or recommend that tool — it just stops.

**Q: How many fragments is "enough"?**
A: There's no number. Stop when you sense you have enough material to start shaping. ~20 fragments is typical for a blog post; long-form essays need more.

**Q: Can fragments be lists, code, or quotes?**
A: Yes — anything markdown supports. A list of related observations, a code snippet, a quoted line, a paragraph of prose. Heterogeneity is the point.

**Q: Should the H1 title match the eventual article title?**
A: No. It's a working title. The article's actual title gets decided much later.

**Q: What if I want to reorder fragments?**
A: Edit the file directly. The skill re-reads before every write — your reorder is preserved.

## Related skills

- **[writing-shape](../writing-shape/)** — the natural next step. Once you have a fragment pile, shape mines it paragraph by paragraph.
- **[writing-beats](../writing-beats/)** — alternative next step. Beats mines the pile as a sequence of journey moves.
- **[writing-draft-article](../writing-draft-article/)** — top-level skill that delegates here when the user lacks raw material.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
