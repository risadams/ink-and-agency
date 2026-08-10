# Plan to Questionnaire

Turn a decision you **can't answer alone** into a Markdown questionnaire for the one person who can — handed over async, or worked through together in a meeting.

## Why this exists

Some blockers aren't thinking problems, they're knowledge problems: the answer lives in someone else's head — the domain expert, the security reviewer, the client, the person who ran the last migration. Asking them in a chat thread gets a partial answer; asking them in a meeting gets whatever you remembered to raise.

A questionnaire is the durable form of that ask. The skill's core move is that it **grills the send, not the subject**: it interviews you about who the recipient is and what you need back — things you always know — and aims every question at the gap between the two.

## Triggers

User-invoked only (`disable-model-invocation: true`). Reach it by:

- Running the slash command: `/plan-to-questionnaire`
- Saying "turn this into a questionnaire for <person>" after typing the skill name

## What it does

Two short exchanges, then a document.

1. **Who is it going to?** — role, expertise, relationship to you. Fixes tone and how much context the document must carry.
2. **What do you need back?** — the concrete decisions or facts you can't resolve alone.
3. **Writes the questionnaire** — most-important-first, grouped by theme, one idea per question, answer stubs inline.

### Inputs

- The decision or topic you're blocked on.
- Answers to the two questions about the send.

### Outputs

- `plan-to-questionnaire-<slug>.md` in the current directory: purpose, from/to, context paragraph, how-to-answer note, themed questions with answer stubs, and a closing catch-all.

## How to use it

```text
You: /plan-to-questionnaire — I can't scope the migration without ops input

Skill: Who's it going to?
You: our SRE lead — owns the clusters, wasn't in the planning
Skill: What do you need back?
You: the maintenance window, whether we can dual-write, rollback expectations

Skill: Written to plan-to-questionnaire-db-migration.md — 9 questions in
       3 themes, window and rollback first.
```

## Getting the most out of it

- **Name the person, not the team.** "Our SRE lead who owns the clusters" produces sharper questions than "ops."
- **Say what you'd do with each answer.** It becomes the _why this matters_ line, and it's what stops throwaway replies.
- **Send it before the meeting.** Async gets you considered answers; the meeting then covers only what came back thin.
- **Keep the file.** A filled questionnaire is a primary source — feed it straight into `plan-to-spec`.

## Anti-patterns

- ❌ **Questions only you can answer.** If the recipient can't know it, it doesn't belong in their document.
- ❌ **Compound questions.** "What's the window and can we dual-write?" gets one answer and loses the other.
- ❌ **Burying the important one at the bottom.** Async may give you exactly one pass.
- ❌ **A context section that's really a spec.** One paragraph. If they need the spec, link it.

## Related skills

- **[plan-to-spec](../plan-to-spec/)** — write the answers up once they come back.
- **[grill-me](../grill-me/)** — when *you* can actually answer it, under pressure.
- **[clarity-council](../clarity-council/)** — when the gap is judgement, not knowledge.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the two-question interview, document template, quality loop)

## Host portability

Runs on Claude Code, Codex, and opencode. Asks questions and writes one Markdown file — no host-specific tools. User-invoked on both hosts from the one frontmatter flag. See [PORTABILITY.md](../PORTABILITY.md).
