# Readme Generator

Writes the front page of a repository. A README has one job: turn a stranger into someone
running the project.

## When to use

- Starting a project that has no README.
- The README has drifted from reality — commands fail, flags are gone, versions are stale.
- You want an existing README scored and told what to fix.

## The two rules

**Repo truth** — every command, flag, env var, path, and version traces to a file that was
read or a command that was run. Gaps become `<!-- TODO: confirm … -->`, never guesses.

**The 30-second test** — the first screen answers what it is, why you'd want it, and how to
run it.

## How it runs

1. **Scan** — manifests, entry points, scripts, tests, CI, config schemas, `--help` output.
2. **Fix the shape** — library, CLI, application/service, or internal repo. Each bends the
   section ladder differently.
3. **Draft** — down the ladder in [STRUCTURE.md](STRUCTURE.md).
4. **Review** — every gate in [REVIEW.md](REVIEW.md). Truth failures block delivery.
5. **Humanize** — a `writing-humanize` pass over the prose, commands left verbatim.
6. **Deliver** — write `README.md`, report TODOs. Git actions only when explicitly requested.

## Review-only mode

Point it at an existing README and ask for a review. It returns a verdict (Ship / Fix first /
Rewrite), failures grouped by gate with concrete fixes, missing sections, and a cut list —
without rewriting the file.

## Reference files

- [STRUCTURE.md](STRUCTURE.md) — the 14-section ladder (required / recommended / optional),
  how it changes per project type, and the writing rules.
- [REVIEW.md](REVIEW.md) — the four-gate rubric: Truth, the 30-second test, Readability, Voice.

## Related skills

- [documentation-engineer](../documentation-engineer/) — docs beyond the repo root
- [technical-writer](../../business-product/technical-writer/) — API references, SDK guides
- [writing-humanize](../../writing/writing-humanize/) — the step 5 prose pass
- [content-quality-editor](../../business-product/content-quality-editor/) — deeper edit when
  humanizing isn't enough

## Tools

Uses: `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, `WebFetch`, `WebSearch`.

## Invocation

Model-invoked from the `description` triggers, or run by name (`readme-generator`).
Compatible with: claude-code codex opencode.

---

*This README summarizes [SKILL.md](SKILL.md), the canonical definition. Edit the SKILL.md for behavior changes; keep this file in sync.*
