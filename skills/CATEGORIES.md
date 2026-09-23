# Skill Categories

All skills live under `skills/<name>/SKILL.md` — a flat layout, because Agent Plugins 1.0.0
fixes skill discovery at the immediate children of `skills/`. Categories are a browsing aid
declared in each skill's `category:` frontmatter field, not a folder path, so recategorizing
a skill moves nothing and breaks no links.

**94 skills across 12 categories**, plus the featured [`clarity-council`](clarity-council/) skill.

> **Featured:** [`clarity-council`](clarity-council/) carries `category: featured` rather than one of
> the browsing buckets below — it's the persona-consultation engine that many other skills delegate to,
> and it ships with the bundled `persona/` library. It's an ordinary invokable skill; the separate
> bucket just reflects how central it is.
>
> **Not a category:** `skills/persona/` holds the council persona contracts — shared reference
> documents (no `SKILL.md`), read by the [`clarity-council`](clarity-council/) skill. They're
> advisory voices you consult, not invokable skills, so they don't appear below.

## Business & Product &nbsp;`business-product` (13)

Product delivery, issue management, and go-to-market.

- [`assumption-mapping`](assumption-mapping/) — Use when the user needs to identify and prioritize risky assumptions in a product idea, feature, or strategy.
- [`backlog-grooming`](backlog-grooming/) — Use when the user needs to groom, refine, or clean up a product backlog.
- [`business-analyst`](business-analyst/) — Use when analyzing business processes, gathering requirements from stakeholders, or identifying process improvement opportunities to drive operatio...
- [`content-quality-editor`](content-quality-editor/) — Use this skill before publishing any AI-generated content — blog posts, READMEs, release notes, commit messages, PR descriptions, documentation, ...
- [`growth-loops`](growth-loops/) — Use when the user wants to design a growth loop, understand PLG mechanics, or build sustainable acquisition.
- [`issue-draft-release-notes`](issue-draft-release-notes/) — Draft a customer-facing release note for a Jira ticket from its context and linked merge requests.
- [`issue-dup-find`](issue-dup-find/) — Scan a Jira project's open issues for likely duplicates and report each suspected pair with a probability score and reasoning.
- [`issue-estimate-sp`](issue-estimate-sp/) — Estimate story points for a Jira ticket using historical data and multi-persona scrum poker.
- [`issue-feature-breakdown`](issue-feature-breakdown/) — Analyze a Jira ticket into an actionable breakdown, following linked tickets and Confluence context to surface gaps and ambiguities.
- [`issue-suggest-component`](issue-suggest-component/) — Suggest Jira components for one ticket or sweep a project's open tickets, confirming before any modification.
- [`issue-triage`](issue-triage/) — Triage a bug or Jira ticket into ranked root-cause candidates and proposed solution paths.
- [`project-manager`](project-manager/) — Use when you need to establish project plans, track execution progress, manage risks, control budget/schedule, and coordinate stakeholders across c...
- [`technical-writer`](technical-writer/) — Use when you need to create, improve, or maintain technical documentation including API references, user guides, SDK documentation, and getting-sta...

## Codebase & Build &nbsp;`codebase-build` (9)

Understand, review, debug, and build a codebase (the implement/tdd loop).

- [`code-review`](code-review/) — Two-axis review of the working diff since a fixed point — Standards (repo conventions and code smells) and Spec (matches the originating ticket).
- [`codebase-churn`](codebase-churn/) — Analyze a git repository's history and produce an SVG treemap of file churn — area = lines changed, color = commit frequency.
- [`codebase-design`](codebase-design/) — Shared vocabulary and principles for designing deep modules — a lot of behaviour behind a small interface, placed at a clean seam.
- [`codebase-explain`](codebase-explain/) — Tell the agent to explain code with broader context and a higher-level perspective.
- [`codebase-improve-architecture`](codebase-improve-architecture/) — Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/.
- [`codebase-plan-refactor`](codebase-plan-refactor/) — Create a detailed refactor plan with tiny commits via user interview, then file it as an issue.
- [`debug`](debug/) — Diagnosis loop for hard bugs and performance regressions.
- [`implement`](implement/) — Build a piece of work (ticket, spec, or free-form request) through a tunable pipeline — test-first, verify, review, and track — where every pha...
- [`tdd`](tdd/) — Test-driven development — the red → green loop and the rules that make its tests worth keeping.

