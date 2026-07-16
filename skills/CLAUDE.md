# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Part of the Ink and Agency ecosystem:** See **[INTEGRATION.md](INTEGRATION.md)** for how skills compose with each other.

## Nature of this repo

This is a **Claude Skills Pack** — a collection of prompt-based skill definitions. Each skill is a markdown file (`SKILL.md`) in its own folder. There is no build system, test runner, or linter.

## Structure

Skills are organized into **category subfolders**. Codex discovers them recursively (any
`SKILL.md` at any depth is a skill); **Claude Code does not** — it loads only the skill folders
enumerated in the `skills` array of `.claude-plugin/plugin.json`, which is generated from the full
`SKILL.md` set by `convert-agents-to-codex.ps1`. So a new skill in any category is picked up on the
next regenerate; do not hand-edit that array. See [CATEGORIES.md](CATEGORIES.md) for the 15
categories and the full index. The `clarity-council` skill sits at the top level of `skills/` (not
inside a category) as a featured skill many others delegate to.

```text
<category>/<name>/SKILL.md        # Skill entry point (YAML frontmatter + instructions)
<category>/<name>/*.md            # Supporting docs, formats, or deep-dive modules
<category>/<name>/agents/openai.yaml  # Codex picker metadata (GENERATED)
clarity-council/                  # featured top-level skill (reads persona/)
persona/                          # shared council persona contracts (reference docs, not skills)
persona/PERSONAS.md               #   persona index; persona/GROUPS.md = pre-made panels
```

The skill **name** (invocation id) is the leaf folder and is independent of its category — moving a
skill between categories does not change how it's invoked, but cross-skill relative links encode the
category path, so fix those if you move one.

## Skill format

Each `SKILL.md` begins with YAML frontmatter:

```yaml
name: skill-name
description: >
  When to trigger this skill. Use "when user says X" or "Use when Y."
  Keep to 1-2 sentences.
version: 2.5.1                         # optional
license: MIT                           # optional
compatibility: claude-code opencode    # optional
allowed-tools:                         # optional
  - Read
  - Write
related-skills:                        # optional — other skills this skill works with
  - skill-a
  - skill-b
loop-eligible: true                    # optional — true if can run via /loop
recurrence-hint: daily                 # optional — daily/weekly/on-demand (if loop-eligible=true)
disable-model-invocation: true         # optional — user-invoked only (see below)
codex-short-description: "…"           # optional — override for the Codex picker label
```

**Note:** The pack is skills-only — there is no `related-agents` field. `related-skills` entries should name skills that actually exist and have a clear workflow connection. See **[INTEGRATION.md](INTEGRATION.md)** for guidance.

### Cross-host invocation (Claude Code + Codex)

`disable-model-invocation: true` marks a skill **user-invoked only** — the model won't auto-trigger it; the human invokes it by name. This one frontmatter flag drives both hosts: the generator (`scripts/convert-agents-to-codex.ps1`) projects it into the skill's `agents/openai.yaml` as `policy.allow_implicit_invocation: false` (the Codex analog). Because the Codex side is generated, the two can't drift — **never hand-edit `agents/openai.yaml`.**

