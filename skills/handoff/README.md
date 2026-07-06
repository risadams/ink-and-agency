# Handoff

Compact the current conversation into a structured handoff document so a fresh agent can pick up the work without re-deriving context. Saves to your OS temp directory (not the workspace), includes recommended skills for the next session, and redacts sensitive data.

## Why this exists

Context loss is expensive. When work spans sessions, the next agent re-reads everything from the start, re-discovers what the problem is, and re-derives why certain decisions were made. This skill compresses the current conversation into a single document that a fresh agent can read in seconds, separating what *is* (facts, decisions, artifacts) from what *isn't* yet (work remaining, unknowns). It also surfaces which skills are likely to help — so the next agent doesn't waste tokens figuring out the right tool for the job.

The handoff avoids duplicating what's already in structured form elsewhere. If you've committed code, filed an issue, or written a design doc, the handoff references it by path or URL instead of copying it. That keeps the handoff lean and always points to truth.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "handoff"
  - "hand off"
  - "prepare a handoff"
  - "next session"
  - "write a handoff"
- Running the slash command: `/handoff` with optional context (e.g., `/handoff for a code review`)

The skill accepts an optional argument describing what the next session will focus on. If provided, the handoff tailors its emphasis to that context.

## What it does

The skill produces a markdown document that:
1. **Summarizes the current conversation** in 2–5 sentences (what was the session about, what changed)
2. **Lists what was accomplished** (commits, PRs, files modified, decisions made)
3. **Notes what remains** (blockers, open questions, work in progress, unknowns)
4. **References artifacts, not duplicates** (links to PRs, issues, docs, design docs by path)
5. **Suggests skills for the next agent** (based on the remaining work and context)
6. **Redacts sensitive data** (API keys, passwords, tokens, PII)

The document is saved to your OS temp directory with a timestamp so it doesn't clutter the workspace.

### Inputs

- **Context (optional)** — What the next session will focus on. E.g., "code review of the auth module" or "test fixes for the payment flow". If omitted, the skill infers from the conversation.

### Outputs

- A markdown handoff document saved to `%TEMP%/handoff-{timestamp}.md` (Windows) or `/tmp/handoff-{timestamp}.md` (macOS/Linux).
- A file path printed to chat so you can find it.

### External systems used

- File I/O to OS temp directory (write only).
- No API calls; no external services.

## How to use it

A typical session looks like this:

```text
You: (after 30 minutes of working on a feature)
     handoff — next person will do the integration tests

Skill: Reading conversation history...
       Identifying accomplishments...
       Detecting remaining work...
       Drafting suggested skills...
       Redacting sensitive data...

       Handoff document written:
       /tmp/handoff-2026-06-17T14-32-45.md

       The next agent should read this file and invoke /run or /verify
       to confirm the changes work before pushing.
```

The handoff is ready to share with the next agent, or to paste into a GitHub issue's next-steps section.

## Getting the most out of it

- **Handoff at a natural break, not mid-task.** A handoff after committing a working feature is cleaner than a handoff mid-refactor.
- **Be specific about what's next.** If you pass an argument (e.g., "for security review"), the handoff emphasizes that scope.
- **Read the handoff yourself first.** The document you get is what a fresh agent will read. If you notice missing context, add it to the conversation and re-run the skill.
- **Link to artifacts, don't summarize them.** If there's a design doc or an issue, let the handoff reference the path. The agent can read it themselves.
- **Don't include sensitive data in the conversation.** If you must discuss an API key or token, the skill will try to redact it, but it's better not to paste it in chat at all.

## Anti-patterns

- ❌ **Handing off without committing or saving.** A handoff that references uncommitted work is useless to the next agent. Commit first.
- ❌ **Repeating what's in code or closed issues.** If the work is already documented in a commit message, issue, or ADR, just link to it.
- ❌ **Asking the skill to decide priorities.** The handoff lists what's left; the next agent (or you, in the next session) decides what matters. Use [clarity-council](../clarity-council/) or [idea-choice](../idea-choice/) for prioritization.
- ❌ **Writing a handoff for a conversation that's still active.** If you're still working, keep going. Handoff when you're stepping away.
- ❌ **Storing sensitive data in the handoff.** The skill redacts obvious patterns (API keys, tokens), but it's your job not to paste them in chat in the first place.

## Examples

### Example: After a refactor session

```text
You: handoff — the next person will need to update tests for the new
     API shape

Skill: Handoff written: /tmp/handoff-2026-06-17T14-32-45.md

       Document includes:
       - Session summary: Refactored checkout API to use paginated list endpoints
       - Accomplishments: 3 new endpoints, deprecated 2 old ones, updated internal clients
       - Remaining: Update jest tests for new response schema, integration tests pending
       - Suggested skills: /verify (run the test suite), /code-review (check new endpoints)
       - References: Commit abc1234, docs/api/CHECKOUT.md, GitHub issue #4521
```

A developer picks up the handoff, reads it in 30 seconds, and knows exactly where to start without re-reading the entire conversation.

