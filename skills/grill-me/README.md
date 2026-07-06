# Grill Me

Interview the user relentlessly about a plan or design — one question at a time, walking the decision tree branch by branch — until reaching shared understanding. For each question, the skill provides a recommended answer so the user can accept, override, or argue. When a question can be answered by exploring the codebase, the skill explores instead of asking.

## Why this exists

Plans look complete in your head and incomplete the moment somebody asks about them. The fastest way to expose what you haven't thought through is to be interrogated by someone who refuses to move on until each branch is resolved. This skill is that interrogator. The one-question-at-a-time discipline is critical: a list of ten questions invites you to skim them and answer the easy ones; one question at a time forces you to engage. The recommended-answer-per-question keeps the friction productive — you're not staring at a blank prompt, you're reacting to a position.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "grill me"
  - "stress-test this plan"
  - "interrogate my design"
  - "interview me on this"
- Running the slash command: `/grill-me`

## What it does

The skill walks the user through the decision tree of a plan, asking one question at a time about each unresolved branch (constraints, dependencies, edge cases, failure modes, scope, alternatives). For each question, the skill provides a recommended answer based on what's known. When a question can be resolved by exploring the codebase (e.g., "how is X currently implemented?"), the skill explores instead of asking. The session ends when the user signals they have enough clarity. It does **not** make decisions for the user — it surfaces decisions and lets the user make them.

### Inputs

- **Plan or design description** — free-form. Can be a paragraph, a spec, a notion page pasted in.

### Outputs

- A series of question/answer exchanges (one at a time) leading to a shared mental model.
- *Optional*: a written summary of the decisions if the user asks at the end.

### External systems used

- Local filesystem (read only — for codebase exploration when relevant)

## How to use it

A typical session looks like this:

```text
You: grill me on my plan to migrate auth from basic to OAuth.

Skill: Q1: Which OAuth flow are you planning — authorization code, PKCE,
       or client credentials? My recommendation: authorization code with
       PKCE for the web app, client credentials for service-to-service.

You: agreed.

Skill: Q2: Where will refresh tokens live — httpOnly cookie, IndexedDB,
       or in-memory only? My recommendation: httpOnly cookie. Anything
       else and an XSS lifts the token.

You: httpOnly cookie.

Skill: Q3: Do you need to support the existing basic-auth tokens during
       cutover, or can you cut hard? My recommendation: parallel-run for
       30 days, accepting both, then cut basic auth. (I checked the code
       — auth/middleware.py already has a try-token-then-fallback pattern,
       so the parallel-run is cheap.)

You: 30-day parallel run, then cut.

Skill: Q4: What's the rollback plan if OAuth provider has an outage on
       day 1 of cutover? My recommendation: feature flag, instant flip
       back to basic auth. The flag should be runtime-toggleable, not
       build-time.

You: agreed.

Skill: Q5: Who owns the IdP relationship after launch? My recommendation:
       platform team if you have one; otherwise the engineer who lands
       this needs to be on-call for it.
       ...
```

## Getting the most out of it

- **Don't skim — actually engage one question at a time.** The skill's value is its refusal to let you batch answers. If you skim, the gap-finding fails.
- **Argue with the recommendations.** Each question comes with a recommended answer. When you disagree, articulate why — that articulation usually exposes the real constraint.
- **Let the skill explore the codebase.** When a question references how something currently works, the skill will look it up rather than ask. Don't preempt with "well, currently we do X" — let the skill verify.
- **Stop when you have enough.** The skill walks the tree until you signal "enough." That's a real signal — not a milestone, just a point where the remaining branches feel lower-stakes than what you've covered.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Make decisions for you.** It surfaces them. The recommended answers are anchors, not commitments.
- ❌ **Ask 10 questions at once.** One at a time. Always.
- ❌ **Replace a design review.** This is a self-stress-test, not a peer review. If you need other voices, run [clarity-council](../clarity-council/) instead.
- ❌ **Leave you with a written plan automatically.** The output is the conversation. If you want a written summary, ask explicitly at the end.

## Examples

### Example: Catching a hidden assumption