## Data & AI &nbsp;`data-ai` (2)

Data engineering, ML, AI, analytics, and LLM work.

- [`data-analyst`](data-analyst/) — Use when you need to extract insights from business data, create dashboards and reports, or perform statistical analysis to support decision-making.
- [`ml-engineer`](ml-engineer/) — Use when building production ML systems — training pipelines, model serving, inference optimization, automated retraining — or setting up MLOps...

## Developer Experience &nbsp;`developer-experience` (7)

Tooling, docs, refactoring, and Git workflow.

- [`branch-rebase`](branch-rebase/) — Safely rebase the current branch onto its upstream target, auto-resolving trivial conflicts and prompting for complex ones.
- [`branch-resolve-conflicts`](branch-resolve-conflicts/) — Reconstruct intent when a git merge or rebase hits complex conflicts, preserving both branches' goals where possible.
- [`documentation-engineer`](documentation-engineer/) — Use when you need to create, architect, or overhaul comprehensive documentation systems including API docs, tutorials, guides, and developer-friend...
- [`readme-generator`](readme-generator/) — Write, overhaul, or review a project README that is accurate to the repository and readable by a human.
- [`refactoring-specialist`](refactoring-specialist/) — Use when you need to transform poorly structured, complex, or duplicated code into clean, maintainable systems while preserving all existing behavior.
- [`visual-asset-generator`](visual-asset-generator/) — Use when you need to generate production-ready visual assets for a project — app icons, favicons, OG images, logos, wordmarks, or social media im...
- [`wizard`](wizard/) — Generate an interactive bash wizard that walks a human step by step through a manual procedure.

## Executive Function &nbsp;`exec-function` (14)

Neurodivergent-friendly executive-function support.

- [`break-it-down`](break-it-down/) — Decode messages into plain language with tone and intent analysis.
- [`daily-briefing`](daily-briefing/) — Personal daily briefing assistant.
- [`energy-budget`](energy-budget/) — Score today's load (meetings, sensory demand, social events, deep work), flag burnout risk, and suggest what to drop or defer.
- [`hyperfocus-exit`](hyperfocus-exit/) — Park a deep work session before an interruption — capture what is only in your head, write a park file, drop a breadcrumb at the cursor.
- [`hyperfocus-recovery`](hyperfocus-recovery/) — Reconstruct context after a deep session or interruption from git diff, modified files, and recent commits, then propose the next concrete action.
- [`i-am-autistic`](i-am-autistic/) — Shape every response for an autistic reader — direct statements, required/optional labels, literal language, quantified uncertainty, named social...
- [`i-have-adhd`](i-have-adhd/) — Shape every response for a reader with ADHD — next action first, numbered steps, progress restated each turn, one thread, numeric time estimates.
- [`interest-capture`](interest-capture/) — Capture the current hyperfixation into the Obsidian vault fast, so it isn't lost and doesn't derail today's work.
- [`meeting-decompression`](meeting-decompression/) — Process a meeting dump — separate facts from feelings, flag action items, sort social ambiguities into worth-following-up vs noise.
- [`overwhelm-triage`](overwhelm-triage/) — Turn an unstructured dump of everything competing for attention into exactly one thing to do now, with the rest parked and dated.
- [`rejection-sensitivity-check`](rejection-sensitivity-check/) — Calibrate a message that stung — separate evidence from interpretation, score how much sting is warranted.
- [`task-initiation`](task-initiation/) — Produce the literal first physical action when the user knows what to do but can't start — not a plan, not a breakdown.
- [`time-reality-check`](time-reality-check/) — Counter time blindness with a calibrated estimate that accounts for setup, interruptions, and re-entry.
- [`wait-what`](wait-what/) — Stop — that last message didn't land.

