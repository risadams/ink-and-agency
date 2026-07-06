# Task Initiation

The "I can't start" skill. You know what to do. Your brain refuses to begin it. This skill asks three questions, produces **one literal physical action** that takes thirty seconds or less, and steps out. Not a plan. Not a breakdown. Not encouragement. Just the first move.

## Why this exists

Executive-function stalls are not motivation problems. The user already wants to do the task — that's why they're frustrated. The problem is *activation*: the brain cannot generate the first concrete physical action, so the task remains an abstract cloud and stays unstarted. Every additional decision (where to start, what to do first, how big a chunk to take on) makes the cloud bigger. The only thing that helps is collapsing the cloud into one specific finger-on-keyboard action small enough that the brain can't object to it. This skill does that collapse. Once the first action is done, momentum usually carries the next.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "I can't start"
  - "I'm stuck"
  - "help me begin"
  - "I keep avoiding this"
  - "task initiation"
  - "stuck on starting"
  - "just-start"
- Running the slash command: `/task-initiation`

The skill does **not** activate for "make me a plan" — for that, route to [request-refactor-plan](../request-refactor-plan/), [grill-me](../grill-me/), or [clarity-council](../clarity-council/).

## What it does

The skill asks three short questions (what's the task, what's the first physical place you'd interact with it, what's the smallest visible output that would count as started), then produces a single block: one literal action, ≤30 seconds, no decision points, no list of further steps. After the user reports "done", it produces the next ≤30-second action. Loop continues until the user says they have momentum or routes to a planning skill. **No council, ever** — speed is the whole point.

### Inputs

- **Task name** — one sentence.
- **Entry surface** — file, editor, email draft, terminal, notebook.
- **Smallest visible output** — what would mean you started.

### Outputs

- One literal physical action per turn, with an explicit "come back when done" handoff.

### External systems used

- None.

## How to use it

A typical session looks like this:

```text
You: task initiation. I need to write the design doc for the rate-
     limiter change and I've been opening and closing the file all
     morning.

Skill: (asks three questions in one shot)

You:
  1. write the rate-limiter design doc
  2. docs/design/rate-limiter-v2.md (already created, empty)
  3. just want a section header to exist so the file isn't blank

Skill:

       **Do this now (≤30 seconds):**
       Open docs/design/rate-limiter-v2.md. Type:

           # Rate Limiter v2 — Design

           ## Problem

       Save the file.

       **When you've done that, come back and say "done".**

You: done

Skill:

       **Do this now (≤30 seconds):**
       Under `## Problem`, type one sentence describing what's broken
       with the current rate limiter. Doesn't have to be good. One
       sentence. Save.

       **When you've done that, come back and say "done".**

You: done. ok i think i can keep going now

Skill: (acknowledges, exits)
```

## Getting the most out of it

- **Answer the three questions terse.** Don't explain. The skill works on shape, not on context.
- **Take the action immediately, while the skill output is still on screen.** If you read the action and then check Slack, the activation cost goes back up.
- **Come back and say "done", even if it took 5 seconds.** The "done" loop is part of the protocol — it builds the momentum the next action runs on.
- **Stop the loop the moment you have momentum.** Don't milk it for more steps. The skill exists to get you moving; once you're moving, get out of its way.

## Anti-patterns

- ❌ **Asking for a plan.** Wrong skill. The whole point is that the user doesn't need a plan, they need an action.
- ❌ **Multiple actions per turn.** One. Always one. More than one is a plan, which is the thing that wasn't working.
- ❌ **Encouragement.** "You've got this!" adds friction, not lubricant. The skill stays neutral.
- ❌ **Calling [clarity-council](../clarity-council/) or any other multi-step skill.** Latency kills the use case.
- ❌ **"Are you sure?" / "Want to do something different?"** No interrogation. The user came here to be unstuck.

## Examples

### Example: Stuck on a Slack reply

```text
You: I have to reply to my boss about whether I want the promotion.
     I've been staring at the message for an hour.

