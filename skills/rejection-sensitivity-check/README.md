# Rejection Sensitivity Check

A specialized message decoder for messages that stung. The user pastes the message and what they read into it; the skill separates **what the text actually says** from **what the brain layered on top**, calibrates whether the sting is warranted on a 1–5 scale, and offers worst-case, best-case, and most-likely interpretations side by side.

## Why this exists

Rejection-sensitive dysphoria (RSD) is the experience of feeling rejected or criticized at the speed and intensity of a body blow, often from messages that contain no criticism at all. It's especially common in ADHD and autism, but lots of people without those labels experience it after enough cumulative hits. The trap is that the felt sense is so strong and arrives so fast that "calm down, you're overreacting" doesn't work — that voice is already in the user's head and it's lost. What helps is laying the evidence out: here's the text, here's the interpretation, here's the evidence weight, here's where they actually point. The skill is the second perspective the brain can't generate for itself.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "did they mean it that way"
  - "is this criticism"
  - "am I reading this wrong"
  - "rejection check"
  - "rsd check"
  - "this stung"
- Running the slash command: `/rejection-sensitivity-check`

The skill always invokes [clarity-council](../clarity-council/) with `psychologist + devils-advocate` — the second perspective is the whole value.

## What it does

The skill produces five sections: (1) a neutral, evidence-only restatement of what the text literally says; (2) the user's interpretation, restated back without judgment; (3) an evidence-vs-interpretation table breaking down each phrase with neutral read, RSD read, and how much the text actually supports the RSD read; (4) a calibrated sting score from 1 (almost certainly neutral) to 5 (critical and disproportionate); (5) worst-case / best-case / most-likely interpretations, plus a recommended response stance that works for all three. The council session is mandatory — psychologist reads the text neutrally, devils-advocate stress-tests both extremes.

### Inputs

- **The message that stung.**
- **Your interpretation** — what you read into it.
- **Relationship context** — who sent it, history with them.
- **Physical state** (optional but useful) — RSD often runs through the body; naming it helps separate signal from somatic noise.

### Outputs

- A five-section markdown analysis with the calibrated 1–5 sting score.

### External systems used

- None. The clarity-council call is local skill-to-skill.

## How to use it

A typical session looks like this:

```text
You: rsd check. my manager just said "we should talk about the migration
     work tomorrow." I'm spiraling — I think they're going to take me
     off the project.

Skill:

       ### What the text actually says
       Your manager wants to talk about the migration work tomorrow.
       That's the entire content of the message.

       ### What your brain is adding
       That "we should talk" = a setup for bad news. That the
       conversation is about you, not the work. That removal from
       the project is the most likely topic.

       ### Evidence vs interpretation

       | Their phrase | Neutral read | RSD read | Evidence weight |
       |--------------|--------------|----------|-----------------|
       | "we should talk" | We need to align on something | They have a complaint to deliver | Low — "we should talk" is generic, no emotional valence in the words |
       | "about the migration work" | The topic is the work | The topic is your performance on the work | None — the work is explicitly the subject, you are not |
       | "tomorrow" | Schedule signal | Urgency = bad | Low — tomorrow is the next workday, not "urgent" |

       ### Warranted sting: **1**

       The text contains zero critical signal. Your brain pattern-
       matched "we should talk" to past instances where that phrase
       did carry criticism. That's a real pattern, not a delusion,
       but the evidence here doesn't support it.

       ### Three interpretations
       **Worst-case:** They want to take you off the project.
       **Best-case:** They've got new info on the migration and want
       to think through it with you.
       **Most likely:** They want to talk about the migration work.
       That's what they said.

       **Recommended response stance:** Reply normally — confirm the
       time, ask if there's anything to read or prep beforehand. The
       prep ask is a low-cost way to surface the agenda without
       asking "am I in trouble?" If they wanted to do a performance
       conversation they would have signaled it more directly.
```

## Getting the most out of it

- **Paste the message verbatim.** Your retelling will already smooth or sharpen it. The skill needs the literal text.
- **Say what your interpretation is.** Don't make the skill guess. Naming the interpretation explicitly is half the work — it forces a separation between "the message" and "my read of the message."
- **Pay attention to the evidence weight column.** A "High" evidence weight on an RSD read is the skill telling you the sting is real and warranted. Don't dismiss it just because the score is low elsewhere.
- **Use the recommended response stance.** It's calibrated to work whether your worst-case or best-case turns out to be right — you don't have to commit to an interpretation before you reply.

## Anti-patterns

- ❌ **"You're overreacting."** Already the voice in their head. The skill doesn't add to it.
- ❌ **Over-validating the worst-case** to be supportive. That makes the spiral worse, not better.
- ❌ **Assuming the sender is fluent.** The sender may have written a tonally-flat message without realizing how it would land. That's not the user's fault, but it's also not malice.
- ❌ **Recommending a response that requires emotional labor the user can't afford right now.** "Schedule a 1:1 to talk about your feelings" is not always the right answer at 11pm on a Tuesday.

## Examples

