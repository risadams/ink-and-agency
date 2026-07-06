---
name: branch-resolve-conflicts
description: "Resolve complex git merge/rebase conflicts by reconstructing intent, preserving both branches' goals when possible, and running automated checks."
argument-hint: "Optional: PR number, ticket, or merge context (e.g., 'GitHub #1234' or 'merging feature/checkout into main')"
version: 1.0.0
license: MIT
allowed-tools:
  - Read
  - Edit
  - Bash
  - Grep
  - Glob
related-agents:
  - code-reviewer
  - git-workflow-manager
  - refactoring-specialist
related-skills:
  - branch-rebase
loop-eligible: false

---

## Workflow

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.

4. Discover the project's **automated checks** and run them — typically typecheck, then tests, then format. Fix anything the merge broke.

5. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.

---

## See also

- **[README](README.md)** — Full guide with examples and best practices
- **[examples.md](examples.md)** — Annotated conflict resolution walkthroughs

