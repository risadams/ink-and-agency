# Writing Apology Calibrator

A narrow sibling to [writing-tone-check](../writing-tone-check/), specialized for apology drafts. Paste a drafted apology and get back a line-by-line annotation (keep / soften / cut / add), a calibrated rewrite, and a one-line read on whether the apology was even warranted in the first place. Strips reflexive over-apology while keeping the parts that are genuine accountability.

## Why this exists

There's a difference between accountability and over-apology. Accountability lands cleanly, repairs trust, and ends the matter. Over-apology lands awkwardly, forces the recipient to reassure the apologizer, and prolongs the discomfort for everyone. Most first drafts of apologies — especially from people trained by upbringing, neurodivergence, or past blowback to apologize reflexively — over-shoot. They apologize for the existence of the message itself. They apologize for taking up space. They apologize for things they didn't cause. The apology, intended to repair, actually adds friction. This skill calibrates: keep what's warranted, cut what's reflexive, and end up with an apology that does its job in fewer words.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "calibrate this apology"
  - "am I over-apologizing"
  - "apology check"
  - "did I say sorry too much"
  - "is this too much"
- Running the slash command: `/writing-apology-calibrator`

The skill always invokes [clarity-council](../clarity-council/) with `psychologist + devils-advocate` — same as [writing-rejection-sensitivity-check](../writing-rejection-sensitivity-check/), the second perspective is the value.

## What it does

