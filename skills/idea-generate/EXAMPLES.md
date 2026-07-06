# Idea Generate — Examples

Five end-to-end sessions across different topic shapes. Each shows the loose topic, the raw Phase 1 list (abbreviated), the user's selection, and the Phase 3 grilling outcome.

---

## 1. Side project — vague topic with two domains

**Topic:** "Side project combining urban gardening and AI. Solo dev, weekends only, want something I'd actually use myself."

### Phase 1 — Divergence (raw council output)

```text
Visionary
  1. Vision-AI plant disease diagnoser (phone photo → species + treatment)
  2. Hyperlocal pollinator schedule generator (zip → planting calendar)
  3. Compost-stage tracker via webcam + LLM
  4. Vacant-lot finder that proposes guerrilla-garden sites

Skeptic
  5. None of #1-4 needs AI — a lookup table beats a model. What about:
     an LLM that drafts mediation letters between neighbors over fence-line
     gardens? (Real problem, no ML toy.)
  6. A "stop me from buying more plants" coach that argues you out of impulse
     purchases at the nursery.

Pragmatist
  7. Weekly garden-log emailer: photos in, weekly progress digest out
  8. "What's wrong with my soil" — soil test photo → amendment plan
  9. Free seed library matcher (you have these, they need those)
 10. Voice notes → garden journal — speak while weeding, get a clean log
```

### Phase 2 — Selection

> User: "#2 and #10 — pollinator schedule and voice-to-journal."

### Phase 3 — Convergence (grill highlights, idea #2)

```text
Grill: Who's the user — hobby gardener or municipality?
You: Hobbyist.
Grill: Then USDA zone + frost dates already exists. What's the AI for?
You: Matching local native species to *their specific yard conditions*
     (shade, soil, existing plants) — not just zone.
Grill: That's a recommender, not generative. Why an LLM and not a filter?
You: ... fair. Could be a filter with a small natural-language frontend.
Grill: So the differentiator is the frontend, not the recommendation.
       Is that enough to ship?
You: Maybe not solo. Let's drop the LLM and lead with the species DB.

Outcome: idea hardened from "AI pollinator app" to "native-species
recommender for hobby gardeners, plain web form, no LLM." Survives.
```

**Takeaway:** The grill killed the AI part but saved the idea. Better than building an LLM wrapper around a lookup.

---

## 2. Conference talk topic

**Topic:** "30-minute internal talk about Claude Code. Audience is engineers who haven't used it."

### Phase 1 — Divergence

```text
1. Live refactor of a real codebase with Claude as pair (Visionary)
2. "Things Claude got wrong this month" — postmortem reel (Skeptic)
3. Sub-agents for your real workflow: 3 patterns (Pragmatist)
4. Five hooks that save 10 minutes a day (Pragmatist)
5. Plan-mode demo: replan a feature that the team already shipped (Visionary)
6. "Why I stopped using cursor and started using Claude Code" — opinion (Skeptic)
7. Skills as a packaging convention: writing your first one (Pragmatist)
8. Comparing Claude Code with copilot/cursor on the same 5-task benchmark (Skeptic)
```

### Phase 2 — Selection

> User: "#2 and #4. Postmortem and hooks."

### Phase 3 — Convergence (grill highlights, idea #2)

```text
Grill: 30 minutes of "Claude got it wrong" — will people leave thinking
       they shouldn't use it?
You: That's the risk. I want them to come away calibrated, not scared.
Grill: Then the title is wrong. "What Claude got wrong" frames failure.
       What if it's "When to override Claude" — same content, agency frame.
You: Yes. And I can end with the patterns I now use to catch it earlier.
Grill: What's the takeaway slide?
You: "Three signals that Claude is about to make a mistake, and what to do."

Outcome: Talk reframed from postmortem to "calibration handbook."
Same examples, different arc.
```

---

## 3. Naming — different persona set

**Topic:** "Name for an internal Obsidian template for daily standup notes."

Note: For naming, the default persona set is swapped to **Visionary + Skeptic + Marketer** (the Pragmatist is replaced because "is this name feasible" is not the question).

### Phase 1 — Divergence

```text
Visionary
  1. "Pulse" — short, evokes a heartbeat / regular signal
  2. "Lighthouse" — guidance, but maybe over-grand for a daily log

Skeptic
  3. "Standup" — what it actually is. Boring on purpose.
  4. "Daily" — already too generic, will collide with the daily-note plugin

Marketer
  5. "Heartbeat" — same idea as Pulse, more relatable
  6. "Logbook" — nautical, suggests continuity
  7. "Field notes" — research-y, suggests observation
  8. "Roll call" — playful, references the standup ritual
```

