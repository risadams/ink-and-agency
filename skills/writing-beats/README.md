# Writing Beats

Shape an article as a journey of beats, choose-your-own-adventure style. The user picks a starting beat from a pile of raw material; you write only that beat to the article file; then you offer 2-3 candidate next beats, the user picks, and the loop continues until the article reaches a natural end. Structure emerges; it isn't imposed.

## Why this exists

Outlines are a tax on writing. Half the time you build one and then ignore it because the actual article wants to go somewhere the outline didn't anticipate; the other half, the outline forces you to write a section that doesn't earn its place. Shaping an article as a journey of beats — small moves that pivot off each other — produces structure that fits the material instead of constraining it. The cost is that you can't see the whole shape at once. The benefit is that you don't have to.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "shape this as beats"
  - "build this article beat by beat"
  - "let's do choose-your-own-adventure on this material"
  - "I have raw material and want a narrative"
- Running the slash command: `/writing-beats`

## What it does

The skill takes a markdown file of raw material as input, drafts 2-3 candidate starting beats (each a different entry into the article), writes only the picked beat to a separate article file, then loops: re-read the article, offer 2-3 candidate next beats with diverse pivot moves (continue / contrast / zoom in / zoom out / aside / pivot hard), write only the picked one. The journey ends when it ends — most piles have leftover material, and that's the point. It does **not** outline the whole article up front, write multiple beats per turn, or edit the raw material file.

### Inputs

- **Raw material** — markdown file path. The pile.
- **Article output path** — optional. If not provided, the skill asks once and remembers.

### Outputs

- A separate markdown article file, grown one beat at a time.

### External systems used

- Local filesystem (read pile, write/append article)

## How to use it

A typical session looks like this:

```text
You: shape ~/notes/async-work.md as beats. Save the article to articles/async.md.

Skill: Read the pile (47 fragments). Three candidate openings:

       1. Open with the failure. Drop the reader into a Tuesday standup
          where nobody knows what anyone else did over the weekend.
          Hooks on shock.
       2. Open with the contradiction. State what async work was supposed
          to be, then state what it became. Hooks on curiosity.
       3. Open with the small scene. A specific Slack message at 11pm,
          a specific reply at 7am the next day. Hooks on intimacy.

       I'd go with 2 — the contradiction sets up the strongest through-line.

You: 2.

Skill: [writes beat 2 to articles/async.md, then re-reads]
       Three candidate next beats:

       1. Continue — go deeper on the contradiction's mechanism.
       2. Contrast — bring in a team that gets async right, briefly.
       3. Zoom in — one specific tool (Slack threads) and what it
          actually optimizes for.

You: 3.

Skill: [writes beat 3...]
```

## Getting the most out of it

- **Trust the recommendation.** The skill always names a recommended next beat and a one-line reason. Override it when you have a real reason; otherwise let the recommendation drive — it's reading the article so far.
- **Edit between beats.** The skill re-reads the file before every write. Aggressively rewrite the previous beat, reorder paragraphs, delete things. The journey adapts.
- **Mix pivot types.** If you've taken three "continue" beats in a row, the skill will force a contrast or zoom. Resist the urge to keep continuing — variety is what makes the journey readable.
- **Let the pile have leftovers.** A great article uses 60-80% of the pile, not 100%. If you find yourself trying to fit every fragment in, you're outlining-by-stealth.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Outline the whole article up front.** That's the technique this skill exists to avoid. If you want an outline, use [writing-shape](../writing-shape/) instead.
- ❌ **Write multiple beats per turn.** One beat at a time. Writing ahead breaks the choose-your-own-adventure loop because the next pivot can't depend on user edits to the previous beat.
- ❌ **Foreshadow or write transitions out of a beat.** Pivots are written when the next beat is written. Transitions baked into the prior beat constrain the pivot.
- ❌ **Edit the raw material file.** The pile is read-only. The article is a separate file.

## Examples

### Example: Opening menu

```text
Where do you want to start?

1. **Open with the question.** Pose the thing you can't stop thinking about.
   Hooks on intellectual itch.
2. **Open with the demo.** Show the thing in action before naming it.
   Hooks on tangibility.
3. **Open with the disagreement.** Quote two people who think they agree
   but actually don't. Hooks on tension.

I'd go with **3** — the disagreement gives you a built-in tension to
resolve, and the pile has two strong quotes that fit.
```

Each candidate is a different *direction*, not a different paragraph of the same direction.

### Example: Mid-article pivot menu

```text
We're three beats in. The article is arguing that async work fragments
attention. Here's where we could go next:

1. **Continue.** Push further: the cost of context-switching across 14
   Slack threads. The pile has three good fragments here.
2. **Contrast.** Bring in the team that uses async well. The pile has
   that scene about the documentation-first culture.
3. **Aside.** A footnote-shaped paragraph: the one tool that breaks
   the pattern. Drop it as a callout, then return to the main thread.

I'd go with **2** — without a contrast, this becomes a one-note
critique. The contrast keeps it honest.
```

The recommendation is opinionated. Take it or override.

## Internals

The skill follows a beat-by-beat loop, not a phased workflow:

1. **Read the pile** in full once.
2. **Offer 2-3 starting beats** as a menu with sketched moves; recommend one.
3. **Write only the picked beat** to the article file. Stop.
4. **Re-read the article** from disk (preserves user edits).
5. **Offer 2-3 next beats** with diverse pivot moves (continue / contrast / zoom in / zoom out / aside / pivot hard).
6. **Loop** until the user calls it done or you sense an ending.

A beat is sized by what it needs: one sentence, one paragraph, or several. If a "beat" requires five paragraphs and three subheadings, it's two beats glued together — split it.

Pivot vocabulary:

- **Continue** — push further in the same direction.
- **Contrast** — opposite, counterexample, doubt.
- **Zoom in** — narrow to a specific case or detail.
- **Zoom out** — widen to broader implication.
- **Aside** — break the fourth wall, drop a footnote-shaped paragraph.
- **Pivot hard** — change subject; trust the connection lands later.

Key constraints:

- **Append only.** Never overwrite.
- **Re-read before every write.** Preserves user edits.
- **The structure is the journey.** No fixed intro/body/conclusion shape.

## FAQ

**Q: When does the article end?**
A: When the journey reaches a natural landing — not when the pile is empty. The skill says when it senses an ending: "we could end on the last beat, or add one more — which?"

**Q: Can I rewrite an earlier beat?**
A: Yes. Tell the skill "rewrite beat 3" and it edits in place, leaving the rest alone. The journey may pivot differently afterward.

**Q: What if I don't like any of the offered beats?**
A: Say so. Describe what you actually want; the skill regenerates options.

**Q: How is this different from writing-shape?**
A: Shape grows the article paragraph-by-paragraph with format arguments at each step (prose vs list vs callout). Beats grow it as a sequence of journey moves with pivot choices. Beats is more narrative; shape is more structural.

**Q: Does it work for short pieces (social posts)?**
A: Better for medium-length essays. For social posts and threads, [writing-shape](../writing-shape/) tends to work better because beats want room to pivot.

## Related skills

- **[writing-fragments](../writing-fragments/)** — generates the raw material pile this skill consumes.
- **[writing-shape](../writing-shape/)** — alternative shaping mode: paragraph-by-paragraph with format arguments at each step.
- **[writing-draft-article](../writing-draft-article/)** — top-level skill that delegates to beats when narrative shape is what you want.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
