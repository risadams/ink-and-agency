# Idea Choice — Examples

Six end-to-end sessions: three single-idea evaluations, two multi-idea comparisons, and a worked case showing where this skill and `idea-decision-maker` would each give a different (correct) answer for the same input.

---

## 1. Single technical idea — migration

**Topic:** "Should I migrate our internal dashboard from Streamlit to Next.js + tRPC?"

### Setup

- **Criteria:** maintainability, onboarding cost, shipping risk, reversibility, cost-to-host
- **Council:** Advocate / Skeptic / Senior Engineer
- **Grill:** skipped — idea is concrete

### Output

```markdown
## Idea: Migrate dashboard from Streamlit to Next.js + tRPC

**Criteria:** maintainability, onboarding cost, shipping risk, reversibility, cost-to-host
**Assumptions surfaced:** (none — concrete idea, no grill)

### Pros

| # | Pro                                                      | I | C | W  |
|---|----------------------------------------------------------|:-:|:-:|:--:|
| 1 | Typed client/server via tRPC removes a whole bug class   | 5 | 5 | 25 |
| 2 | Easier onboarding for JS-fluent teammates (4 of 6)       | 4 | 4 | 16 |
| 3 | Better long-term ecosystem support than Streamlit        | 3 | 4 | 12 |
| 4 | Real frontend routing — multi-page dashboard finally clean| 3 | 4 | 12 |

### Cons

| # | Con                                                      | I | C | W  |
|---|----------------------------------------------------------|:-:|:-:|:--:|
| 1 | Migration cost: 4–6 weeks of build with no new features  | 5 | 4 | 20 |
| 2 | Loses Streamlit's "edit Python, see chart" feel for new analyses | 3 | 4 | 12 |
| 3 | Hosting moves from cheap-Python container to Node runtime | 2 | 5 | 10 |
| 4 | Risk that "Next.js + tRPC" stretches the one frontend person too thin | 4 | 3 | 12 |

### Totals

- **Pros:** 65
- **Cons:** 54
- **Net:** +11

### Recommendation

**Go with caveats.** Net positive but con #1 (weight 20) is significant. Mitigate by:
- Time-box to 6 weeks; if not feature-complete by then, halt and reassess.
- Build the hardest existing view as a spike in week 2 — if it takes >5 days, halt.
- Keep Streamlit running in parallel until cutover.

Re-evaluate after the spike — confidence on con #4 may shift.
```

**Note on scoring:** Pro #1 gets a perfect 25 because tRPC's type-safety is both decisive (5 impact) and empirically demonstrated (5 confidence). Con #1's confidence is 4 not 5 because the 4–6 week estimate is informed but not verified.

---

## 2. Single personal idea — life choice

**Topic:** "Should I commit to a half-marathon in October?"

### Setup

- **Criteria:** time cost / week, injury risk, satisfaction if completed, overlap with current goals
- **Council:** Advocate / Skeptic / Psychologist
- **Grill:** **invoked** — vague topic, hidden assumptions about training base

### Grill output (3 questions surfaced)

1. What's your current weekly mileage? → "About 8 miles."
2. Have you raced before? → "5K once, four years ago."
3. What does success look like — finish time, finishing at all, or building a habit? → "Building a habit. Time doesn't matter."

### Output

```markdown
## Idea: Commit to half-marathon in October

**Criteria:** time cost/week, injury risk, satisfaction-if-completed, overlap with current goals
**Assumptions surfaced:**
- Current weekly mileage is 8 miles (need to ramp ~4x for race-readiness)
- No recent racing experience (4 years since last race)
- Goal is habit-formation, not a target time

### Pros

| # | Pro                                                  | I | C | W  |
|---|------------------------------------------------------|:-:|:-:|:--:|
| 1 | External deadline forces consistent training         | 5 | 4 | 20 |
| 2 | Aligns with "build a movement habit" goal for the year | 4 | 5 | 20 |
| 3 | Sense of accomplishment carries over to other domains | 3 | 4 | 12 |
| 4 | Social — running clubs are common in Pittsburgh       | 2 | 4 | 8  |

### Cons

| # | Con                                                  | I | C | W  |
|---|------------------------------------------------------|:-:|:-:|:--:|
| 1 | 6–10 hours/week through summer — significant time sink | 4 | 5 | 20 |
| 2 | Injury risk ramping from 8 to ~30 miles/week         | 4 | 4 | 16 |
| 3 | If you don't finish, the "habit" framing collapses    | 3 | 3 | 9  |
| 4 | Heat training in July/August is genuinely unpleasant  | 2 | 5 | 10 |

### Totals

- **Pros:** 60
- **Cons:** 55
- **Net:** +5

### Recommendation

**Go with caveats.** Net positive but two cons are ≥ 16. Mitigate by:
- **Injury risk:** follow a documented 16-week plan (Hal Higdon Novice 2 or equivalent) instead of self-coaching the ramp.
- **Time cost:** front-load the long runs to Saturday morning to protect weekday focus blocks. If the calendar can't absorb 6h/week by mid-July, pull back to a 10K.

The pro/con margin is thin — re-run in 4 weeks once mileage has ramped. If injury or burnout shows up, the picture changes.
```

