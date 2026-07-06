# Branch Rebase

Safely rebase the current feature branch onto its upstream target (baseline, main, or master) with automatic resolution of trivial conflicts — version bumps in build manifests, additive entries in changelogs — and explicit prompts for anything more complex. Never pushes; never amends; never bypasses hooks.

## Why this exists

Manual rebases consume disproportionate attention for the same handful of repetitive conflicts: `version = "1.3.0"` vs `version = "1.4.0"` in `build.gradle`; `## 1.3.0` vs `## 1.4.0` headings in `CHANGELOG.md`; the same patch pattern across `package.json`, `pom.xml`, `*.csproj`. These are decisions, but they're not interesting decisions — and getting them wrong creates ugly merge histories. This skill resolves the boring conflicts mechanically while strictly handing the interesting ones back to the human, then takes care of the post-rebase version bump and changelog hygiene that everyone forgets until CI complains.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "rebase"
  - "rebase onto main"
  - "update my branch"
  - "sync with baseline"
  - "catch up with main"
- Running the slash command: `/branch-rebase` or `/branch-rebase main`

## What it does

The skill runs an 8-step workflow: validate the working tree, detect the target branch (defaults to baseline → main → master), refuse to start if there are uncommitted changes, fast-forward the target, rebase the current branch, auto-resolve trivial conflicts (version bumps, changelog version-section additions), prompt for complex conflicts, then perform a post-rebase version bump and changelog hygiene pass if the rebase collapsed the version. It does **not** push, force, amend, or skip hooks.

### Inputs

- **Target branch** — optional. Defaults to the first of `baseline`, `main`, `master` that exists locally or on `origin`.

### Outputs

- A clean rebase against the target branch.
- *Optional*: a follow-up commit (`chore: bump version to {NEW_VERSION} after rebase onto {TARGET}`) if the rebase collapsed the version.
- A summary listing files auto-resolved + any version/changelog changes made.

### External systems used

- Local git (read + write — the entire workflow operates on local refs)
- Remote `origin` (read only — `git pull --ff-only` for the target branch)

## How to use it

A typical session looks like this:

```text
You: rebase

Skill: Validating environment...
       Current branch: feat/checkout-redesign
       Target detected: main (no baseline branch found).
       Working tree clean.

       Updating main: git pull --ff-only — fast-forwarded 12 commits.
       Returning to feat/checkout-redesign: git rebase main.

       Rebase paused on conflict in CHANGELOG.md.
       Auto-resolving: target added ## 1.4.0; current has ## 1.5.0.
       Keeping both sections, newest first. git add CHANGELOG.md.

       Continuing rebase... clean.

       Post-rebase check: build.gradle version is 1.4.0 (matches target).
       Auto-bumping to 1.4.1. Updated CHANGELOG.md with new section.

       Committing: chore: bump version to 1.4.1 after rebase onto main.

       Rebase complete. Your branch has not been pushed. When ready:
         git push --force-with-lease
```

## Getting the most out of it

- **Commit or stash before invoking.** The skill stops immediately if the working tree is dirty. That's intentional — a dirty rebase is how work gets lost.
- **Trust the auto-resolutions, but verify the diff.** When the skill auto-resolves a conflict, it tells you which file. After the rebase finishes, `git diff main...HEAD` lets you spot-check.
- **Use `--force-with-lease` for the push, not `--force`.** The skill never pushes, but the suggestion at the end is `--force-with-lease` for a reason: it refuses to clobber commits you didn't know about.
- **Re-run after merging into your branch.** If you cherry-picked a hotfix from main, re-running the rebase keeps the linear history clean and prevents the patch from appearing twice.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Push the branch.** Pushing is your decision and timing. The skill only suggests the command.
- ❌ **Use `--force` (without lease).** Force-pushing without lease can clobber commits made by collaborators on shared branches. The skill always recommends `--force-with-lease`.
- ❌ **Auto-resolve same-version changelog conflicts.** If both branches added entries under the same version heading (e.g., both touched `## 1.4.0`), that's a logical clash, not a mechanical one. The skill prompts and recommends a version bump on the current branch.
- ❌ **Merge entries from two branches under one version heading.** This creates muddled changelogs that are hard to attribute. The skill always bumps the version instead.
- ❌ **Skip hooks (`--no-verify`).** Pre-commit hooks exist for a reason. If a hook fails during the post-rebase commit, the skill stops and asks you what to do.

