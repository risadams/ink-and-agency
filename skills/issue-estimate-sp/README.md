# Issue Story-Point Estimator

Read-only story-point estimate for a Jira ticket via context gathering and a multi-persona scrum-poker session. The skill pulls the ticket plus its related context, calibrates against historical actuals from a reference dataset, runs four personas through a clarity-council "play your card" round, and returns a Fibonacci estimate with reasoning — without touching the ticket.

## Why this exists

Estimation meetings are expensive. A 30-minute scrum-poker session for one ticket can swallow an hour of three engineers' time, and the resulting number is often noisier than what a structured analysis of the ticket plus historical comparables would produce. This skill collapses the "gather context and argue about it" loop into a single chat turn while keeping the multi-perspective rigor that makes scrum poker useful in the first place. Read-only by default means you can use it before the meeting (to anchor discussion) or instead of it (when the team trusts the heuristic).

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "estimate this ticket"
  - "how many points for PROJ-1234"
  - "story point estimate for ABC-456"
- Running the slash command: `/issue-estimate-sp PROJ-1234`

## What it does

The skill takes a Jira ticket key, gathers the ticket plus related context (parent epic, linked tickets, Confluence pages, similar completed work), loads a reference dataset of historical actuals for calibration, runs a four-persona scrum-poker session via clarity-council, and returns a Fibonacci estimate (1, 2, 3, 5, 8, 13, 21) with rationale and risk factors. It does **not** write the estimate back to the ticket.

### Inputs

- **`ticket_key`** — string, required. Format: `[A-Z][A-Z0-9]+-\d+` (e.g., `PROJ-1234`).

### Outputs

- A markdown estimate report containing: recommended Fibonacci value, scrum-poker results table (one row per persona), 2-3 sentence rationale, risk factors, and a comparable-tickets table sourced from [REFERENCE_DATA.md](REFERENCE_DATA.md).

### External systems used

- Jira (read only — `jira_get_issue`, `jira_get_comments`, `jira_get_changelog`, `jira_search`, `jira_get_epic_issues`)
- Confluence (read only — `confluence_search`, `confluence_get_page`)
- Local filesystem (reads `REFERENCE_DATA.md` for calibration)

## How to use it

A typical session looks like this:

```text
You: estimate WEB-7890

Skill: [Step 1] Pulled WEB-7890.
       Type: Story · Priority: Medium · Components: checkout-flow
       Summary: "Add Apple Pay option to mobile checkout"

       [Step 2] Parent epic: WEB-7000 (mobile-payments-q2). 2 linked stories.
       [Step 3] Loaded reference data — keyword "Apple Pay" anchors at 5 SP.
       [Step 4] Council deliberating...

       ## Story Point Estimate: WEB-7890

       **Recommended: 5 story points**

       ### Scrum Poker Results
       | Persona | Card | Reasoning |
       |---------|------|-----------|
       | Scrum Master | 5 | Fits a sprint; matches WEB-6240 actual flow time. |
       | Tech Lead | 5 | Two integration points; coordination tax with payments-api team. |
       | Senior Developer | 3 | Implementation is straightforward — Apple Pay SDK is well-trodden. |
       | QA Engineer | 5 | Sandbox testing requires real device; regression risk on existing checkout. |

       ### Risk factors
       - Payments-api team must be available to review the contract change.
       - First-time Apple Pay sandbox setup may add half a day of yak-shaving.
```

## Getting the most out of it

- **Run before the planning meeting, not in place of it.** The estimate anchors discussion. If the team's gut disagrees with the skill's number, that disagreement is the actual conversation worth having.
- **Keep [REFERENCE_DATA.md](REFERENCE_DATA.md) current.** The calibration is only as good as the comparables. Add representative tickets at each Fibonacci level after each retrospective; remove ones that have aged out.
- **Trust the keyword anchors.** If the ticket summary contains a strong keyword signal (e.g., "smoke test", "STIG upgrade", "investigate"), the keyword table has empirical authority — let it pull the estimate before the council debates.
- **Watch for split-pressure.** When the council recommends 13 or 21, that's usually a signal the ticket should be split rather than estimated. Read the rationale before accepting.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Write the estimate back to the ticket.** The skill is strictly read-only. Update story points yourself in Jira after team agreement.
- ❌ **Estimate epics or features.** The skill targets atomic work items (Story, Task, Bug). For features, use [issue-feature-breakdown](../issue-feature-breakdown/) first to decompose, then estimate each piece.
- ❌ **Replace the team's velocity.** A 5-SP ticket means "about 5 days of flow time for this team based on history." Other teams calibrate differently — port the reference data before relying on cross-team estimates.
- ❌ **Treat 21 as a real estimate.** Per the council's rules, 21 means "we don't know enough to estimate this." Take it as a signal to split or spike, not as a number to commit to.

