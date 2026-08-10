# Codebase Improve Architecture

Surface architectural friction in a codebase and propose **deepening opportunities** — refactors that turn shallow modules into deep ones, with the goal of better testability and AI-navigability. The skill is grounded in the project's domain glossary (`CONTEXT.md`) and existing decisions (`docs/adr/`), so suggestions speak the team's language and don't re-litigate settled questions.

## Why this exists

"Refactor opportunities" without a frame produce noise. Without grounding in the project's domain vocabulary, suggestions drift into generic patterns — "extract a service," "introduce a boundary" — that don't survive review. Without grounding in past decisions, suggestions re-propose the same idea that was rejected six months ago for good reasons. This skill enforces both groundings: every candidate uses the project's terms, and every candidate that contradicts an ADR is flagged explicitly with a reason worth re-opening.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "improve the architecture"
  - "find refactoring opportunities"
  - "find tightly-coupled modules to consolidate"
  - "make this codebase more testable"
- Running the slash command: `/codebase-improve-architecture`

## What it does

The skill explores the codebase looking for shallow modules, friction points, and untested seams; presents a numbered list of deepening candidates; lets the user pick one; then drops into a grilling conversation to design the deepened module. Side effects happen *inline*: domain terms get added to `CONTEXT.md`, rejected candidates with load-bearing reasons get recorded as ADRs, and alternative interfaces are explored via [INTERFACE-DESIGN.md](../codebase-design/INTERFACE-DESIGN.md). It does **not** apply refactors automatically — the design conversation is the deliverable.

### Inputs

