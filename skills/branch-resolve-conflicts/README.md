# Branch Resolve Conflicts

Resolve complex git merge and rebase conflicts by reconstructing the original intent behind each change, then carefully preserve both intents when possible. Runs automated checks (typecheck, tests, format) after resolution to catch breaks early.

## Why this exists

Most merge conflicts are syntactic — "file changed here, also changed there" — and can be resolved mechanically (see [branch-rebase](../branch-rebase/)). But some conflicts are semantic: two branches both modified the same function, and the changes are incompatible. A mechanical resolution will either lose intent or invent new behavior.

This skill is for those conflicts. It digs into commit messages, PRs, and original issues to understand *why* each change was made, then makes an informed choice: preserve both intents (usually by combining them differently), or pick the one matching the merge's goal and document the trade-off. After resolution, it runs the full automated check suite so you don't discover a broken build hours later.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "resolve conflicts"
  - "help me resolve this merge conflict"
  - "i'm stuck on a rebase conflict"
  - "resolve this conflict"
  - "conflict resolution"
- Running the slash command: `/branch-resolve-conflicts`

The skill assumes you're already in the middle of a merge or rebase with conflicts. If you're not, it will ask you to run `git merge` or `git rebase` first.

## What it does

The skill follows a 5-step workflow: understand the current conflict state, discover the intent behind each conflicting change, resolve each hunk while preserving intent, run the full automated check suite, and finish the merge/rebase.

### Inputs

- **Active merge or rebase** — Required. You must be in the middle of `git merge` or `git rebase` with at least one conflicted file.
- **Project context** — The skill reads commit messages, PRs, issues, and code comments to reconstruct intent. Provide links or ticket numbers if context isn't obvious.

### Outputs

- All conflicts resolved (no `<<<<<<< / ======= / >>>>>>>` markers).
- A completed merge or rebase commit(s).
- Automated checks passing (typecheck, tests, format).
- A summary of each conflict's resolution and any trade-offs made.

### External systems used

- Local git (read + write — entire workflow operates on local refs)
- Potentially GitHub/GitLab APIs (read only — fetching PR and issue context)
- Project build tools — typecheck, test, format commands (typically `npm`, `gradle`, `cargo`, `maven`, etc.)

## How to use it

A typical session looks like this:

```text
You: resolve conflicts

Skill: Detecting merge/rebase state...
       Found 3 conflicted files in an active merge.
       Analyzing each conflict...

       Conflict 1 of 3: src/components/checkout.tsx
       ├─ Main branch: Moved validateCart() to separate function
       ├─ Feature branch: Added async/await to submitCart()
       └─ Analysis: Both intent to improve code clarity, not incompatible.
       
       Resolution: Apply both changes — extract function AND add async/await.
       (This is called a "resolve by combine" — both intents preserved.)

       Conflict 2 of 3: src/utils/api.ts
       ├─ Main branch: Changed fetch timeout to 10s (perf improvement)
       ├─ Feature branch: Changed fetch timeout to 30s (timeout fix for slow networks)
       └─ Analysis: Conflicting intents. 
       
       Which should win? 
       A) Main (10s perf, may timeout on slow networks)
       B) Feature (30s safety, slower perf)
       C) Neither — use dynamic timeout (fast by default, retry with backoff)
       
       Your choice?

You: C

Skill: Noted. Implementing dynamic timeout strategy in api.ts.

       Conflict 3 of 3: tests/checkout.test.ts
       ├─ Main branch: Updated test expectations for new timeout
       ├─ Feature branch: Added new test cases for retry logic
       └─ Analysis: Both intent to improve test coverage. Combine.
       
       Resolution: Merging both test files, resolving assertion conflicts.

       Running automated checks...
       ├─ TypeCheck: 2 errors in api.ts (timeout signature changed)
       ├─ Tests: 4 failing (new timeout logic not yet implemented)
       ├─ Format: OK
       
       Fixing type errors and test failures...
       (Showing diffs for each fix)
       
       Re-running checks...
       ├─ TypeCheck: OK
       ├─ Tests: OK
       ├─ Format: OK
       
       All conflicts resolved, checks passing.
       Merge complete. You can now:
         git log --oneline -n 5
         git push
```

## Getting the most out of it

- **Provide context if available.** If you know the PR number or ticket, mention it. The skill can fetch context from GitHub/GitLab to understand intent faster.
- **Be honest about trade-offs.** When two intents conflict, say which goal matters more (performance vs. safety, feature completeness vs. simplicity). The skill will make the choice explicit in the commit message.
- **Review the resolution before continuing.** The skill shows diffs for each conflict and asks before auto-resolving complex ones. If a resolution looks wrong, stop and reconsider.
- **Trust the automated checks.** If tests still fail after conflict resolution, it's a sign the merge broke something subtle. The skill will keep running checks until they pass.
- **Commit the merge, then handle follow-up bugs separately.** If the merge reveals a deeper issue (e.g., the combined code has a race condition), commit the merge, file a follow-up issue, and fix it in a new PR.

## Anti-patterns