## Examples

### Example: A "smoke test" keyword anchor

```text
You: estimate ABC-456

Skill: Summary: "Smoke test new login flow before release"
       Keyword anchor: "smoke test" → 1 SP (per REFERENCE_DATA.md)
       Council confirms.

       **Recommended: 1 story point**
       Reasoning: Smoke tests historically resolve in <1 day. No dependencies surfaced.
```

Strong keyword signals short-circuit the council debate.

### Example: Council disagreement, split recommended

```text
You: estimate PROJ-1234

Skill: Summary: "Refactor authentication to use OAuth instead of basic auth"

       ### Scrum Poker Results
       | Persona | Card |
       |---------|------|
       | Scrum Master | 8 |
       | Tech Lead | 13 |
       | Senior Developer | 13 |
       | QA Engineer | 21 |

       ### Recommendation: SPLIT
       The 21 from QA flags broad regression risk that no single sprint absorbs.
       Suggested decomposition:
       - PROJ-1234a: Spike OAuth library selection (3 SP)
       - PROJ-1234b: Implement OAuth flow against staging IdP (8 SP)
       - PROJ-1234c: Migration plan + parallel-run validation (5 SP)
```

When QA plays a 21, the skill recommends decomposition rather than committing to a 13.

## Internals

The skill follows a 5-step workflow:

1. **Gather ticket context** — issue, comments, changelog (so prior estimates and debates are visible).
2. **Gather related context** — parent epic, linked tickets, Confluence references, similar completed tickets matching team labels (`emerald`, `pyrite`, etc.) or category labels (`POAM`, `sp-candidate`).
3. **Load reference data** — reads [REFERENCE_DATA.md](REFERENCE_DATA.md) for representative tickets at each Fibonacci level, keyword anchors, and team estimation profiles.
4. **Run scrum-poker council** — invokes `/clarity-council` with `scrum-master`, `tech-lead`, `senior-developer`, `qa-engineer` personas; each plays a Fibonacci card independently before group synthesis.
5. **Present estimate** — recommended value, per-persona reasoning, risk factors, and comparable-ticket table.

Key constraints:

- **1 story point ≈ 1 business day of flow time** (In Progress → Done). Calibrated against the project's historical actuals.
- **Fibonacci values only**: 1, 2, 3, 5, 8, 13, 21. The 21 is a "split me" flag, not a real estimate.
- **Read-only across Jira and Confluence.** No write tools allowed.

## FAQ

**Q: Why is my project's estimate different from another team's for the same kind of work?**
A: Story points are a team-local measure of flow time, not a universal complexity unit. Different teams have different review queues, deployment cadences, and coordination overhead. Don't normalize across teams.

**Q: What if the ticket has no comparable in REFERENCE_DATA.md?**
A: The council still deliberates from first principles using ticket scope and acceptance criteria. The estimate may be noisier — flag it as low-confidence and consider a spike.

**Q: Can I get a non-Fibonacci estimate?**
A: No. Fibonacci is the constraint. If you want hours, multiply SP by your team's average hours-per-point — but recognize that's a leaky abstraction.

**Q: Does the changelog data influence the estimate?**
A: Yes — if SP was previously set and changed, the council will note it as evidence of prior team disagreement and weight the new estimate accordingly.

## Related skills

- **[issue-feature-breakdown](../issue-feature-breakdown/)** — for features (vs atomic stories), decompose first then estimate each piece.
- **[clarity-council](../clarity-council/)** — Step 4 invokes this directly. Use standalone when you want the same panel to estimate something that isn't a Jira ticket.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
- **[REFERENCE_DATA.md](REFERENCE_DATA.md)** — Historical calibration data: representative tickets per Fibonacci level, keyword anchors, team profiles