---

## 3. Multi-idea comparison — database choice

**Topic:** "Compare Postgres vs SQLite vs DuckDB for our analytics workload."

### Setup

- **Criteria:** query speed on 100M rows, ops burden, cost, ecosystem
- **Council:** Advocate / Skeptic / Senior Engineer
- **Grill:** skipped

### Output

```markdown
## Idea A: Postgres

### Pros (38)
| # | Pro | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Team already operates it | 4 | 5 | 20 |
| 2 | OLTP+OLAP in one engine | 3 | 3 | 9  |
| 3 | Mature ecosystem | 3 | 3 | 9  |

### Cons (34)
| # | Con | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | 100M-row aggregate queries slow without tuning | 4 | 4 | 16 |
| 2 | Requires indexes/partitioning — extra ops work | 3 | 4 | 12 |
| 3 | Not columnar — analytical queries less efficient | 3 | 2 | 6  |

Net: **+4** → Go with caveats

---

## Idea B: SQLite

### Pros (19)
| # | Pro | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Zero ops — just a file | 5 | 3 | 15 |
| 2 | Free | 2 | 2 | 4  |

### Cons (47)
| # | Con | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | 100M-row joins are its known weak point | 5 | 5 | 25 |
| 2 | Single-writer — concurrent ingest is painful | 4 | 4 | 16 |
| 3 | No real analytical functions | 3 | 2 | 6  |

Net: **−28** → Don't

---

## Idea C: DuckDB

### Pros (46)
| # | Pro | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Columnar — designed for 100M-row analytics | 5 | 5 | 25 |
| 2 | Zero ops in single-node mode | 4 | 4 | 16 |
| 3 | Reads Parquet directly — no ETL step needed | 3 | 5 | 15 |

### Cons (21)
| # | Con | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Less ecosystem maturity than Postgres | 3 | 3 | 9  |
| 2 | Newer — team has to learn it | 3 | 4 | 12 |

Net: **+25** → Go

---

## Comparison

| Idea     | Pros | Cons | Net  | Recommendation  |
|----------|:----:|:----:|:----:|------------------|
| Postgres |  38  |  34  |  +4  | Go with caveats |
| SQLite   |  19  |  47  | −28  | Don't           |
| DuckDB   |  46  |  21  | +25  | Go              |

**Winner: DuckDB.** Margin over Postgres is +21 — clear call. SQLite is eliminated by con #1 (weight 25, the known weakness for the actual workload).

**Why not Postgres:** Team familiarity is real but doesn't outweigh fundamental architecture mismatch on the 100M-row analytical workload. DuckDB's con #2 (learning curve) is solvable in 1–2 weeks; Postgres's con #1 (tuning work) recurs every quarter.
```

---

## 4. Multi-idea comparison — talk format

**Topic:** "I have a 30-minute slot at the team offsite. Should I do (A) a hands-on workshop, (B) a slide presentation, or (C) a live-demo + Q&A?"

### Setup

- **Criteria:** prep time, audience retention, my anxiety, repeatability afterward
- **Council:** Advocate / Skeptic / Pragmatist

### Comparison table

```markdown
| Idea | Pros | Cons | Net | Recommendation |
|------|:----:|:----:|:---:|----------------|
| A: Workshop  | 28 | 38 | −10 | Don't |
| B: Slides    | 32 | 24 | +8  | Go with caveats |
| C: Live demo | 34 | 21 | +13 | Go |

**Winner: C (live demo + Q&A).** Margin over B is +5 — meaningful but not large.

Why not B: Slides score lower mostly on "audience retention" (con: people zone out). The +5 margin reflects that slides are *safe*; the demo is higher-variance but higher-ceiling.

Why not A: Workshop loses on prep time (12h vs 4h) and on anxiety. The Advocate liked it for retention, but the Skeptic's "30 minutes is not enough for hands-on" hit weight 18, which sinks it.

If the offsite is moved to a 60-minute slot, re-run — workshop's anti-pattern (insufficient time) may flip.
```

---

## 5. Single idea — process change

**Topic:** "Should we cut our sprint planning meeting from 2h to 1h?"

### Setup

- **Criteria:** team alignment, time saved, risk of mid-sprint surprise, team morale
- **Council:** Advocate / Skeptic / Pragmatist + Scrum Master (custom add)