### Example: After a spike / investigation

```text
You: handoff for implementation

Skill: Handoff written: /tmp/handoff-2026-06-17T15-12-03.md

       Document includes:
       - Session summary: Investigated caching strategies for the search index
       - Accomplishments: Benchmarked Redis vs PostgreSQL, identified N+1 queries, prototyped batch-load optimization
       - Remaining: Implement the batch-load in production, tune Redis TTLs, load test at 10k QPS
       - Artifacts referenced: benchmark results (docs/perf/search-cache-study.md), prototype branch (feat/search-batch-cache)
       - Suggested skills: /run (benchmark in staging), /performance-review (validate the improvement)
```

The next implementer has all the research without re-doing it, and knows which measurements matter.

### Example: Blocking issue detected

```text
You: (after hitting a blocker and deciding to step away for the day)
     handoff — waiting on infra to provision the staging database

Skill: Handoff written: /tmp/handoff-2026-06-17T16-45-21.md

       Document includes:
       - Session summary: Feature ready for E2E testing, blocked on staging database setup
       - Accomplishments: Implementation complete, unit tests passing, reviewed by @alice
       - Remaining: Staging DB provisioning (in progress, infra ETA 2026-06-18 13:00 UTC), then run E2E suite
       - Blocker: Database setup ticket INFRA-2841 (currently assigned to @bob)
       - Suggested skills: /loop (check the provisioning status every 30m), /verify (run E2E tests once DB is ready)
```

The next session knows not to start coding — there's a blocker to watch. The skill suggests `/loop` to check status automatically.

## Internals

The skill follows a 6-step workflow:

1. **Extract conversation history** — reads the current session transcript.
2. **Identify artifacts** — scans for commits, PRs, file edits, design decisions. Groups them by type (code changes, docs, decisions, experiments).
3. **Classify work** — separates accomplished (done and committed) from remaining (in progress, blocked, unknown).
4. **Reference, don't duplicate** — for each artifact, decides: include a brief summary + link, or just link. Never copies code or docs into the handoff.
5. **Suggest skills** — matches remaining work to skills in the pack. E.g., "tests failing" → `/code-review` + `/run`; "needs to decide architecture" → `/clarity-council`.
6. **Redact sensitive data** — scans output for API keys, tokens, passwords (patterns: `api_key=...`, `Authorization: Bearer ...`, AWS key formats). Replaces with `[REDACTED]`.

### Key constraints

- **Never duplicates artifacts.** If a commit exists, link it. If a doc exists, link it. No copy-paste.
- **Stays lean.** The handoff is skimmable in 2–3 minutes, not a full replay of the conversation.
- **Redacts by default.** Common sensitive patterns are caught; if you see a secret in a handoff, report it.
- **Temporal markers.** The handoff filename includes a timestamp so multiple handoffs don't overwrite.

## FAQ

**Q: Where does the handoff file go?**
A: Your OS temp directory. Windows: `%TEMP%/handoff-{timestamp}.md`. macOS/Linux: `/tmp/handoff-{timestamp}.md`. The skill prints the path so you can find it.

**Q: Can I customize what goes in the handoff?**
A: Yes — by passing an argument that describes the next session's focus. The skill will emphasize that context in the "Remaining work" and "Suggested skills" sections.

**Q: What if the conversation has sensitive data I didn't notice?**
A: The skill redacts obvious patterns (API keys, tokens, passwords). But it's your responsibility not to paste secrets in chat. If you see `[REDACTED]` in the handoff, the secret was caught. If you see a secret that wasn't redacted, redact it manually before sharing the handoff.

**Q: Can I use the handoff as a progress report?**
A: Yes. A handoff is a snapshot of "what changed, what's left, what to do next." You can paste it into a GitHub issue, email it to a collaborator, or save it to a wiki for async context-passing.

**Q: What if I want to edit the handoff before sharing it?**
A: The file is just markdown in your temp directory. Open it, edit freely, then share. The skill doesn't lock it.

**Q: Can I handoff to the same person (myself in the next session)?**
A: Absolutely. A handoff is useful for your own context recovery when you return to a project after an interruption or a long break.

**Q: What if the conversation is very long?**
A: The skill compresses ruthlessly. Long conversations produce short handoffs — that's the whole point. If the handoff feels too terse, add clarifying context to the conversation and re-run the skill.

## Related skills

- **[hyperfocus-recovery](../hyperfocus-recovery/)** — inverse case: you were deep in work and got interrupted. Reconstructs your re-entry point from git/file artifacts.
- **[task-initiation](../task-initiation/)** — next agent is stuck starting. Use this if the handoff says "ready to begin, but unclear where to start."
- **[grill-me](../grill-me/)** — next agent needs to stress-test the plan or design. Reference from the handoff if you want the next session to challenge assumptions.
- **[clarity-council](../clarity-council/)** — if the handoff surfaces a decision that needs multiple perspectives, the next agent can invoke this.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