- ❌ **Inventing new behavior during resolution.** Conflicts should be resolved by understanding both intents and combining them, not by rewriting the code to "fix it right." If the merge reveals a deeper issue, that's a follow-up, not the merge resolution itself.
- ❌ **Ignoring test failures.** If tests fail after resolving conflicts, stop and investigate. Don't ship a merge where tests are broken.
- ❌ **Using `--ours` or `--theirs` blindly.** Picking one side without understanding intent is how logic gets lost. Use this skill instead.
- ❌ **Aborting the merge.** This skill never aborts. If a conflict is genuinely unresolvable, it will recommend reverting the merge *after* completion and filing a detailed issue, not mid-merge.
- ❌ **Merging without running checks.** A conflict resolution that passes your eye but fails type-check or tests is a hidden bug. Always run checks.
- ❌ **Combining conflicting intents without documenting trade-offs.** When you preserve both intents (e.g., dynamic timeout instead of picking one), add a code comment explaining why both are important.

## Examples

### Example: Incompatible but resolvable via compromise

```text
You: resolve conflicts — we're merging the auth refactor into main

Skill: Found 1 conflicted file: src/auth/session.ts

       Conflict analysis:
       ├─ Main: Moved session validation to a middleware
       ├─ Feature: Extracted session validation to a hook
       └─ Incompatible intent (two different architectures)

       Which approach should win?
       A) Middleware (main branch) — simpler, applies to all routes
       B) Hook (feature branch) — more flexible, per-component opt-in
       C) Both — middleware as default, hook for opt-out

You: C

Skill: Implementing both approaches:
       ├─ Keep middleware as default (main's intent)
       ├─ Export the hook alongside (feature's intent)
       ├─ Add toggle to disable middleware per-component
       
       TypeCheck, tests, format: OK
       
       Merge complete. Commit message explains trade-off:
       "merge: integrate session validation refactor (middleware + hook)"
       
       Migration note: Feature branches can now opt out of middleware
       by using the hook directly. Gradual migration path preserved.
```

### Example: Intent is the same, syntax is different

```text
You: resolve conflicts — feature branch rebasing onto main

Skill: Found 2 conflicted files: src/api/client.ts, src/types.ts

       Conflict 1: src/api/client.ts (apiTimeout constant)
       ├─ Main: Changed timeout value from 5000 to 10000
       ├─ Feature: Also changed to 10000, but via a CONFIG object
       └─ Analysis: Both intent to increase timeout. Same value, different style.
       
       Resolution: Use main's direct constant (simpler, matches codebase style).
       Rebase continues...

       Conflict 2: src/types.ts (RequestOptions interface)
       ├─ Main: Added retryCount field
       ├─ Feature: Added retryOnTimeout field
       └─ Analysis: Both extend the interface for resilience, non-overlapping intent.
       
       Resolution: Add both fields.
       
       Checks: OK
       Rebase complete. All commits rebased cleanly.
```

### Example: One intent wins, document why

```text
You: resolve conflicts — we're merging the performance optimization branch

Skill: Found 1 conflicted file: src/cache/strategy.ts

       Conflict: Cache eviction policy
       ├─ Main: LRU (least recently used) — fair, predictable
       ├─ Feature: LFU (least frequently used) — optimized for real-world workloads
       └─ Analysis: Different algorithms, incompatible.

       Context: Merge goal is "phase 1: implement caching." 
       Perf optimization is a separate goal.
       
       Recommendation: Main's LRU should win (simpler, sufficient for phase 1).
       Feature branch's LFU is a follow-up optimization.
       
       Resolve by: Keeping main's LRU, add TODO comment for future optimization.
       Commit message documents trade-off.

       Checks: OK
       Merge complete. Open issue for "perf: evaluate LFU eviction policy"?
```

The resolved commit message explicitly names the trade-off so future developers understand why this design was chosen.

## Internals

The skill follows a 5-step workflow:

1. **Detect state** — confirm you're in active `git merge` or `git rebase`; list conflicted files; detect conflict markers.
2. **Reconstruct intent** — for each conflicted file, read both versions; check commit messages (`git log -p`); fetch PR context if available; understand the original intent behind each change.
3. **Classify conflicts**:
   - **Syntactic only** — different markers but same intent → merge mechanically, preserve both.
   - **Intent-preserving combine** — both intents are valuable and compatible → find a way to include both (e.g., dynamic timeout instead of picking one).
   - **Incompatible intent** — one must win → apply the merge's stated goal; document the trade-off; recommend a follow-up PR.
4. **Resolve and check** — apply resolutions; run `typecheck` (or `tsc`, `cargo check`, etc.); run tests; run format check. Fix anything broken. Re-run until clean.
5. **Finish** — stage all resolved files; complete the merge (`git merge --continue` or `git rebase --continue`); commit with detailed message explaining trade-offs.

### Key constraints

- **Never invent behavior.** Resolutions should combine or pick existing intents, not create new ones.
- **Always run checks.** A conflict resolution that passes human eyes but fails tests is a hidden bug.
- **Document trade-offs.** If one intent is dropped, the commit message (and ideally a follow-up issue) explains why.
- **Never abort.** If a conflict seems impossible, the recommendation is to complete the merge, then file an issue for deeper refactoring — not to abort mid-merge.