### Example: Warranted sting (score 4)

```text
You: rsd check. my PM said "I think we just have different
     standards for what done means" after I closed a ticket they
     reopened. I'm really upset.

Skill:

       ### What the text actually says
       Your PM is asserting that you and they have different
       definitions of "done" and connecting it to your closure of
       the ticket they reopened.

       ### What your brain is adding
       That this is a personal critique. That they think you're
       cutting corners. That this will surface in your review.

       ### Evidence vs interpretation

       | Their phrase | Neutral read | RSD read | Evidence weight |
       |--------------|--------------|----------|-----------------|
       | "I think we just have different standards" | Framing as a mutual difference | Framing as you having lower standards | Medium — "just" softens it, but the asymmetry (they reopened your closure) makes it directional |
       | "for what done means" | Definitional disagreement | A judgment that your work is incomplete | High — this is the actual content of the critique |

       ### Warranted sting: **4**

       This is genuine critical feedback, delivered in a way that
       softens the form but doesn't soften the substance. The sting
       is proportionate. The brain reaching for "and this will
       surface in your review" is RSD — that's not in the text. But
       "they think my work isn't meeting the bar" is in the text.

       ### Three interpretations
       **Worst-case:** Pattern of complaints, headed toward formal
       feedback.
       **Best-case:** One-off disagreement on this specific ticket.
       **Most likely:** They genuinely think this ticket wasn't
       done. Whether it's a pattern depends on history you have
       and I don't.

       **Recommended response stance:** Don't relitigate the ticket
       in writing — it'll read as defensive. Reply: "Want to walk
       through what 'done' looks like for you on this one? I'd
       rather get aligned than guess." That converts the critique
       into a working conversation.
```

### Example: Almost certainly neutral (score 1)

```text
You: my friend hasn't replied to my text in 6 hours. They're mad
     at me.

Skill:

       ### What the text actually says
       Your friend hasn't replied. That's the entire data point.

       ### What your brain is adding
       That the silence means anger. That you did something to cause
       it. That the relationship is in trouble.

       ### Evidence vs interpretation

       | Signal | Neutral read | RSD read | Evidence weight |
       |--------|--------------|----------|-----------------|
       | 6 hours of silence | They are busy / asleep / phone is dead | They are angry and ignoring you | None — silence has no inherent valence, you're projecting one onto it |

       ### Warranted sting: **1**

       This is pattern-matching on absence of data, not on data.
       Six hours is well within the normal range of "person is
       living their life and not on their phone." The body is
       reacting; the evidence isn't there.

       ### Three interpretations
       **Worst-case:** They saw your text, decided not to reply,
       have feelings about it.
       **Best-case:** They saw the notification, will reply later
       today.
       **Most likely:** They haven't seen it yet, or saw it and
       got distracted before replying.

       **Recommended response stance:** Don't double-text. If
       they're mad, double-texting makes it worse. If they're not
       mad, double-texting telegraphs the spiral. Wait until
       tomorrow morning. If still silent then, send something light
       and unrelated.
```

## Internals

The clarity-council session is mandatory and uses `[psychologist, devils-advocate]`:

- The psychologist produces the neutral read, the evidence-vs-interpretation table, and names the cognitive pattern if one is operating.
- The devils-advocate stress-tests both directions — challenges the worst-case reading, but also challenges any too-charitable read of an actually-critical message.

The 1–5 scale is calibrated for *evidence in the text*, not for *how the user feels*. A score of 1 doesn't mean "your feeling is invalid"; it means "the text alone doesn't support the reading your brain is producing."

Hard constraints: don't say "you're overreacting"; don't invalidate the feeling; don't over-validate the worst case; cite specific words; recommend responses that work across multiple interpretations.

## FAQ

**Q: What if the sting score comes back low and I still feel terrible?**
A: That's normal and not a failure of the skill. The score reflects evidence in the text; the felt sense reflects body state and history. A low score gives you a reason to wait before reacting — not permission to suppress the feeling.

**Q: What if the score comes back high?**
A: Then the sting is warranted, and the skill should help you separate "what's worth a response" from "what's worth re-litigating in your head." The recommended response stance is the place to focus.

**Q: Can it be wrong about the read?**
A: Yes. The skill is reading text without the relationship context you have. If the read feels off, push back on the skill — give it the relationship detail it's missing and ask for a re-read.

**Q: Is this therapy?**
A: No. It's calibration. It can help you not spiral on individual messages; it cannot replace working on the RSD pattern itself.

## Related skills

- **[break-it-down](../break-it-down/)** — general-purpose decoder. Use that when the message didn't sting but is ambiguous; use this one when the message specifically triggered an RSD reaction.
- **[meeting-decompression](../meeting-decompression/)** — for the post-meeting equivalent: sorting "actually a problem" from "RSD noise".
- **[writing-tone-check](../writing-tone-check/)** — sibling that runs in the other direction (outgoing drafts).
- **[clarity-council](../clarity-council/)** — the psychologist + devils-advocate pairing is what makes the calibration honest.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full output format and council wiring)
