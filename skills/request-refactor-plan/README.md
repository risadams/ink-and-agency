# Request Refactor Plan

Walk the user through a structured refactor interview, then file the result as a GitHub issue with a detailed plan of tiny commits. The interview covers problem, alternatives, scope, and test coverage; the output is an actionable plan that someone (you, your future self, or a teammate) can execute commit-by-commit while keeping the codebase in a working state at every step.

## Why this exists

Refactors fail two ways: undocumented and oversized. Undocumented refactors get half-done and abandoned because the why was in someone's head and they got distracted. Oversized refactors try to land in one heroic PR, fail review, and become a permanent branch graveyard. A written plan with tiny commits — Martin Fowler's discipline — fixes both. This skill produces that plan through a guided interview, then files it as a GitHub issue so the plan survives context-switches and can be tracked, claimed, and updated like any other unit of work.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "plan a refactor"
  - "create a refactoring RFC"
  - "break this refactor into safe steps"
  - "request a refactor plan for {area}"
- Running the slash command: `/request-refactor-plan`

## What it does

The skill conducts an 8-step interview: problem statement, codebase verification, alternatives consideration, implementation interview, scope definition, test coverage check, commit decomposition (Fowler-style tiny commits), and GitHub issue creation. The output is a structured GitHub issue with sections for Problem, Solution, Commits, Decisions, Testing, Out of Scope, and Notes. It does **not** apply the refactor; the issue is the deliverable for someone (often you) to execute later.

### Inputs

- **Refactor description** — free-form. The user starts with a problem they want to solve and ideas for how.
- **Codebase access** — read-only exploration to verify assumptions and check test coverage.

### Outputs

- A GitHub issue containing the full refactor plan in the structured template format.

### External systems used

- Local filesystem (read only — codebase exploration to verify claims)
- GitHub (write — `gh issue create` to file the resulting plan)

## How to use it

A typical session looks like this:

```text
You: I want to plan a refactor of the auth middleware

Skill: Tell me about the problem in detail. What hurts about the current
       middleware? What ideas do you have for fixing it?

You: It's three files (middleware.py, refresh.py, session_store.py) doing
     overlapping work. I want to consolidate into one Token Refresh module.

Skill: [explores auth/]
       Confirmed: middleware.py calls refresh.py twice with different retry
       params; refresh.py imports from session_store.py for cache lookup.
       The retry logic is duplicated in middleware.py and refresh.py.

       Have you considered alternatives? E.g., (1) keep three files but
       extract a shared retry helper, or (2) introduce a Token interface
       that both refresh and session_store implement?

You: Hadn't considered (2). Let's discuss...

       [...interview continues through scope, test coverage, commit plan...]

Skill: Filing the GitHub issue at github.com/example-org/web-checkout...

       Created: github.com/example-org/web-checkout/issues/4521
       Title: "Refactor: consolidate token refresh into single module"
```

## Getting the most out of it

- **Bring a problem, not a solution.** The interview probes alternatives in step 3. If you arrive committed to a specific implementation, you'll skip the most valuable step.
- **Be honest about test coverage.** Step 6 asks. If the area is undertested, the commit plan will include "add characterization tests" as the first commits — that's the right answer, not a problem.
- **Trust the tiny-commit constraint.** "Each commit should leave the codebase in a working state" feels excessive until you're three commits deep and the build breaks. Tiny commits make the bisect easy and the reviewer happy.
- **Don't include file paths in the Decision Document.** The skill enforces this: file paths rot fast. Decisions describe modules and interfaces; paths belong in the commit messages, not in the plan.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Apply the refactor.** The skill produces a plan, not a diff. Implementation is a separate task once the plan is filed and reviewed.
- ❌ **File the issue silently.** The skill always shows you the issue body before posting and confirms the repo + title. There's no `--yes` mode.
- ❌ **Plan refactors against code it can't see.** Step 2 verifies the user's claims by reading the codebase. If the code described doesn't exist or doesn't do what the user thinks, the skill flags it and the interview pauses.
- ❌ **Produce a one-commit plan.** Even small refactors get decomposed into the tiniest steps that compile. If the natural answer is "just one commit," the refactor probably doesn't need a plan — write it directly.

