# Council: Multi-Agent Persona-Based Consultation Suite

The Council suite provides three specialized agents for structured decision-making with expert personas:

## Agents

### 1. **council-single-persona** 
Get focused advice from one expert perspective.

**Use when**:
- You want one expert viewpoint on a decision
- You say "As a [persona], what should we do?"
- You need quick advice (10–15 min execution)

**Example**: "As a senior-architect, should we migrate to microservices?"

**Output**: Structured advice with assumptions, questions, and confidence.

**Escalates to**: council-multi-persona (if user asks for multiple perspectives)

---

### 2. **council-multi-persona**
Convene multiple experts and synthesize their perspectives into agreements, conflicts, and tradeoffs.

**Use when**:
- A decision is complex enough for multiple viewpoints
- You need to understand where experts agree and where they clash
- You're stress-testing a proposal with diverse perspectives
- You want a single synthesized recommendation with conflict analysis

**Example**: "Convene a council on Kubernetes adoption. Personas: senior-architect, devops-engineer, tech-lead, devils-advocate."

**Output**: 
- Individual persona responses
- Synthesis: agreements, conflicts (with decision tables), risks, next steps

**Escalates to**: council-iterative (if conflicts remain unresolved)

---

### 3. **council-iterative**
Run a multi-turn session where clarifications refine the recommendation over several turns.

**Use when**:
- You need to iterate through a complex decision
- Constraints or priorities emerge during conversation
- You want to resolve conflicts with targeted follow-up questions
- You're exploring a decision space that's not fully defined

**Example**: "Convene a council on Kubernetes adoption. I'll iterate." (Then ask clarifying questions over 3–5 turns)

**Output**:
- Each turn refines the recommendation
- Conflict Protocol surfaces decision options explicitly
- Final output: fully locked-in decision with rationale and roadmap

---

## Persona Library

All agents reference the same persona library (`${CLAUDE_PLUGIN_ROOT}/references/council-personas/` folder):

- **Technical personas**: senior-architect, senior-developer, tech-lead, qa-engineer, devops-engineer, security-expert
- **Product personas**: product-owner, product-manager, customer-advocate, ux-designer
- **Operations personas**: scrum-master, release-train-engineer, site-reliability-engineer
- **Business personas**: business-owner, financial-officer, growth-strategist, compliance-officer
- **Specialized personas**: data-engineer, statistics-expert, ai-ml-engineer, technical-writer
- **Cross-cutting personas**: devils-advocate, psychologist, personal-assistant, culture-lead

Each persona has a contract that defines:
- **Soul**: One-sentence identity
- **Voice**: Communication style
- **Decision Lens**: How they evaluate options
- **Preferred Frameworks**: Reasoning structures they favor
- **Default Clarifying Questions**: What they always ask
- **Blind Spots**: What they consistently underweight
- **Output Requirements**: What their response must include

---

## How to Choose an Agent

### Start with a single persona?
→ Use **council-single-persona**

Example prompt: "As a senior-architect, should we cache user profiles at the CDN edge or request them fresh every time?"

---

### Need multiple perspectives on a defined problem?
→ Use **council-multi-persona**

Example prompt: "Convene a council: should we migrate our monolith to microservices? Personas: senior-architect, devops-engineer, tech-lead, qa-engineer, devils-advocate."

---

### Exploring a decision with evolving constraints?
→ Use **council-iterative**

Example prompt: "Run a multi-turn council on payment processor selection. I'll iterate as constraints become clear."

(Agent asks: "What's your main constraint: cost, latency, or compliance?" You answer. Agent refines. Repeat 3–5 times.)

---

## Quality Guarantees

Every response includes:

✅ **Explicit Assumptions**: What must be true for this advice to hold  
✅ **Clear Conflicts**: Where experts disagree, and on what dimension (cost/time/risk/reversibility/people)  
✅ **Actionable Next Steps**: Concrete actions to reduce ambiguity or validate assumptions  
✅ **Confidence Levels**: Low / Medium / High with justification  
✅ **Persona-Specific Reasoning**: Using each persona's Decision Lens and Frameworks  

No vague advice. No false confidence.

---

## Common Patterns

### Pattern 1: Quick Expert Opinion
```
User: "As a product-owner, should we ship this feature this quarter or defer?"
Agent (council-single-persona): [structured advice in 15 min]
```

### Pattern 2: Architectural Review with Synthesis
```
User: "Convene a council on whether to adopt Kubernetes."
Agent (council-multi-persona): 
  - Gets input from 6 personas
  - Synthesizes: 3 agreements, 2 conflicts, 4 risks, 3 next steps
  - Output in 30 min
```

### Pattern 3: Iterative Decision-Making
```
User: "Run a council on feature prioritization. I'll iterate."

Turn 1 (Agent): "What's your main constraint: time, budget, or team capacity?"
Turn 1 (User): "Time — we need to ship in 6 weeks."

Turn 2 (Agent): [Consults council with 6-week constraint locked in]
Turn 2 (Agent): "Conflict between shipping all three features (product-owner) vs. quality (qa-engineer). Which do you prioritize?"
Turn 2 (User): "Quality first; we can defer lower-impact features."

Turn 3 (Agent): [Refines recommendation; conflict resolved]
Turn 3 (Agent): "Next steps: prioritize these three features, defer these two."
```

---

## Invoking the Agents

### From Claude Code

