# Branch Rebase — Post-rebase Version and Changelog

Read after the rebase completes, when the repo has a version manifest or a changelog (step 7 of [SKILL.md](SKILL.md)).

After the rebase completes, automatically ensure the branch has a unique version and changelog section.

## 7a. Detect version state

Read the version from the build manifest on **both** branches:

```bash
TARGET_VERSION=$(git show $TARGET:build.gradle 2>/dev/null | grep -oP "version\s*=\s*['\"]?\K[^'\"]+")
CURRENT_VERSION=$(grep -oP "version\s*=\s*['\"]?\K[^'\"']+" build.gradle 2>/dev/null)
```

Also check `build.gradle.kts`, `pom.xml`, `package.json`, or `*.csproj` using the same approach — whichever manifest exists.

## 7b. Bump version if needed

If `CURRENT_VERSION` equals `TARGET_VERSION` (the rebase collapsed the version), bump it automatically:

1. Determine the bump type — increment the **patch** segment by default (e.g. `1.3.0` → `1.3.1`).
2. Update the version in the build manifest file.
3. Tell the user what you changed:
   > Auto-bumped version from `{TARGET_VERSION}` to `{NEW_VERSION}` in `build.gradle`.

If the version format is non-standard or you cannot parse it reliably, ask the user what version to use instead.

## 7c. Ensure a unique changelog section

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

## 7d. Commit the fixup

If any changes were made in 7b or 7c:

```bash
git add build.gradle CHANGELOG.md   # (or whichever files were touched)
git commit -m "chore: bump version to {NEW_VERSION} after rebase onto {TARGET}"
```

This keeps the version/changelog fixup as a clean, separate commit at the tip of the branch.