## Examples

### Example: Clean rebase, no conflicts

```text
You: rebase onto main

Skill: Working tree clean. Updating main (fast-forwarded 4 commits).
       Rebasing feat/auth-token-refresh onto main... clean.

       No version collapse. No changelog updates needed.

       Rebase complete. When ready:
         git push --force-with-lease
```

The fast path is genuinely fast — usually under 10 seconds.

### Example: Auto-resolve build.gradle version conflict

```text
You: rebase

Skill: Conflict in build.gradle.
       Auto-resolving: keeping current branch's version 2.1.0
       (target moved to 2.0.5 on a release branch).
       git add build.gradle.

       Continuing... clean.
       Post-rebase check: version 2.1.0 is unique. No bump needed.

       Rebase complete.
```

The "current branch wins" rule for version conflicts respects the developer's intentional bump.

### Example: Complex conflict requires user input

```text
Skill: Conflict in src/checkout/cart-button.tsx (not auto-resolvable).

       Showing diff:
       <<<<<<< HEAD (target)
       const handleClick = useCallback(() => {
         analytics.track('checkout_clicked');
         submitCart();
       }, []);
       =======
       const handleClick = useCallback(async () => {
         await validateCart();
         submitCart();
       }, []);
       >>>>>>> feat/cart-validation (current)

       This conflict needs manual resolution. Options:
       1. Resolve it now (I'll wait while you edit).
       2. Abort the rebase (git rebase --abort).

       Which?
```

Anything outside the auto-resolve table is handed back with full context.

## Internals

The skill follows an 8-step workflow:

1. **Validate environment** — confirm git repo, fail otherwise.
2. **Detect branches** — current branch (refuse if detached HEAD); target (arg, or first of baseline/main/master); refuse if current == target.
3. **Check for uncommitted changes** — refuse to start if dirty; list dirty files so the user can decide.
4. **Update target** — `git checkout TARGET && git pull --ff-only`. Warn if pull fails.
5. **Return + rebase** — `git checkout CURRENT && git rebase TARGET`.
6. **Resolve conflicts** — for each conflicted file: classify against the auto-resolve table (build manifest version, changelog version-section additions); auto-resolve and `git add` if matched; otherwise show diff and prompt user. Continue with `git rebase --continue` per commit.
7. **Post-rebase version bump and changelog hygiene** — if `CURRENT_VERSION` collapsed to `TARGET_VERSION`, bump patch by 1; ensure a unique changelog section exists for the new version; commit as a separate fixup.
8. **Report** — what was auto-resolved, what was changed, the `--force-with-lease` push command.

Auto-resolve table:

- `build.gradle{,.kts}` — only `version = "..."` conflicts → keep current.
- `pom.xml` — only `<version>` in project's own `<parent>` or root `<project>` → keep current.
- `package.json` — only top-level `"version"` → keep current.
- `*.csproj` — only `<Version>` or `<PackageVersion>` → keep current.
- `CHANGELOG.md` / `CHANGES.md` / `HISTORY.md` — different version headings on each side → keep both, newest first.

Key constraints:

- **Never push.** User decides when.
- **Never `--force`.** Suggest `--force-with-lease` only.
- **Never amend or squash.** The fixup commit is a separate commit at the tip.
- **Never `--no-verify`.** Hook failures stop the workflow.

## FAQ

**Q: What if I want to rebase onto a non-default branch?**
A: Pass it: `/branch-rebase release/1.5`. The skill uses your argument verbatim.

**Q: What does the auto-resolve do for `package.json` if there are conflicts in *other* fields too?**
A: The auto-resolve only matches when the *only* conflict is in the version field. Anything else (deps, scripts, etc.) is treated as complex and prompts.

**Q: Why does the skill bump the patch version after a rebase?**
A: To prevent two branches from sharing a version heading in the changelog. Two branches sharing a version causes downstream merge headaches; bumping early avoids them.

**Q: What if the post-rebase commit's pre-commit hook fails?**
A: The skill stops and reports. The rebase is already done — the hook failure only blocks the version-bump fixup commit. You can fix and re-commit manually.

**Q: Can I dry-run it?**
A: Not built in. For preview, use `git fetch && git log --oneline HEAD..origin/main` to see what's new on the target before invoking the skill.

## Related skills

- **[request-refactor-plan](../request-refactor-plan/)** — for refactor work, plan the small commits first; the rebase skill keeps them clean against main as you go.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