## Comparison: branch-resolve-conflicts vs. branch-rebase

| | **branch-rebase** | **branch-resolve-conflicts** |
| --- | --- | --- |
| **When to use** | Rebasing feature branch onto main for a clean linear history | Complex semantic conflicts during a merge/rebase |
| **Conflict handling** | Auto-resolves trivial conflicts (version bumps, changelog sections) | Reconstructs intent, resolves semantically |
| **Automation** | High — most rebases finish without user input | Low — most conflicts require understanding and choice |
| **Output** | Clean rebase, ready to push | Merge complete, all checks passing, trade-offs documented |
| **Checks** | Post-rebase version bump + changelog | Full suite: typecheck, tests, format |

You'll often run `branch-rebase` to get onto main, then `branch-resolve-conflicts` if a conflict is too complex for auto-resolution.

## FAQ

**Q: What if the conflict looks impossible?**
A: The skill will show you all three versions (base, ours, theirs) and the surrounding context. Usually, looking at the intent makes a path forward clear. If not, the recommendation is to complete the merge anyway, commit it, then file a detailed issue for follow-up refactoring. Aborting hides the problem.

**Q: Can this skill handle a rebase with many conflicted commits?**
A: Yes. It will handle conflicts commit-by-commit, resolve each one, and continue the rebase. You'll work through them sequentially.

**Q: What if I disagree with the skill's analysis of intent?**
A: Stop and tell it. The skill will re-analyze based on your input. Intent reconstruction is collaborative — you provide domain knowledge the skill can't have.

**Q: Does this run tests every time?**
A: Yes. Tests are cheap compared to shipping broken code. The skill will run checks after each conflict batch, and again before marking the merge complete.

**Q: What if tests fail and I don't know how to fix them?**
A: The skill will show the failing tests, then help you decide: is this a problem with the merge resolution, or a pre-existing issue? If it's the merge, it will guide you through fixing it. If it's pre-existing, it can be a separate issue.

**Q: Can I use this for a merge of a super long-lived branch?**
A: Yes, but be prepared for many conflicts. The skill works through them systematically. If there are >10 conflicts, consider whether a deep rewrite might be simpler — use a code-reviewer or architect to assess first.

**Q: What if a conflict is in a file I didn't write?**
A: The skill will read the commit history and PR context to understand intent, even if you didn't author the code. That's the whole point — reconstructing intent from history, not from personal knowledge.

**Q: Should I test locally before running this skill?**
A: You don't need to pre-test, but you do need to be in an active merge/rebase with conflicts. The skill runs checks after resolution, so you'll catch breaks then. Local testing beforehand doesn't hurt, but it's not required.

**Q: Can I use this to merge branches that have been developing in parallel for months?**
A: Yes. The longer branches have been separate, the more conflicts you'll likely have, but the skill handles this. The advantage of resolving by intent (not just syntax) is that it scales well to long-lived branches.

## Troubleshooting

**Conflicts keep reappearing after resolution:**
Likely cause: The skill resolved correctly, but subsequent commits or other branches have similar conflicts. Keep using the skill for each conflict batch. If this happens repeatedly, it's a sign the branching strategy should change — escalate to the git-workflow-manager agent.

**Tests pass locally but fail after merge:**
This usually means the merge introduced a subtle incompatibility the tests don't fully cover. The skill will show the failing test. Review the test and the resolution together to find the gap. If needed, expand the test, fix the merge, and commit the test improvement.

**Automated checks can't find the project's configuration:**
The skill looks for standard config files (package.json, gradle.build, Cargo.toml, etc.). If your project uses a non-standard setup, describe it and the skill will adapt. Alternatively, manually run your checks after the skill finishes the merge.

## Escalation to Agents

This skill handles conflict resolution during an active merge/rebase. Sometimes, the conflict signals a deeper architectural or refactoring problem that needs agent-level expertise.

**When to escalate:**

- **Code Review After Merge** — If the conflict resolution involved significant logic changes, invoke the [code-reviewer agent](https://github.com/risadams/claude-agents) to validate the merged code for quality and correctness.

- **Coordinated Refactoring** — If two branches are both heavily refactoring overlapping code and conflicts are severe, the [refactoring-specialist agent](https://github.com/risadams/claude-agents) can assess whether a coordinated refactor (instead of merging) would be cleaner. Useful when conflicts expose deeper architectural issues.

- **Git Workflow Strategy** — If merges are consistently painful or branching strategy needs rethinking, the [git-workflow-manager agent](https://github.com/risadams/claude-agents) can design better workflows to prevent future conflicts.

## Related skills

- **[branch-rebase](../branch-rebase/)** — for clean, linear history rebases with trivial conflict auto-resolution. Use this first; if a conflict is too complex, escalate to branch-resolve-conflicts.
- **[handoff](../handoff/)** — after resolving complex conflicts, use this to hand off the work to another session or teammate with full context preservation.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
- **[examples.md](examples.md)** — Annotated conflict resolution walkthroughs
