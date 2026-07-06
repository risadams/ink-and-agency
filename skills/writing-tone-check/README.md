# Writing Tone Check

A pre-send tone reviewer. Paste a draft message, name the recipient and the goal, and get back a landing prediction (cold / passive-aggressive / over-apologetic / warm) plus targeted rewrite suggestions. The sibling to [break-it-down](../break-it-down/) — that one decodes incoming, this one previews outgoing.

## Why this exists

Most "is this okay to send?" anxiety isn't actually about the message — it's about not being able to read your own writing the way a stranger will. Re-reading your own draft trains on your intent; the recipient reads only the words. This skill produces the recipient's read so you can adjust before sending, instead of finding out from a one-line reply that lands like a punch. It's especially useful for ADHD/autistic writers, ESL writers, anyone trained by past blowback to over-apologize, and anyone whose default register reads colder than they intend.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "tone check"
  - "how does this sound"
  - "before I send this"
  - "will this land okay"
  - "check this draft"
- Running the slash command: `/writing-tone-check`

Pass the draft inline (paste it) along with the recipient relationship and the message goal.

## What it does

The skill produces three sections: (1) a plain restatement of what the draft is actually trying to say underneath the phrasing; (2) a landing-prediction table with rows for direct/clear, cold/curt, passive-aggressive, over-apologetic, and warm/collaborative, plus relationship-specific reads ("reads as challenging authority", "reads as oversharing") — each with Low/Medium/High probability and specific phrases as signals; (3) rewrite suggestions split into Keep / Soften / Strengthen, with optional full rewrite on request. For non-trivial drafts it invokes the [clarity-council](../clarity-council/) `psychologist` persona for the landing prediction; trivial drafts are handled inline.

### Inputs

- **Draft text** — pasted.
- **Recipient relationship** — manager, peer, customer, partner, etc. (Always asked if not stated.)
- **Goal of the message** — what needs to be true after they read it.

### Outputs

- A three-section markdown analysis with landing prediction and rewrite suggestions.

### External systems used

- None. The clarity-council call is local skill-to-skill.

## How to use it

A typical session looks like this:

```text
You: tone check this — going to my manager about a missed deadline:
     "Hey, just wanted to flag that I'm not going to hit Friday on the
     Atlas migration. Sorry about this. Happy to do whatever to make
     it right."

Skill:

       ### Plain restatement
       - You're going to miss Friday.
       - You're apologizing.
       - You're asking what to do.

       ### Landing prediction

       | Read | Probability | Signals |
       |------|-------------|---------|
       | Direct/clear | Medium | Lead with the miss is good |
       | Cold or curt | Low | "Hey" warms the opening |
       | Passive-aggressive | Low | None |
       | Over-apologetic | High | "Sorry about this" + "whatever to make it right" reads as panic-apology, not accountability |
       | Warm/collaborative | Low | The over-apology crowds out collaboration |

       ### Rewrite suggestions

       **Keep:** the lead with "I'm not going to hit Friday" — that's
       exactly right.

       **Soften:** nothing.

       **Strengthen:** swap "Sorry about this. Happy to do whatever to
       make it right." → "Here's where I am and what I think the
       options are: [option 1] / [option 2]. Want to pick or want me
       to?" That moves you from "please don't be mad" to a peer
       conversation.
```

## Getting the most out of it

- **Always answer the recipient question.** "How does this sound" without naming the recipient produces generic output. The same draft reads very differently for a manager vs. a customer vs. a peer.
- **Name the goal, not the topic.** "Telling my PM the deadline slipped" is the topic; "getting them to agree to a new date without escalating to their boss" is the goal. The goal changes the calibration.
- **Take "Soften" suggestions seriously, but not automatically.** Sometimes blunt is correct. The skill will flag where you're sharper than intended, but it's still your call whether the sharpness is warranted.
- **Take "Strengthen" suggestions more seriously.** Most drafts from over-apologetic writers have far more hedging than they realize. If the skill flags hedging, it's usually right.

## Anti-patterns

- ❌ **Rewriting the whole draft by default.** The skill produces suggestions, not a replacement. It rewrites in full only on explicit request.
- ❌ **Flattening directness into mush.** "Soften" is for unintended sharpness, not for making every email warm. Some messages should be blunt.
- ❌ **Assuming the worst about the recipient.** The landing prediction is a neutral read, not a worst-case read.
- ❌ **Adding emojis or fake warmth** to the suggested rewrites unless the original used them.

## Examples

