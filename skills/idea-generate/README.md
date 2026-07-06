# Idea Generate

Generate, refine, and stress-test ideas from loose topics through a two-phase workflow: **Divergence** (a multi-persona [clarity-council](../clarity-council/) session generates wide-ranging options using First Principles and SCAMPER) followed by **Convergence** (a [grill-me](../grill-me/) session attacks the shortlist to harden it into something defensible). The output is not a brainstorm dump but a small set of ideas that have already survived their first round of skepticism.

## Why this exists

Most brainstorming fails one of two ways. Either it produces a long list of weak ideas that nobody can rank (Divergence without Convergence), or it jumps straight to "is this feasible?" before any wild options have surfaced (Convergence without Divergence). This skill enforces the order: go wide first with three personas who actively disagree, then go deep on the survivors using a grilling session that tries to break them. The user's job is to pick which 2–3 sparks to harden — not to invent the ideas, and not to evaluate the raw list alone.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "brainstorm ideas for X"
  - "I need ideas for a side project / talk / article / feature"
  - "give me some options for X"
  - "I'm stuck on X, what could I do"
  - "stress-test these ideas"
- Invoking `/idea-generate` directly

## What it does

The skill orchestrates two sibling skills in sequence. **Phase 1** spawns a clarity-council with three personas (Visionary, Skeptic, Pragmatist) that apply structured frameworks (First Principles, SCAMPER) to the loose topic and produce a raw list of diverse options. **Phase 2** asks the user to pick 2–3 to pursue, then runs each through grill-me to find the gaps, contradictions, and weaknesses — refining the idea until it can survive scrutiny. The skill itself produces no files unless the user asks; the output is conversational, designed to leave the user with a small set of hardened concepts.

### Inputs

- **A loose topic** — vague is fine. "Side project related to urban gardening and AI" is better than "a SaaS product."
- **Optional constraints** — budget, time, target audience, tech stack, format. Constraints sharpen the council's output.

### Outputs

- A raw list of 8–15 diverse ideas (Phase 1).
- A shortlist of 2–3 refined ideas after user selection (Phase 2 entry).
- A hardened version of each shortlisted idea with the gaps surfaced and addressed (Phase 3 exit).

### External systems used

- **[clarity-council](../clarity-council/)** — multi-persona idea generation in Phase 1.
- **[grill-me](../grill-me/)** — iterative stress-testing in Phase 3.

## How to use it

A typical session looks like this:

```text
You: brainstorm side-project ideas combining urban gardening and AI

Skill: [runs clarity-council with Visionary + Skeptic + Pragmatist]

       Raw list (Phase 1):
       1. Vision-AI app that diagnoses plant diseases from a phone photo
       2. Hyperlocal pollinator-friendly planting schedule (zip code → species)
       3. Compost-camera that tracks decomposition stages
       4. ...
       [12 more]

       Which 2-3 spark something? Or should the council push harder
       in a direction?

You: 2 and 4 look interesting. let's grill #2.

Skill: [runs grill-me on the pollinator schedule idea]

       Q1: who is the user — gardener, municipality, or schoolkid?
       ...

       [iterative grilling until the idea is concrete and defensible]
```

## Getting the most out of it

- **Start vague.** The council does best with a loose topic and a constraint or two. Over-specified prompts collapse the divergence phase into a single direction.
- **Resist picking too early.** The shortlist should be 2–3 ideas, not 1. Carrying two through Phase 3 lets you compare which one survives the grill better — a single survivor isn't a comparison, it's a coronation.
- **Let the personas disagree.** If the Visionary and Skeptic agree on every idea in Phase 1, the council is too consensus-driven. Push back: "give me three the Skeptic actively dislikes."
- **Use SCAMPER on the shortlist, not the raw list.** First Principles is for divergence; SCAMPER is most useful when iterating on a chosen idea ("eliminate the camera — what's left?"). The skill applies both in Phase 1 by default, but you can call for specific frameworks on a specific idea later.
- **Treat the grill as a forge, not a court.** [grill-me](../grill-me/) finds weaknesses so you can fix them — not to kill the idea. Push back on any question that feels like it's just trying to discourage you.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Skip the council and go straight to grilling.** Without a divergent first pass, you grill the first idea that came to mind — which is rarely the best one.
- ❌ **Produce one "best" idea in Phase 1.** The council's job is variety. If it converges on a single recommendation, that's a failed Phase 1.
- ❌ **Grill an idea you've already decided to build.** The grill works when the user can still walk away. If you've already committed, you're not stress-testing — you're rationalizing.
- ❌ **Use this for problems that have a known answer.** "How do I fix this bug" is not an idea-generation task. Use [issue-triage](../issue-triage/) or [grill-me](../grill-me/) directly.
- ❌ **Carry more than 3 ideas into Phase 3.** Grilling is expensive. Three is the cap.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for full end-to-end transcripts across different topic shapes — side projects, talk topics, naming, product features, and team-process changes.

