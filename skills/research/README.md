# Research

Investigate a question against **high-trust primary sources** and capture the findings as a single cited Markdown file in the repo. The skill delegates the reading legwork to a **background agent** so the main session keeps working while the investigation runs, then leaves behind a durable, source-linked note rather than a chat answer that evaporates.

## Why this exists

Two problems this solves. First, research is slow reading work that blocks nothing else — parking it on a background agent means you don't sit idle while docs get read. Second, quick answers rot: an ungrounded "I think the API works like X" is worthless in a week, whereas a Markdown note with a link to the official spec beside every claim can be re-checked, corrected, and built on. The skill's discipline is **primary sources only** — the doc, the spec, the source code, the first-party API — never a secondary write-up, and never the model's own parametric memory.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "research X"
  - "look into how Y works"
  - "gather the docs / API facts on Z"
  - "find out what the spec says about …"
  - "go read up on … while I keep working"
- Running the slash command: `/research`

## What it does

The skill spins up a background agent whose job is narrow and fixed: (1) investigate the question against primary sources, following every claim back to the source that owns it; (2) write the findings to one Markdown file, citing each claim's source inline; (3) save the file where the repo already keeps such notes — matching the existing convention, or picking a sensible location and saying where when there's no established one. Because it runs in the background, the main session is free to continue; the note is the deliverable.

### Inputs

- **A question** — the thing to find out. A sharp question ("what auth flows does the Stripe API support for terminal readers?") produces a sharper note than a vague one ("research Stripe").
- **Optional: source hints** — a docs URL, a repo path, a spec name. Narrows the agent to the right primary sources faster.

### Outputs

- **One Markdown file** in the repo, with every claim cited to the primary source that owns it, saved to the repo's existing notes location (or a stated sensible default).

### External systems used

- **A background agent** — does the reading so the foreground session isn't blocked.
- **Web / docs / source access** — to reach the primary sources (official docs, specs, first-party APIs, source code).

## How to use it

A typical session looks like this:

```text
You: research how GitLab's MR approval rules interact with CODEOWNERS,
     while I keep working on the pipeline config.

Skill: Spinning up a background agent to investigate against GitLab's
       official docs and API reference. It'll write a cited note and
       save it to the repo's notes convention. Carry on — I'll report
       back when it lands.

       [main session continues; you keep editing the pipeline]

Skill: Research done. Wrote docs/research/gitlab-mr-approvals-codeowners.md
       — every claim links to docs.gitlab.com or the API reference.
       Key finding: CODEOWNERS-derived approval rules are additive to
       explicit approval rules, not a replacement. [cited]
```

## Getting the most out of it

- **Ask a precise question.** The note is only as focused as the prompt. "How does X handle Y under condition Z?" beats "tell me about X."
- **Hand it source hints when you have them.** A docs URL or a repo path saves the agent a discovery pass and keeps it on primary material.
- **Let it run in the background — that's the point.** Don't wait on it. Kick it off, keep working, read the note when it lands.
- **Treat the note as the artifact, not the chat summary.** The value is the cited file you can revisit and correct, not the one-line recap in the transcript.
- **Trust the citations, verify the surprises.** If a claim matters and its source is a single link, open the link before you build on it.

## It's working if

- Your own session keeps going. If you're sitting watching it read, the delegation didn't happen.
- **Exactly one** new background task appears. A second with a near-identical name is the nesting failure — stop it.
- The question it went away with is narrow enough that "answered" is observable: one API, one behaviour, one version claim.
- One new Markdown file shows up, in the folder the repo already uses for notes, and you're told the path.
- Every claim carries a link, and following two at random lands you on an official doc, a spec, or the actual source — not someone's write-up of it.
- You can make the decision you were stuck on from the file alone.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Cite secondary write-ups.** A blog post summarising the docs is not the source. The skill follows every claim back to the doc, spec, or code that owns it.
- ❌ **Answer from parametric memory.** "I recall the API does X" is exactly what this skill exists to replace. No claim ships without a source behind it.
- ❌ **Return a chat answer with no file.** The deliverable is a Markdown note in the repo. A verbal summary alone defeats the durability the skill is for.
- ❌ **Block the main session waiting on it.** It runs in the background by design. If you find yourself idling until it finishes, you've used it as a foreground call.
- ❌ **Use it for questions about the current working directory.** For "how does *this* code work," the reading is local and foreground — reach for [codebase-explain](../codebase-explain/) instead.

## Internals

The background agent's job is fixed at three steps:

1. **Investigate against primary sources** — official docs, source code, specs, first-party APIs. Follow every claim back to the source that owns it; never a secondary write-up, never parametric memory.
2. **Write the findings** — a single Markdown file, each claim cited to its source inline.
3. **Save it by convention** — where the repo already keeps such notes; if there's no convention, somewhere sensible, and state where.

The delegation to a background agent is deliberate: research is I/O-bound reading that shouldn't stall the foreground.

## FAQ

**Q: Why a background agent instead of just answering?**
A: Research is slow reading that blocks nothing else. Backgrounding it means the main session keeps moving while the investigation runs, and you get a durable cited note rather than a transient answer.

**Q: What counts as a "primary source"?**
A: The thing that *owns* the fact — official documentation, a spec, the first-party API, or the source code itself. A third-party tutorial or summary is secondary, even if accurate.

**Q: Where does the note get saved?**
A: Wherever the repo already keeps research notes. If there's no established convention, the agent picks a sensible location (e.g. `docs/research/`) and tells you where.

**Q: Can I point it at a specific doc set or repo?**
A: Yes — source hints (a URL, a repo path, a spec name) narrow the agent to the right primary material and speed it up.

**Q: How is this different from a plain web search?**
A: A search returns links you still have to read and synthesise. This reads them for you, insists on primary sources, and leaves a cited file behind.

## Related skills

- **[codebase-explain](../codebase-explain/)** — when the question is about the *local* code, not external docs/APIs; the reading is foreground and in-repo.
- **[defuddle](../defuddle/)** — extract clean Markdown from a specific web page you already have the URL for (token-efficient reading of one source).
- **[work-plan](../work-plan/)** — uses `/research` subagents to resolve its `research`-type decision tickets in parallel.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (background-agent research brief)
