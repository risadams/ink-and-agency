# Writing Shape

Take a markdown file of raw material and shape it into a separate article through a conversational session — drafting candidate openings, growing the piece paragraph by paragraph, arguing about format (prose / list / table / callout / quote / code) at each step. The pile is a quarry; the article is a separate artifact; structure is decided one block at a time, with the user pushing back at every step.

## Why this exists

Two failure modes for shaping notes into an article. First: outline first, then write — produces stiff, schematic prose where the outline becomes a tax. Second: just start writing — produces shapeless drift that doesn't earn its place. This skill threads between them: the article grows one block at a time, but every block is justified out loud (why this paragraph, why prose vs list, why this transition). The argument-as-you-go is the whole point. Reviewers later read past the prose to the structure; the structure is what holds.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "shape this material into an article"
  - "I have raw notes — let's make an article"
  - "grow this into a draft"
  - "let's argue about format as we write"
- Running the slash command: `/writing-shape`

## What it does

The skill reads the raw material file in full, drafts 2-3 candidate openings (each implying a different thesis), writes the chosen opening to a separate article file, then loops paragraph by paragraph. At each step it asks "given the article so far, what does the reader need next?" and argues about whether the next block is a paragraph, list, table, callout, quote, or code block. It pulls material from the pile (treating it as a quarry — fragments can be split, merged, paraphrased, quoted) but does **not** edit the raw material file.

### Inputs

- **Raw material** — markdown file path. The pile.
- **Article output path** — optional. If not provided, the skill asks once and remembers.

### Outputs

- A separate markdown article file, grown one block at a time.

### External systems used

- Local filesystem (read pile, write/append article)

## How to use it

A typical session looks like this:

```text
You: shape ~/notes/checkout-redesign.md into an article. Save to articles/checkout.md.

Skill: Read the pile (32 fragments, ~3,000 words of raw material).
       Three candidate openings:

       1. **The complaint.** Open with the user research finding that
          43% of mobile users abandon at the cart. Argues from data.
       2. **The decision.** Open with the moment we decided to ship
          the new flow despite the pushback. Argues from narrative.
       3. **The contradiction.** Open with what the metric said vs
          what the qualitative interviews said. Argues from tension.

       I'd recommend 3 — the pile has the strongest material for the
       contradiction angle, and it sets up the rest cleanly.

You: 3.

Skill: [writes opening to articles/checkout.md, re-reads]

       Given that opening: the reader now wants to know what the
       contradiction was. The pile has three relevant fragments.

       Two format options:
       1. Prose paragraph synthesizing the three fragments.
       2. A short table: metric column, interview column, mismatch column.

       I'd go prose — the table makes the contradiction look smaller
       than it was. Save the table for the redesign decision later.

You: agreed.

Skill: [writes the next paragraph]
       What does the reader need next?
```

## Getting the most out of it

- **Argue back.** The skill argues for a format choice; if you have a reason to disagree, say so. The friction is what produces good prose.
- **Edit aggressively between turns.** The skill re-reads the article from disk before every write. Rewrite the previous paragraph; the next one will adapt.
- **Name gaps explicitly.** If the pile is missing something the article needs, the skill says so: "we need an example here and the pile doesn't have one." Either give it one or accept a cut. Don't let the skill paper over a gap.
- **Stop when you sense the landing.** The skill won't ride the article past a natural ending unless you tell it to. When the closer feels right, ship it.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Edit the raw material file.** The pile is read-only. Edit the article file separately.
- ❌ **Pull material that isn't in the pile.** No invented examples, no fabricated quotes. If the article needs something the pile doesn't have, the skill names the gap.
- ❌ **Batch multiple paragraphs per turn.** One block at a time. Batching prevents you from editing between turns and breaks the conversational shape.
- ❌ **Add platform-specific frontmatter you didn't ask for.** No tags, no SEO blocks, no `published: true` flags. Publication formatting is a later step.

## Examples

### Example: Format argument — prose vs list