## Infrastructure &nbsp;`infrastructure` (1)

Security engineering and operational hardening.

- [`security-engineer`](security-engineer/) — Use when implementing security across infrastructure and CI/CD — threat modeling, zero- trust architecture, security automation, vulnerability ma...

## Meta-Orchestration &nbsp;`meta-orchestration` (12)

Planning, handoff, and the plan-to-spec-to-tickets build pipeline.

- [`agent-installer`](agent-installer/) — Use when the user wants to discover, browse, or install Claude Code agents from the subagent repository.
- [`defuddle`](defuddle/) — Extract clean markdown from web pages using Defuddle CLI, stripping navigation and clutter to save tokens.
- [`handoff`](handoff/) — Compact the current conversation into a handoff document for another agent to pick up.
- [`plan-to-questionnaire`](plan-to-questionnaire/) — Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can — filled in async, or worked through together in ...
- [`plan-to-spec`](plan-to-spec/) — Synthesize the current conversation into a spec (PRD) and stage it as a local file.
- [`plan-to-tickets`](plan-to-tickets/) — Break a spec, plan, or the current conversation into a local, numbered, spec-kit-style task list of tracer-bullet vertical slices with explicit dep...
- [`prototype`](prototype/) — Build a throwaway prototype to answer a design question.
- [`research`](research/) — Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo.
- [`skill-create`](skill-create/) — Create new agent skills with proper structure, progressive disclosure, and bundled resources.
- [`teach`](teach/) — Teach the user a new skill or concept, within this workspace.
- [`work-plan`](work-plan/) — Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets on your issue tracker, and resolve them ...
- [`writing-for-agents`](writing-for-agents/) — Reference for writing any document an agent consumes — a skill, an AGENTS.md or CLAUDE.md, a doc reached by a pointer.

## Obsidian &nbsp;`obsidian` (6)

Read/write and structure an Obsidian vault.

- [`obsidian-bases`](obsidian-bases/) — Create and edit Obsidian Bases (.base files) with views, filters, formulas, and summaries.
- [`obsidian-canvas`](obsidian-canvas/) — Create and edit Obsidian Canvas files (.canvas) following the JSON Canvas spec — nodes, edges, groups, and connections.
- [`obsidian-charts`](obsidian-charts/) — Build interactive Chart.js charts in Obsidian notes via `chart` codeblocks — inline series, a markdown table by block ID, or a Dataview query.
- [`obsidian-cli`](obsidian-cli/) — Read, create, search, and manage Obsidian vault notes, tasks, and properties from the command line; also supports plugin and theme development and ...
- [`obsidian-markdown`](obsidian-markdown/) — Create and edit Obsidian Flavored Markdown with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax.
- [`obsidian-vault`](obsidian-vault/) — Search, create, and manage notes in the Obsidian vault with wikilinks and index notes.

## Quality & Security &nbsp;`quality-security` (4)

Testing, debugging, performance, and content-quality review.

- [`ai-writing-auditor`](ai-writing-auditor/) — Use when you need to audit content for AI writing patterns and rewrite text to remove them.
- [`debugger`](debugger/) — Use when you need to diagnose and fix bugs, identify root causes of failures, or analyze error logs and stack traces to resolve issues.
- [`performance-engineer`](performance-engineer/) — Use when you need to identify and eliminate performance bottlenecks in applications, databases, or infrastructure systems, and when baseline perfor...
- [`test-automator`](test-automator/) — Use when you need to build, implement, or enhance automated test frameworks, create test scripts, or integrate testing into CI/CD pipelines.


## Research & Analysis &nbsp;`research-analysis` (10)

Research, decision support, and idea work.

