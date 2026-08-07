# Idea Choice

Deliberate pros/cons analysis with weighted scoring and a written recommendation. Takes one or more ideas/concepts, runs a [clarity-council](../clarity-council/) pass to surface arguments on both sides (with an optional [grill-me](../grill-me/) preflight to expose hidden assumptions), scores each pro and con on **Impact × Confidence** (1–25), and renders a markdown table per idea — plus a comparison table when multiple ideas are evaluated together. The output is a defensible record, not a vibe.

## Why this exists

Pros/cons lists usually fail two ways. Either they're an unranked dump (every point given equal visual weight, even though some are decisive and most are noise), or they're a personal narrative dressed up as analysis (the items the user secretly wants surface first; the rest get padded). This skill enforces a discipline: every point gets two numbers (how much it matters, how sure we are), the totals are arithmetic, and the recommendation is bounded by explicit thresholds. The user still chooses, but the analysis on the page is honest about its own shape.

## When to use this vs. idea-decision-maker

These two skills look superficially similar but solve different problems. **Idea-choice deliberates; idea-decision-maker forces.**

| Situation | Use |
|---|---|
| "I want to evaluate this before committing" | **idea-choice** |
| "I've been spinning on this for an hour, just pick one" | **idea-decision-maker** |
| "I need a written record of why we chose X over Y" | **idea-choice** |
| "It's 4pm, I have to decide before standup tomorrow" | **idea-decision-maker** |
| "Compare these three options on the merits" | **idea-choice** |
| "I keep flip-flopping between A and B" | **idea-decision-maker** |
| "Build me a justification I can put in an ADR / proposal / RFC" | **idea-choice** |
| "Low stakes, I just need someone else to call it" | **idea-decision-maker** |

### The shape of the difference

- **Decision-breaker is a forcing function.** Three questions, one pick, ~5 minutes. It's designed for paralysis — the user has already done the analysis and is now stuck. The cost of indecision exceeds the cost of being slightly wrong, so the skill picks and closes the loop. Output is a verdict.
- **Idea-choice is a deliberation tool.** A council pass, weighted scoring, a per-idea table, ~15–30 minutes. It's designed for stakes high enough that you want a written record — something you could paste into an ADR, a 1:1 doc, or a proposal. Output is an artifact.

### Rule of thumb

> If the user is *stuck*, use **idea-decision-maker**.
> If the user is *deliberating*, use **idea-choice**.
> If the user wants the *record* of the decision, use **idea-choice**.
> If the user wants the *decision itself*, use **idea-decision-maker**.

When in doubt, ask: *"do you want me to pick one for you, or weigh them and write up the reasoning?"*

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "weigh the tradeoffs"
  - "pros and cons of X"
  - "should I do X" (when the user wants analysis, not a verdict — see above)
  - "is X worth it"
  - "compare these options"
  - "build me a pros/cons list with weights"
  - "justify this decision in writing"
- Invoking `/idea-choice` directly

## What it does

The skill captures the idea(s) plus optional criteria, runs the relevant sibling skills (council always; grill if the idea is vague), scores every surfaced pro and con on Impact × Confidence, sums the weighted totals, and renders a structured table with a clear recommendation. It does **not** produce new options (use [idea-generate](../idea-generate/)) and does **not** force a snap pick (use [idea-decision-maker](../idea-decision-maker/)).

### Inputs

- **One or more ideas/concepts** — phrased as "should I X" or "X vs Y vs Z" or just a list.
- **Optional criteria** — what the user is optimizing for (cost, time, reversibility, fit, risk). If absent, the skill asks one targeted question to surface 2–4.

### Outputs

- A markdown block per idea: criteria, surfaced assumptions, pros table, cons table, totals, recommendation.
- A comparison table when multiple ideas were evaluated.
- A recommendation tag: **Go** / **Go with caveats** / **Don't** / **Needs more analysis**.

### External systems used

- **[clarity-council](../clarity-council/)** — required, for the pros/cons generation pass.
- **[grill-me](../grill-me/)** — optional, for surfacing hidden assumptions when the idea is vague.