### Phase 2 — Selection

> User: "Pulse, Field notes."

### Phase 3 — Convergence (grill highlights, idea: "Field notes")

```text
Grill: Field notes implies observation of something external. Standups are
       about *your own* status. Does the metaphor land?
You: Hmm. It works if I'm observing "what the team is doing", less if I'm
     reporting "what I did".
Grill: Who fills it in — you, the team, or both?
You: Just me.
Grill: Then it's a self-log, not field notes. Lean toward Pulse, or
       go literal: "Standup".

Outcome: Pulse wins. Field notes was metaphorically wrong for the use case.
```

---

## 4. Product feature — constraint-driven

**Topic:** "Feature for the sprint-snapshot skill that would make it more useful for team leads. Constraint: must work offline, must not require additional plugins."

### Phase 1 — Divergence

```text
1. Auto-compute capacity vs commitment delta, surface as a single sparkline
2. Per-member "wedge" balance check — flag when one person owns >40% of WIP
3. Detect ticket-status thrash (changed state 3+ times this sprint)
4. Highlight tickets that have been in-review longer than 3 days
5. Compute team "swarm score": % of tickets touched by 2+ people
6. Suggest tickets to descope based on age + lack of activity
7. Render the whole snapshot as a single PNG for screenshot-sharing
8. Auto-generate the "what changed since yesterday" diff vs last snapshot
```

### Phase 2 — Selection

> User: "#3 and #4. Thrash detection and in-review aging."

### Phase 3 — Convergence (grill highlights, idea #3)

```text
Grill: How does the skill detect thrash without calling Jira every snapshot?
You: It already pulls changelog data per ticket.
Grill: Define thrash — three transitions of any kind, or three that loop?
You: Looping (e.g., In Progress → Review → In Progress) is real thrash.
     Linear progression (Backlog → In Progress → Review → Done) is just work.
Grill: So you need state-cycle detection, not transition count. Will the
       team lead understand the distinction in a report?
You: I'll surface both: "5 transitions, 2 cycles." The cycles are the signal.

Outcome: Feature scope tightened from "thrash" (ambiguous) to "state
cycles" (precise), with a clear surfacing pattern.
```

---

## 5. Team-process change

**Topic:** "Ideas for cutting our sprint planning meeting from 2 hours to 1 hour without losing alignment."

### Phase 1 — Divergence

```text
1. Pre-grooming the backlog the day before — only refined tickets enter planning
2. Story-point estimation moves async; planning only ratifies
3. Drop estimation entirely, count tickets, calibrate over time
4. Split the meeting: 30-min commitment for the team, 30-min Q&A for stakeholders
5. Read the spec ahead, planning only answers questions (Amazon-style)
6. Eliminate the meeting; use a shared doc with comments over 24h
7. Cap discussion at 5 min per ticket; rolled-over discussion goes to async
8. Have only the people doing the work attend; PO joins for first 15 min
```

### Phase 2 — Selection

> User: "#1 and #7. Pre-grooming + time-cap per ticket."

### Phase 3 — Convergence (grill highlights, idea #1)

```text
Grill: Who refines the backlog the day before, and when?
You: PO + tech lead, 30 min the day before.
Grill: That's 30 min you've added back. Net savings?
You: 30 min, since the PO+TL would've spent the time in planning anyway,
     just with the whole team idle.
Grill: What happens to a ticket that surfaces a real question during
       refinement?
You: It doesn't enter planning. Goes into next sprint or gets resolved
     async first.
Grill: Will the team object to having tickets pulled at the last minute?
You: Possible. I'll need to socialize "refined or it doesn't enter" as
     a hard rule.

Outcome: Idea survives but with a known socialization risk. Worth piloting
for one sprint before committing.
```

---

## When the council disagrees

A sign the divergence phase is healthy:

```text
Visionary: "Build it as an AR overlay — point your phone at the plant."
Skeptic:   "That's a 6-month build for a weekend dev. Strong no."
Pragmatist:"AR-lite: a photo + bounding boxes is 90% of the value at 5% of the cost."
```

This is what you want. If all three agree on the first idea, the council is collapsing — push back: "give me three the Skeptic *actively* dislikes."

---

## When to bail out

Some sessions reveal that idea-generation isn't the right tool:

- **Phase 1 keeps producing the same idea in different clothes.** The topic is too narrow — you've already converged. Switch to grill-me on the one idea.
- **You can't pick a shortlist of 2–3.** The constraints aren't tight enough. Add one ("must ship in a week", "must use Python") and re-run Phase 1.
- **The grill keeps killing every idea.** The constraint set is impossible. Loosen one constraint and re-run, or accept that the project as framed isn't viable.