```text
You: grill me on adding a feature flag system.

Skill: Q1: Will flags evaluate per-request, per-session, or per-user?
       My recommendation: per-request, with the flag value cached for
       the session if the use case is "rollout" rather than "experiment."

You: per-request.

Skill: Q2: Where does the source of truth live — config file, database,
       or external service like LaunchDarkly? My recommendation: config
       file for v1, database when you want runtime toggle.

You: config file is fine.

Skill: Q3: What happens to in-flight requests when a flag changes mid-flight?
       My recommendation: the cached request-scoped value wins; new requests
       get the new value. If you need atomic flips, that's a separate problem.

You: hadn't thought about that. The "atomic flip" thing — when would that matter?

Skill: When you flip a flag during a multi-request workflow (e.g., a cart
       checkout that spans 3 requests). If the flag controls whether the
       new payment provider is used, you don't want request 1 going to
       the old one and request 3 going to the new one. Want me to walk
       that branch?

You: yes.
```

The "hadn't thought about that" moment is the goal. Each one prevents a future bug.

### Example: Skill explores the codebase instead of asking

```text
You: grill me on refactoring the notifications-worker.

Skill: Q1: What's the current retry policy on failed notifications?
       (Checking the code...)
       Found it — internal/notifications/worker.go uses an exponential
       backoff with max 5 retries, dropping the message after that.
       My recommendation: keep the exponential backoff but make max
       retries configurable instead of hardcoded.

You: agreed.

Skill: Q2: Are dropped messages logged anywhere or silently lost?
       (Checking...)
       Logged to stderr as WARN level — not stored. My recommendation:
       move the dropped messages to a dead-letter queue so they're
       inspectable. Want me to walk the DLQ design?

You: yes.
```

Codebase questions get answered by reading code, not by asking the user to recall.

## Internals

The skill's workflow is intentionally minimal — most of the work is in the discipline of *one question at a time* and *recommend an answer*:

1. **Read the plan** the user provides.
2. **Identify the decision tree** — every unresolved branch is a question.
3. **Pick the next question** — usually the one with the highest "if this is wrong, the rest of the plan changes" leverage.
4. **Provide a recommendation** with the question.
5. **Wait for the user's answer** before moving on.
6. **Update the tree** based on the answer (some branches collapse; new ones may surface).
7. **Loop until the user signals enough.**

When a question can be resolved by reading code instead of asking, the skill reads code. The user's time is spent on questions only the user can answer.

Key constraints:

- **One question per turn.** No batching.
- **Recommendation per question.** No bare prompts.
- **Codebase exploration over questions when possible.**

## FAQ

**Q: How is this different from clarity-council?**
A: Council collects multiple opinions on a decision; grill-me interrogates *you* about your plan. Council is "what would different experts say?"; grill-me is "here are the gaps in your thinking."

**Q: How is this different from grill-with-docs?**
A: Grill-with-docs anchors against project documentation (CONTEXT.md, ADRs) and updates those docs inline as decisions crystallize. Grill-me is plain — no documentation context, no docs updates.

**Q: Will the skill ever say "I don't have enough info to ask the next question"?**
A: Yes. When the next question depends on context the skill doesn't have, it asks for that context first instead of guessing.

**Q: Can I pause and resume?**
A: Yes — re-invoke the skill in a later turn with "continue grilling on the auth migration plan." The skill will pick up where the conversation left off.

**Q: Does the skill care about my plan being good?**
A: No. The skill cares about your plan being *understood*. If your plan is bad, the questions will surface that — but the skill won't editorialize.

## Related skills

- **[grill-with-docs](../grill-with-docs/)** — same shape, but anchored to project documentation and updates docs inline.
- **[clarity-council](../clarity-council/)** — for getting *other* perspectives instead of stress-testing your own plan.
- **[request-refactor-plan](../request-refactor-plan/)** — Phase 4 of that skill borrows the grill-me discipline for the implementation interview.
- **[writing-draft-article](../writing-draft-article/)** — Phase 1 of that skill can delegate to grill-me for thesis stress-testing.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the discipline is the skill — the file is short by design)
