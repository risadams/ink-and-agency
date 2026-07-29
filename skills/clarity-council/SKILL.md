---
name: clarity-council
description: Facilitates structured single-persona or multi-persona consultation for strategy, product, engineering, operations, and risk decisions. Use when the user requests a council, multiple perspectives, persona advice, tradeoff analysis, or iterative clarification and debate.
codex-short-description: "Facilitates structured single-persona or multi-persona consultation for strategy…"
related-skills:
  - grill-me
  - idea-generate
loop-eligible: false
recurrence-hint: on-demand
compatibility: claude-code codex opencode
---
# Clarity Council

Structured persona-based consultation for decisions that benefit from expert perspectives. The
council runs entirely inline in one of three **modes** — nothing depends on a separate subagent, so
it behaves identically on every host.

Persona contracts live in the shared [`skills/persona/`](../../persona/) category — the index is
[`skills/persona/PERSONAS.md`](../../persona/PERSONAS.md) and pre-made panels are in
[`skills/persona/GROUPS.md`](../../persona/GROUPS.md). Links below are relative to this skill's
folder.

## When to use

Use this skill when you need any of:

- Quick expert opinion from one persona
- Multiple expert viewpoints with synthesis
- Iterative decision-making with clarifications
- Structured tradeoff analysis

Do not use for pure factual lookup with no decision component.

## Which mode?

| Mode | When | Feel |
| :--- | :--- | :--- |
| **single** | Focused advice from one expert | Quick (10–15 min) |
| **multi** | A decision needs several viewpoints synthesized | Standard (20–30 min) |
| **iterative** | Multi-turn refinement as constraints emerge | Deep (30–60 min, 3–5 turns) |

Callers select a mode explicitly. A skill invoking the council via `Skill` names the mode
(e.g. "invoke `clarity-council` in **multi** mode with personas `[psychologist, personal-assistant]`").
Users can say "as a senior-architect…" (single), "convene a council on…" (multi), or "run a council,
I'll iterate" (iterative).

## Common inputs

- **Decision/problem** — required.
- **Personas** — optional; which experts to consult (defaults apply per mode).
- **Persona groups** — optional; pre-made panels from [`skills/persona/GROUPS.md`](../../persona/GROUPS.md).
- **Depth** — optional: `brief` / `standard` / `deep`.
- **Context / constraints / desired outcome** — optional but strongly recommended.
- **Iterative state** — for multi-turn sessions (sessionId, turn, history).

**Resolving a persona name** (two steps, see [`skills/persona/PERSONAS.md`](../../persona/PERSONAS.md)):
first look for `skills/persona/<name>.md` and use its **Decision Lens**, **Preferred Frameworks**,
and **Blind Spots** (most personas live here). If there's no such file, the name is a hands-on
specialist skill that doubles as a voice (`data-engineer`, `devops-engineer`, `technical-writer`) —
read its **## Council Persona Lens** section, which is the persona contract (the rest of that skill is
implementation guidance). Keep terminology consistent with the names in
[`skills/persona/PERSONAS.md`](../../persona/PERSONAS.md).

---

## Mode: single

Deliver focused expert perspective from **one** persona. If no persona is named, ask which
perspective would help most.

**Workflow**

1. **Confirm the persona.** Resolve its lens per the two-step rule above (local file, else the
   top-level specialist skill of that name).
2. **Understand the problem.** Ask a clarifying question only if a hard constraint (state, decision,
   budget/timeline/compliance, definition of success) is ambiguous.
3. **Apply the lens.** Frame the analysis through the persona's Decision Lens and Preferred
   Frameworks (e.g. senior-architect → structural/scalability impact; security-expert → attack
   surface/compliance; devils-advocate → challenge the obvious).
4. **Produce structured advice** (template below).
5. **Quality checks:** advice tied to the persona's focus (not generic); assumptions separated from
   facts; at least one concrete next step; confidence justified; blind spots flagged where they matter.

If the user then wants multiple perspectives → switch to **multi**; back-and-forth refinement →
**iterative**.

### Single-persona output

```markdown
summary: <short answer>
advice:
- <point>
assumptions:
- <assumption>
questions:
- <question>
next_steps:
- <action>
confidence: <low|medium|high>
```

---

## Mode: multi

Convene several personas, collect each perspective, then **synthesize**. Synthesis is mandatory —
do not just list opinions.