### Quick example

```text
You: ideas for a 30-minute internal talk about Claude Code

Skill: Council says (Visionary / Skeptic / Pragmatist):

       1. Live-coding a complex refactor with Claude as pair (Visionary)
       2. "Things Claude got wrong" — a postmortem reel (Skeptic)
       3. Setting up sub-agents for your real workflow (Pragmatist)
       4. The hook system: 5 hooks that save 10 minutes a day (Pragmatist)
       5. ...

       Which appeal? I'd note #2 and #3 are the most "talk-able" —
       the others would work better as written posts.
```

## Internals

The skill follows this workflow per request:

1. **Receive the loose topic** — capture constraints if the user offered any.
2. **Phase 1: Divergence** — invoke [clarity-council](../clarity-council/) with the Visionary + Skeptic + Pragmatist persona set, directing them to apply First Principles and SCAMPER (see [REFERENCE.md](REFERENCE.md)).
3. **Phase 2: Selection** — present the raw list, ask the user to pick 2–3.
4. **Phase 3: Convergence** — for each shortlisted idea, invoke [grill-me](../grill-me/) for an iterative hardening session.
5. **Output** — leave the user with refined concepts; no files unless asked.

Three personas, by design:

- **Visionary** — blue-sky possibilities, radical recombinations, "what if the constraint were removed?"
- **Skeptic** — failure modes, constraints, "why hasn't this been done already?"
- **Pragmatist** — feasibility, utility, fastest path to a usable v0.

Two frameworks, applied in Phase 1:

- **First Principles** — strip assumptions, build up from fundamental truths.
- **SCAMPER** — substitute, combine, adapt, modify, put-to-another-use, eliminate, reverse.

## FAQ

**Q: Can I skip Phase 1 if I already have ideas?**
A: Yes — say "skip to grilling: [idea]" and the skill jumps straight to Phase 3. You lose the comparative benefit but save time.

**Q: What if no idea in the raw list resonates?**
A: Two options: (1) ask the council to push harder in a specific direction ("more weird, less practical"); (2) add a constraint and re-run ("must use no electricity").

**Q: How many ideas should Phase 1 produce?**
A: 8–15 is the target. Fewer means the council is hedging; more means it's padding.

**Q: Can the grill kill an idea entirely?**
A: Yes — and that's a successful outcome. Better to find the fatal flaw in a 20-minute grilling session than after 3 months of building.

**Q: Does this work for naming things?**
A: Yes, but the council framing shifts — use Visionary + Skeptic + Marketer (or specify your own persona set). See the naming example in [EXAMPLES.md](EXAMPLES.md).

**Q: Can I use this for personal decisions, not just creative work?**
A: It works, but for binary decisions try [idea-decision-maker](../idea-decision-maker/) first — it's purpose-built for "pick A or B" stalls.

## Related skills

- **[clarity-council](../clarity-council/)** — the multi-persona engine that powers Phase 1.
- **[grill-me](../grill-me/)** — the iterative questioning engine that powers Phase 3.
- **[idea-decision-maker](../idea-decision-maker/)** — when the task is "pick between two options," not "generate options."
- **[interest-capture](../interest-capture/)** — when an idea surfaces that you don't want to develop now but don't want to lose.
- **[writing-fragments](../writing-fragments/)** — when the raw material is for an article, not a project.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (three-phase workflow)
- **[REFERENCE.md](REFERENCE.md)** — Idea-generation frameworks (First Principles, SCAMPER)
- **[EXAMPLES.md](EXAMPLES.md)** — End-to-end session transcripts