The skill produces four sections: (1) was an apology needed — Yes (warranted) / Yes (proportional courtesy) / No (reflexive — you didn't owe one); (2) line-by-line annotation of the draft with Keep / Soften / Cut / Add tags; (3) calibrated rewrite applying the annotations in the user's voice; (4) why the cuts — one short paragraph naming the pattern (not the lines) so the user can notice it next time. The council session is mandatory: psychologist for the reflexive-vs-warranted sort, devils-advocate to stress-test both directions.

### Inputs

- **Apology draft** — pasted.
- **What actually happened** — one sentence, not the apology, the event.
- **Recipient + relationship.**

### Outputs

- A four-section markdown analysis with the calibrated rewrite.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: calibrate this. drafted apology to my coworker for missing
     our planned pairing session yesterday:

     "Hi Mara, I'm SO sorry about missing our pair session yesterday.
     I feel really bad — I know your time is valuable and I totally
     dropped the ball. There's no excuse, I should have set a reminder.
     I hope this didn't mess up your day too badly. Sorry again. Let
     me know if you ever want to try to reschedule, no pressure at
     all if you'd rather not!"

Skill: (asks: what actually happened, relationship)

You: I forgot the pair session, was deep in another task. She didn't
     reach out to me — found out from the calendar. Coworker, peer
     relationship, we pair every couple weeks.

Skill: (council session)

       ### Was an apology needed?
       **Yes (proportional courtesy)** — you missed a scheduled
       commitment with a peer. A short, clean apology is warranted.
       Not a big one.

       ### Line-by-line annotation
       - "Hi Mara, I'm **SO sorry** about missing our pair session
         yesterday." → **Soften** — "SO sorry" is one level too
         loud for a missed pair session. "Sorry" without the
         caps-emphasis is right.
       - "I feel really bad" → **Cut** — your feelings aren't her
         concern; this asks her to soothe you.
       - "I know your time is valuable" → **Cut** — implicit
         flattery, reads as performative.
       - "I totally dropped the ball" → **Soften** — "I forgot" is
         the same content with less self-flagellation.
       - "There's no excuse, I should have set a reminder" →
         **Soften** — "I'll set a reminder for next time" is
         forward-facing and concrete; "there's no excuse" is
         self-attack disguised as accountability.
       - "I hope this didn't mess up your day too badly" → **Cut**
         — assumes harm that may not have happened; invites her to
         reassure you.
       - "Sorry again" → **Cut** — second apology in 50 words.
       - "Let me know if you ever want to try to reschedule, no
         pressure at all if you'd rather not!" → **Soften** — the
         "no pressure at all" undermines the offer. Just offer to
         reschedule.

       ### Calibrated rewrite
       > "Hi Mara — sorry I missed our pair session yesterday, I
       >  forgot. I'll set a reminder for next time. Want to
       >  reschedule for next week?"

       Same content. Repairs the trust without dragging her into
       reassuring you.

       ### Why the cuts
       The original draft was apologizing for the *existence of
       the message* in addition to apologizing for the miss. The
       double-sorry, the "I feel really bad," and the "I hope this
       didn't mess up your day" are all reflexive — they push the
       emotional labor of resolution onto her. Calibrated apology
       takes the responsibility cleanly, names a forward fix, and
       ends.
```

## Getting the most out of it

- **Be honest about what happened.** "I missed our meeting" vs "I missed our meeting after also being late twice this month" calibrate to different apologies. The skill needs the real event, not the softened version.
- **Pay attention to the "Was an apology needed" verdict.** A surprising fraction of drafts come back as "No (reflexive)" — meaning the user is apologizing for something they didn't actually do wrong. Take that read seriously; it's the most useful output.
- **Use the rewrite as a draft, not a paste.** The skill preserves your voice but adapt the final to match your normal phrasing exactly.
- **Notice the pattern named in "Why the cuts."** Repeated drafts will surface the same pattern (often: apologizing for the existence of the message itself, or apologizing in advance for taking up space). Naming it once helps notice it next time.

## Anti-patterns

- ❌ **Stripping accountability where it's warranted.** The goal is calibration, not minimization. If you genuinely caused harm, the apology stays.
- ❌ **Adding burden-shifting reassurances ("don't worry about it!", "no big deal!").** That's just a different shape of the same problem.
- ❌ **Producing a robotic "I take responsibility for X. Going forward I will Y."** That's a corporate-policy apology, not a personal one. Calibration preserves warmth where warmth was warranted.
- ❌ **Lecturing about over-apologizing as a pattern.** One sentence in "why the cuts" is enough.
- ❌ **Invalidating the instinct to apologize.** The instinct is fine; the calibration is the work.

## Examples

### Example: No apology was actually needed

```text
You: calibrate. drafted apology to my manager for being 6 minutes
     late to our 1:1:

     "Hey, sorry I was late! Got pulled into another meeting that
     ran over. Won't happen again, my fault for not building in
     buffer. Apologies!"

Skill:

       ### Was an apology needed?
       **No (reflexive — you didn't owe one)**

       Being 6 minutes late to a 1:1 because the previous meeting
       ran over is not an apology event. It's a normal occurrence
       between busy people. Apologizing for it teaches everyone
       (including yourself) that this normal occurrence is a
       failure, which is both inaccurate and exhausting.

       Skip the apology entirely. The right opening line is just
       "Hey, sorry for the delay" said in passing, or nothing at
       all if you were only 6 minutes late.

       If you want to send a message anyway: "Hey, finally free —
       coming now" is sufficient.

       ### Why
       Your draft contained two apologies, one self-blame ("my
       fault for not building in buffer"), and a forward-commitment
       ("won't happen again") for a thing that absolutely will
       happen again because that's how meetings work. The draft
       is overcorrecting against a non-failure.
```

The skill is willing to say "don't send this" when an apology was reflexive.

### Example: A warranted apology that needs less calibration

```text
You: calibrate. I shipped a bug to prod that broke checkout for an
     hour:

     "Hey team — I shipped a bug to prod about an hour ago that
     broke checkout. I'm really sorry, this is on me. I should
     have tested the edge case I missed. The fix is deploying now.
     I'll write up a postmortem tomorrow. Apologies for the
     disruption."

Skill:

       ### Was an apology needed?
       **Yes (warranted)** — production breakage that affected
       customers. Apology is appropriate. The draft is mostly
       right; minor tightening only.

       ### Line-by-line annotation
       - "Hey team — I shipped a bug to prod about an hour ago
         that broke checkout." → **Keep** — clean factual lead.
       - "I'm really sorry, this is on me." → **Keep** — owns it
         without grovel.
       - "I should have tested the edge case I missed." → **Keep**
         — names the specific failure, useful for the postmortem
         and for the team's mental model.
       - "The fix is deploying now." → **Keep** — concrete action.
       - "I'll write up a postmortem tomorrow." → **Keep** —
         forward action.
       - "Apologies for the disruption." → **Cut** — second
         apology, redundant with the "I'm really sorry" earlier.

       ### Calibrated rewrite
       > "Hey team — I shipped a bug to prod about an hour ago
       >  that broke checkout. I'm really sorry, this is on me.
       >  I should have tested the edge case I missed. The fix is
       >  deploying now. I'll write up a postmortem tomorrow."

       ### Why the cuts
       Single change: the trailing "apologies for the disruption"
       is a second apology that adds nothing and signals
       uncertainty about whether the first apology landed. One
       apology lands; two apologies sound like asking for
       forgiveness. The rest of the draft is already calibrated —
       owns the cause, names the fix, commits to the postmortem.
       This is what a warranted apology looks like.
```

The skill makes only minimal cuts when most of the draft is already calibrated.

## Internals

The clarity-council session uses `[psychologist, devils-advocate]`:

- The **psychologist** identifies the reflexive vs. warranted patterns in each line and names the cognitive pattern when over-apology is operating.
- The **devils-advocate** stress-tests both directions — pushes back if accountability is being stripped from a warranted apology, and pushes back if reflexive over-apology is being preserved as "the user's voice."

The four annotation tags are deliberately limited:
- **Keep:** warranted, lands cleanly
- **Soften:** over-strong, suggested replacement
- **Cut:** reflexive, remove entirely
- **Add:** rare, used only when a concrete repair or forward action is missing

Hard constraints: do not strip accountability where warranted; do not flatten warmth into clinical detachment; do not add "no worries!" style burden-shifting; do not produce a robotic policy-style apology; preserve the user's voice in the rewrite.

## FAQ

**Q: What if the verdict comes back "No apology needed" but I still feel like I should send one?**
A: That's data — the instinct to apologize for things you didn't cause is a pattern worth noticing. The skill will tell you when an apology isn't owed, but it won't stop you from sending one. Sometimes the apology is for your own peace of mind, which is allowed; just notice it.

**Q: Can I keep my voice if I use the rewrite?**
A: Yes. The skill swaps phrases, not personality. If you normally write terse, the rewrite stays terse. If you're warm, it stays warm.

**Q: What if the recipient *expects* over-apology (e.g., in some workplace cultures)?**
A: Name the cultural context when invoking and the calibration will adjust the floor. In high-courtesy cultures, "Yes (proportional courtesy)" replaces "No (reflexive)" for many drafts.

**Q: How is this different from writing-tone-check?**
A: Tone-check is general-purpose pre-send review. Apology-calibrator is specialized for the apology shape — the annotation tags, the rewrite focus, and the "was an apology even needed" verdict are apology-specific.

## Related skills

- **[writing-tone-check](../writing-tone-check/)** — general-purpose pre-send tone reviewer; use that for non-apology drafts.
- **[writing-rejection-sensitivity-check](../writing-rejection-sensitivity-check/)** — for the *receiving* end: a message that landed badly and you're not sure if it warranted the sting.
- **[break-it-down](../break-it-down/)** — for decoding the message you're responding to before drafting your apology.
- **[writing-social-script](../writing-social-script/)** — if you don't have a draft yet, use this for scripted apology shapes.
- **[clarity-council](../clarity-council/)** — the psychologist + devils-advocate engine.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (annotation tags, council wiring, output format)
