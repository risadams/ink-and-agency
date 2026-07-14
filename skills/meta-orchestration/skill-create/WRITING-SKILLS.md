# Writing great skills

The principles and vocabulary behind a *good* skill — the layer above the mechanics in [SKILL.md](SKILL.md). `skill-create` tells you how to assemble a skill; this tells you how to make it **predictable**, lean, and reliably invoked. Consult it while drafting (step 2) and reviewing (step 3).

## The root virtue: predictability

A skill exists to wrangle determinism out of a stochastic system. The goal is **predictability** — the agent taking the same *process* every run, not producing the same *output*. (A brainstorming skill should predictably diverge; its tokens vary, its behaviour doesn't.) Every lever below serves predictability. Cost and maintainability are symptoms of it, not rivals.

## Invocation: the two loads

Every skill is reached one of two ways, and the choice spends one of two budgets. In this repo the decision lives once in `SKILL.md` frontmatter and is projected to Codex by the generator (see [AGENTS.md](../../../AGENTS.md#skill-invocation-across-hosts)) — you never set it twice.

- **Model-invoked** (default) — keeps its `description`, so the agent can fire it autonomously *and* other skills can reach it (the human can still type its name). It pays **context load**: the description sits in the window every turn. Write a model-facing description with rich trigger phrasing.
- **User-invoked** — set `disable-model-invocation: true`. Only the human, typing its name, can invoke it; no other skill can reach it. Zero context load, but it spends **cognitive load**: the human is now the index that must remember it exists. The `description` becomes human-facing — a one-line summary, triggers stripped.

Pick model-invocation only when the agent must reach the skill on its own, or another skill must. If it only ever fires by hand, make it user-invoked and pay no context load.

**When user-invoked skills multiply past what you can remember, that piled-up cognitive load is cured by a router skill** — one user-invoked skill that names the others and when to reach for each. (This pack has one: `which-skill`.)

## Writing the description

The `description` does two jobs — state what the skill is, and list the **branches** that should trigger it. Every word is permanent context load, so it earns harder pruning than the body:

- **Front-load the leading word** — the description is where it does its invocation work.
- **One trigger per branch.** Synonyms renaming a single branch are duplication ("build features using TDD … asks for test-first development" is one branch written twice). Collapse them; keep only genuinely distinct branches.
- **Cut identity already in the body.** Keep the description to triggers plus any "when another skill needs…" reach clause.
- **Repo-specific:** if the first sentence reads badly as a Codex picker label, add `codex-short-description:` — the generator uses it verbatim.

## Information hierarchy

A skill is built from two content types — **steps** (ordered actions) and **reference** (definitions, rules, facts) — that mix freely. The core decision is where each sits on the ladder, ranked by how immediately the agent needs it:

1. **In-skill step** — an ordered action in `SKILL.md`. Each ends on a **completion criterion**: the checkable condition that says the work is done. Make it *checkable* (can the agent tell done from not-done?) and, where it matters, *exhaustive* ("every modified model accounted for", not "produce a change list"). A vague criterion invites premature completion.
2. **In-skill reference** — a rule or fact in `SKILL.md`, consulted on demand. Often a legitimately flat peer-set (every rule of a review on one rung) — fine, not a smell.
3. **External reference** — pushed out of `SKILL.md` into a linked file, reached by a **context pointer**, loaded only when the pointer fires.

Push too little down and the top bloats; push too much and you hide material the agent needs. That tension is the whole decision.

**Progressive disclosure** is the move down the ladder — out of `SKILL.md` into a linked file — so the top stays legible. **Branching is the cleanest disclosure test:** inline what every branch needs; push behind a pointer what only some branches reach. A context pointer's *wording*, not its target, decides when and how reliably the agent reaches the material — a must-have behind a weak pointer is a variance bug.

**Co-location:** keep a concept's definition, rules, and caveats under one heading, so reading one part brings its neighbours with it.

## When to split

**Granularity** is how finely you divide skills; each cut spends one of the two loads, so split only when the cut earns it:

- **By invocation** — split off a model-invoked skill when you have a distinct **leading word** that should trigger it on its own, or another skill must reach it. You pay context load for the new always-loaded description.
- **By sequence** — split a run of steps when the steps still ahead tempt the agent to rush the one in front (premature completion). Hiding them encourages more legwork on the current task.

(This repo's own soft rule of thumb — split a `SKILL.md` when it crosses ~100 lines — is the practical face of this: sprawl is the smell, the ladder is the cure.)

## Leading words

A **leading word** is a compact concept already living in the model's pretraining that the agent thinks with while running the skill (e.g. *lesson*, *fog of war*, *tracer bullet*, *tight loop*, the loop going *red*). Repeated through the text, it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens, by recruiting priors the model already holds.

It serves predictability twice. In the **body** it anchors execution: the agent reaches for the same behaviour every time the word appears. In the **description** it anchors invocation: when the same word lives in your prompts, docs, and code, the agent links that shared language to the skill and fires it more reliably.

Hunt for restatements that a leading word retires:

- "fast, deterministic, low-overhead" → *tight* (a *tight* loop).
- "a pass/fail signal you believe in" → *red* (the loop goes *red* on the bug, or it doesn't).

You win twice: fewer tokens, *and* a sharper hook for the agent to hang its thinking on.

## Failure modes

Diagnose a misbehaving skill against these:

- **Premature completion** — ending a step before it's genuinely done, attention slipping to *being done*. Defence, in order: sharpen the completion criterion first (cheap, local); only if it's irreducibly fuzzy *and* you observe the rush, hide the post-completion steps by splitting.
- **Duplication** — the same meaning in more than one place. Costs maintenance and tokens, and inflates a meaning's rank on the ladder past its real one. Keep each meaning in a **single source of truth**.
- **Sediment** — stale layers that settle because adding feels safe and removing feels risky. The default fate of any skill without a pruning discipline.
- **Sprawl** — a skill simply too long, even when every line is live. The cure is the ladder: disclose reference behind pointers, split by branch or sequence.
- **No-op** — a line the model already obeys by default, so you pay load to say nothing. Test: does it change behaviour versus the default? *Be thorough* when the agent is already thorough-ish is a no-op; the fix is a stronger word (*relentless*), not more text.
- **Negation** — steering by prohibition backfires: *don't think of an elephant* names the elephant. Prompt the **positive** — state the target behaviour so the banned one is never spoken; keep a prohibition only as a hard guardrail you can't phrase positively, and pair it with what to do instead.

## Pruning discipline

Before calling a skill done:

1. **Single source of truth** — each meaning in one authoritative place, so a behaviour change is a one-place edit.
2. **Relevance** — every line still bears on what the skill does.
3. **No-op hunt** — sentence by sentence, in isolation. When one fails the no-op test, delete the whole sentence rather than trim words. Be aggressive; most prose that fails should go, not be rewritten.