### Example: Slack reply to a peer's tense message

```text
You: tone check, going to a peer who pushed back hard on my MR review:
     "I disagree but if you really want it that way we can do it."

Skill:

       ### Plain restatement
       - You disagree.
       - You're conceding anyway.
       - You're telegraphing that the concession is reluctant.

       ### Landing prediction

       | Read | Probability | Signals |
       |------|-------------|---------|
       | Direct/clear | Low | Direct on disagreement, indirect on resolution |
       | Cold or curt | Medium | "If you really want it that way" reads as cold |
       | Passive-aggressive | High | The whole second clause is the textbook shape — conceding while making sure they know you're conceding |
       | Over-apologetic | Low | No apology at all |
       | Warm/collaborative | Low | The disagreement is foregrounded, the collaboration is buried |

       ### Rewrite suggestions

       **Keep:** "I disagree" — say the thing.

       **Strengthen:** Either commit to the disagreement and push back
       harder, or commit to the concession cleanly. The mush in the
       middle is what makes it passive-aggressive.

       Two cleaner options:
       - "I disagree because [reason]. Convince me or I'll defer."
       - "I disagree but you've thought about it more than me. Going
         with your call."

       Pick one based on whether you actually want to fight for it.
```

### Example: Email to a customer about a bug fix

```text
You: tone check, going to a customer who reported the bug:
     "Just wanted to circle back here — we've identified the root cause
      and pushed a fix. Apologies again for the inconvenience. Let me
      know if you have any other issues, no problem at all!"

Skill:

       ### Plain restatement
       - The bug is fixed.
       - You're apologizing.
       - You're inviting more reports.

       ### Landing prediction

       | Read | Probability | Signals |
       |------|-------------|---------|
       | Direct/clear | Low | The fix is buried in corporate phrasing |
       | Cold or curt | Low | None |
       | Passive-aggressive | Low | None |
       | Over-apologetic | Medium | "Apologies again" + "no problem at all!" is double-apologizing |
       | Warm/collaborative | Medium | The intent lands but the phrasing is over-cushioned |

       ### Rewrite suggestions

       **Keep:** the apology — one is warranted.

       **Soften:** nothing.

       **Strengthen:** lead with the fix. "Fixed and deployed — the
       root cause was [thing]. Apologies for the impact. If you spot
       anything else, send it our way." Fewer words, customer gets the
       answer in the first sentence, the apology lands once instead
       of twice.
```

## Internals

The skill follows a fixed three-section output:

1. **Plain restatement** — one paragraph or bullets, no interpretation.
2. **Landing prediction** — markdown table with the five mandatory rows (direct/clear, cold/curt, passive-aggressive, over-apologetic, warm/collaborative) using Low/Medium/High bands, plus relationship-specific rows. Signals column cites specific phrases.
3. **Rewrite suggestions** — Keep / Soften / Strengthen, with optional full rewrite on request.

For non-trivial drafts (>3 sentences, signs of writer anxiety, weighty recipient), the skill invokes [clarity-council](../clarity-council/) in `persona_consult` mode with `psychologist`. Trivial drafts run inline.

Hard constraints: preserve the writer's voice; don't rewrite the whole draft unless asked; don't strip directness in the name of politeness; don't add emojis.

## FAQ

**Q: What if my draft is actually fine?**
A: The landing prediction will show that — Direct/clear High, everything else Low — and the rewrite section will say "Keep all, no changes needed."

**Q: Will it tell me if I'm being too blunt?**
A: Yes, but it will also flag if you're being *not blunt enough*. Both are calibration failures.

**Q: How is this different from break-it-down?**
A: Break-it-down decodes a message you received. Tone-check predicts how a message you wrote will be received. Same lens, opposite direction.

**Q: Can it preserve my voice if I ask for a full rewrite?**
A: Yes. The rewrite swaps phrases, not personality. If your normal register is terse and direct, the rewrite stays terse and direct.

## Related skills

- **[break-it-down](../break-it-down/)** — the inverse: decoding incoming messages.
- **[writing-apology-calibrator](../writing-apology-calibrator/)** — narrower sibling specifically for apology drafts.
- **[writing-social-script](../writing-social-script/)** — when you don't have a draft yet, but you need a script for a specific scenario.
- **[writing-cold-open](../writing-cold-open/)** — when you can't get past the first sentence.
- **[clarity-council](../clarity-council/)** — the psychologist persona is the engine behind the landing prediction.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full output format and council wiring)