- [`ab-test-analysis`](ab-test-analysis/) — Use when the user wants to analyze A/B test results, interpret p-values, determine statistical significance, or make a ship/no-ship decision.
- [`cohort-analysis`](cohort-analysis/) — Use when the user wants to analyze retention, cohort behavior, engagement trends, or understand how different user groups perform over time.
- [`domain-modeling`](domain-modeling/) — Actively build and sharpen a project's domain model — challenge fuzzy terms, stress-test with scenarios, and write CONTEXT.md and ADRs inline as ...
- [`first-principles-thinking`](first-principles-thinking/) — Use when the user wants to challenge assumptions, break down a complex problem from scratch, or approach something with first principles reasoning.
- [`grill-me`](grill-me/) — Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
- [`grill-with-docs`](grill-with-docs/) — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) in...
- [`idea-choice`](idea-choice/) — Weigh one or more ideas with a structured pros-and-cons analysis and a Go / Go with caveats / Don't recommendation.
- [`idea-decision-maker`](idea-decision-maker/) — Force a binary pick when the user is stuck between options — three clarifying questions, then a verdict with reasoning.
- [`idea-generate`](idea-generate/) — Helps users generate, refine, and stress-test ideas from loose topics.
- [`which-skill`](which-skill/) — Router over this pack's skills and flows.

## Scrum & Sprint &nbsp;`scrum-sprint` (6)

The Scrum ceremony chain — snapshot, plan, standup, review.

- [`daily-standup-prep`](daily-standup-prep/) — Generate a per-team standup report from recent Jira, GitLab, Confluence, and Git activity, written into the Obsidian vault.
- [`good-morning`](good-morning/) — Morning kickoff wrapper running sprint-snapshot, daily-standup-prep, and daily-briefing in order; idempotent on same-day re-runs.
- [`sprint-plan`](sprint-plan/) — Convert the start-of-sprint canvas into a planning report — committed scope, capacity vs commitment, WIP-saturation risk, observations, risks.
- [`sprint-review`](sprint-review/) — End-of-sprint stakeholder report comparing the sprint's start and end canvases, fitted to the standard Scrum Master template.
- [`sprint-snapshot`](sprint-snapshot/) — Capture a point-in-time snapshot of a scrum team's sprint board into the Obsidian vault.
- [`sprint-sos-report`](sprint-sos-report/) — Weekly scrum-of-scrums report comparing two sprint snapshots — findings, observations, trouble areas, trends.

## Writing &nbsp;`writing` (9)

Draft, shape, and calibrate written material.

- [`writing-apology-calibrator`](writing-apology-calibrator/) — Calibrate a drafted apology — strip reflexive over-apology, keep warranted accountability.
- [`writing-beats`](writing-beats/) — Shape an article as a journey of beats, choose-your-own-adventure style — write one beat, offer pivots, repeat until it ends.
- [`writing-cold-open`](writing-cold-open/) — Produce the first sentence of a message when the blank cursor is winning — two or three openings matched to relationship and goal, then step out.
- [`writing-draft-article`](writing-draft-article/) — Guide the user from raw idea or draft to a finished article through relentless questioning and iterative writing.
- [`writing-fragments`](writing-fragments/) — Mine the user for raw writing fragments — claims, vignettes, sharp sentences, half- thoughts — and append them to one document as material for ...
- [`writing-humanize`](writing-humanize/) — Remove signs of AI-generated writing — inflated symbolism, promotional language, vague attributions, em dash overuse, rule of three, AI vocabular...
- [`writing-shape`](writing-shape/) — Shape a file of raw material into an article through a conversational session — candidate openings, paragraph by paragraph, arguing format at eac...
- [`writing-social-script`](writing-social-script/) — Generate a script for a dreaded social scenario — declining, asking for an extension, following up, setting a boundary — in two or three phrasi...
- [`writing-tone-check`](writing-tone-check/) — Reverse decoder — paste a draft message and get a read on how it will land before you send.
