# Writing Cold Open

A first-sentence generator for when you can't get past the blank cursor. You know what the message needs to say. You cannot type the opening word. The skill asks three short questions, produces three openings (direct / warm / contextual), labels each with who it works best for, and then steps out — you write the rest. It does **not** draft the whole message.

## Why this exists

A surprising amount of writing-friction is just the activation barrier of the first sentence. Once typing has started, the rest usually flows; the blank cursor is the specific obstacle. This is especially true after a long break, before sensitive messages, or any time the brain is trying to over-plan the opening. The skill collapses the blank-cursor problem into a pick-one choice: three openings at three registers, deliverable verbatim or as scaffolding. Sibling to [task-initiation](../task-initiation/) (which handles non-writing stalls) and [writing-social-script](../writing-social-script/) (which writes the whole thing) — this one is narrower, just the opener.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "cold open"
  - "help me start this message"
  - "how do I begin"
  - "stuck on opening"
  - "first sentence"
  - "what do I even say first"
  - "I've been staring at this message"
- Running the slash command: `/writing-cold-open`

The skill normally runs inline. For high-stakes openers (cold outreach to a stranger, sensitive subject, message drafted-and-deleted multiple times) it invokes [clarity-council](../clarity-council/) with the `psychologist` persona for a landing-prediction per opening.

## What it does

The skill asks three setup questions (message goal in one sentence, recipient + relationship, channel), then produces three opening sentences: a **direct** opening (gets to the point in the first sentence), a **warm** opening (one beat of relational acknowledgment then pivots), and a **contextual** opening (names the trigger or shared context first). Each is labeled with who it works best for. The skill ends with a literal nudge — "pick one, paste it in, keep typing" — and exits. It does not write past the first sentence, does not include a sign-off, does not offer to draft the rest unless asked.

### Inputs

- **Message goal** — one sentence; the actual ask or update.
- **Recipient + relationship.**
- **Channel** — email, Slack, text, etc.

### Outputs

- Three opening sentences with register labels.
- One nudge line.

### External systems used

- None. The optional clarity-council call is local.

## How to use it

A typical session looks like this:

```text
You: cold open. emailing a former colleague I haven't talked to in
     2 years to ask if they'd be a reference for me.

Skill: (asks goal, relationship, channel)

You:
  1. ask them to be a reference for a job I'm applying to
  2. former coworker, friendly but we lost touch
  3. email

Skill:

       ### Three openings

       **Direct** — gets to the point in the first sentence:
       > "Hi Jamie — long time. I'm applying for a senior eng
       >  role at Foo Co and wondered if you'd be willing to be
       >  a reference."
       *Works best for:* you and Jamie are both people who
       prefer no preamble; they'll appreciate not having to
       wade through small talk before the ask.

       **Warm** — one beat of relational acknowledgment, then
       pivots:
       > "Hi Jamie — it's been a while; I hope things have been
       >  good. Reaching out because I'm in the middle of a job
       >  search and was hoping I could ask a favor."
       *Works best for:* Jamie historically responded warmly to
       relational openers, or if the ask might catch them off
       guard.

       **Contextual** — names the trigger first:
       > "Hi Jamie — I was rereading some of our old design
       >  notes from the migration project recently and it
       >  reminded me how much I learned from working with you.
       >  I'm applying for a new role and wondered if you'd
       >  consider being a reference."
       *Works best for:* you actually have a specific shared
       memory to name (don't fake it), and the ask feels like
       it needs a stronger relational bridge first.

       **Pick one. Paste it in. Keep typing.**
```

## Getting the most out of it

- **Answer the three questions terse.** "Goal in one sentence" — don't explain the backstory.
- **Pick the opening that matches your actual register, not the safest one.** "Direct" is the right pick more often than people think; the worry about being too blunt is usually larger than the actual landing risk.
- **Don't ask the skill to keep writing.** That's the trap. The skill exists to get you past the opener; once you've typed it, the next sentence is yours.
- **Adapt the phrasing.** The openings are scaffolding. Swap two words to match how you actually talk — but keep the shape (e.g., direct lead, no preamble) because the shape is the durable part.

## Anti-patterns

- ❌ **Producing more than three openings.** More options is more paralysis. Stop at three.
- ❌ **Writing past the first sentence.** That's not what this skill is for — route to [writing-social-script](../writing-social-script/) or [writing-tone-check](../writing-tone-check/) if you need a whole draft reviewed or generated.
- ❌ **"I hope this email finds you well."** Template phrase that adds nothing and signals the writer doesn't know what to say. The skill won't produce it.
- ❌ **Including a sign-off.** You only need the opener.
- ❌ **"Are you sure?" after generating.** No interrogation. The user came here to be unstuck.
- ❌ **Editorializing about how the message should go.** Just produce the openers.