- **Codebase scope** — optional. The whole repo, a subsystem, or a specific module. Free-form.
- **Existing CONTEXT.md** — optional. Read first if present; provides domain vocabulary.
- **Existing docs/adr/** — optional. Read first if present; informs which suggestions to skip or flag.

### Outputs

- A numbered list of **deepening candidates**, each with files / problem / solution / benefits.
- A **grilling conversation** for the selected candidate.
- *Inline side effects*: appended terms to `CONTEXT.md`, drafted ADRs in `docs/adr/`, explored alternative interfaces.

### External systems used

- Local filesystem (read/write — codebase, `CONTEXT.md`, `docs/adr/`)
- Git history (read — the scan is weighted toward paths that change often)
- Parallel read-only exploration agents where the host provides them; the walk falls back to direct reads where it doesn't

## How to use it

A typical session looks like this:

```text
You: improve architecture in the auth module

Skill: Reading CONTEXT.md and docs/adr/...
       (Found 12 domain terms, 3 ADRs about auth.)

       Exploring auth/...

       Deepening candidates:

       1. Consolidate token refresh logic
          Files: auth/middleware.py, auth/refresh.py, auth/session_store.py
          Problem: Refresh logic split across 3 files; same retry logic
            duplicated in middleware and refresh.
          Solution: Introduce a Token Refresh module behind a single
            interface. Middleware calls it once.
          Benefits: Locality (one place to change retry policy);
            tests can target the refresh module directly.

       2. Adapter for IdP integration
          Files: auth/oidc.py, auth/saml.py
          Problem: Two implementations of essentially the same flow;
            no shared interface.
          Solution: IdentityProvider seam with one adapter per protocol.
          Benefits: Adding a new IdP becomes a 1-file change instead of 3.
          (Note: contradicts ADR-0007 — but worth reopening because the
          third IdP request is now in the backlog.)

       Which would you like to explore?

You: 2.

Skill: [Grilling loop on candidate 2]
       Constraints: which IdP must always remain the default?
       (...continues design conversation, updates CONTEXT.md inline as
       new terms emerge, drafts ADR if you reject the candidate)
```

## Getting the most out of it

- **Have a CONTEXT.md before running.** Without one, candidates use generic terms. The skill will offer to start one, but bringing your own gives much sharper output.
- **Start with a scope.** "Improve the architecture" against a 200-file repo produces too many candidates. Scope to a subsystem you've been frustrated by.
- **Engage the grilling loop honestly.** The grilling conversation is where good designs are pressure-tested. Skipping it gets you a list of vague proposals; engaging produces an actual design.
- **Capture the rejections.** When you reject a candidate with a real reason, accept the ADR offer. Future runs of the skill won't re-suggest the same thing.

## It's working if

- The candidates name your domain's concepts — "the Order intake module", not "the FooBarHandler".
- The candidates cluster in files that have changed recently, not in dormant corners of the repo.
- No code changed during the run. The deliverable is the list and the conversation.
- **It stops after the list and asks which candidate you want**, instead of interrogating you about the first idea it had.
- Each candidate carries a strength label, and a report that's all `Speculative` is stated as "this area looks healthy" rather than dressed up.
- Each card explains the payoff as locality or leverage and says which tests get simpler — not just "this is cleaner".
- Rejecting a candidate for a durable reason gets you an offer to record an ADR, so the next run doesn't re-suggest it.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Apply refactors automatically.** The skill is a design tool. Implementing the refactor is a separate task — usually one for [codebase-plan-refactor](../codebase-plan-refactor/) followed by careful incremental commits.
- ❌ **Suggest a refactor with no callers.** Per the deletion test: a module that doesn't simplify anything when deepened isn't worth deepening. The skill skips suggestions that fail this test.
- ❌ **Use generic vocabulary when the domain has its own.** "Service," "component," "API," "boundary" — all banned. The skill uses Module, Interface, Implementation, Seam, Adapter (see [codebase-design](../codebase-design/)) and the project's domain terms from `CONTEXT.md`.
- ❌ **Re-propose ADR-rejected candidates as if new.** When a candidate contradicts an ADR, the skill flags it explicitly and only surfaces it if there's a load-bearing reason to re-open the discussion.

## Examples

### Example: Suggesting a deepening of a shallow module

```text
Candidate: Deepen the Order intake module

Files: internal/orders/intake.go, internal/orders/validate.go,
       internal/orders/normalize.go

Problem: intake.go is 40 lines that calls validate.go (15 lines) and
  normalize.go (12 lines) in sequence. Three modules, each with a
  one-line public function. The interface is nearly as complex as
  the implementation — shallow.

Solution: Collapse validate and normalize into intake. The Order
  intake module's public interface becomes a single function:
  Intake(raw RawOrder) (Order, error). Internal helpers stay private.

Benefits:
  - Locality: changes to validation rules and normalization happen in
    one place. Currently a new field requires touching 3 files.
  - Leverage: callers see one function instead of three.
  - Tests: the test surface becomes a single function. Currently 3
    test files mostly duplicate setup.
```

The candidate names the *shape* — "Order intake module" — using the project's domain term, not "OrderHandler" or "Intake service."

### Example: Adding a CONTEXT.md term inline

```text
Skill: ...during the grilling loop...
       You're calling this the "Reservation" module. CONTEXT.md doesn't
       have that term yet. I can add:

       Reservation — A temporary hold on inventory placed during checkout
       and either confirmed (becomes part of an Order) or released
       (returned to available stock) within 30 minutes.

       Add to CONTEXT.md? (Yes / Adjust wording / No)
```

Domain vocabulary grows as the design conversation surfaces concepts.

## Internals

The skill follows a 3-phase process:

1. **Explore** — reads `CONTEXT.md` and any `docs/adr/` first; then uses `Agent(subagent_type=Explore)` to walk the codebase organically. Notes friction: deep concepts requiring many small modules to understand, shallow modules where interface ≈ implementation, pure-function extractions that lost locality, tightly-coupled leaks across seams, untested or hard-to-test areas.
2. **Present candidates** — numbered list, each with files / problem / solution / benefits. Uses Module/Interface/Implementation/Seam/Adapter vocabulary plus the project's domain terms. Flags ADR conflicts explicitly. Asks the user which to explore.
3. **Grilling loop** — drops into design conversation for the selected candidate. Walks constraints, dependencies, the deepened module's shape, what survives, what tests look like. Side effects inline: append to `CONTEXT.md`, draft ADR if user rejects, explore interfaces via [INTERFACE-DESIGN.md](../codebase-design/INTERFACE-DESIGN.md).

Key principles (full list in [codebase-design](../codebase-design/)):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

## FAQ

**Q: What is "deepening"?**
A: Increasing the leverage at the interface — more behavior behind a smaller, simpler API. The opposite of "extracting a tiny module just because we can." See [DEEPENING.md](../codebase-design/DEEPENING.md) and [codebase-design](../codebase-design/).

**Q: Why ban words like "service" and "boundary"?**
A: They're overloaded and drift in meaning. Module, Interface, Seam, Adapter have precise definitions in [codebase-design](../codebase-design/). Using them consistently makes the design conversation portable across reviewers.

**Q: What if there's no CONTEXT.md?**
A: The skill will offer to start one as terms emerge during the grilling loop. You can also draft one upfront with [grill-with-docs](../grill-with-docs/).

**Q: Does it actually write code?**
A: No. The output is a design conversation and updated docs (CONTEXT.md, ADRs). For implementation, hand off to [codebase-plan-refactor](../codebase-plan-refactor/) or implement directly with normal coding tools.

**Q: When does it record an ADR?**
A: Only when the user rejects a candidate with a *load-bearing* reason — one that a future explorer would need to know to avoid re-suggesting the same refactor. Ephemeral reasons ("not worth it right now") and self-evident ones don't get ADRs.

## Related skills

- **[codebase-churn](../codebase-churn/)** — pair these. Churn surfaces *which* files are unstable; this skill decides *what to do* about them.
- **[codebase-explain](../codebase-explain/)** — run first to orient if you don't know the area well.
- **[grill-with-docs](../grill-with-docs/)** — for drafting `CONTEXT.md` and `docs/adr/` artifacts. The grilling conversation in this skill follows the same discipline.
- **[codebase-plan-refactor](../codebase-plan-refactor/)** — once a deepening is designed, this skill builds an incremental commit plan for the implementation.
- **[codebase-design](../codebase-design/)** — the vocabulary and principles this skill speaks. It owns the glossary, `DEEPENING.md`, and `INTERFACE-DESIGN.md`; this skill supplies the scan and the grilling loop.
- **[domain-modeling](../domain-modeling/)** — owns `CONTEXT.md` and the ADR discipline this skill triggers inline.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions the agent follows)

Shared reference lives in the skills that own it:

- **[codebase-design/DEEPENING.md](../codebase-design/DEEPENING.md)** — dependency categories and seam discipline for a deepening
- **[codebase-design/INTERFACE-DESIGN.md](../codebase-design/INTERFACE-DESIGN.md)** — exploring alternative interfaces during the grilling loop
- **[domain-modeling/CONTEXT-FORMAT.md](../domain-modeling/CONTEXT-FORMAT.md)** and **[domain-modeling/ADR-FORMAT.md](../domain-modeling/ADR-FORMAT.md)** — formats for the artifacts written inline
