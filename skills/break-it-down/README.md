# Break It Down

A communication decoder. Takes any message — email, Slack, comment, prompt — and produces a three-section analysis: a plain-language breakdown of what they actually mean, a tone analysis table with probability bands and signals, and editor's notes covering sentiment, ambiguity flags, and suggested follow-up questions.

## Why this exists

A lot of professional communication is indirect on purpose: "per my last email," "let me know if that works," "circle back," "thanks in advance." The indirection serves social functions, but it costs reader cycles. Decoding it manually drains attention. This skill does the decoding once, surfaces the actual ask, and flags the parts that are genuinely ambiguous (so you don't waste a reply on the wrong interpretation). It's particularly useful for anyone who finds indirect communication exhausting — including most people who self-identify as preferring plain language.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "break it down"
  - "decode this message"
  - "what does this mean"
  - "what are they actually saying"
- Running the slash command: `/break-it-down`

Pass the text inline (paste it), quote it, or point to a file.

## What it does

The skill produces three sections, always in this order: (1) plain-language restatement of the message stripped of jargon, sarcasm, passive aggression, and indirectness; (2) tone analysis as a markdown table with rows for sarcasm, humor, anger, passive aggression, sincerity (always present), plus additional rows when other tones are strongly signaled (urgency, frustration, formality), with Low/Medium/High bands and specific signals from the text; (3) editor's notes covering overall sentiment, what's not being said, ambiguity flags, and suggested follow-up questions. It does **not** judge the sender or assume bad intent without strong evidence.

### Inputs

- **Text to decode** — pasted, quoted, or file path.

### Outputs

- A three-section markdown analysis.

### External systems used

- Local filesystem (read only — when text is in a file)

## How to use it

A typical session looks like this:

```text
You: break it down:
     "Hey — circling back on this. As discussed, we really need to lock
     down the scope before EOW. Happy to jump on a call if it's easier!"

Skill:

       ### What they're actually saying
       - They feel they've already been waiting on you.
       - They want scope agreement by end of week (Friday).
       - "Happy to jump on a call" is escalation pressure, not a
         genuine offer — they're signaling that async conversation
         isn't moving fast enough.
       - "As discussed" implies you already agreed to lock down scope;
         if you didn't, that's worth flagging back.

       ### Tone analysis

       | Tone | Probability | Signals |
       |------|-------------|---------|
       | Sarcasm | Low | No overt sarcasm markers |
       | Humor | Low | No clear signals |
       | Anger | Low | Polite phrasing, but mild frustration is present |
       | Passive aggression | Medium | "Circling back" + "as discussed" + "happy to jump on a call" together signal that async is not getting them what they want |
       | Sincerity | Medium | The request itself is real; the politeness is partly performative |
       | Urgency | High | "EOW" with no qualification; the call offer adds escalation |
       | Formality | Medium | Casual greeting ("Hey"), but corporate phrases throughout |

       ### Editor's notes

       **Overall sentiment:** Neutral-to-mildly-frustrated. Professional
       tone over a "do this" core.

       **What's not being said:** They probably feel they're being slow-rolled
       and the call offer is a soft threat to escalate further if you don't
       respond promptly.

       **Ambiguity flags:**
       - "Lock down the scope" — which scope? If multiple workstreams are
         in play, this could refer to any of them.
       - "As discussed" — was there an explicit agreement, or are they
         describing it as discussed when it was actually open-ended?

       **Suggested follow-up questions:**
       - "Can you confirm which scope you mean — the Atlas integration
         or the broader Q3 roadmap?"
       - "When you say 'as discussed,' are you referring to the meeting
         on Tuesday? My read of that was different — let's align."
```

## Getting the most out of it

- **Decode before you reply.** The skill is most useful as a pre-reply step. Decoding *after* you've already misread the message is too late.
- **Pay attention to the ambiguity flags.** Tone analysis is interesting; ambiguity flags are actionable. The suggested follow-up questions exist to convert ambiguity into clarity before you commit to an interpretation.
- **Use it on your own drafts too.** Flip the framing: "how is this likely to be received?" The skill will analyze your message with the same lens. Catches passive aggression you didn't intend.
- **Threads get thread-level summary.** When you paste multiple messages, the skill analyzes each separately and adds a thread-level summary at the end. The summary is often where the actual story lives.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Judge the sender.** "They're being a jerk" is not output. The skill describes what's happening; the moral reading is yours.
- ❌ **Assume bad intent without strong evidence.** Passive aggression at "Medium" is the default for "circling back" — that's a calibrated read, not an accusation.
- ❌ **Skip a section.** All three sections appear every time, even if the section would be brief. Short messages still get all three.
- ❌ **Use jargon to explain jargon.** The "plain language" section is plain language. If a translation requires another technical term, it's not done.

## Examples

### Example: Very short message

```text
You: break it down: "K"

Skill:

       ### What they're actually saying
       - Acknowledged your message.
       - That's it. No additional commitment, no pushback, no enthusiasm.
       - In most contexts, "K" reads as terser than "OK" — the missing
         "O" is itself a signal that the writer doesn't want to invest
         more keystrokes than necessary.

       ### Tone analysis

       | Tone | Probability | Signals |
       |------|-------------|---------|
       | Sarcasm | Low | "K" is too terse to carry sarcasm reliably |
       | Humor | Low | No clear signals |
       | Anger | Low-Medium | Single-letter responses sometimes signal annoyance |
       | Passive aggression | Medium | "K" is read as dismissive in many contexts; the brevity itself is a signal |
       | Sincerity | Low | Without context this is a dismissal, not a sincere acknowledgment |
       | Brevity | High | Single character with no punctuation |

       ### Editor's notes

       **Overall sentiment:** Mildly negative or disengaged. Could also be
       genuine acknowledgment from someone in a hurry — context matters.

       **What's not being said:** If the prior message was a request, this
       is "noted, will do." If it was an opinion, this might be "I disagree
       and don't want to debate it."

       **Ambiguity flags:**
       - The intent depends entirely on the relationship and the prior
         message. Same "K" from a friend joking around vs. a manager
         reading a long pitch reads very differently.

       **Suggested follow-up questions:**
       - If you need confirmation: "Quick check — by 'K' do you mean
         we're good to proceed, or is there something you'd like me
         to adjust?"
```

Short messages often carry the most ambiguous tone — the skill still produces all three sections.

### Example: Decoding your own draft before sending

```text
You: how will this read? draft: "Just following up on this — wanted to
     make sure it didn't slip through the cracks. No worries if you're
     swamped, just let me know either way!"

Skill: (using the "how will this be received" framing)

       ### How this will be received
       - You're asking for a response.
       - "Slip through the cracks" softens the ask but implies you
         think they may have ignored you.
       - "No worries if you're swamped" is genuine politeness but
         doesn't actually let them off the hook — "let me know either
         way" still requires a reply.

       ### Tone they'll likely read
       (table)

       ### Editor's notes
       This is friendly but slightly insistent. If you genuinely want
       to give them an out, drop "let me know either way." If you
       want a reply, keep it but expect they may read the politeness
       as performative.
```

The framing flips when the message is yours.

## Internals

The skill follows a fixed three-section output structure:

1. **Section 1 — What they're actually saying** — restated in plain language. Short sentences or bullets, one idea per bullet, separate distinct requests, flag contradictions, no editorializing.
2. **Section 2 — Tone analysis** — markdown table with the five mandatory rows (sarcasm, humor, anger, passive aggression, sincerity) using Low/Medium/High bands (no false-precision percentages), plus additional rows for strongly-signaled tones. Signals column cites specific words/phrases/structures.
3. **Section 3 — Editor's notes** — overall sentiment, what's not being said, ambiguity flags with possible interpretations, suggested follow-up questions.

Edge case handling:

- **Very short messages** — all three sections still produced; brevity itself is a signal.
- **Code or technical content** — focus on human communication around the code; if pure code, ask whether the user wants a code review instead.
- **Multiple messages (thread)** — analyze each separately, then a thread-level summary.
- **User's own writing** — flip the framing to "how will this be received."

Key constraints:

- **No emojis.**
- **No judging the sender** beyond what the text strongly supports.
- **Plain language in the analysis** — no jargon to explain jargon.
- **All three sections every time.**

## FAQ

**Q: Why bands instead of percentages?**
A: Percentages imply false precision. "65% passive aggressive" is not measurable; "Medium passive aggressive with these signals" is honest.

**Q: Can the skill be wrong about tone?**
A: Yes. Tone is contextual — a "K" from a close friend is different from a "K" from your boss. The skill calibrates from the text alone; you have the relationship context.

**Q: Does it work on non-English text?**
A: Best on English. The patterns are language-specific (passive-aggression markers in English don't map directly to other languages' equivalents).

**Q: What if the message has no ambiguity?**
A: The Ambiguity flags section will say "No significant ambiguity." All three sections still appear.

**Q: Will it tell me how to reply?**
A: It suggests follow-up *questions* to reduce ambiguity. The reply is your call — the skill won't draft it.

## Related skills

- **[clarity-council](../clarity-council/)** — for structured analysis of decisions (not messages). When the decoded message reveals a real decision to make, the council can take it from there.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full output format with examples)
