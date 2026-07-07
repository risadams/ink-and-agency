# Council Agent Suite: Index

This folder contains the multi-agent implementation of the clarity-council system for structured decision-making with expert personas.

## Quick Start

### I need quick expert advice on one topic
→ Use **council-single-persona**

Invoke: `/council-single-persona`  
Say: "As a [persona], should we...?"  
Time: 10–15 minutes

---

### I need multiple expert perspectives synthesized
→ Use **council-multi-persona**

Invoke: `/council-multi-persona`  
Say: "Convene a council on [decision]. Personas: [list]."  
Time: 20–30 minutes

---

### I need to explore a decision with clarifications
→ Use **council-iterative**

Invoke: `/council-iterative`  
Say: "Run a council on [topic]. I'll iterate."  
Time: 30–60 minutes (3–5 turns)

---

## Architecture

```
00-council/
├── council-single-persona.md     # Single expert perspective
├── council-multi-persona.md      # Multi-expert synthesis
├── council-iterative.md          # Multi-turn iteration
├── <plugin-root>/references/council-personas/
│   ├── PERSONAS.md               # Full persona index
│   ├── GROUPS.md                 # Pre-made persona panels
│   ├── senior-architect.md       # Persona contracts
│   ├── product-owner.md
│   ├── ...                       # 35+ personas
├── README.md                     # Detailed guide
└── INDEX.md                      # This file
```

---

## Decision Tree

**Should I use an agent or the skill?**

→ **Always use an agent** (the agents in this folder). The `clarity-council` skill is deprecated and delegates to these agents.

**Single persona vs. multi-persona vs. iterative?**

| Mode | Single Persona | Multi-Persona | Iterative |
| --- | --- | --- | --- |
| **When to use** | Quick expert opinion | Complex decision needing synthesis | Decision with evolving constraints |
| **Time** | 10–15 min | 20–30 min | 30–60 min (3–5 turns) |
| **Output** | One perspective + assumptions | Multiple perspectives + synthesis + conflicts | Refined recommendation over turns |
| **Example** | "As a security-expert, what's our top risk?" | "Council on Kubernetes adoption" | "Council on team hiring. I'll iterate." |

---

## Persona Groups (Pre-Made Panels)

Use these to quickly convene a focused council:

- **product-delivery-core** — Prioritization & scope (product-owner, product-manager, scrum-master, tech-lead, qa-engineer)
- **platform-and-reliability** — Architecture & operations (senior-architect, devops-engineer, site-reliability-engineer, security-expert)
- **growth-and-content** — Audience & messaging (growth-strategist, social-media-marketer, customer-advocate, technical-writer)
- **governance-and-resourcing** — Funding & policy (business-owner, financial-officer, compliance-officer, finops-engineer)
- **personal-productivity** — Daily/focus work (personal-assistant, psychologist, scrum-master)

Invocation: `council-multi-persona`, say: "Convene a council using the 'product-delivery-core' group."

See **<plugin-root>/references/council-personas/GROUPS.md** for the full list.

---

## Persona List (35+ Available)

**Technical**: senior-architect, senior-developer, tech-lead, qa-engineer, devops-engineer, security-expert

**Product**: product-owner, product-manager, customer-advocate, ux-designer

**Operations**: scrum-master, release-train-engineer, site-reliability-engineer

**Business**: business-owner, financial-officer, growth-strategist, compliance-officer

**Specialized**: data-engineer, statistics-expert, ai-ml-engineer, technical-writer, accessibility-expert

**Cross-cutting**: devils-advocate, psychologist, personal-assistant, culture-lead

See **<plugin-root>/references/council-personas/PERSONAS.md** for the full index and contracts.

---

## Output Format Guarantee

Every response includes:

✅ **Recommendations** — Tied to the persona's Decision Lens  
✅ **Assumptions** — Explicit constraints for the advice to hold  
✅ **Questions** — Clarifications to validate assumptions  
✅ **Next Steps** — Concrete actions  
✅ **Confidence** — Low / Medium / High with justification  

Multi-persona mode adds:

✅ **Synthesis** — Agreements, Conflicts (with decision tables), Risks, Next Steps  
✅ **Conflict Dimensions** — Named (cost vs. time, risk vs. reversibility, etc.)  

Iterative mode adds:

✅ **Session State** — Carried forward across turns  
✅ **Conflict Protocol** — Decision tables + targeted questions to resolve  

---

## Common Workflows

### Workflow 1: "I need a quick sanity check"
```
Single-persona session:
1. Invoke council-single-persona
2. Pick one persona (e.g., "senior-architect")
3. Ask your question
4. Get advice with assumptions and next steps
→ 10 min, done
```

### Workflow 2: "I need multiple opinions on a big decision"
```
Multi-persona session:
1. Invoke council-multi-persona
2. Provide decision context
3. Pick personas (or let agent suggest)
4. Get individual responses + synthesis
→ 30 min, done
```

### Workflow 3: "I'm not sure what I'm optimizing for; help me figure it out"
```
Iterative session (3–5 turns):
1. Invoke council-iterative
2. Provide initial problem
3. Agent asks: "What's your main constraint?"
4. You answer; agent refines recommendation
5. Repeat 2–3 more times until decision is clear
→ 45 min, done
```

---

## Migration from Skill to Agents

**Old**: `/clarity-council` skill  
**New**: Three agents in `00-council/`

| Old Skill (Deprecated) | New Agent | Use Case |
| --- | --- | --- |
| `persona_consult.md` | council-single-persona | One persona, quick advice |
| `council_consult.md` | council-multi-persona | Multiple personas, synthesis |
| `council_discuss.md` | council-iterative | Multi-turn, evolving constraints |