## How to use it

A typical single-idea session looks like this:

```text
You: should I migrate our internal dashboard from Streamlit to Next.js + tRPC?
     I care about long-term maintainability and onboarding cost.

Skill: Criteria captured: maintainability, onboarding cost. Adding two
       defaults: shipping risk, reversibility. OK?

You: yes, plus cost-to-host.

Skill: [runs council with Advocate / Skeptic / Senior Engineer]

       ## Idea: Migrate dashboard to Next.js + tRPC

       Criteria: maintainability, onboarding cost, shipping risk,
                 reversibility, cost-to-host

       ### Pros
       | # | Pro                                      | I | C | W  |
       |---|------------------------------------------|:-:|:-:|:--:|
       | 1 | Typed client/server via tRPC             | 5 | 5 | 25 |
       | 2 | Easier onboarding for JS-fluent teammates| 4 | 4 | 16 |
       | 3 | Better long-term ecosystem support       | 3 | 4 | 12 |

       ### Cons
       | # | Con                                      | I | C | W  |
       |---|------------------------------------------|:-:|:-:|:--:|
       | 1 | Migration cost: 4-6 weeks of build       | 5 | 4 | 20 |
       | 2 | Loses Streamlit's instant data-app feel  | 3 | 4 | 12 |
       | 3 | Hosting moves from cheap-Python to Node  | 2 | 5 | 10 |

       Totals: Pros 53, Cons 42, Net +11

       **Recommendation: Go with caveats.** The 20-weight migration cost
       is significant — gate the start on a fixed 6-week box and a
       working spike of the most complex view by week 2.
```

## Getting the most out of it

- **Provide criteria upfront.** The skill will ask if you don't, but you'll get a sharper analysis if you name the 2–4 dimensions you actually care about. Generic criteria → generic pros/cons.
- **Use it for the things you'll have to defend.** ADRs, proposals, "why we chose X" conversations with leadership. The artifact is the point.
- **Compare 2–4 ideas at once when feasible.** The comparison table is more useful than three separate analyses, because the council applies the same lens across all of them.
- **Don't fight the score.** If you're tempted to argue with the weights, that's the analysis working — your gut disagrees with the numbers, and the disagreement is data. Adjust the criteria, not the scoring, if you think the numbers are missing something.
- **Re-run when the assumptions change.** Idea-choice produces a snapshot. If a key con's confidence was 3 ("we think") and you later learn the answer for sure (now 5), re-run — the recommendation may flip.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Use for snap decisions.** If you need a pick in five minutes, this is the wrong skill. Use [idea-decision-maker](../idea-decision-maker/).
- ❌ **Use to generate ideas.** If you don't have the options yet, run [idea-generate](../idea-generate/) first, then feed its output here.
- ❌ **Inflate confidence to make a preferred idea win.** Confidence is "how sure am I this is true," not "how much do I want this to be true." The whole point of the skill is to expose the bias, not hide it.
- ❌ **Recommend "Needs more analysis" because the totals are close.** Only use that tag when the totals are within ±10 *and* no single item is ≥ 16. Otherwise pick a side — even a thin edge is a signal.
- ❌ **Use different criteria for different ideas in a comparison.** Makes the totals incommensurate. Hold the criteria steady or the comparison is theater.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for full end-to-end transcripts: single-idea evaluations, multi-idea comparisons, a technical-decision example, a personal-life example, and a worked case where idea-choice and idea-decision-maker would each give a different (correct) answer for the same input.

### Quick example: short comparison

```text
You: compare Postgres vs SQLite vs DuckDB for our analytics workload.
     Criteria: query speed on 100M rows, ops burden, cost.

Skill: ## Comparison

       | Idea     | Pros | Cons | Net | Recommendation  |
       |----------|:----:|:----:|:---:|------------------|
       | Postgres |  38  |  34  | +4  | Go with caveats |
       | SQLite   |  19  |  47  | −28 | Don't           |
       | DuckDB   |  46  |  21  | +25 | Go              |

       Winner: DuckDB. Margin over Postgres is +21 — clear call.
       SQLite is out: 100M-row joins are its known weak point (con #1, weight 25).
```

