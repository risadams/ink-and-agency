# Writing for Agents

The reference for writing anything an **agent** reads: a skill, an `AGENTS.md` / `CLAUDE.md`, a doc reached by a pointer. Packaging differs; the writing doesn't.

## Why this exists

Prose written for humans optimises for a reader who skims, infers, and forgives. An agent doesn't: it takes the document as a program. The failure mode isn't "unclear writing," it's **variance** — the same document producing a different process on different runs, because a completion criterion was fuzzy, a pointer was weakly worded, or the instruction was a no-op the model was going to obey anyway.

This skill names the levers that reduce that variance: context pointers, the two loads, the information hierarchy, completion criteria, leading words, and a pruning discipline. It's the writing counterpart to [skill-create](../skill-create/), which builds the structure.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "write a skill for X" / "this skill isn't firing reliably"
  - "update AGENTS.md" / "improve CLAUDE.md"
  - "this doc is too long — what should move out?"
  - "why does the agent skip this step?"
- Running the slash command: `/writing-for-agents`
- Automatically, when creating or editing a skill or agent-facing instruction file.

## What it does

Supplies the vocabulary and the decisions. It doesn't scaffold folders or run the generator — those are `skill-create` and `scripts/convert-agents-to-codex.ps1`.

The levers, briefly:

- **Context pointers** — a description or `AGENTS.md` line is a pointer; its *wording* decides how reliably the material gets reached. Sharpen the pointer before inlining the material.
- **The two loads** — context load (always-loaded tokens) vs cognitive load (what the human must remember). Every document spends one.
- **Information hierarchy** — in-file step → in-file reference → disclosed reference. Progressive disclosure is the move down the ladder; sprawl is the failure mode.
- **Completion criteria** — clarity (can the agent tell done from not-done?) and demand (how much it forces). Vague bounds invite premature completion.
- **Leading words** — a pretrained concept that anchors a region of behaviour in one token. Negation is the failure mode beside it: prompt the positive.
- **Pruning** — single source of truth, the environment as a source of truth, relevance, and the no-op test.

### Inputs

- The document being written or revised, and what it must make the agent do.

### Outputs

- A document that produces the same *process* every run — not the same output.

## How to use it

```text
You: this skill fires maybe half the time

Skill: Your description's first branch is "use when refactoring" — and three
       other skills claim refactoring. It's not a weak pointer, it's an
       ambiguous one. Two distinct branches here: the shallow-module scan,
       and the seam decision. Name both, front-load "deepening," and drop
       the sentence restating the title.
```

## Getting the most out of it

- **Settle no-ops by running the document, not by arguing.** The test is model-relative: two people disagreeing about a no-op disagree about the default.
- **Hunt for restatements.** A triad spelled out at three sites usually collapses into one leading word — fewer tokens *and* a sharper hook.
- **Disclose by branch.** Inline what every run needs; push behind a pointer what only some runs reach.
- **Delete whole sentences.** When a line fails the no-op test, trimming its words keeps the load and loses the meaning.

## Anti-patterns

- ❌ **Steering by prohibition.** "Don't use em dashes" activates em dashes. State the positive target.
- ❌ **Duplicating a meaning across documents.** It costs tokens, drifts, and inflates the meaning's rank on the hierarchy.
- ❌ **Caching what the environment already says.** Restating `package.json` scripts just gives you a copy that goes stale.
- ❌ **Fuzzy completion criteria.** "Understanding reached" ends the step whenever the agent feels done.
- ❌ **Adding a document to avoid pruning one.** That's sediment, and it's the default fate of every doc nobody deletes from.

## Related skills

- **[skill-create](../skill-create/)** — scaffolds a new skill in this pack; this skill governs its prose.
- **[which-skill](../which-skill/)** — the pack's router, and the worked example of the cognitive-load cure in `SKILL-MECHANICS.md`.
- **[content-quality-editor](../content-quality-editor/)** / **[writing-humanize](../writing-humanize/)** — for human-facing prose. Different reader, different levers.
- **[documentation-engineer](../documentation-engineer/)** — documentation systems for people.

## Files

- **[SKILL.md](SKILL.md)** — the universal reference: pointers, loads, hierarchy, criteria, splitting, leading words, pruning
- **[SKILL-MECHANICS.md](SKILL-MECHANICS.md)** — the skill-specific branch: the invocation choice, splitting by invocation, router skills

## Host portability

Runs on Claude Code, Codex, and opencode. Pure reference — no host-specific tools. The pack-specific mechanics it points at (frontmatter fields, the flat layout, the Self-Evolve footer) live in [skills/CLAUDE.md](../CLAUDE.md) and [AGENTS.md](../../AGENTS.md). See [PORTABILITY.md](../PORTABILITY.md).
