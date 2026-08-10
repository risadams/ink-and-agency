# Wizard

Generate an **interactive bash wizard** that walks a human, step by step, through a procedure only they can perform — provisioning a service, collecting credentials, clicking through an unfamiliar dashboard, running a one-off cutover.

## Why this exists

Some steps can't be automated and shouldn't be: someone has to log into Stripe with their own eyes, reveal a key, and paste it back. Today that knowledge lives in a README section that rots, or in a conversation you re-explain to an agent every time.

A wizard makes the procedure executable *by a human*. It opens the URL, says exactly what to click, hides secret input, upserts the value into `.env`, pushes the ones CI needs to GitHub, and tells you how many stages are left. The delightful part is already written — [template.sh](template.sh) is the same library in every wizard — so the work is scoping the procedure, not building a TUI.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "walk me through setting this up"
  - "generate a setup script for the new environment"
  - "I need to collect API keys for local dev and CI"
  - "script the cutover steps I have to do by hand"
- Running the slash command: `/wizard`

Not for steps the agent can do itself. If no human judgement or human-only access is required, automate it instead.

## What it does

Scopes the manual procedure from the repo, confirms the stage list with you, then authors stages below the `STAGES` marker in a copy of the template.

### Inputs

- **The procedure** — what the human must do, or enough of the repo (`.env*`, CI workflows, `docker-compose*`, framework config) for the skill to infer it.
- **Confirmation of the stage list** before any script is written.

### Outputs

- An executable bash script — ephemeral by default (scratch or `scripts/`), committed only when it's a repeatable setup path.
- Values landed where they belong: `.env` upserts, `gh secret` / `gh variable` writes, and a closing summary of anything skipped.

### External systems used

- The human's browser (via `open_url`, including WSL).
- `gh` for repository secrets and variables — optional; the wizard records a to-do rather than failing when it isn't available.

## How to use it

```text
You: /wizard — set up a new dev environment for the payments service

Skill: Six stages, from .env.example and .github/workflows/deploy.yml:
       1. Stripe test keys → STRIPE_PUBLISHABLE_KEY, STRIPE_SECRET_KEY (+ CI secret)
       2. Supabase project → SUPABASE_URL, SUPABASE_ANON_KEY
       ...
       Add, drop, or reorder?

You: drop 4, we don't use Sentry anymore
Skill: Written to scripts/setup-dev.sh. Run it with: bash scripts/setup-dev.sh
```

## Getting the most out of it

- **Correct the stage list.** It's the cheapest moment to fix the procedure — before any script exists.
- **Say when you don't know the dashboard.** The skill asks rather than inventing UI paths; confirming a real one is faster than debugging a wrong one.
- **Re-run it freely.** `.env` writes are idempotent and existing values offer themselves as defaults, so Ctrl-C and resume is safe.
- **Commit the ones you'll run again.** A wizard linked from the README is onboarding that can't drift out of sync with the code the way prose does.

## Anti-patterns

- ❌ **Hand-editing the library above the `STAGES` marker.** Consistency across wizards is the point; author below the marker.
- ❌ **Wizarding what could be automated.** If a human isn't required, this is ceremony.
- ❌ **Inventing dashboard steps.** A confidently wrong click path costs more than asking.
- ❌ **Cramming several tasks into one stage.** Each `stage` clears the screen; anything that scrolls away is lost.
- ❌ **Running it end-to-end yourself to "test" it.** It opens browsers and blocks on input. Trace it statically instead.

## Related skills

- **[shell-expert](../shell-expert/)** — for non-trivial shell logic added below the marker.
- **[cli-developer](../cli-developer/)** — when the one-off wizard deserves to become a real CLI.
- **[deployment-engineer](../deployment-engineer/)** — when the procedure should become CI automation instead of a human script.
- **[readme-generator](../readme-generator/)** — to give a committed wizard a front-door mention.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (scoping, stage mapping, authoring, verification)
- **[template.sh](template.sh)** — the wizard library: progress, confirmation gates, cross-platform URL opening, hidden entry, idempotent `.env` upserts, `gh` writes, closing summary

## Host portability

Runs on Claude Code, Codex, and opencode — the skill writes a file and asks questions. The *generated script* is bash: on Windows, run it under Git Bash or WSL (`open_url` already handles `wslview` and `explorer.exe`). See [PORTABILITY.md](../PORTABILITY.md).