The generated `openai.yaml` also carries the Codex picker label: `interface.display_name` (from `name`) and `interface.short_description` (first sentence of `description`, ~90 chars). When that first sentence reads badly or truncates, add `codex-short-description:` and the generator uses it verbatim. Full model: [AGENTS.md](../AGENTS.md#skill-invocation-across-hosts).

## Extended Skill Format: Loop Method

The Loop Method adds optional frontmatter fields and markdown sections to enable:

1. **Cross-skill delegation:** Declare which other skills this skill uses
2. **Quality loops:** Self-evaluate output before returning
3. **Recurring execution:** Document how this skill runs via `/loop`

### New Frontmatter Fields

| Field | Type | Rules | Example |
|-------|------|-------|---------|
| `related-skills` | Array[string] | 0-6 skill names; must exist | `related-skills: [grill-me, clarity-council]` |
| `loop-eligible` | Boolean | True if can run recurring; false otherwise | `loop-eligible: true` |
| `recurrence-hint` | Enum | `daily`, `weekly`, `on-demand`, `none`; required if loop-eligible=true | `recurrence-hint: daily` |

### Quality Loop Section

Add an optional "Quality Loop" section to your SKILL.md (after main instructions):

```markdown
## Quality Loop

This skill evaluates its output before returning it.

1. **Generate initial output** — Follow main workflow
2. **Self-evaluate** — Against criteria:
   - Completeness: All required fields present?
   - Accuracy: Facts grounded in input?
   - Actionability: Can user take next step?
   - Format: Matches template?
3. **Loop condition** — If ≥2 criteria fail, refine and re-evaluate
4. **Exit** — When all pass OR max 2 iterations reached
```

### Delegation Map Section

Add an optional "Delegation Map" section to your SKILL.md (at end of file):

```markdown
## Delegation Map

| User Need | Delegate Via | Parameters |
|-----------|---|---|
| [Use case] | Invoke `[skill]` with ... | [params] |
| [Use case] | Invoke `[specialist-skill]` for... | [context] |

**Loop eligibility:** [true/false]  
**Recurrence:** [daily/weekly/on-demand]  
**Example:** `/loop 1d /[skill-name] --param value`
```

### Examples

#### good-morning (Orchestration Skill)

```yaml
---
name: good-morning
related-skills: [sprint-snapshot, daily-standup-prep, daily-briefing]
loop-eligible: false  # Orchestrator doesn't recur alone; components do
---
```

#### sprint-snapshot (Repeating Skill)

```yaml
---
name: sprint-snapshot
related-skills: [sprint-plan, sprint-review, daily-standup-prep, scrum-master, project-manager]
loop-eligible: true
recurrence-hint: weekly  # Usually run once per sprint, or on-demand
---
```

### Validation Rules

- **Existence check:** related-skills entries must resolve to real skills
- **No self-reference**
- **No circular chains:** A→B→C→A rejected
- **Type correctness:** only skill names in related-skills (no tool or MCP names)
- **Recurrence consistency:** loop-eligible=true requires recurrence-hint

Validation is performed by `scripts/lint-skills.ps1`.

## Skills inventory

> **Public skills only.** Private skills live in `_private/` and surface as junctions in the root (e.g. `cpf`, `mr-*`, `setup-*`). They are gitignored and **must not** be listed here. To check what's private: `cmd //c "dir /AL"` lists junctions, and `.gitignore` is the canonical list.
>
> **Scope of this table.** The rows below are the *workflow* skills (the "Ink" set). The ~138 **specialist** skills (former subagents — language/framework experts, infra, data/AI, security, product, etc.; e.g. `python-pro`, `security-auditor`, `terraform-engineer`) are not enumerated here — they are discovered by their trigger `description`. Browse `skills/` for the full set.

| Skill | Purpose |
| :--- | :--- |
| branch-rebase | Safely rebase the current branch onto its upstream target; auto-resolves trivial conflicts |
| branch-resolve-conflicts | Resolve complex merge/rebase conflicts by reconstructing intent, preserving both branches' goals when possible, running full automated checks (typecheck, tests, format) |
| break-it-down | Decode messages into plain language with tone/intent analysis |
| clarity-council | Persona-based consultation (single/multi-persona, iterative) |
| code-review | Two-axis review of the working diff since a fixed point — Standards (repo conventions + Fowler code-smell baseline) and Spec (matches the originating ticket) — run as parallel sub-agents, reported side by side, never merged. Pre-MR counterpart to mr-review |
| codebase-churn | Git-history treemap (SVG): area = lines changed, color = commit frequency — find unstable, bug-prone files |
| codebase-explain | High-level context and module mapping for unfamiliar code areas |
| codebase-improve-architecture | Find refactor/deepening opportunities, informed by CONTEXT.md and ADRs |
| codebase-plan-refactor | Build incremental refactor plan via interview → file as GitHub issue |
| daily-briefing | Outlook-driven daily briefing: 24h email + calendar recap, today's schedule, action items, focus blocks |
| daily-standup-prep | Per-team standup report: gathers Jira/GitLab/Confluence/Git activity over N days, maps to roster, renders Mermaid kanban + talking order, writes to vault |
| debug | Six-phase diagnosis loop for hard bugs and performance regressions: build a tight red-capable feedback loop first, then reproduce/minimise → ranked falsifiable hypotheses → one-variable instrumentation → fix + regression test → cleanup + post-mortem. Hands off to codebase-improve-architecture when the root cause is architectural |
| defuddle | Extract clean markdown from web pages via Defuddle CLI (use instead of WebFetch for HTML) |
| energy-budget | Spoon-theory accounting for the calendar: score today's load, flag burnout risk, suggest defers. Council: personal-assistant + psychologist |
| good-morning | Morning kickoff wrapper: runs sprint-snapshot (daily tag) → daily-standup-prep (with burndown) → daily-briefing (report only, no focus blocks). Idempotent — overwrites today's artifacts on re-run |
| grill-me | Stress-test plans through iterative questioning |
| grill-with-docs | Grilling against domain docs + updating CONTEXT/ADR artifacts inline |
| handoff | Compact the current conversation into a structured handoff document so a fresh agent can pick up work without re-deriving context. Saves to OS temp directory, includes suggested skills, redacts sensitive data. |
| hyperfocus-recovery | Reconstruct context after a deep session or interruption from git/file artifacts → suggested re-entry point |
| idea-choice | Deliberate pros/cons analysis for one or more ideas: clarity-council pass + optional grill-me, scores each item on Impact × Confidence, renders markdown table per idea, comparison table across ideas, recommendation (Go / Go with caveats / Don't / Needs more analysis). Complements idea-generate (which produces ideas) and idea-decision-maker (which forces a fast binary pick) |
| idea-decision-maker | Force a pick between options to defeat analysis paralysis. Council: senior-architect + devils-advocate + personal-assistant vote, majority wins. Fast counterpart to idea-choice — use when the user needs a verdict, not a written record (was: `decision-breaker`) |
| idea-generate | Generate and refine ideas from loose topics using Divergence (council) and Convergence (grill) workflows |
| implement | Build a ticket/spec/free-form request through a tunable pipeline (source → test-first → verify → review → track) where every phase is skippable. Auto-detects a preset (prototype / standard / full), proposes an editable run plan, then drives tdd + code-review. `disable-model-invocation` — explicit invoke only |
| interest-capture | Fast capture for hyperfixations so they don't derail today's work but aren't lost. Files into Obsidian inbox, returns user to task |
| issue-draft-release-notes | Draft a customer-facing release note for a Jira ticket from ticket context + related GitLab MR changes; clarity-council quality pass (technical-writer + product-owner + customer-advocate); read-only with opt-in to post as a Jira comment or set a Release Notes field |
| issue-dup-find | Scan open Jira issues (default project from memory) for likely duplicates → markdown report with probability + reason (read-only) |
| issue-estimate-sp | Story point estimation via Jira context + scrum-poker council session (read-only) |
| issue-feature-breakdown | Read-only Jira/Confluence context gathering + council analysis → actionable breakdown |
| issue-suggest-component | Suggest Jira components for a ticket or sweep a project (default project from memory, max 250). Confirms before each add; can create new components |
| issue-triage | Triage Jira ticket or free-form bug → ranked root-cause hypotheses + solution paths (read-only) |
| meeting-decompression | Process a meeting dump: separate facts/action-items/social ambiguities. Sorts ruminations into "worth following up on" vs "RSD noise". Council: psychologist + personal-assistant |
| obsidian-bases | Create and edit Obsidian Bases (.base files) — views, filters, formulas, summaries |
| obsidian-canvas | Create and edit Obsidian .canvas files (nodes, edges, groups, connections) |
| obsidian-charts | Build interactive Chart.js charts in Obsidian via `chart` codeblocks — inline literal series, link to a markdown table by `^blockId` (same note or cross-file), or render from a Dataview/Dataviewjs query via `window.renderChart` |
| obsidian-cli | Interact with Obsidian vaults via CLI: notes, tasks, properties; supports plugin/theme dev |
| obsidian-markdown | Create and edit Obsidian Flavored Markdown (wikilinks, callouts, frontmatter, embeds) |
| obsidian-vault | Search, create, and manage notes in the Obsidian vault with wikilinks and index notes |
| plan-to-spec | Synthesize a settled design discussion into a spec (PRD) staged as a local `spec.md` (spec-kit style, numbered feature folder) — no interview, just write-up. Publishing to Confluence is opt-in, on request. Bridges grill/work-plan → tickets. `disable-model-invocation` — explicit invoke only |
| plan-to-tickets | Break a spec/plan/conversation into a local numbered `tasks.md` (spec-kit style: tracer-bullet vertical slices, explicit dependencies, `[P]` markers). Pushing to Jira as tickets with native "Blocks" links is opt-in, on request. Handles wide refactors via expand–contract. `disable-model-invocation` — explicit invoke only |
| rejection-sensitivity-check | Calibrate a stung-by message: separate evidence from interpretation, score warranted sting 1–5. Council: psychologist + devils-advocate (always) |
| research | Delegate a question to a background agent that investigates against high-trust primary sources (docs, specs, source, first-party APIs — never secondary write-ups or parametric memory) and writes a single cited Markdown note into the repo's notes convention |
| skill-create | Create new skills with structured prompts, resources, and packaging conventions |
| sprint-plan | Convert the start-of-sprint canvas into a planning markdown report (committed scope split carry-over vs new commit, capacity vs commitment, WIP-saturation risk, observations, risks). Assumes all unclosed items from the previous sprint's `end.canvas` carry into this one. Date-stamped output: same-day re-runs refresh silently, prior days preserved. Auto-runs clarity-council. Port of `Prompts/Sprint Plan.md`. |
| sprint-review | End-of-sprint stakeholder report: compares `start.canvas` to `end.canvas`, fits the standard SM template (Accomplishments / Status / Sprint Commitment / PI Confidence / Impediments). Auto-runs clarity-council. Port of `Prompts/Sprint Review.md`. |
| sprint-snapshot | Point-in-time snapshot of a scrum team's sprint board: writes Obsidian Canvas + companion markdown summary + append-only JSONL trend log into the team's vault folder. Auto-detects sprint phase; supports `--as-of` for historical snapshots. Port of `Sprint-Planner.ps1`. Hosts the shared `_team-rules.md` schema used by all `sprint-*` skills. |
| sprint-sos-report | Weekly scrum-of-scrums report comparing two sprint snapshots: scope changes, status transitions, per-member workload delta, wedge balancing, council findings/observations/trouble-areas/trends. Auto-detects which two snapshots to compare (`--from`/`--to` overrides for re-planning churn). Port of `Prompts/Scrum of Scrums.md`. |
| task-initiation | Defeat executive-function stalls with one ≤30-second physical action — not a plan, not a breakdown. Inline-only (no council, speed matters) |
| tdd | Test-driven development: the red → green loop and the rules that make its tests worth keeping (behaviour through public interfaces, pre-agreed seams, vertical slices). Reference primitive; drives implement's test-first phase. tests.md + mocking.md |
| teach | Turn the current directory into a stateful, multi-session teaching workspace (MISSION / RESOURCES / learning-records / HTML lessons / reusable assets). Grounds every lesson in the user's mission, cites trusted resources over parametric knowledge, designs for storage strength (retrieval, spacing, interleaving) within the zone of proximal development. `disable-model-invocation` — explicit invoke only |
| time-reality-check | Counter time blindness with a calibrated three-point estimate (best/likely/worst) accounting for setup, interruptions, re-entry. Council: statistics-expert + devils-advocate |
| which-skill | Router over the pack: describe a situation, get the one skill (or flow) that fits, why, and the exact command — the cure for remembering 61 skills. Reads FLOWS.md. `disable-model-invocation` — explicit invoke only |
| work-plan | Plan work too big for one session (and too foggy to see the route) as a shared map of decision tickets on the issue tracker (work-plan): name the destination, chart the frontier + fog of war, resolve one decision ticket per session (research/prototype/grilling/task) until the way is clear. Plans decisions, not the build. `disable-model-invocation` — explicit invoke only |
| writing-apology-calibrator | Calibrate a drafted apology: strip reflexive over-apology, keep warranted accountability. Council: psychologist + devils-advocate |
| writing-beats | Shape an article as a journey of beats, choose-your-own-adventure style |
| writing-cold-open | Produce just the first sentence of a message when the blank cursor is winning. Three openings (direct/warm/contextual), then steps out |
| writing-draft-article | Guide from raw idea/draft to a finished, polished article through iterative questioning |
| writing-fragments | Mine the user for raw writing fragments before imposing structure |
| writing-humanize | Remove signs of AI-generated writing from text |
| writing-shape | Shape raw material into an article paragraph by paragraph through a conversational session |
| writing-social-script | Generate a literal script for a dreaded social scenario. Three phrasings (direct/neutral/softened) + exit line. Council: psychologist + customer-advocate |
| writing-tone-check | Pre-send tone reviewer: paste a draft, get a landing prediction (cold / passive-aggressive / over-apologetic) + rewrite suggestions. Sibling to break-it-down. Council: psychologist |

## Adding a new skill

1. Create `<category>/<name>/SKILL.md` under one of the categories in [CATEGORIES.md](CATEGORIES.md), with proper YAML frontmatter (name, description). The `name` must equal the leaf folder `<name>` and be globally unique across all categories.
2. Add a row to the **Skills inventory** table above in this file — **but only for public skills**. If the skill lives under `_private/` (junction in the root), skip the inventory row and add it to `.gitignore` instead. (README.md links to the inventory — do not duplicate it there.)
3. Keep supporting docs inside the skill folder.
4. Each skill should have a README.md that expands on the instructions in `SKILL.md` with examples, edge cases, and troubleshooting tips. Link to it from `SKILL.md` if needed.
5. Each skill should be self-contained. If it depends on another skill, link to that skill's README for instructions instead of cross-referencing internal steps.
6. If needed, the skill should have an examples.md with annotated code snippets for common use cases and edge cases. Link to it from the README.
7. Folder names are stable — do not rename once published.

## Editing an existing skill

- The `SKILL.md` at the folder root is the entry point. Never move it.
- Supporting files (formats, deep-dive modules, persona contracts) stay in the same folder.
- Update the skill's README if the workflow or reference files change.
- **Loop Method:** If you add related-skills or a Delegation Map, update the frontmatter + add the section to SKILL.md.
- If the skill can now run recurring, add `loop-eligible: true` and `recurrence-hint: [frequency]`.
