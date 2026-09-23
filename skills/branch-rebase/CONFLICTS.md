# Branch Rebase — Resolving Conflicts

Read when `git rebase` stops with conflicts (step 6 of [SKILL.md](SKILL.md)).

When the rebase stops with conflicts, inspect each conflicted file:

```bash
git diff --name-only --diff-filter=U
```

For **each** conflicted file, classify and act:

## Auto-resolvable (resolve silently, then `git add` the file)

| Pattern | Resolution |
|---|---|
| `build.gradle` / `build.gradle.kts` — only `version = "..."` lines conflict | Accept the **current branch's** version (ours during rebase = theirs flag). The developer's version bump is intentional. |
| `pom.xml` — only `<version>` inside the project's own `<parent>` or root `<project>` block conflicts | Same — keep the current branch's version. |
| `package.json` — only the top-level `"version"` field conflicts | Keep current branch's version. |
| `*.csproj` — only `<Version>` or `<PackageVersion>` conflicts | Keep current branch's version. |
| `CHANGELOG.md` / `CHANGES.md` / `HISTORY.md` — conflict is between **different version headings** (e.g. target added `## 1.3.0` and current branch has `## 1.4.0`) | Keep **both** version sections, ordered newest-first. Each version heading and its entries stay intact. |

**Changelog same-version conflicts:** If both sides modified entries **under the same version heading**, this is **not auto-resolvable**. Two branches must not share a version — treat this as a complex conflict.

After auto-resolving a file:

```bash
git add <file>
```

## Not auto-resolvable

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
