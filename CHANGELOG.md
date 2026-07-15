# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