## Examples

### Example: Slack DM to your boss about something awkward

```text
You: cold open. need to DM my boss to tell him I disagreed with a
     call he made in our team meeting earlier and I want to push
     back. slack, my manager, we have a good relationship.

Skill:

       ### Three openings

       **Direct:**
       > "Hey — wanted to push back on the call to drop the
       >  caching work. Got 5 min?"
       *Works best for:* you and your manager prefer to handle
       disagreement quickly without preamble.

       **Warm:**
       > "Hey — quick one. Been turning over the caching
       >  decision and I think I land somewhere different.
       >  Mind if I make the case?"
       *Works best for:* preserving a relational softness while
       still flagging disagreement.

       **Contextual:**
       > "Hey — re: the caching call in team meeting. Sat with
       >  it after and I'm not actually on board. Want to talk
       >  through?"
       *Works best for:* the disagreement needs to be anchored
       to the specific meeting and decision, so there's no
       confusion about what you're pushing back on.

       **Pick one. Paste it in. Keep typing.**
```

### Example: Cold outreach to a stranger

```text
You: cold open. cold email to someone whose work I admire — I'd
     like to ask if they'd do a 30 min call about how they got
     into their field.

Skill: (invokes council — high-stakes opener)

       ### Three openings

       **Direct:**
       > "Hi — I'm a long-time admirer of your work on X and
       >  would love to ask if you'd be open to a 30-min call
       >  about how you got into the field."
       *Works best for:* their bio/online presence suggests
       they value people who get to the point. Many busy
       people prefer this.
       *Likely to land:* well — short, specific, includes the
       ask up front.

       **Warm:**
       > "Hi — this is out of the blue, but your essay on Y has
       >  shaped how I think about [the work] more than almost
       >  anything I've read in the last few years. Wondering if
       >  you'd be open to a 30-min call."
       *Works best for:* you actually have a specific piece of
       theirs that mattered to you (don't fake it). Lands
       warmly without feeling sycophantic.
       *Likely to land:* well, if the specific reference is
       real.

       **Contextual:**
       > "Hi — I'm currently [thing they might find relevant
       >  about you] and trying to figure out how to make the
       >  jump into [their field]. Your trajectory looks like
       >  one of the closest analogues I've found. Would you be
       >  open to a 30-min call?"
       *Works best for:* you have a concrete reason your
       trajectory and theirs share shape. Gives them a reason
       to care about the ask beyond goodwill.
       *Likely to land:* well, when the analogy is real and
       specific.

       **Pick one. Paste it in. Keep typing.**
```

The council-augmented version adds landing predictions because the stakes are higher.

## Internals

For most invocations the skill runs inline — three openings, no debate, exit. For high-stakes openers (cold outreach to strangers, sensitive subject matter, drafts the user has deleted multiple times) it invokes [clarity-council](../clarity-council/) in `persona_consult` mode with `psychologist`, which adds a one-line landing prediction to each opening.

The three registers are deliberately the standard set:
- **Direct** is the under-used option for most writers; included by default to keep it on the menu.
- **Warm** is the over-used default for many writers; included so they can see the alternatives.
- **Contextual** is the highest-effort and highest-fit when the message needs anchoring.

Hard constraints: exactly three openings; first sentence only; no sign-off; no template phrases ("I hope this email finds you well"); no offer to draft the rest unless asked; no second-guessing the user.

## FAQ

**Q: What if none of the three feel right?**
A: Ask the skill to recalibrate the register — e.g., "all three are too warm" or "I need something even more direct." It'll regenerate with a shifted center.

**Q: Can I ask for subject lines?**
A: Yes, but only if you ask. By default the skill produces only the opening sentence — adding subject lines by default would defeat the point.

**Q: What if the message is really short and the opening is also the whole message?**
A: The skill will still produce three openings, and one of them is probably also the whole message. That's fine.

**Q: Why no sign-off?**
A: Sign-offs are easy. Openings are hard. The skill is for the hard part.

**Q: When should I use this vs. writing-social-script vs. writing-tone-check?**
A: Cold-open = stuck on the first sentence. Social-script = need a whole scripted message for a specific scenario. Tone-check = have a draft, want it reviewed.

## Related skills

- **[task-initiation](../task-initiation/)** — sibling for non-writing stalls. Same shape of output (one literal action / one literal sentence, then exit).
- **[writing-social-script](../writing-social-script/)** — for when you need the whole script, not just the opener.
- **[writing-tone-check](../writing-tone-check/)** — for when you have a draft and want to know how it lands.
- **[writing-apology-calibrator](../writing-apology-calibrator/)** — for apology drafts specifically.
- **[clarity-council](../clarity-council/)** — the psychologist persona is used for high-stakes openers.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (output format, council wiring for high-stakes mode)