### Output (abbreviated)

```markdown
## Idea: Cut sprint planning from 2h to 1h

### Pros
| # | Pro | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Reclaims 1h × 6 people = 6 person-hours/sprint | 4 | 5 | 20 |
| 2 | Forces backlog refinement earlier in the cycle | 4 | 3 | 12 |
| 3 | Long meetings are widely rated as low-value by team | 3 | 4 | 12 |

### Cons
| # | Con | I | C | W |
|---|-----|:-:|:-:|:-:|
| 1 | Mid-sprint surprises if tickets enter underspecified | 5 | 4 | 20 |
| 2 | PO has to invest more in pre-grooming (30 min added back) | 3 | 5 | 15 |
| 3 | Team may interpret as "we don't value alignment" | 4 | 2 | 8  |

Totals: Pros 44, Cons 43, Net +1

### Recommendation

**Needs more analysis.** Net is +1 (well within ±10) AND no single item is ≥ 16... wait, con #1 is exactly 20. Revise: **Go with caveats.**

Mitigate the mid-sprint-surprise risk with: a "refined or it doesn't enter planning" hard rule, plus a 15-min Friday refinement slot. Pilot for one sprint; revisit after Sprint Review.
```

**Note:** This example shows the rule "don't recommend Needs more analysis as a cop-out" in action. The skill initially flagged Needs-more-analysis on the net score, then caught the 20-weight con and revised to Go with caveats. That's the correct call.

---

## 6. Worked case: idea-choice vs idea-decision-maker on the same input

**Input the user might give:** *"Should I take the team-lead role they offered me, or stay IC and do the architecture track?"*

This is the canonical case where the choice of skill matters. The same input, run through each skill, produces different (both correct) outputs.

### If routed to `idea-decision-maker`

```text
[3 questions: options, success-in-30-days, cost-of-being-wrong]

The pick: **Take the team-lead role.**

Why this one:
- Your "success in 30 days" answer (run my first team meeting well) is
  IC-incompatible — you can't take that role back later if you skip it now.
- Team-lead is rare to be offered; staying IC is always available.
- The architecture-track skills you'd gain as a lead overlap with the
  IC track (system design, cross-team influence).

Why not stay IC:
- The architecture track has no deadline; the team-lead offer does.

Cost of being wrong:
| If wrong | Cost | Reversible? |
|---|---|---|
| Team-lead role turns out to be 80% meetings | 6-12 months of slower technical growth | Yes — request to step back |

Revisit if: you haven't run a full sprint cycle as lead by month 3.
```

Time: ~5 min. Output: a verdict. User unsticks, moves on.

### If routed to `idea-choice`

```text
## Comparison

| Idea | Pros | Cons | Net | Recommendation |
|------|:----:|:----:|:---:|----------------|
| A: Team-lead | 47 | 41 | +6 | Go with caveats |
| B: Stay IC + arch track | 44 | 31 | +13 | Go |

Winner: B (IC + architecture). Margin over A is +7 — meaningful but thin.

Why: Lead has a 20-weight pro ("rare opportunity") but also two 16+
weight cons ("80% meetings projected," "loses 6 months of hands-on
depth at a critical career inflection point"). IC has lower ceilings on
upside (none > 16) but no deal-shapers on the down side either.

This is a values-shaped call: the analysis prefers IC for skill growth;
the team-lead path prefers role experience. Either is defensible — the
margin alone shouldn't override your gut on which growth axis matters more.
```

Time: ~25 min. Output: an artifact with explicit weights, suitable for a 1:1 doc or a journal note.

### When each is the right tool

- The user has 30 minutes before they need to respond to their manager → **idea-decision-maker**.
- The user wants to think it through over the weekend and have notes to point at later → **idea-choice**.
- The user is genuinely spinning and needs someone to break the tie → **idea-decision-maker**.
- The user is calm but wants the reasoning made explicit → **idea-choice**.

Both skills are correct. The difference is what the user needs more right now: a decision, or a record.

---

## Patterns for when scoring gets weird

### Pattern: "All cons have low confidence"

If every con's Confidence is 2–3, the analysis is dominated by speculation. Two fixes:
- **Run a grill** to convert speculation into informed guesses.
- **Acknowledge in the recommendation** that the down-side is mostly hypothetical, and revisit after first real data.

### Pattern: "Net is +35 but I still don't want to do it"

Two possibilities:
- The criteria are wrong — you're optimizing for the wrong thing. Restate criteria, re-run.
- A real con is missing — the council didn't surface it because *you* didn't surface it. Add the con manually, score it honestly, re-aggregate.

### Pattern: "Same con appears in different language across multiple ideas in a comparison"

Normalize the language and use identical wording, so the comparison table sums it consistently. Otherwise you'll over- or under-count.
