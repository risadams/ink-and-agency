# ADR-0007: Skills Are Organized Into Category Subfolders

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** Maintainer review

## Context

After [ADR-0006](ADR-0006-agents-folded-into-skills.md) folded the agent library into skills, the pack
held **215 skills flat** under `skills/<name>/`. A flat directory of 215 folders is hard to browse,
hard to reason about ("what do we have for infrastructure?"), and gives no visual grouping of the
former agent domains.

Two facts made grouping safe:

- **Skill `name` is the invocation identifier and is independent of folder path.** Moving
  `skills/python-pro/` to `skills/language-specialists/python-pro/` does not change how the skill is
  invoked (`/ink-and-agency:python-pro`).
- **All 215 skill names are globally unique**, so grouping introduces no collisions.

The binding risk was tooling and host discovery: the repo's own generator and linter enumerated
`skills/` non-recursively, and whether the Claude Code / Codex hosts discover nested `SKILL.md` files
was not confirmable from docs in the build environment.

## Decision

Organize all skills into **15 category subfolders**: `skills/<category>/<name>/SKILL.md`. The
categories (see [`skills/CATEGORIES.md`](../../skills/CATEGORIES.md)) extend the former 10 agent
domains with 5 workflow groups:

`business-product`, `codebase-build`, `core-development`, `data-ai`, `developer-experience`,
`exec-function`, `infrastructure`, `language-specialists`, `meta-orchestration`, `obsidian`,
`quality-security`, `research-analysis`, `scrum-sprint`, `specialized-domains`, `writing`.

Supporting changes:

- **Tooling recurses.** `convert-agents-to-codex.ps1` and `lint-skills.ps1` discover skills via a
  recursive `SKILL.md` search, so any depth works. Category folders carry no meaning to the tools —
  they're pure organization.
- **Relative links updated.** Nesting adds one folder level, so intra-pack relative links were
  rewritten by a one-time migration (`scripts/_migrate-nest.py`): root-file links (`../PORTABILITY.md`
  → `../../PORTABILITY.md`), sibling-skill links (`../<name>/` → `../../<category>/<name>/`), and
  deeper external links each gained one `../`.
- **Categories are not a contract.** They exist for human browsability. Because `name` is
  path-independent, a skill can be re-categorized by moving its folder and fixing inbound relative
  links — no invocation changes.

## Consequences

**Positive**
- `skills/` is browsable by domain; 15 folders instead of 215.
- Mirrors the former agent taxonomy, so returning maintainers recognize the structure.
- No invocation or referential-integrity impact (`related-skills` resolves by name, not path).

**Negative / trade-offs**
- **Host recursion was unverified at authoring time** (web docs blocked in the build env). The change
  was validated by the repo toolchain and requires a `--plugin-dir` smoke-test on each host before
  release. If a host turns out to be flat-only, the move is fully revertible from git history.
- Cross-skill relative links now encode a category path, so moving a skill later means fixing inbound
  links. `lint-skills.ps1` validates `related-skills` by name (unaffected), but does not yet verify
  relative markdown links — that check is manual (`scripts/_migrate-nest.py`'s verifier can be reused).
- Deeper paths (one extra level) in every intra-pack link.

## Compliance

- New skills go under an existing category: `skills/<category>/<name>/`. Add a new category only with
  a strong reason (and update `CATEGORIES.md` + this ADR's list).
- Keep skill `name` == leaf folder name, globally unique.
- After moving or adding a skill, re-run `convert-agents-to-codex.ps1` and `lint-skills.ps1`, and
  verify relative links still resolve.