The skill now delegates to these agents for backward compatibility, but you should invoke the agents directly.

---

## Quality & Reliability

### What You Get

- **Persona consistency**: Each persona follows a contract (Decision Lens, Blind Spots, Output Requirements).
- **Conflict clarity**: When personas disagree, the disagreement is named (cost? time? reversibility?), not just listed.
- **Assumption transparency**: Assumptions are separated from facts; you know what might not hold.
- **Confidence calibration**: Advice comes with confidence levels (low/medium/high) with justification.
- **Actionable next steps**: Every response includes concrete actions, not vague guidance.

### What You Don't Get

- ❌ Final decisions made for you (you decide based on tradeoffs)
- ❌ Confidence in ambiguous situations (if ground is shaky, we say so)
- ❌ Advice that ignores assumptions (ignored assumptions ≠ safe assumptions)
- ❌ Generic "best practices" (advice is persona-specific and decision-specific)

---

## Examples

### Example 1: Quick Expert Opinion (Single Persona)
```
User: "As a security-expert, what's our top risk in the current auth model?"

Agent (council-single-persona):
  Summary: Session token storage is your top risk (not salted, no rotation).
  
  Advice:
  - Move to httpOnly cookies immediately.
  - Implement token rotation (refresh token every 15 min).
  - Add signed headers for tampering detection.
  
  Assumptions:
  - You can tolerate a 1–2 week implementation window.
  - Users can handle 15-minute session timeouts.
  
  Confidence: high
    — Token storage risks are well-understood; this is a validated pattern.
```

### Example 2: Multi-Persona Synthesis (Architecture)
```
User: "Convene a council on Kubernetes adoption."

Agent (council-multi-persona):
  Responses:
  - senior-architect: "Adopt gradually; 18 months"
  - devops-engineer: "Adopt, but invest in observability first ($800k)"
  - tech-lead: "Adopt this quarter; start with one service"
  - devils-advocate: "Don't adopt yet; your org structure isn't ready"
  
  Synthesis:
  Agreements:
  - Kubernetes is the right direction (all agree except devils-advocate)
  
  Conflicts:
  - Dimension: TIMING
    | Option | Benefit | Risk | Who Favors |
    | Aggressive (6 mo) | Ship fast | High incident risk | tech-lead |
    | Gradual (18 mo) | Lower risk | Slow velocity | senior-architect |
  
  Next Steps:
  - Run org-structure workshop this week
  - Prototype one service with Kubernetes
  - Decide: aggressive or gradual based on org readiness
```

### Example 3: Iterative Decision-Making (Multi-Turn)
```
User: "Run a council on team restructuring. I'll iterate."

Turn 1 (Agent): "Clarification: Are you restructuring for speed (team autonomy) or risk (shared knowledge)?"
Turn 1 (User): "Speed — we need teams to ship independently."

Turn 2 (Agent): [Consults council with "speed" locked in]
Turn 2 (Agent): "Conflict: product-owner wants 6 teams (isolated), tech-lead wants 4 (shared infra). Which matters more?"
Turn 2 (User): "Isolation matters; we accept some infra duplication."

Turn 3 (Agent): [Refines recommendation]
Turn 3 (Agent): "Decision locked in: 6 autonomous teams, shared CI/CD layer. Next step: define team charters."
```

---

## Extending the System

### Add a Custom Persona

Create `<plugin-root>/references/council-personas/my-persona.md`:

```markdown
# Persona: [Name]

## Soul
<one-sentence identity>

## Voice
<tone>

## Decision Lens
<how this persona evaluates options>

## Preferred Frameworks
- <framework>: <description>

## Default Clarifying Questions
- <question>

## Blind Spots
- <what they underweight>

## Output Requirements
- <mandatory fields in their response>

## Escalation Conditions
- <when this persona flags for escalation>
```

Then invoke: `council-multi-persona` → "Convene a council with my-persona, senior-architect, devils-advocate."

---

## File Reference

### Agent Definitions
- **council-single-persona.md** — Single expert perspective agent
- **council-multi-persona.md** — Multi-persona synthesis agent
- **council-iterative.md** — Multi-turn iterative decision agent

### Documentation
- **README.md** — Detailed guide, patterns, anti-patterns
- **INDEX.md** — This file (quick navigation)

### Personas
- **<plugin-root>/references/council-personas/PERSONAS.md** — Full persona index (35+ personas)
- **<plugin-root>/references/council-personas/GROUPS.md** — Pre-made persona panels
- **<plugin-root>/references/council-personas/[persona-name].md** — Individual persona contracts

---

## Support

See **README.md** for:
- Full workflow descriptions
- Anti-patterns to avoid
- Extending with custom personas
- Related skills/agents

---

## Version

**Council Agent Suite v1.0**  
Converted from `clarity-council` skill  
Last updated: 2026-06-20

---

## Notes

- **Agents, not skills**: These are agents you invoke directly (via `/agent-name` or via agent-to-agent invocation).
- **Persona contracts are load-bearing**: Each persona has explicit constraints (Decision Lens, Blind Spots). They're useful *because* they have constraints.
- **Synthesis is mandatory**: You don't get a list of opinions; you get agreements, conflicts (named by dimension), and a synthesized recommendation.
- **State carries forward in iterative mode**: Each turn builds on prior turns. Constraints lock in; conflicts resolve one by one.
- **This is advice, not decisions**: The agents surface tradeoffs and risks; you decide based on your priorities.
