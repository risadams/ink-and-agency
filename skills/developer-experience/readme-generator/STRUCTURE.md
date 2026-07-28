# README structure

The section ladder, in order. **Required** sections ship in every README. **Recommended**
sections ship unless there is a reason to drop one. **Optional** sections earn their place.

Order matters more than completeness: a reader scans top-down and stops when they have what
they came for. Never bury the run command under a philosophy essay.

## The ladder

| # | Section | Tier | Contains |
| :-- | :--- | :--- | :--- |
| 1 | Title + one-liner | Required | Project name, then a single sentence naming what it does and for whom. No marketing adjectives. |
| 2 | Badges | Recommended | Build status, version/package, license, coverage. Only badges that are live and true — a stale badge is worse than none. |
| 3 | Visual | Recommended | Screenshot, GIF, terminal cast, or architecture diagram. Skip only when the project is genuinely invisible (a pure library). |
| 4 | Why / what problem | Required | 2–4 sentences: the problem, and why this over the obvious alternative. This is the section most READMEs skip and most readers need. |
| 5 | Quick start | Required | Prerequisites (with versions), install, then the smallest command that produces visible output. Copy-pasteable, in that order. |
| 6 | Usage | Required | Real examples with expected output. Escalate simple → common → advanced. |
| 7 | Table of contents | Optional | Only when the README passes ~2 screens. Place it after the one-liner. |
| 8 | Configuration | Recommended | Every env var and config key: name, type, default, required?, what it does. A table, not prose. |
| 9 | How it works | Optional | Architecture, data flow, key decisions. For anything a contributor must understand before their first change. |
| 10 | Development | Recommended | Clone-to-running-tests for a contributor. Distinct from Quick start, which is for a *user*. |
| 11 | Troubleshooting / FAQ | Optional | Only real, observed failures — the errors your issue tracker actually shows. |
| 12 | Contributing | Recommended | Link `CONTRIBUTING.md` if it exists; otherwise 3–5 lines on branch, test, PR expectations. |
| 13 | Credits | Optional | Contributors, upstream projects, tutorials the work is built on. |
| 14 | License | Required | Name the license and link the file. One line. |

## Shape by project type

The ladder bends to the artifact:

- **Library / SDK** — Usage is the centre of gravity. Expand it with an API surface table.
  Visual is often a code block rather than an image.
- **CLI** — Quick start carries a real terminal session including output. Add a command
  reference table (command, flags, what it does) captured from `--help`.
- **Application / service** — Visual is required, not recommended. Add Deployment after
  Configuration.
- **Internal / private repo** — Drop badges and Credits. Add an Owner section: who to ask,
  which channel, on-call.

## Writing rules

- **Second person, active voice, present tense.** "Run `npm start`" — not "the application
  may then be started".
- **Commands in fenced blocks with a language tag**, one command per line, no `$` prompt
  prefix (it breaks copy-paste).
- **Headings are navigation.** A reader skimming only the `##` lines should get the shape of
  the project.
- **Link, don't inline.** Long API tables, changelogs, and architecture deep-dives live in
  their own files.
- **Absolute over relative time.** "Requires Node 20+", never "requires a recent Node".
