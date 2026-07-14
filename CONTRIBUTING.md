# Contributing notes

This is an unsupported personal project. Fork freely, but no PRs are accepted.

Keep the structure stable so the skills remain easy to discover.

## Project conventions

- This repository is a skills catalog, not an application: changes should improve skill clarity, portability, and discoverability.
- Keep each skill self-contained in its own folder; avoid cross-folder dependencies unless there is a clear shared framework.
- Prefer additive updates over broad rewrites so existing workflows and references do not break.

## Naming scheme

- Skill folder names use lowercase kebab-case, for example `writing-humanize`, `issue-triage`, `clarity-council`.
- Keep published skill folder names stable; renames are considered breaking changes for existing users.
- Related skills should share a common prefix so they group naturally in directory listings.
- Use family-style prefixes for topic clusters, for example `codebase-*`, `obsidian-*`, `issue-*`, `sprint-*`, `writing-*`.
- Within a family, use a specific action or outcome suffix, for example `codebase-explain`, `codebase-improve-architecture`, `obsidian-vault`, `obsidian-markdown`.
- Create a new prefix only when multiple skills clearly form a reusable domain; avoid one-off prefixes with a single skill.
- Each skill entry point is exactly `SKILL.md` at the skill folder root.
- Supporting docs should use clear, purpose-driven names, usually uppercase with hyphens for reference artifacts, for example `README.md`, `EXAMPLES.md`, `REFERENCE.md`, `RUNBOOK.md`, `SKILL_GRAPH.md`.
- Keep file names descriptive and specific to their role (template, format, deep dive, examples, personas).

## Layout and documentation rules

- Keep `SKILL.md` at the root of each skill folder.
- Include a `README.md` for each skill whenever practical, especially for non-trivial workflows.
- Keep nested docs inside the skill folder when they add useful examples or reference material.
- Place persona contracts, helper modules, and runbooks under the owning skill subtree (for example `clarity-council/skills/personas/`).
- Avoid adding new top-level folders that are not skills or shared metadata folders.

## Consistency checks before publishing

- Verify names, paths, and examples in docs match the actual folder and file names.
- Confirm `CLAUDE.md` skills inventory reflects public skills only and remains the source of truth.
- Ensure frontmatter in each `SKILL.md` is valid and aligned with the skill's intent.
