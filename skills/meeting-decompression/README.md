# Meeting Decompression

A post-meeting sorter. Dump everything that happened in the meeting; the skill separates facts and decisions from action items from social ambiguities, and — critically — sorts the social ambiguities into "worth following up on" vs "rumination noise that's RSD, not data." Especially useful after masking-heavy meetings where the cognitive cost is paid afterward.

## Why this exists

A meeting ends and the brain is doing three jobs at once: extracting what was decided, listing what you have to do, and replaying the social moments — usually the moment you said "um" three times in a row, or the moment your manager glanced at their phone while you were talking. The three jobs don't separate on their own; they interfere with each other until you can't tell whether the awkward pause was meaningful or whether you actually committed to something or whether someone is mad at you. This skill separates them so each gets the right kind of attention: facts get archived, action items get scheduled, and social moments get sorted into "follow up" or "let go." The third bucket is where the most value usually lives — distinguishing RSD-flavored worry from a real social signal worth addressing.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "meeting decompression"
  - "process this meeting"
  - "what just happened"
  - "decompress"
  - "after meeting"
  - "I think I said something weird"
- Running the slash command: `/meeting-decompression`

The skill always invokes [clarity-council](../clarity-council/) with `psychologist + personal-assistant` — psychologist sorts the social ambiguities, personal-assistant handles the action items.

## What it does