```
/council-single-persona
  As a security-expert, what are the top three risks of our current auth model?

/council-multi-persona
  Convene a council on whether to rewrite our frontend in a new framework.
  Personas: senior-developer, ux-designer, tech-lead, devops-engineer, devils-advocate.

/council-iterative
  Run a council on team restructuring. I'll iterate.
```

### From Other Agents or Skills

Other agents can invoke these agents programmatically to get expert perspectives on decisions:

```
Invoke: council-multi-persona
  problem: "Should we adopt TypeScript?"
  selected_personas: ["senior-developer", "tech-lead", "devils-advocate"]
  depth: "standard"
```

The multi-persona agent returns:
```json
{
  "responses": [...],
  "synthesis": {
    "agreements": [...],
    "conflicts": [...],
    "risks_tradeoffs": [...],
    "next_steps": [...]
  }
}
```

---

## Workflow Example: Feature Prioritization

**Turn 1 — Single Persona (Product Owner)**
```
User: "As a product-owner, should we ship X or Y this quarter?"
Agent: [Gives product-owner's recommendation with assumptions]
```

**Turn 2 — Multi-Persona (Broader Perspectives)**
```
User: "Actually, get input from tech-lead and qa-engineer too."
Agent (council-multi-persona): [Consults all three personas]
  - Product-owner: Ship X (higher market value)
  - Tech-lead: Ship Y (lower tech debt)
  - QA-engineer: Neither ready; both need 2 more weeks
  - Synthesis: Conflict on reversibility (X is harder to undo; Y locks you into a codebase)
```

**Turn 3 — Iterative (Resolve Conflicts)**
```
User: "Let's iterate. What if we ship X in a beta, gather data, then decide on Y?"
Agent (council-iterative): [Turn 2, updated with beta approach]
  - Product-owner: Loves the beta approach (learn fast)
  - Tech-lead: Concerned about beta debt
  - QA-engineer: Needs defined exit criteria for beta
  - Next step: Write beta exit criteria
```

---

## Personas at a Glance

| Persona | Lens | Blind Spot |
| --- | --- | --- |
| **senior-architect** | Structural impact, scalability | Underestimates team learning curve |
| **senior-developer** | Implementation complexity, local velocity | Overestimates importance of "clean code" |
| **product-owner** | User value, market timing | Underestimates technical risk |
| **devops-engineer** | Operational complexity, observability | Overestimates importance of tooling |
| **security-expert** | Attack surface, compliance risk | Underestimates business impact of friction |
| **qa-engineer** | Test coverage, data edge cases | Overestimates ability to catch all bugs upfront |
| **tech-lead** | Dependencies, team capacity | Underestimates importance of shipping velocity |
| **devils-advocate** | Challenges the obvious | Can derail consensus prematurely |

---

## Anti-Patterns

❌ **Don't use for pure factual lookup**: "What's the PostgreSQL syntax for a partial index?" — use documentation or a search agent instead.

❌ **Don't skip assumptions**: Assumptions are where disagreements live. Ignoring them turns advice into "trust me."

❌ **Don't ask the council to make the final decision**: The council surfaces tradeoffs; *you* decide based on your priorities.

❌ **Don't use a council without context**: "Should we hire?" with no context → garbage in, garbage out. Invest 5 min in a problem statement.

❌ **For single-persona quick consults, don't add five personas**: One lens, one voice. If you want multiple perspectives, use council-multi-persona.

---

## Extending the Council

### Custom Personas

Want a persona that doesn't exist? Define it and add to `${CLAUDE_PLUGIN_ROOT}/references/council-personas/` folder:

```markdown
# Persona: [Name]

## Soul
<one-sentence identity>

## Voice
<tone and communication style>

## Focus
- <topic 1>
- <topic 2>

## Decision Lens
<how this persona evaluates options>

## Preferred Frameworks
- <framework name>: <description>

## Default Clarifying Questions
- <question>

## Failure Modes To Watch
- <pattern>

## Blind Spots
- <what they underweight>

## Output Requirements
- <what the response must include>

## Escalation Conditions
- <when this persona flags for escalation>
```

Then reference it in prompts: "Convene a council with personas: senior-architect, my-custom-persona, devils-advocate."

---

## Files

- **council-single-persona.md** — Single expert perspective agent
- **council-multi-persona.md** — Multi-persona synthesis agent
- **council-iterative.md** — Multi-turn iterative decision agent
- **${CLAUDE_PLUGIN_ROOT}/references/council-personas/** — Persona contract library
- **README.md** — This file
- **PERSONAS.md** — Full persona index (in ${CLAUDE_PLUGIN_ROOT}/references/council-personas/ folder)

---

## Related Skills (Deprecated)

The original skill-based implementation (`clarity-council` skill) is deprecated. Use these agents instead:

- Single persona → **council-single-persona agent**
- Multi-persona → **council-multi-persona agent**
- Iterative discussion → **council-iterative agent**

The skill will delegate to these agents for backward compatibility, but you should invoke the agents directly.

---

## Notes

- **Personas are contracts, not oracles**: Each persona has a Decision Lens and Blind Spots. They're useful precisely *because* they have constraints.
- **Synthesis is mandatory**: In multi-persona mode, you get agreements + conflicts, not just a list of opinions.
- **Assumptions are explicit**: Every response says "this advice holds if X, Y, Z are true." If you can't verify those, revisit the advice.
- **Confidence is earned**: Low confidence means "don't rely on this heavily." High confidence means "this is grounded in validated evidence or repeated patterns."
- **This is advice, not a final decision**: The council surfaces tradeoffs and risks; you decide based on your priorities and constraints.