## Internals

The skill follows this workflow per request:

1. **Capture** — read the idea(s) and any user-supplied criteria. Ask one question if criteria are missing.
2. **Optional grill** — invoke [grill-me](../grill-me/) for 3–5 questions if the idea is vague. Skip if concrete.
3. **Council** — invoke [clarity-council](../clarity-council/) with persona trio appropriate to the domain (default: Advocate / Skeptic / Pragmatist; technical adds Senior Engineer; product adds Customer Advocate; personal adds Psychologist).
4. **Score** — for every pro and con, assign Impact (1–5) and Confidence (1–5). Weight = product.
5. **Aggregate** — sum weighted pros, sum weighted cons, compute net.
6. **Render** — pros table, cons table, totals, recommendation.
7. **Compare** (if multiple ideas) — produce a comparison table; call the winner if the margin justifies it.

### Recommendation thresholds

| Tag | Condition |
|---|---|
| **Go** | Net ≥ +20 AND no single con ≥ 16 |
| **Go with caveats** | Net positive AND at least one con ≥ 16 (list mitigations) |
| **Don't** | Net ≤ −10 OR any con ≥ 20 that cannot be mitigated |
| **Needs more analysis** | Net within ±10 AND no single item ≥ 16 |

### Scoring scale

- **Impact (1–5):** how much this point matters if it turns out to be true.
  - 1 = trivial, 3 = noticeable, 5 = decisive on its own
- **Confidence (1–5):** how sure we are that the point is/will be true.
  - 1 = speculation, 3 = informed guess, 5 = empirically verified
- **Weight = I × C** (range 1–25). A weight ≥ 16 is a "deal-shaper" — must be addressed in the recommendation even on a "Go."

## FAQ

**Q: How is this different from idea-decision-maker?**
A: Decision-breaker is fast and forces a single pick when you're paralyzed. Idea-choice is slower and produces a written artifact with weighted reasoning. See the table at the top of this README.

**Q: How is this different from idea-generate?**
A: Idea-generate produces *new* ideas from a loose topic. Idea-choice evaluates ideas you already have. They chain: generate → choose.

**Q: What if the council produces 15 pros and 2 cons?**
A: Either the idea is genuinely lopsided, or the Skeptic persona was too quiet — push back: "give me 3 more cons the Skeptic actively believes." Watch out for confirmation bias inflating the pros column.

**Q: Can the same idea get different recommendations on different runs?**
A: Yes — confidence scores reflect what's known *right now*. As the situation changes, re-run. This is a feature, not a bug.

**Q: Should I publish the table somewhere?**
A: Often yes — that's the point. Paste it into the relevant ADR, decision doc, or Obsidian note for future-you. The weights make later "why did we decide that" conversations much shorter.

**Q: What if I disagree with a weight the council assigned?**
A: Adjust it and re-aggregate. The numbers exist to be argued with — that's the deliberation. What you can't do (without invalidating the analysis) is adjust *only the weights that don't favor your preferred outcome*.

## Related skills

- **[idea-decision-maker](../idea-decision-maker/)** — when you need a fast pick, not a written analysis. See the comparison table above.
- **[idea-generate](../idea-generate/)** — when you don't have the options yet. Runs before this skill.
- **[clarity-council](../clarity-council/)** — the multi-persona engine that powers the pros/cons pass.
- **[grill-me](../grill-me/)** — for surfacing hidden assumptions before scoring.
- **[time-reality-check](../time-reality-check/)** — useful when an idea involves a time estimate the user might be miscalibrated on (feeds into Confidence scores).
- **[energy-budget](../energy-budget/)** — useful when the criteria include "do I have the energy for this." Can feed the council a load score.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (workflow, scoring scheme, output format)
- **[EXAMPLES.md](EXAMPLES.md)** — End-to-end session transcripts