```text
Skill: Three relevant fragments from the pile, all variations of
       "what we changed about the flow." Two format options:

       1. **List.** The three changes as bullets. Faster to scan;
          good if these are parallel changes that share a theme.
       2. **Prose.** Three short paragraphs in sequence. Slower
          but supports causal language ("the first change made the
          second one possible").

       The pile suggests these are NOT parallel — change 2 was
       enabled by change 1, and change 3 was the consequence of both.
       I'd argue prose. Override?

You: prose.

Skill: [writes three short paragraphs in sequence]
```

The argument is the deliverable as much as the prose. A reviewer asking "why prose?" gets the answer baked in.

### Example: Naming a gap

```text
Skill: The opening promised we'd compare the redesign against the
       original. The pile has rich material on the redesign but the
       original is only described through the complaint metric (43%
       abandon rate). We need either:

       1. A specific scene of a user struggling with the original
          flow, OR
       2. A trim of the opening so the comparison promise isn't there.

       Which?

You: option 2 — trim the promise.

Skill: [edits the opening in place, re-reads, continues]
```

Calling the gap forces a real choice instead of papering over with vague prose.

## Internals

The skill follows a paragraph-by-paragraph loop:

1. **Read the pile** in full.
2. **Draft 2-3 candidate openings** — each implying a different thesis. Force the user to pick or compose a hybrid.
3. **Write the chosen opening** to the article file.
4. **Loop**: ask "given this so far, what does the reader need next?" Pull material from the pile. Argue format (prose vs list vs table vs callout vs quote vs code). Append the agreed block immediately.
5. **Re-read the article** before every write to preserve user edits.
6. **End when the user calls it done.**

Format arguments to actually have:

- **Prose vs list** — prose carries argument; lists carry parallel items. Mismatch = wrong choice.
- **Inline vs callout** — callouts (`> [!TIP]`, `> [!NOTE]`) when the aside would derail inline.
- **Table vs repeated structure** — table when 3+ items share fields; prose with bold leads otherwise.
- **Quote vs paraphrase** — quote when wording is the point; paraphrase when only the idea matters.
- **Code block vs inline code** — multi-line/runnable → block; single token → inline.

Specific moves to keep using:

- "What does this paragraph do for the reader that the previous one didn't?"
- "If I cut this, what breaks?"
- "Is this prose, or should it be a list? Why prose?"
- "This sentence is doing two jobs — split it or pick one."
- "The opening promised X. We've drifted to Y. Re-thread or change the opening."

Key constraints:

- **Append-only on the article file.** Never overwrite.
- **Read-only on the raw material file.**
- **One block per turn.** No batching.
- **Re-read before every write.** User edits are first-class.

## FAQ

**Q: How is this different from writing-beats?**
A: Beats grows the article as a sequence of journey moves with pivot choices (continue / contrast / zoom in / zoom out). Shape grows it paragraph-by-paragraph with format arguments at each step. Beats is more narrative; shape is more structural.

**Q: What if the pile is too small?**
A: The skill names gaps as it goes. If the gaps overwhelm the material, the skill suggests stopping and using [writing-fragments](../writing-fragments/) to mine more before continuing.

**Q: Can it shape something that isn't fragments — like a transcript?**
A: Yes. The pile format doesn't matter. A transcript, a wall of unstructured prose, a list of bullets — all are mineable.

**Q: What if I want to restructure mid-session?**
A: Edit the article file directly. Reorder paragraphs, delete sections. The skill re-reads and adapts the next "what's needed?" question to the new state.

**Q: How long are sessions typically?**
A: A 1500-word article is 30-90 minutes of paragraph-by-paragraph work. The opening is the slowest part; momentum builds after.

## Related skills

- **[writing-fragments](../writing-fragments/)** — for the upstream work when the pile doesn't exist yet.
- **[writing-beats](../writing-beats/)** — alternative shaping mode: choose-your-own-adventure journey instead of paragraph-by-paragraph.
- **[writing-draft-article](../writing-draft-article/)** — top-level skill that delegates here when material is plentiful and structure is the question.
- **[writing-humanize](../writing-humanize/)** — run after shaping if the prose has drifted into AI patterns.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