The skill produces four sections: (1) what happened — neutral, evidence-only facts and decisions; (2) action items table with owner / action / due / source; (3) social moments split into "worth following up on" (with a specific follow-up line) and "worth letting go of" (with the reason it's noise); (4) a one-paragraph decompression note that names what the user did well and is probably not crediting themselves for. The council session is mandatory: personal-assistant for the action items, psychologist for the social-moment sort.

### Inputs

- **Meeting type** — 1:1, team standup, customer call, interview, etc.
- **The dump** — free-form, however long.
- **Stuck point** (optional) — the specific moment the brain is replaying.

### Outputs

- A four-section markdown decomp with sorted social moments and action items.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: meeting decompression. just had my weekly 1:1 with my manager.
     pretty sure I rambled when they asked about Q3 priorities, and
     they said "we should think about your scope" which I can't tell
     if that's good or bad. Also I think I committed to something
     about the dashboard project but I'm fuzzy.

Skill: (asks for meeting type, dump, stuck point if any)

You: (provides more detail on the dump)

Skill: (council session)

       ### What happened
       - Reviewed last week's tickets — no blockers flagged.
       - Discussed Q3 priorities; you outlined the migration work
         and the dashboard project.
       - Manager said "we should think about your scope" in the
         context of Q3.
       - You agreed to send a summary of dashboard project status
         by EOW.
       - Meeting ended on time.

       ### Action items

       | Owner | Action | Due | Source |
       |---|---|---|---|
       | **You** | Send dashboard project status summary | Friday | Direct ask in meeting |

       ### Social moments — sort

       **Worth following up on:**
       - "We should think about your scope" is genuinely
         ambiguous. Could mean scope expansion (good), scope
         narrowing (neutral or concerning), or "let's revisit
         what you own." **Follow-up:** in next week's 1:1, ask
         "you mentioned thinking about my scope last week — what
         were you thinking?" Don't email. The phrasing was
         exploratory, not prepared; a written reply will read as
         heavier than they meant.

       **Worth letting go of:**
       - The rambling on Q3 priorities. They asked an open
         question, you gave a long answer, they took notes. That
         is the meeting working as intended. Long answers to open
         questions are not "rambling," they're "answering." This
         is RSD reading meeting silence as judgment.

       ### Decompression note
       You handled an ambiguous scope comment without immediately
       asking for clarification, which is what a less-experienced
       version of you would have done (and would have come across
       as anxious). You let it sit, took the action item, and now
       have a structured plan to follow up next week. That's the
       right move in the room and the right move now.
```

## Getting the most out of it

- **Dump everything, fast.** The skill works on raw content. Don't pre-edit. The "ums" and "and then they said" pieces are the data.
- **Name the stuck point.** If there's one specific moment your brain is replaying, say so. The skill will sort it explicitly into the follow-up or let-go bucket.
- **Trust the "let go" sort, but verify the "follow up."** The let-go items are usually RSD noise the skill caught correctly. The follow-up items are worth a sanity check before acting — the skill is conservative there.
- **Run it within an hour of the meeting.** The dump is highest fidelity right after; by tomorrow your brain has already smoothed the rough edges and you'll lose the data.

## Anti-patterns

- ❌ **"Don't worry about it."** That's not sorting, that's dismissing. The worry is data — the skill sorts it.
- ❌ **Over-validating the worst-case** social read just to seem supportive.
- ❌ **Producing a meeting summary as if the user is a stenographer.** They were *in* the meeting; they don't need it dictated back to them.
- ❌ **Lecturing about masking or burnout.** The user is decompressing, not learning.
- ❌ **Adding new action items** the user didn't actually commit to. The action items list is conservative.

## Examples

### Example: After a customer call that went sideways

```text
You: meeting decompression. customer call about the integration
     issues, they were not happy. I think I conceded too much. Said
     yes to things I shouldn't have.

Skill:

       ### What happened
       - Customer raised three issues: SSO timeout, missing webhook
         on order cancellation, slow report export.
       - You acknowledged all three as real.
       - You committed to: a fix for the SSO timeout in this
         sprint, investigating the missing webhook, and adding the
         report export to the next planning cycle.
       - Customer asked for a written summary by Wednesday.

       ### Action items

       | Owner | Action | Due | Source |
       |---|---|---|---|
       | **You** | Send written summary of agreed actions | Wed | Customer ask |
       | **You** | SSO timeout fix scoped and assigned | This sprint | Your commitment |
       | **You** | Investigate missing webhook on order cancel | Before next call | Your commitment |

       ### Social moments — sort

       **Worth following up on:**
       - You committed to a sprint timeline on the SSO fix
         without checking team capacity. That's a real concession
         worth retroactively bounding. **Follow-up:** ping your
         tech lead today: "I told a customer SSO timeout fix this
         sprint — what's the actual scope? May need to renegotiate
         the timeline."

       **Worth letting go of:**
       - The feeling that you conceded "too much" overall. You
         conceded to the things that were genuinely true. The
         report export went to the next planning cycle, not this
         one — that's not a concession, that's normal prioritization.
         The discomfort is from being on the receiving end of an
         unhappy customer, not from anything you actually
         mishandled.

       ### Decompression note
       Three concrete issues went in, three calibrated commitments
       came out. The SSO one needs a quick retro-bound with your
       lead, but the call itself did what it needed to do. A less
       grounded version of you would have promised all three in
       this sprint; you didn't.
```

### Example: After a team standup where you stayed quiet

```text
You: decompress. I didn't say much in standup. I think people
     noticed. I had nothing to update on because the ticket I'm
     working on is huge and I'm only partway in.

Skill:

       ### What happened
       - Standup ran 12 minutes.
       - Six teammates gave updates.
       - You said "still on the auth refactor, no blockers."
       - No one asked follow-up questions.
       - Meeting ended on time.

       ### Action items
       (none — no commitments made)

       ### Social moments — sort

       **Worth following up on:**
       (none)

       **Worth letting go of:**
       - "I think people noticed I didn't say much." Standup is
         not a performance — short updates are the *correct* shape
         for a small in-progress increment. The teammates who gave
         long updates probably had concrete things to report; you
         didn't. That's not a flaw, that's accurate signaling.

       ### Decompression note
       "Still on X, no blockers" is the canonical right answer
       when "still on X, no blockers" is true. You didn't pad,
       which is what would have actually been noticeable. Save the
       longer update for when you have something concrete to ship
       or a real blocker to surface.
```

## Internals

The clarity-council session uses `[psychologist, personal-assistant]`:

- The **personal-assistant** extracts action items and identifies any commitments made without explicit owners.
- The **psychologist** sorts social moments into worth-following-up vs. RSD-noise, with explicit reasoning for each placement.

The "worth letting go" sort is where the skill is most opinionated — it will explicitly name RSD patterns when it sees them, and it will not validate worst-case readings just to be supportive. The "worth following up on" sort is conservative — it includes only items with concrete evidence in the dump, not items the user is worried about.

Hard constraints: never say "don't worry about it"; never validate worst-case social readings; distinguish rumination from legitimate follow-up; do not produce a stenographer-style meeting summary; do not invent action items not actually committed.

## FAQ

**Q: What if I genuinely did mess up?**
A: It'll be in the "worth following up on" bucket with a concrete repair action. The skill doesn't pretend everything is fine — it sorts honestly.

**Q: What if I don't remember enough to dump?**
A: Dump what you have. The skill works on whatever's there. If the only thing you remember is the one moment that's replaying, dump that — it'll get sorted explicitly.

**Q: Can this replace meeting notes?**
A: No. Use it for the decompression after; use real notes for the substance. The "what happened" section is reconstructed from your dump, not authoritative.

**Q: Should I run this for every meeting?**
A: Only when there's something to sort. Quiet, low-load meetings don't need decompression. Save it for the masking-heavy ones, the customer-facing ones, and the 1:1s where you're tracking ambiguous signals.

## Related skills

- **[writing-rejection-sensitivity-check](../writing-rejection-sensitivity-check/)** — for when the trigger is a single message, not a whole meeting.
- **[break-it-down](../break-it-down/)** — for decoding a specific phrase someone used in the meeting that's nagging at you.
- **[energy-budget](../energy-budget/)** — pairs well when post-meeting decompression reveals a day that's tipping toward overload.
- **[clarity-council](../clarity-council/)** — the psychologist + personal-assistant pair is the engine.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (council wiring and output format)
