# Clarity Council

Run structured persona-based consultation for decisions that benefit from multiple perspectives. The
skill is **self-contained** — it ships its own persona library and runs entirely inline in one of
three **modes**:

- **single** — Quick expert advice (10–15 min)
- **multi** — Synthesized multi-perspective advice (20–30 min)
- **iterative** — Multi-turn iterative decisions (30–60 min)

Output is consistently structured (assumptions, advice, conflicts, tradeoffs, next steps) so
downstream consumers can parse it reliably.

## Why this exists

Most decisions die in one of two ways: a single perspective dominates and the blind spots ship into
production, or you collect five opinions in a meeting and walk out without a synthesis. Persona-based
consultation catches both: each persona is constrained to a defined viewpoint (so blind spots can't
dominate), and the synthesis step is non-optional (so disagreements get articulated, not buried). The
output structure is consistent across modes and across invoking skills, so you reason about the same
decision the same way no matter which entry point you used.

## Why one skill, three modes (not three agents)

Earlier versions shipped the council as three subagents (`council-single-persona`,
`council-multi-persona`, `council-iterative`) under `agents/00-council/`. That split was folded into
this single skill for one decisive reason: **Codex plugins bundle only `./skills/` — they can't carry
agents.** A skill that told the model to "invoke `council-multi-persona`" left that agent unbundled on
Codex, breaking the pack's most-used integration on one host. Folding the modes inline (and moving the
persona library inside the skill) makes the council behave identically everywhere. See
[ADR-0005](../../../docs/adr/ADR-0005-council-skill-side.md).

## How to invoke

### Direct

```
/clarity-council
  As a senior-architect, should we migrate to microservices?   (single)

/clarity-council
  Convene a council on Kubernetes adoption.                    (multi)

/clarity-council
  Run a council on team restructuring. I'll iterate.           (iterative)
```

### From other skills

Other skills (issue-triage, issue-feature-breakdown, issue-estimate-sp, energy-budget, etc.) invoke
the council via `Skill`, naming the mode and (optionally) the personas:

```
Skill: clarity-council (mode: multi)
  problem: "Should we adopt TypeScript?"
  personas: [senior-developer, tech-lead, qa-engineer]
  depth: standard
```

## How it works

The skill loads persona contracts from its own [`skills/personas/`](skills/personas/) library,
generates perspective-specific responses with explicit assumptions, and (in multi/iterative modes)
synthesizes across viewpoints. Output is structured markdown so downstream consumers (other skills,
dashboards) can parse it reliably.

- **single** — one expert perspective with confidence and assumptions
- **multi** — several perspectives + synthesis (agreements / conflicts named by dimension / risks)
- **iterative** — multi-turn refinement with targeted clarifications and carried-forward session state

### Common inputs

- **Decision/problem** — required.
- **Context** — background, constraints, prior decisions.
- **Personas** — which experts to consult (defaults apply per mode).
- **Persona groups** — pre-made panels from [`skills/personas/GROUPS.md`](skills/personas/GROUPS.md).
- **Depth** — `brief` / `standard` / `deep`.
- **Iterative state** — sessionId, turn, history (iterative mode only).

## Examples

See [EXAMPLES.md](EXAMPLES.md) for worked invocations of all three modes.

## Tips for best results

- **Pick the right mode.** single for a quick perspective; multi for complex decisions; iterative for
  evolving constraints.
- **Assemble deliberately.** Predefined groups work well, but custom persona lists let you optimize.
- **Always read the synthesis.** In multi mode, synthesis is where the value lives.
- **Read agreements first.** Agreements are strong evidence; conflicts are the live questions.
- **Match depth to stakes.** `brief` for routine, `standard` for important, `deep` for high-stakes.
- **Use iterative when uncertain.** If you're not sure what you're optimizing for, let the council ask
  clarifying questions over 3–5 turns.

## Anti-patterns

- ❌ **Don't expect final decisions.** The council surfaces tradeoffs and risks; you decide.
- ❌ **Don't use for pure factual lookup.** A council is for decisions with tradeoffs.
- ❌ **Don't run with thin context.** Garbage in = structured garbage out.
- ❌ **Don't skip assumptions.** Assumptions are usually where real disagreement lives.
- ❌ **Don't use multi when you need single expertise.** single is faster and clearer.
- ❌ **Don't skip the synthesis in multi mode.** Reading opinions with no synthesis misses the point.

## Quality guarantees

Every response includes:

✅ Recommendations tied to stated constraints
✅ Assumptions separated from facts
✅ Concrete next steps (not vague)
✅ Explicit risks/tradeoffs for non-trivial decisions
✅ Confidence level with justification
✅ Persona-specific reasoning using their Decision Lens

## FAQ

**Q: Which mode should I use?**
A: single if you want one expert; multi if you need synthesis; iterative if constraints evolve.

**Q: Can I add custom personas?**
A: Yes. Add a persona contract file to [`skills/personas/`](skills/personas/) and reference it
(e.g. "convene with my-custom-persona and senior-architect").

**Q: How is this different from grill-me?**
A: `grill-me` interrogates *you* one question at a time. This skill collects multiple expert opinions
and synthesizes them.

**Q: Why structured markdown output?**
A: Other skills and dashboards can parse it reliably; consistent structure means downstream tools
don't break.

## Related skills

- **[grill-me](../../research-analysis/grill-me/)** — stress-tests *your* plan; the council collects *other* opinions
- **[grill-with-docs](../../research-analysis/grill-with-docs/)** — like grill-me but anchored to project docs
- **[idea-generate](../../research-analysis/idea-generate/)** — uses the council to diverge on options
- **[issue-triage](../../business-product/issue-triage/)** · **[issue-feature-breakdown](../../business-product/issue-feature-breakdown/)** ·
  **[issue-estimate-sp](../../business-product/issue-estimate-sp/)** — invoke the council in multi mode

## Files

- **[SKILL.md](SKILL.md)** — skill entry point (all three modes)
- **[EXAMPLES.md](EXAMPLES.md)** — worked invocations
- **[skills/personas/PERSONAS.md](skills/personas/PERSONAS.md)** — full persona index
- **[skills/personas/GROUPS.md](skills/personas/GROUPS.md)** — pre-made persona panels
- **[skills/personas/](skills/personas/)** — individual persona contracts (36 personas)