## Examples

### Example: Small refactor, 4-commit plan

```text
You: refactor — extract the validation logic out of the order intake handler

Skill: [interview]

       Filed at: github.com/example-org/payments-api/issues/892

       Title: "Refactor: extract validation from intake handler"

       Plan:
       1. Add tests covering current intake validation behavior (no code change).
       2. Introduce a Validate() function in same file (called by handler).
       3. Move Validate() into a new module; update import.
       4. Delete unused inline validation; verify tests still pass.

       Each commit leaves the codebase building and passing tests.
```

Even a "simple" refactor benefits from explicit decomposition.

### Example: Refactor pauses when codebase reveals surprise

```text
You: refactor — split the AuthService class into AuthN and AuthZ classes

Skill: [exploring auth/...]
       The codebase has AuthMiddleware and AuthHandler, not AuthService.
       Are you thinking of a different repo, or has the structure changed
       since you last looked?

You: oh — must be thinking of the old codebase. Let me re-read first.

Skill: Pausing the plan. Re-invoke when you've confirmed the current shape.
```

The verification step prevents plans built on outdated mental models.

## Internals

The skill follows an 8-step workflow. Steps may be skipped if not relevant:

1. **Ask for a long, detailed problem description** — including any solution ideas the user has.
2. **Explore the repo** — verify the user's assertions; understand the current state.
3. **Surface alternatives** — ask whether the user considered other options; offer alternatives.
4. **Interview about implementation** — extremely detailed and thorough.
5. **Define scope** — what changes, what doesn't.
6. **Check test coverage** — read the test files for the affected area; ask about testing plan if coverage is thin.
7. **Decompose into tiny commits** — Fowler discipline: each commit leaves the codebase working.
8. **File a GitHub issue** — using the structured template (Problem / Solution / Commits / Decisions / Testing / Out of Scope / Notes).

GitHub issue template structure:

- **Problem Statement** — the developer's view of what hurts.
- **Solution** — the developer's view of how to fix it.
- **Commits** — a long, plain-English plan; one paragraph per commit; each commit leaves things working.
- **Decision Document** — modules built/modified, interfaces changed, technical clarifications, architectural decisions, schema changes, API contracts. *No file paths or code snippets* — they rot.
- **Testing Decisions** — what makes a good test for this area, which modules will be tested, prior art in the codebase.
- **Out of Scope** — what this refactor explicitly does not touch.
- **Further Notes** — optional.

Key constraints:

- **Read-only against the codebase.** No code changes during the interview.
- **GitHub issue is the only side effect.** No PRs, no commits, no branch creation.
- **No file paths in the Decision Document.** Decisions describe shapes; paths belong elsewhere.

## FAQ

**Q: Why GitHub issues and not Jira?**
A: The skill name hints — it's GitHub-flavored. For Jira-tracked workflows, file the issue in Jira and paste the rendered plan into a comment. The structure transfers.

**Q: What if my refactor is too big to write a plan for in one session?**
A: Run the skill on a sub-piece. A "rewrite the auth system" plan is too coarse; "consolidate the token refresh logic" is the right scope. If the answer is "we need to rewrite the auth system," that's an architectural conversation — start with [codebase-improve-architecture](../codebase-improve-architecture/) instead.

**Q: Does it open the GitHub issue in my browser?**
A: It returns the URL. Whether you open it is up to your terminal; many setups make GitHub URLs clickable.

**Q: What if I don't have `gh` installed?**
A: The skill uses the `gh` CLI for the issue creation. Install it (`brew install gh` or platform equivalent) before running, or paste the rendered template into the GitHub web UI manually.

**Q: Can I edit the plan after filing?**
A: Of course — it's a GitHub issue. Edit it like any other issue; comment with updates as the refactor progresses. The skill doesn't track or update the issue once filed.

## Related skills

- **[codebase-improve-architecture](../codebase-improve-architecture/)** — when the refactor scope isn't clear yet, run this first to design the deepening before planning the implementation.
- **[branch-rebase](../branch-rebase/)** — once the refactor is in progress, use this to keep the branch synced with main between commits.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