**Default panels** (if no personas named; ask if the panel doesn't fit):

- **Architecture** — senior-architect, senior-developer, qa-engineer, tech-lead, devops-engineer, devils-advocate
- **Feature/product** — product-owner, senior-developer, ux-designer, customer-advocate, tech-lead, devils-advocate
- **Hiring/people** — culture-lead, product-owner, senior-architect, devils-advocate
- **Risk/security** — security-expert, compliance-officer, senior-architect, devops-engineer, devils-advocate
- **Financial/business** — financial-officer, product-owner, business-owner, devops-engineer, devils-advocate
- **Estimation** — scrum-master, tech-lead, senior-developer, qa-engineer

Pre-made groups also live in [`skills/persona/GROUPS.md`](../../persona/GROUPS.md) — domain panels
(`product-delivery-core`, `platform-and-reliability`, `investigation-and-diagnosis`,
`stakeholder-reporting`, …) plus convenience archetypes (`technical-focus`, `stakeholder-focus`,
`full-council`, `quick-pulse`, `estimation`). Reference a group by its slug; expand it into its listed
personas before consulting.

**Workflow**

1. **Classify & prepare.** Confirm the problem; load/expand personas; dedupe, preserve requested order.
2. **Consult each persona** using the single-mode method. **Collect all responses before
   synthesizing — do not synthesize as you go.**
3. **Synthesize across five dimensions:** Cost vs Speed · Risk vs Reversibility · Short-term vs
   Long-term · Confidence (evidence vs assumption) · People Impact.
4. **Agreements** — where two or more personas converge (strong evidence).
5. **Conflicts** — **name the dimension** ("they disagree on reversibility", not "they disagree") and
   give each a decision table.
6. **Risks & tradeoffs** — what could go wrong; what the user is choosing between; underweighted
   blind spots.
7. **Next steps** — 2–4 concrete actions that reduce ambiguity or resolve conflicts.
8. **Quality checks:** agreements separated from conflicts; every conflict has a dimension + table;
   next steps concrete; blind spots acknowledged.

If the user needs iterative back-and-forth → switch to **iterative**; a single perspective needs a
deeper dive → **single**.

### Multi-persona output

```markdown
responses:
- persona: <name>
  summary: <short answer>
  advice:
  - <point>
  assumptions:
  - <assumption>
  questions:
  - <question>
  next_steps:
  - <action>
  confidence: <low|medium|high>

synthesis:
  agreements:
  - <point>
  conflicts:
  - dimension: <Speed|Reversibility|Risk|People|Confidence>
    table: |
      | Option | Benefit | Risk | Who Favors |
      | --- | --- | --- | --- |
      | A | ... | ... | ... |
      | B | ... | ... | ... |
    decision_point: <one-line question that resolves this conflict>
  risks_tradeoffs:
  - <point>
  next_steps:
  - <action>
```

---

## Mode: iterative

Run a multi-turn session: ask targeted clarifications, re-consult the council (multi-mode) with
updated constraints, resolve conflicts, and refine toward a decision. Slower, but catches edge cases
and hidden assumptions.

**Session state** carried each turn: `sessionId`, `turn`, `history` (compact per-turn summaries),
`personas_active`, `conflicts_open`.

**Workflow**

- **Turn 1 — initialize:** load personas (or ask which panel); classify the problem; ask **one**
  clarifying question if ambiguity is high; return `needs_clarification` or `in_progress`.
- **Turn 2+ — iterate:** read the user's answer; update `history`; re-consult the council (multi mode)
  with new constraints; check conflicts; return `needs_clarification`, `in_progress`, or `completed`.
- **Conflict Protocol (mandatory when personas clash):** name the dimension → present a 2–3 option
  decision table → ask **one** targeted question → record the decision in `history` → continue with
  that constraint locked in.
- **Turn limit:** 5–7. Beyond that, suggest narrowing the decision, external stakeholder input, or a
  prototype/experiment.

**Notes:** one question per turn; state carries forward (never make the user repeat constraints);
this surfaces options and tradeoffs — the user decides.

### Iterative output

```markdown
status: <needs_clarification|in_progress|completed>
message: <short user-facing response>
nextAction: <what is needed next>
output:
  <single- or multi-persona structure for this turn>
state:
  sessionId: <id>
  turn: <number>
  decisions_made:
  - <decision>: <rationale>
  conflicts_open:
  - <unresolved conflict>
  history:
  - <compact turn summary>
```

---

## Quality checks (all modes)

Before finalizing:

- recommendations tie to stated constraints
- assumptions separated from facts
- at least one concrete next step
- at least one explicit risk or tradeoff for non-trivial decisions
- terminology consistent with the persona names in [`skills/persona/PERSONAS.md`](../../persona/PERSONAS.md)

## Reference files

- [`skills/persona/PERSONAS.md`](../../persona/PERSONAS.md) — full persona index
- [`skills/persona/GROUPS.md`](../../persona/GROUPS.md) — pre-made persona panels
- [`skills/persona/`](../../persona/) — individual persona contracts (30 total)
- [EXAMPLES.md](EXAMPLES.md) — worked invocations for all three modes

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts
> (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/clarity-council.md` (workspace-local
`.ink-and-agency/learnings/clarity-council.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
