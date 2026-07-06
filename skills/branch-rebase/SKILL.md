---
name: branch-rebase
description: >
  Safely rebase the current branch onto its upstream target (baseline, main, or master).
  Auto-resolves simple merge conflicts (version bumps, changelogs). Prompts for complex ones.
  Use when user says "rebase", "rebase branch", "rebase onto main", "update my branch",
  "sync with baseline", "catch up with main", or invokes /branch-rebase.
related-agents:
  - devops-engineer
  - git-workflow-manager
related-skills:
  - branch-resolve-conflicts
loop-eligible: false

---

# Branch Rebase

Rebase the current feature branch onto its upstream target with automatic resolution of trivial conflicts.

## Invocation

```
/rebase-branch [target]
```

- `target` — branch to rebase onto. Defaults to the first of `baseline`, `main`, `master` that exists.

## Workflow

Follow every step in order. Do not skip steps. Do not push at the end.

### 1. Validate environment

```bash
git rev-parse --is-inside-work-tree
```

If not a git repo, stop and tell the user.

### 2. Detect branches

```bash
CURRENT=$(git branch --show-current)
```

If `CURRENT` is empty (detached HEAD), stop: "You are in detached HEAD state. Check out a branch first."

If a target argument was provided, use it. Otherwise detect the target:

```bash
for candidate in baseline main master; do
  if git show-ref --verify --quiet "refs/heads/$candidate" || \
     git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
    TARGET=$candidate
    break
  fi
done
```

If no target found, stop: "Could not find baseline, main, or master. Specify a target branch."

If `CURRENT` equals `TARGET`, stop: "You are already on the target branch."

### 3. Check for uncommitted changes

```bash
git status --porcelain
```

If output is non-empty, **stop immediately** and tell the user:

> You have uncommitted changes. Please commit or stash them before rebasing.

List the dirty files so they can decide. Do not proceed.

### 4. Update the target branch

```bash
git checkout $TARGET
git pull --ff-only
```

If the pull fails (e.g. diverged local target), warn the user and ask whether to continue or abort.

### 5. Return to feature branch and rebase

```bash
git checkout $CURRENT
git rebase $TARGET
```

If the rebase completes cleanly, skip to step 7.

### 6. Resolve conflicts

When the rebase stops with conflicts, inspect each conflicted file:

```bash
git diff --name-only --diff-filter=U
```

For **each** conflicted file, classify and act:

#### Auto-resolvable (resolve silently, then `git add` the file)

| Pattern | Resolution |
|---|---|
| `build.gradle` / `build.gradle.kts` — only `version = "..."` lines conflict | Accept the **current branch's** version (ours during rebase = theirs flag). The developer's version bump is intentional. |
| `pom.xml` — only `<version>` inside the project's own `<parent>` or root `<project>` block conflicts | Same — keep the current branch's version. |
| `package.json` — only the top-level `"version"` field conflicts | Keep current branch's version. |
| `CHANGELOG.md` / `CHANGES.md` / `HISTORY.md` — conflict is between **different version headings** (e.g. target added `## 1.3.0` and current branch has `## 1.4.0`) | Keep **both** version sections, ordered newest-first. Each version heading and its entries stay intact. |

**Changelog same-version conflicts:** If both sides modified entries **under the same version heading**, this is **not auto-resolvable**. Two branches must not share a version — treat this as a complex conflict.
| `*.csproj` — only `<Version>` or `<PackageVersion>` conflicts | Keep current branch's version. |

After auto-resolving a file:

```bash
git add <file>
```

#### Not auto-resolvable

Any conflict that does **not** match the table above is complex. Use the `/branch-resolve-conflicts` skill:

```
/branch-resolve-conflicts
```

This skill will:
- Reconstruct the intent behind each conflicting change
- Preserve both branches' goals where possible
- Run automated checks (typecheck, tests, format)
- Stage all resolutions and continue the rebase

If the user prefers to abort rather than resolve complex conflicts:

```bash
git rebase --abort
```

Stop and report that the rebase was aborted.

After all conflicts for the current commit are resolved:

```bash
git rebase --continue
```

If further commits also conflict, repeat step 6.

### 7. Post-rebase version bump and changelog

After the rebase completes, automatically ensure the branch has a unique version and changelog section.

#### 7a. Detect version state

Read the version from the build manifest on **both** branches:

```bash
TARGET_VERSION=$(git show $TARGET:build.gradle 2>/dev/null | grep -oP "version\s*=\s*['\"]?\K[^'\"]+")
CURRENT_VERSION=$(grep -oP "version\s*=\s*['\"]?\K[^'\"']+" build.gradle 2>/dev/null)
```

Also check `build.gradle.kts`, `pom.xml`, `package.json`, or `*.csproj` using the same approach — whichever manifest exists.

#### 7b. Bump version if needed

If `CURRENT_VERSION` equals `TARGET_VERSION` (the rebase collapsed the version), bump it automatically:

1. Determine the bump type — increment the **patch** segment by default (e.g. `1.3.0` → `1.3.1`).
2. Update the version in the build manifest file.
3. Tell the user what you changed:
   > Auto-bumped version from `{TARGET_VERSION}` to `{NEW_VERSION}` in `build.gradle`.

If the version format is non-standard or you cannot parse it reliably, ask the user what version to use instead.

#### 7c. Ensure a unique changelog section

Read the changelog file (`CHANGELOG.md`, `CHANGES.md`, or `HISTORY.md` — whichever exists).

- If a section heading for `NEW_VERSION` (from 7b) or `CURRENT_VERSION` (if already unique) **does not exist**, create one at the top of the changelog:
  ```markdown
  ## {VERSION}

  - Rebased onto `{TARGET}`.
  ```
  The user will fill in real entries, but the section must exist so it doesn't collide with the target's entries.

- If a section heading for the branch's version **already exists** and contains entries that also appear on the target branch (i.e. duplicate entries from the merge base), remove the duplicates and keep only entries unique to the current branch. If this leaves the section empty, add a placeholder line:
  ```markdown
  - Rebased onto `{TARGET}`.
  ```

- **Never merge entries from two branches under the same version heading.** If after the rebase, the changelog would have the current branch's entries and the target's entries under one heading, bump the version (back to 7b) and create a new section.

#### 7d. Commit the fixup

If any changes were made in 7b or 7c:

```bash
git add build.gradle CHANGELOG.md   # (or whichever files were touched)
git commit -m "chore: bump version to {NEW_VERSION} after rebase onto {TARGET}"
```

This keeps the version/changelog fixup as a clean, separate commit at the tip of the branch.

### 8. Report success

Tell the user:

> Rebase complete. `{CURRENT}` is now based on `{TARGET}`.

If a version bump or changelog update was made, list exactly what changed:
> - Version bumped: `{OLD}` → `{NEW}` in `build.gradle`
> - New changelog section added for `{NEW}`

Then:
> **Your branch has not been pushed.** When you're ready:
> ```
> git push --force-with-lease
> ```

List any files that were auto-resolved during conflict resolution so the user can verify.

## Important rules

- **Never push.** The user decides when and how to push.
- **Never use `--force`.** Only suggest `--force-with-lease` in the final message.
- **Never amend or squash** commits during this workflow.
- If anything unexpected happens (network errors, lock files, hook failures), stop and report rather than retrying destructively.
- Prefer `git rebase --abort` over leaving the repo in a broken state.

