# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Part of the Ink and Agency ecosystem:** See **[INTEGRATION.md](INTEGRATION.md)** for how skills compose with each other.

## Nature of this repo

This is a **Claude Skills Pack** — a collection of prompt-based skill definitions. Each skill is a markdown file (`SKILL.md`) in its own folder. There is no build system, test runner, or linter.

## Structure

The layout is **flat** — one folder per skill, directly under `skills/`. Agent Plugins 1.0.0
requires it: conformant hosts look at the immediate children of `skills/` and must not search
deeper, so a nested `SKILL.md` would simply never be found. Category is a `category:` frontmatter
field instead; see [CATEGORIES.md](CATEGORIES.md) for the 15 buckets and the full index. Claude Code
also reads the `skills` array in `.claude-plugin/plugin.json`, generated from the tree by
`convert-agents-to-codex.ps1` — do not hand-edit it.

```text
<name>/SKILL.md                   # Skill entry point (YAML frontmatter + instructions)
<name>/*.md                       # Supporting docs, formats, or deep-dive modules
<name>/agents/openai.yaml         # Codex picker metadata (GENERATED)
clarity-council/                  # featured skill (reads persona/)
persona/                          # shared council persona contracts (reference docs, not skills)
persona/PERSONAS.md               #   persona index; persona/GROUPS.md = pre-made panels
```

The skill **name** (invocation id) is the folder name and is independent of its category —
recategorizing is a one-line frontmatter edit that moves no files and breaks no links. Cross-skill
relative links are a single hop: `../<name>/`.

## Skill format

Each `SKILL.md` begins with YAML frontmatter:

```yaml
name: skill-name
category: writing                      # required — a bucket from CATEGORIES.md (or 'featured')
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
self-evolve: false                     # optional — opt out of the Self-Evolve Loop footer
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
- **Self-Evolve footer:** every SKILL.md carries the Self-Evolve Loop footer unless it opts out with `self-evolve: false`; the footer link must resolve to `SELF-EVOLVE.md`

Validation is performed by `scripts/lint-skills.ps1`.

## Self-Evolve Loop (cross-invocation)

Where the Quality Loop evaluates output *before returning it*, the **Self-Evolve
Loop** learns *across invocations*: at the end of each run a skill self-evaluates,
optionally asks the user for feedback (never blocking), appends signal-bearing
learnings to a per-skill journal (`~/.ink-and-agency/learnings/<name>.md`, or the
workspace-local `.ink-and-agency/learnings/<name>.md` where the sandbox confines
writes), reads that journal back at the start of future runs, and routes
skill-improvement ideas by tier — editing the **canonical repo** directly when one is
present on the machine (never the plugin cache), recording suggestions otherwise.
The full contract is [SELF-EVOLVE.md](SELF-EVOLVE.md).

Every skill carries a short `## Self-Evolve Loop` footer between
`<!-- self-evolve:start -->` / `<!-- self-evolve:end -->` markers pointing at the
contract. The footer is **machine-maintained** by `scripts/add-self-evolve.ps1`
(idempotent: adds missing footers, syncs drifted ones to the template, strips them
from skills with `self-evolve: false`) — edit the template in the script and re-run,
never hand-edit a footer.

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
| codebase-design | Deep-module design vocabulary — module, interface, depth, seam, adapter, leverage, locality — plus DEEPENING.md (dependency categories, seam discipline) and INTERFACE-DESIGN.md (design-it-twice). Reference skill: the single source of the language codebase-improve-architecture, codebase-plan-refactor, and tdd all speak |
| codebase-explain | High-level context and module mapping for unfamiliar code areas |
| codebase-improve-architecture | Find refactor/deepening opportunities, informed by CONTEXT.md and ADRs |
| codebase-plan-refactor | Build incremental refactor plan via interview → file as GitHub issue |
| daily-briefing | Outlook-driven daily briefing: 24h email + calendar recap, today's schedule, action items, focus blocks |
| daily-standup-prep | Per-team standup report: gathers Jira/GitLab/Confluence/Git activity over N days, maps to roster, renders Mermaid kanban + talking order, writes to vault |
| debug | Six-phase diagnosis loop for hard bugs and performance regressions: build a tight red-capable feedback loop first, then reproduce/minimise → ranked falsifiable hypotheses → one-variable instrumentation → fix + regression test → cleanup + post-mortem. Hands off to codebase-improve-architecture when the root cause is architectural |
| defuddle | Extract clean markdown from web pages via Defuddle CLI (use instead of WebFetch for HTML) |
| domain-modeling | Active domain-model discipline: challenge terms against the glossary, sharpen fuzzy language, stress-test with scenarios, write CONTEXT.md and ADRs inline. Owns CONTEXT-FORMAT.md + ADR-FORMAT.md; grill-with-docs runs the interview half |
| energy-budget | Spoon-theory accounting for the calendar: score today's load, flag burnout risk, suggest defers. Council: personal-assistant + psychologist |
| good-morning | Morning kickoff wrapper: runs sprint-snapshot (daily tag) → daily-standup-prep (with burndown) → daily-briefing (report only, no focus blocks). Idempotent — overwrites today's artifacts on re-run |
| grill-me | Stress-test plans through iterative questioning |
| grill-with-docs | Grilling against domain docs + updating CONTEXT/ADR artifacts inline |
| handoff | Compact the current conversation into a structured handoff document so a fresh agent can pick up work without re-deriving context. Saves to OS temp directory, includes suggested skills, redacts sensitive data. |
| hyperfocus-exit | Park a deep session before a forced interrupt: clock-tiered (slam / standard / full), captures the head-state that isn't on disk, writes `.ink-and-agency/park/<ts>.md` + a `PARKED` breadcrumb at the cursor line. Inverse of hyperfocus-recovery, which reads both |
| hyperfocus-recovery | Reconstruct context after a deep session or interruption from git/file artifacts → suggested re-entry point. Reads a hyperfocus-exit park file first when one exists |
| i-am-autistic | Output-shaping skill for an autistic reader: say the thing directly, label every instruction required/recommended/optional, literal language, quantified uncertainty instead of hedges, fact/inference/opinion labeled, social subtext named, no demanded social performance. Composes with i-have-adhd (safety → explicitness → brevity) |
| i-have-adhd | Output-shaping skill for an ADHD reader: next action on the first line, numbered multi-step work, progress state restated every turn, one thread at a time, numeric time estimates, no preamble/recap/closer. Overrides for "explain", destructive actions, debug spirals, real ambiguity. Shapes form, never substance |
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
| overwhelm-triage | Unstructured dump of everything competing for attention → exactly one thing to do, rest parked with a date. Sorts by consequence-if-missed (not importance) into Today / this week / no date / not yours; non-tasks pulled out as worries. Routes to energy-budget when ≥3 real Today items (capacity, not triage) |
| obsidian-bases | Create and edit Obsidian Bases (.base files) — views, filters, formulas, summaries |
| obsidian-canvas | Create and edit Obsidian .canvas files (nodes, edges, groups, connections) |
| obsidian-charts | Build interactive Chart.js charts in Obsidian via `chart` codeblocks — inline literal series, link to a markdown table by `^blockId` (same note or cross-file), or render from a Dataview/Dataviewjs query via `window.renderChart` |
| obsidian-cli | Interact with Obsidian vaults via CLI: notes, tasks, properties; supports plugin/theme dev |
| obsidian-markdown | Create and edit Obsidian Flavored Markdown (wikilinks, callouts, frontmatter, embeds) |
| obsidian-vault | Search, create, and manage notes in the Obsidian vault with wikilinks and index notes |
| plan-to-questionnaire | Turn a decision the user can't answer alone into a Markdown questionnaire for the person who can — grills the *send* (recipient + what's needed back), never the subject. Writes `plan-to-questionnaire-<slug>.md`. `disable-model-invocation` — explicit invoke only |
| plan-to-spec | Synthesize a settled design discussion into a spec (PRD) staged as a local `spec.md` (spec-kit style, numbered feature folder) — no interview, just write-up. Publishing to Confluence is opt-in, on request. Bridges grill/work-plan → tickets. `disable-model-invocation` — explicit invoke only |
| plan-to-tickets | Break a spec/plan/conversation into a local numbered `tasks.md` (spec-kit style: tracer-bullet vertical slices, explicit dependencies, `[P]` markers). Pushing to Jira as tickets with native "Blocks" links is opt-in, on request. Handles wide refactors via expand–contract. `disable-model-invocation` — explicit invoke only |
| prototype | Build throwaway code that answers one design question, then keep only the answer. Two branches: a hand-driven TUI over a pure logic module (state models), or N structurally different UI variants on one route behind a `?variant=` switcher. Resolves `work-plan`'s prototype-type decision tickets |
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
| wait-what | Fire it the moment a message doesn't land: same message re-pitched with a run-up, in ASD-STE100 Simplified Technical English, using CONTEXT.md vocabulary. No apology, no redo. `disable-model-invocation` — explicit invoke only |
| which-skill | Router over the pack: describe a situation, get the one skill (or flow) that fits, why, and the exact command — the cure for remembering the whole catalogue. Reads FLOWS.md. `disable-model-invocation` — explicit invoke only |
| wizard | Generate an interactive bash wizard walking a human through a manual procedure (credentials, dashboards, one-off cutovers). Ships template.sh — the shared library (progress, confirm gates, WSL-aware URL opening, hidden entry, idempotent .env upserts, gh secret writes); the skill only scopes and authors stages |
| work-plan | Plan work too big for one session (and too foggy to see the route) as a shared map of decision tickets on the issue tracker (work-plan): name the destination, chart the frontier + fog of war, resolve one decision ticket per session (research/prototype/grilling/task) until the way is clear. Plans decisions, not the build. `disable-model-invocation` — explicit invoke only |
| writing-apology-calibrator | Calibrate a drafted apology: strip reflexive over-apology, keep warranted accountability. Council: psychologist + devils-advocate |
| writing-beats | Shape an article as a journey of beats, choose-your-own-adventure style |
| writing-cold-open | Produce just the first sentence of a message when the blank cursor is winning. Three openings (direct/warm/contextual), then steps out |
| writing-draft-article | Guide from raw idea/draft to a finished, polished article through iterative questioning |
| writing-for-agents | Reference for writing documents an agent consumes — context pointers, the two loads, information hierarchy/progressive disclosure, completion criteria, leading words, pruning. SKILL-MECHANICS.md covers the skill-specific branch (invocation choice, router skills) |
| writing-fragments | Mine the user for raw writing fragments before imposing structure |
| writing-humanize | Remove signs of AI-generated writing from text |
| writing-shape | Shape raw material into an article paragraph by paragraph through a conversational session |
| writing-social-script | Generate a literal script for a dreaded social scenario. Three phrasings (direct/neutral/softened) + exit line. Council: psychologist + customer-advocate |
| writing-tone-check | Pre-send tone reviewer: paste a draft, get a landing prediction (cold / passive-aggressive / over-apologetic) + rewrite suggestions. Sibling to break-it-down. Council: psychologist |

