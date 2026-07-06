# Clarity Council: Agent-Based System

Run structured persona-based consultation for decisions that benefit from multiple perspectives. Three specialized agents handle different decision-making needs:

- **council-single-persona** — Quick expert advice (10–15 min)
- **council-multi-persona** — Synthesized multi-perspective advice (20–30 min)
- **council-iterative** — Multi-turn iterative decisions (30–60 min)

Output is consistently structured (assumptions, advice, conflicts, tradeoffs, next steps) so downstream consumers can parse it reliably.

## Why this exists

Most decisions die in one of two ways: a single perspective dominates and the blind spots ship into production, or you collect five opinions in a meeting and walk out without a synthesis. Persona-based consultation catches both: each persona is constrained to a defined viewpoint (so blind spots can't dominate), and the synthesis step is non-optional (so disagreements get articulated, not buried). The skill also makes the consultation portable — the output structure is consistent across modes and across invoking skills, so you can reason about the same decision the same way no matter which entry point you used.

## How to Invoke

### Direct Agent Invocation (Recommended)

Use the appropriate agent based on your need:

```
/council-single-persona
  As a senior-architect, should we migrate to microservices?

/council-multi-persona
  Convene a council on Kubernetes adoption.

/council-iterative
  Run a council on team restructuring. I'll iterate.
```

### From Other Skills

Other skills (issue-triage, issue-feature-breakdown, issue-estimate-sp, etc.) invoke the agents programmatically:

```
Invoke: council-multi-persona
  problem: "Should we adopt TypeScript?"
  selected_personas: ["senior-developer", "tech-lead", "qa-engineer"]
  depth: "standard"
```

## How It Works

The agent-based system loads persona contracts, generates perspective-specific responses with explicit assumptions, and synthesizes across viewpoints. Each agent is optimized for its mode:

**council-single-persona**: Single expert perspective with confidence and assumptions  
**council-multi-persona**: Multiple expert perspectives + synthesis (agreements/conflicts/risks)  
**council-iterative**: Multi-turn refinement with targeted clarifications and session state

Output is structured (YAML-style markdown blocks) so downstream consumers (other skills, dashboards, APIs) can parse reliably.

### Common Inputs

- **Decision/problem** — required. What you're deciding on.
- **Context** — optional. Background, constraints, prior decisions.
- **Personas** — optional. Which experts to consult (defaults apply per mode).
- **Persona groups** — optional. Use pre-made panels (product-delivery-core, platform-and-reliability, etc.).
- **Depth** — optional: `brief` / `standard` / `deep` (affects thoroughness).
- **Iterative state** — for multi-turn sessions (sessionId, turn, history).

### Consistent Outputs

All agents produce structured markdown with:
- **Summary** — The recommendation
- **Advice** — Specific points tied to persona's lens
- **Assumptions** — What must be true for this to hold
- **Questions** — To validate assumptions
- **Next steps** — Concrete actions
- **Confidence** — Low / Medium / High with justification

Multi-persona mode adds:
- **Responses** — Individual perspective per persona
- **Synthesis** — Agreements, conflicts (named by dimension), risks/tradeoffs

Iterative mode adds:
- **Session state** — Carried forward per turn
- **Conflict protocol** — Decision tables to resolve clashes

## Examples

### Single-Persona Quick Consult

**Invocation**: `/council-single-persona`
```
As a security-expert, what's the top risk in our current auth model?
```

**Output**:
```markdown
Summary: Session token storage is your top risk.

Advice:
- Move to httpOnly cookies immediately.
- Implement token rotation (refresh every 15 min).
- Add signed headers for tampering detection.

Assumptions:
- You can tolerate a 1–2 week implementation window.
- Users can handle 15-minute session timeouts.

Confidence: high
  — Token storage risks are well-understood; this is a validated pattern.
```

### Multi-Persona Synthesis

**Invocation**: `/council-multi-persona`
```
Convene a council on whether to migrate our auth from basic to OAuth.
Personas: senior-architect, security-expert, product-owner.
```

**Output** (abbreviated):
```markdown
responses:
- persona: senior-architect
  summary: Migrate; operational complexity of basic auth already exceeds OAuth's setup cost.
  advice: [...]
  confidence: high

- persona: security-expert
  summary: Migrate, but only after threat-modeling attack surface.
  confidence: high

- persona: product-owner
  summary: Don't migrate this quarter; Q3 has in-flight payment features.
  confidence: medium

synthesis:
  agreements:
  - Migration is the right direction.

  conflicts:
  - Dimension: TIMING
    | Option | Benefit | Risk | Who Favors |
    | --- | --- | --- | --- |
    | Now | Unblock roadmap | High incident risk | architect, security |
    | Q4 | Lower risk | Deferred complexity | product-owner |

  risks_tradeoffs:
  - Q3 conflict with payments work is the load-bearing tradeoff.

  next_steps:
  - Decide cutover quarter before scoping further.
  - Threat-model attack surface regardless of timing.
```

### Iterative Multi-Turn Decision

**Invocation**: `/council-iterative`
```
Run a council on Kubernetes adoption. I'll iterate.
```

**Turn 1**: Agent asks "What's your main constraint: cost, latency, or operational complexity?"  
**Turn 2** (You answer): Agent consults council, surfaces conflict  
**Turn 3** (Clarification): Agent narrows options based on constraint  
**Turn 4** (Final): Agent delivers decision with roadmap

## Tips for Best Results

- **Pick the right agent.** Single persona for quick perspective; multi-persona for complex decisions; iterative for evolving constraints.
- **Assemble deliberately.** Predefined groups work well (product-delivery-core, platform-and-reliability, etc.), but custom personas let you optimize.
- **Always read the synthesis.** For multi-persona mode, synthesis is where the value lives. Skipping to one persona's advice defeats the point.
- **Read agreements first.** In multi-persona output, agreements are strong evidence; conflicts are the live questions. Most users skim to conflicts and miss what everyone already agrees on.
- **Match depth to stakes.** `brief` for routine decisions (faster), `standard` for important ones, `deep` for high-stakes (more thorough).
- **Use iterative mode when uncertain.** If you're not sure what you're optimizing for, let the agents ask clarifying questions over 3–5 turns.

## Anti-Patterns

What these agents will NOT do, or what to avoid:

- ❌ **Don't expect final decisions.** The agents surface tradeoffs and risks; you decide. They won't say "do X" with no qualification.
- ❌ **Don't use for pure factual lookup.** "What's the syntax for a Postgres index?" doesn't need a council. Use agents for decisions with tradeoffs.
- ❌ **Don't run with thin context.** Garbage in = structured garbage out. A two-sentence problem and no background gives personas nothing to push on. Invest 5 min in problem statement.
- ❌ **Don't skip assumptions.** Every response includes assumptions explicitly. Ignoring them turns advice into "trust me"—and assumptions are usually where real disagreement lives.
- ❌ **Don't use multi-persona when you need single expertise.** If you just want one expert's view, use council-single-persona (faster and clearer).
- ❌ **Don't skip the synthesis in multi-persona mode.** If you read 6 personas' opinions but no synthesis, you've missed the point.

## Architecture

Each agent handles one decision-making mode:

**`council-single-persona`**
- Purpose: Single expert perspective
- Workflow: Load persona contract → apply lens → generate response → return with assumptions
- Output: Summary, advice, assumptions, questions, next steps, confidence
- Time: 10–15 min

**`council-multi-persona`**
- Purpose: Multi-expert synthesis
- Workflow: Consult each persona → synthesize → identify agreements/conflicts/risks → return structured synthesis
- Output: Individual responses + synthesis (agreements/conflicts/risks/next steps)
- Time: 20–30 min

**`council-iterative`**
- Purpose: Multi-turn iterative refinement
- Workflow: Initialize session → ask clarification → consult council → apply conflict protocol → return state
- Output: Per-turn refinement with session state, decision tables for conflicts
- Time: 30–60 min (3–5 turns)

All agents load persona contracts from `references/council-personas/PERSONAS.md`.

## Quality Guarantees

Every response includes:

✅ **Recommendations** tied to stated constraints  
✅ **Assumptions** separated from facts  
✅ **Concrete next steps** (not vague)  
✅ **Explicit risks/tradeoffs** for non-trivial decisions  
✅ **Confidence level** with justification  
✅ **Persona-specific reasoning** using their Decision Lens  

## FAQ

**Q: Which agent should I use?**
A: Single persona if you want one expert; multi-persona if you need synthesis; iterative if constraints evolve.

**Q: Can I add custom personas?**
A: Yes. Add a persona contract file to `references/council-personas/` and reference it (e.g., "Convene with my-custom-persona and senior-architect").

**Q: How is this different from grill-me?**
A: `grill-me` interrogates *you* one question at a time. These agents collect multiple expert opinions and synthesize them.

**Q: Why structured markdown output?**
A: Other skills and dashboards can parse the output reliably. Consistent structure means downstream tools don't break.

**Q: What about the old skill references in issue-triage, etc.?**
A: Those skills have been updated to invoke the agents directly (council-single-persona, council-multi-persona, council-iterative).

## Related Agents

The three Council agents work together:
- Use **council-single-persona** when you need one expert's perspective
- Escalate to **council-multi-persona** when you need multiple viewpoints
- Use **council-iterative** when exploring a decision space

Related skills that invoke council agents:
- **[issue-triage](../issue-triage/)** — Invokes council-multi-persona for root-cause analysis
- **[issue-feature-breakdown](../issue-feature-breakdown/)** — Invokes council-multi-persona for impact assessment
- **[issue-estimate-sp](../issue-estimate-sp/)** — Invokes council-multi-persona for scrum-poker estimation
- **[grill-me](../grill-me/)** — Stress-tests *your* plan; council agents collect *other* opinions
- **[grill-with-docs](../grill-with-docs/)** — Like grill-me but anchored to project docs

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point and agent routing
- **[EXAMPLES.md](EXAMPLES.md)** — Invocation examples for all three agents
- **[references/council-personas/PERSONAS.md](references/council-personas/PERSONAS.md)** — Full persona index
- **[references/council-personas/GROUPS.md](references/council-personas/GROUPS.md)** — Pre-made persona panels
- **[references/council-personas/](references/council-personas/)** — Individual persona contracts (35+ personas)

**Agent documentation** (in agents/00-council/):
- `council-single-persona.md`
- `council-multi-persona.md`
- `council-iterative.md`
- `README.md` — Comprehensive guide
- `INDEX.md` — Quick navigation
