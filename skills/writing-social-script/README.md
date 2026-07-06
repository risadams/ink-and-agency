# Writing Social Script

A literal-script generator for social situations you're dreading. You know what you need to say — decline the meeting, ask for the extension, follow up on the silence, leave the party early, set the boundary. You can't find the words. This skill produces three phrasings (direct / neutral / softened), each with a predicted reaction and a follow-up line, plus an exit line for if it goes sideways.

## Why this exists

A surprising amount of social friction is just the activation cost of word-finding under pressure. Once the script exists, the action is easy; without it, the action stalls indefinitely. Masking-heavy folks (autistic adults, anxious-attached people, anyone who's been burned for saying it wrong) often have the answer in their head but can't translate it into something deliverable in one breath. This skill is the translator. It does *not* replace genuine human communication — it produces a script you can adapt, deliver, or use as scaffolding.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "script for ..."
  - "help me say ..."
  - "how do I tell them ..."
  - "I need to ask ..."
  - "I need to decline ..."
  - "social script"
- Running the slash command: `/writing-social-script`

The skill always asks three setup questions before writing.

## What it does

The skill produces a one-line scenario restatement, then three phrasings — direct, neutral, softened — each with: the script (deliverable in one breath), a predicted recipient reaction, and a follow-up line for after their reaction. It closes with a single exit line for if the conversation escalates. For non-trivial scripts (emotionally loaded, weighty recipient) it invokes [clarity-council](../clarity-council/) with `psychologist + customer-advocate`. The psychologist handles delivery and likely recipient response; the customer-advocate ensures the script actually serves the user's goal, not just defuses the moment.

### Inputs

- **Scenario** — what the user needs to say.
- **Recipient + relationship** — manager, partner, friend, stranger, etc.
- **Goal** — what needs to be true after this conversation ends.
- **Channel** — in-person, phone, email, text, Slack.

### Outputs

- Scenario restatement.
- Three scripts (direct / neutral / softened) with predicted reactions and follow-up lines.
- One exit line.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: script for telling my manager I can't take the on-call rotation
     next week because of a family thing

Skill: (asks: who, goal, channel)

You: my manager, goal is they reassign without making it a thing,
     in our 1:1 tomorrow

Skill:

       ### Scenario
       Declining next week's on-call to your manager in tomorrow's
       1:1, hoping to get it reassigned without a discussion.

       ### Three phrasings

       **Direct:**
       > "Hey — I can't take on-call next week, family thing. Can we
       >  swap me out?"
       *Likely reaction:* "Sure, who can cover?"
       *Follow-up line:* "I'll ping the team channel and find a swap."

       **Neutral:**
       > "Quick one — I need to be off the on-call rotation next week.
       >  Want me to find my own swap or do you want to reassign?"
       *Likely reaction:* "Find your own swap, just let me know who."
       *Follow-up line:* "Will do. I'll have a name by EOD."

       **Softened:**
       > "Something came up at home for next week — would it be okay
       >  if I traded my on-call shift with someone? I can ask around."
       *Likely reaction:* "Of course, no problem."
       *Follow-up line:* "Thanks, I'll take care of the swap."

       ### Exit line
       If they push back on why: "It's a family thing, I'd rather not
       get into details. I'll cover a future shift to balance it."
```

## Getting the most out of it

- **Pick the phrasing that matches your actual register, not the one that feels safest.** Softened is the trap for over-apologetic writers — direct often serves you better and lands fine.
- **Use the follow-up line.** The scripts are written so the first line lands clean; the follow-up keeps the conversation moving without you having to improvise.
- **Memorize the exit line separately.** If the conversation goes sideways, the exit line is what you reach for. Worth committing to muscle memory before the conversation starts.
- **Adapt to your voice.** The scripts are scaffolding — swap words to match how you actually talk. The shape (lead with the ask, end with action) is the durable part.

## Anti-patterns

- ❌ **Producing paragraphs.** These are scripts. If you can't deliver it in one breath, it's not a script, it's a speech.
- ❌ **Reflexive "I'm sorry but..."** unless an apology is actually warranted. Most "I'm sorry"s in this category are activation lubricant, not real apology.
- ❌ **Fake warmth.** "Hope you're well!" is not in your register — don't pretend it is.
- ❌ **More than three phrasings.** More options is more paralysis. Stop at three.
- ❌ **Predicting the recipient will react badly** when there's no evidence. The reaction prediction should be neutral by default.

## Examples

### Example: Asking for a deadline extension

```text
You: script for asking my client for a one-week extension on the
     report. We agreed Friday. I'm not going to make it. Email,
     they're a longtime client, goal is they say yes without losing
     trust.

Skill:

       ### Scenario
       Asking a longtime client by email for a one-week extension on
       the report due Friday. Goal: yes without trust damage.

       ### Three phrasings

       **Direct:**
       > "Quick update: the report needs another week — I want to
       >  ship something solid, not rushed. New target: next Friday.
       >  Let me know if that creates any downstream problems on
       >  your side."
       *Likely reaction:* "Works, thanks for the heads up."
       *Follow-up line:* "Appreciate it. I'll send a draft midweek so
       you can review before final."

       **Neutral:**
       > "Hi — I'm pushing the report to next Friday so I can do
       >  it right. Wanted to flag now rather than the day of. Does
       >  that work?"
       *Likely reaction:* "Sure, thanks for letting me know early."
       *Follow-up line:* "Thanks. I'll send a midweek draft."

       **Softened:**
       > "Hi — wanted to give you a heads up that I'm going to need
       >  an extra week on the report to make sure it's right. Would
       >  next Friday work on your end? Happy to adjust if not."
       *Likely reaction:* "Next Friday is fine."
       *Follow-up line:* "Thanks for the flexibility. Midweek draft
       coming your way."

       ### Exit line
       If they push back on the timeline: "Understood — what's the
       hardest constraint on your end? I'll see what I can do to
       split the difference."
```

### Example: Leaving a social event early

```text
You: I'm at a dinner and I need to leave in 30 min without making
     it weird. Script for telling the host.

Skill:

       ### Scenario
       Telling your host you're leaving the dinner in 30 min, without
       creating a scene.

       ### Three phrasings

       **Direct:**
       > "Hey — I have to head out around 9. Wanted to give you a
       >  heads up so it's not abrupt."
       *Likely reaction:* "Aw, that's too bad — thanks for letting
       me know."
       *Follow-up line:* "Thanks for hosting, this was great."

       **Neutral:**
       > "I'm going to need to slip out around 9. Just wanted to flag
       >  early so I'm not weird about it later."
       *Likely reaction:* "No worries, glad you came."
       *Follow-up line:* "Yeah, really good to see you all. Thanks
       again."

       **Softened:**
       > "I've had such a good time but I'm going to need to head out
       >  around 9 — wanted to give you fair warning."
       *Likely reaction:* "Of course, thanks for coming!"
       *Follow-up line:* "Thanks for having me. Let's do this again."

       ### Exit line
       If they push to stay longer: "I wish I could — early start
       tomorrow. Let's plan something soon though."
```

## Internals

The skill always asks three setup questions before writing — recipient, goal, channel — because each one changes the script meaningfully. For non-trivial scripts it invokes [clarity-council](../clarity-council/) in `council_consult` mode with `[psychologist, customer-advocate]`:

- The psychologist handles the recipient's likely first reaction and the social cost of each phrasing.
- The customer-advocate keeps the script anchored to the user's goal, not just to defusing the moment.

Hard constraints: no corporate jargon, no over-apologizing, no fake warmth, scripts must be deliverable in one breath, exactly three phrasings, exactly one exit line.

## FAQ

**Q: Why three phrasings and not five?**
A: More options is more paralysis. Three is enough to span the register range (direct → softened) without inducing decision overload.

**Q: What if none of the three feel right?**
A: Ask the skill to recalibrate the register — e.g., "all three are too warm." It'll regenerate with a shifted center.

**Q: Will it write a whole conversation?**
A: No. It writes the opening, the predicted reaction, and the follow-up line. Beyond that you're improvising.

**Q: Can I use this for written messages, not just spoken?**
A: Yes — channel is one of the setup questions and changes the phrasing accordingly. Email scripts read differently than spoken scripts.

**Q: When should I use this vs. writing-tone-check?**
A: Use writing-social-script when you don't have a draft yet and need help finding words. Use [writing-tone-check](../writing-tone-check/) when you have a draft and want to know how it will land.

## Related skills

- **[writing-tone-check](../writing-tone-check/)** — for when you already have a draft.
- **[writing-cold-open](../writing-cold-open/)** — for when you just need the first sentence of a longer message.
- **[writing-apology-calibrator](../writing-apology-calibrator/)** — for apology drafts specifically.
- **[break-it-down](../break-it-down/)** — for decoding what *they* meant before you reply.
- **[clarity-council](../clarity-council/)** — the personas powering the recipient prediction.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full output format and council wiring)
