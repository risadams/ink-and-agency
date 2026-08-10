# Wait, What

Fire this the moment a message doesn't land. The agent re-pitches it — with the context you were missing, in plain language, using your project's own vocabulary.

## Why this exists

An agent that has been deep in a codebase for twenty minutes writes like someone who has been deep in a codebase for twenty minutes: three unexplained module names, an assumption about what you already decided, and a conclusion with no path to it. The usual repair — "can you explain that?" — gets you the same message with more words.

This skill is a single-purpose interrupt: same message, pitched again, from the top, in language you can actually parse. It's the fastest way out of a comprehension stall, and it costs one word to reach.

## Triggers

User-invoked only (`disable-model-invocation: true`). Reach it by:

- Running the slash command: `/wait-what`
- Typing the skill name right after the message that lost you

## What it does

Re-pitches the last message with:

- A short run-up — what problem it was solving and where in the work it is.
- **ASD-STE100 Simplified Technical English** — short sentences, one idea each, plain words.
- The **ubiquitous language** from `CONTEXT.md` for domain terms, and any term outside it spelled out.
- No apology, no redoing the work, nothing new added.

If the agent can't tell which part lost you, it re-pitches the whole thing and asks one question about where it broke.

### Inputs

- The message that didn't land (already in the conversation).
- `CONTEXT.md`, if the project has one.

### Outputs

- The same content, re-pitched. No files, no side effects.

## How to use it

```text
Agent: The projection lag means the read model can't be authoritative for the
       idempotency check, so I moved the guard into the command handler.

You: /wait-what

Agent: Context: you asked why the same order was created twice.
       The check for "have we seen this request before" was in the part of
       the system that reads data. That part is a copy, and the copy is a
       few seconds behind. So the check sometimes looked at old data and
       said "no, this is new."
       I moved the check to the part that writes data. That part is never
       behind.
```

## Getting the most out of it

- **Fire it early.** The stall compounds: three more messages built on the one you didn't get is a much bigger repair.
- **Say where it broke, if you know.** "Lost you at the projection bit" narrows the re-pitch.
- **Pair it with `CONTEXT.md`.** The more the project's real vocabulary is written down, the better the re-pitch lands.
- **Use it on your own drafts too.** It works on any message in the conversation, not just the agent's.

## Anti-patterns

- ❌ **Using it to ask for more detail.** This is the same message, simpler — not a deeper one. Ask a normal question for depth.
- ❌ **Using it to redo the work.** It re-explains; it doesn't re-decide.
- ❌ **Accepting a re-pitch that swaps in new jargon.** Say so and fire it again.

## Related skills

- **[break-it-down](../break-it-down/)** — decodes a message from *another human*, with tone and intent analysis. This skill re-pitches the agent's own.
- **[codebase-explain](../codebase-explain/)** — when the thing you don't understand is the code, not the message.
- **[domain-modeling](../domain-modeling/)** — if the same term loses you twice, the glossary is the real fix.
- **[i-am-autistic](../i-am-autistic/)** / **[i-have-adhd](../i-have-adhd/)** — session-long output shaping, when every message needs this treatment rather than one.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the re-pitch instruction)

## Host portability

Runs on Claude Code, Codex, and opencode. Pure prompt — no tools, no files. User-invoked on both hosts from the one frontmatter flag. See [PORTABILITY.md](../PORTABILITY.md).