## README shape

Every skill ships a sibling `README.md` (lint warns without one). It is the human's page — `SKILL.md` is the agent's — so it carries the reasoning, the edge cases, and the honest limits that would be pure context load inside the skill itself. The sections that earn their place, in order:

| Section | Carries |
| :--- | :--- |
| Why this exists | The failure mode the skill guards against |
| Triggers | Phrasings that fire it, the slash command, and what invokes it automatically |
| What it does / Inputs / Outputs | The mechanism, and the artifacts it leaves behind |
| How to use it | One realistic transcript, not a feature list |
| Routing table *(optional)* | "Which skill do I actually want?" — a two-column table against its nearest neighbours. Worth it wherever a skill is routinely confused with a sibling |
| **It's working if** | **Observable signals the run went right** — what the user should *see*, not what the skill intends. This is the section that makes a skill checkable rather than aspirational; include at least one signal that catches the skill going off the rails |
| Common questions *(optional)* | Real failure reports and the honest answer, including what deliberately isn't supported. A limitation stated here is worth more than one discovered mid-run |
| Getting the most out of it / Anti-patterns | Usage judgement, then the ❌ list |
| Related skills / Files / Host portability | Navigation and the portability note |

"It's working if" and "Common questions" are the two sections a skill is most often missing. When adding either to an existing skill, write signals you have actually observed — an invented checklist is worse than none.

## Adding a new skill

1. Create `<name>/SKILL.md` directly under `skills/` — never nested deeper, or conformant hosts won't discover it. Frontmatter needs `name`, `description`, and a `category` from [CATEGORIES.md](CATEGORIES.md). The `name` must equal the folder name and be globally unique.
2. Add a row to the **Skills inventory** table above in this file — **but only for public skills**. If the skill lives under `_private/` (junction in the root), skip the inventory row and add it to `.gitignore` instead. (README.md links to the inventory — do not duplicate it there.)
3. Keep supporting docs inside the skill folder.
4. Each skill should have a README.md following the **README shape** above — examples, edge cases, an "It's working if" checklist, and troubleshooting. Link to it from `SKILL.md` if needed.
5. Each skill should be self-contained. If it depends on another skill, link to that skill's README for instructions instead of cross-referencing internal steps.
6. If needed, the skill should have an examples.md with annotated code snippets for common use cases and edge cases. Link to it from the README.
7. Run `pwsh ./scripts/add-self-evolve.ps1` so the new skill gets its Self-Evolve Loop footer (lint fails without it; opt out with `self-evolve: false` in frontmatter where end-of-run evaluation makes no sense).
8. Folder names are stable — do not rename once published.

## Editing an existing skill

- The `SKILL.md` at the folder root is the entry point. Never move it.
- Supporting files (formats, deep-dive modules, persona contracts) stay in the same folder.
- Update the skill's README if the workflow or reference files change.
- **Loop Method:** If you add related-skills or a Delegation Map, update the frontmatter + add the section to SKILL.md.
- If the skill can now run recurring, add `loop-eligible: true` and `recurrence-hint: [frequency]`.
- **Self-Evolve footer:** never hand-edit the block between the `self-evolve` markers — change the template in `scripts/add-self-evolve.ps1` and re-run it.