Skill:

       Three quick questions:
       1. What's the task? (one sentence)
       2. What's the first physical place you'd interact with it?
       3. What's the smallest output that would mean you started?

You:
  1. reply to boss about promotion
  2. the slack thread
  3. one sentence drafted in the compose box, even if i delete it

Skill:

       **Do this now (≤30 seconds):**
       Open the Slack thread. Click in the compose box. Type:

           "Thanks for asking — let me think through it and reply
            tomorrow."

       Do NOT send it. Just type it.

       **When you've done that, come back and say "done".**

You: done

Skill:

       **Do this now (≤30 seconds):**
       Read what you typed. If you want to send it as-is, send it.
       If not, delete the last clause and replace it with whatever
       feels truer.

       **When you've done that, come back and say "done".**
```

The skill picked the smallest sub-action of the smallest sub-action — *typing* before *deciding*.

### Example: Stuck on starting a code change

```text
You: stuck. need to add the timeout field to the config schema and
     it's been on my todo for three days.

Skill:

       Three quick questions:
       1. What's the task?
       2. Where do you interact with it first?
       3. Smallest output that means you started?

You:
  1. add a `timeout` field to ConfigSchema
  2. src/config/schema.ts
  3. a one-line declaration of the field

Skill:

       **Do this now (≤30 seconds):**
       Open src/config/schema.ts. Find the ConfigSchema definition.
       Inside it, add this line:

           timeout: z.number().optional(),  // TODO

       Save.

       **When you've done that, come back and say "done".**

You: done

Skill:

       **Do this now (≤30 seconds):**
       Replace the `// TODO` with whatever default you think the
       timeout should be. Guess. You can change it later.

       **When you've done that, come back and say "done".**
```

The TODO is the trick — it gives the brain permission to be wrong, which makes typing it easy.

## Internals

The skill is intentionally minimal. There is no council, no planning subskill, no validation loop. The output shape is a single block:

```
**Do this now (≤30 seconds):**
[one literal action]

**When you've done that, come back and say "done".**
```

The loop continues until the user signals momentum ("I can keep going", "I've got it", "thanks") or routes to a planning skill.

The three setup questions are required because the skill needs:
- The task name (so the action references the right thing)
- The entry surface (so the action specifies a real physical location)
- The smallest-output criterion (so the action is calibrated to feel achievable)

If the user can't answer the third question, the skill picks it for them — the *smallest possible* visible thing.

Hard constraints: one action per turn, ≤30 seconds, no decisions in the action itself, no encouragement, no explanation, no plan.

## FAQ

**Q: What if I do the action and still can't keep going?**
A: Say "done" and the skill will give you the next ≤30-second action. The loop is designed to be repeated as many times as needed.

**Q: What if the action the skill gives me is wrong / I don't want to do it?**
A: Say what you'd rather do instead and the skill will recalibrate. The point is to get *something* started, not to commit to a specific path.

**Q: Why won't the skill make a plan?**
A: Because planning is what got you stuck. If you genuinely need a plan, use [request-refactor-plan](../request-refactor-plan/) or [grill-me](../grill-me/). Task-initiation is specifically for when planning is the trap.

**Q: How is this different from a todo list?**
A: A todo list says "do this 1-hour task." Task-initiation says "type these 7 characters in this file." Different unit of work.

## Related skills

- **[hyperfocus-recovery](../hyperfocus-recovery/)** — sibling for the inverse case: you *were* working and got pulled away and now don't know where to re-enter. Same shape of output (one literal action).
- **[request-refactor-plan](../request-refactor-plan/)** — when you actually do need a plan.
- **[grill-me](../grill-me/)** — when the stall is "I don't know what I'm doing" rather than "I can't start."
- **[interest-capture](../interest-capture/)** — when the stall is because a hyperfixation just lit up. Capture it, then return here.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full output protocol)
