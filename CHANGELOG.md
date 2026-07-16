# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.2] - 2026-07-16

### Fixed
- Generate .claude-plugin skills array so Claude Code loads category-nested skills

## [1.4.1] - 2026-07-15

### Fixed
- infographics-expert: require comma-separated `xychart-beta` x-axis category lists. Space-separated labels (`x-axis ["a" "b" "c"]`) throw a Mermaid `Parse error` and break the whole chart block; added as render-validity rule (e).

## [1.4.0] - 2026-07-15

### Added
- Add 6 skill-quality rules to lint-skills.ps1
- Merge deleted persona content into surviving skills

### Changed
- Bump actions/checkout to v7
- Remove ADRs and scrub references
- Normalize all line endings to LF + add .gitattributes
- Declare compatibility on the last 10 skills
- Frame clarity-council as a featured top-level skill
- Consolidate skill map and composition docs into root README
- Promoted council
- Reclassify 16 advisory skills as council personas
- Scrub internal identifiers from skill docs with generic placeholders
- Promote council personas to a shared skills/persona/ category
- Organize 215 skills into 15 category subfolders
- De-duplicate personas vs top-level skills
- Fold all agents into skills (skills-only pack)
- Fold council agents into the clarity-council skill
- Removed bad upstreams refs
- Expand README with install, update, and invocation guidance

### Fixed
- Don't treat a clean convert as failure in bump-version
- Repair council cross-references after top-level promotion
- Repair broken persona-group references
- Clean skill metadata defects and doc drift

## [1.3.0] - 2026-07-14

### Added

- Baseline snapshot of the Ink and Agency dual-host agent plugin (Claude Code + Codex).
- Prompt-based skills for writing, sprint work, and neurodivergent-friendly workflows.
- Specialist subagent library and a persona council for multi-perspective decisions.
- `convert-agents-to-codex.ps1` generator keeping Codex artifacts in sync with the canonical markdown sources.
- `lint-agents.ps1` frontmatter and taxonomy validation.
- `Validate` GitHub workflow enforcing agent linting and Codex-artifact sync.

---

The releases below predate the merge and were published under the standalone
[risadams/skills](https://github.com/risadams/skills) repository, whose history
is preserved here via `git subtree`.

## [1.2.0] - 2026-06-17

### Added

- Communication & interpretation: `break-it-down` (decode messages and intent).
- Code analysis & understanding: `codebase-explain`, `codebase-improve-architecture`, `codebase-churn`, `codebase-plan-refactor`, `issue-triage`, `issue-dup-find`, `issue-estimate-sp`, `issue-feature-breakdown`, `issue-suggest-component`.
- Collaboration & decisions: `clarity-council`, `grill-me`, `grill-with-docs`, `idea-generate`, `idea-choice`, `idea-decision-maker`.
- Git & merge workflows: `branch-rebase`, `branch-resolve-conflicts`.
- Planning & reporting: `sprint-plan`, `sprint-review`, `sprint-snapshot`, `sprint-sos-report`, `daily-briefing`, `daily-standup-prep`, `good-morning`.
- Writing workflows: `writing-draft-article`, `writing-shape`, `writing-fragments`, `writing-beats`, `writing-cold-open`, `writing-humanize`, `writing-tone-check`, `writing-apology-calibrator`, `writing-social-script`, `writing-rejection-sensitivity-check`.
- Workspace & knowledge: `obsidian-vault`, `obsidian-markdown`, `obsidian-canvas`, `obsidian-charts`, `obsidian-bases`, `obsidian-cli`, `defuddle`.
- Utilities: `hyperfocus-recovery`, `task-initiation`, `time-reality-check`, `energy-budget`, `interest-capture`, `meeting-decompression`, `rejection-sensitivity-check`, `handoff`, `skill-create`.

### Changed

- Reworked the Skills + Agents section with integration patterns and `related-agents` field documentation.
- `branch-resolve-conflicts` now performs full intent preservation for complex conflicts.

## [1.1.0] - 2026-05-19

### Added

- New `writing-*` siblings for outgoing messages: `writing-tone-check`, `writing-apology-calibrator`, `writing-rejection-sensitivity-check`, `writing-social-script`, `writing-cold-open`.
- New Focus & state skills: `task-initiation`, `hyperfocus-recovery`, `time-reality-check`, `energy-budget`, `interest-capture`, `meeting-decompression`.

### Changed

- Renamed `decision-breaker` to `idea-decision-maker`.

## [1.0.0] - 2026-05-18

### Added

- Initial public release of the skills pack.
