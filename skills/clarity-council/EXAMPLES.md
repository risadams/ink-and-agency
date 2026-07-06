# Clarity Council: Agent Invocation Examples

This file shows how to invoke the three Council agents in different scenarios.

## 1. Single Persona Consultation

Use `council-single-persona` when you want focused advice from one expert.

### Example 1a: Quick Development Decision

```
Invocation: /council-single-persona

As a senior-developer, our CI pipeline takes 45 minutes and blocks releases.
Context: Monorepo with 12 services, mostly TypeScript, GitHub Actions.
Goal: Reduce average pipeline time to under 15 minutes.
Constraints: No paid CI add-ons this quarter; must keep security scans.
```

**What happens**: Agent loads senior-developer persona, applies their implementation-focused lens, generates advice on pipeline optimization.

### Example 1b: Quick Architecture Opinion

```
Invocation: /council-single-persona

As a security-expert, what's our biggest risk in the current auth model?
Context: We're using session tokens stored in cookies without rotation.
Constraints: Must maintain backward compatibility with existing mobile clients.
```

**What happens**: Agent loads security-expert persona, evaluates attack surface, returns risk assessment with next steps.

---

## 2. Multi-Persona Council Synthesis

Use `council-multi-persona` when you need tradeoffs across multiple roles.

### Example 2a: Architecture Decision with Synthesis

```
Invocation: /council-multi-persona

Should we move from a modular monolith to microservices this year?

Context: B2B SaaS, 20 engineers, rapid feature growth, occasional scaling pain.
Goal: Choose architecture strategy for next 12 months.

Constraints:
- Cannot pause roadmap delivery
- Platform team has only 3 engineers

Personas:
- senior-architect
- financial-officer
- devops-engineer
- product-owner
- devils-advocate

Depth: deep
```

**What happens**: 
1. Agent loads all 5 personas
2. Consults each with the problem
3. Produces individual responses
4. Synthesizes: agreements (all want to improve), conflicts (timing and risk tolerance differ), risks (team capacity)
5. Returns structured output with conflict decision tables

### Example 2b: Using Pre-Made Persona Groups

```
Invocation: /council-multi-persona

Convene a council on adopting TypeScript codebase-wide.

Context: Current project is JavaScript, team has 2 TypeScript experts and 8 novices.
Desired outcome: Go/no-go recommendation for Q3.

Use group: technical-focus

Depth: standard
```

**What happens**: Agent expands `technical-focus` group into: senior-architect, senior-developer, tech-lead, qa-engineer, devops-engineer, security-expert, devils-advocate. Consults all, synthesizes.

### Example 2c: Custom Persona Selection

```
Invocation: /council-multi-persona

Should we hire or build a custom payment processor integration?

Context: 
- Current payment system is industry-standard but rigid
- We have 4 payment-specific features we need
- Budget for either approach is $200k

Personas:
- financial-officer
- product-owner
- senior-architect
- senior-developer
- devils-advocate

Depth: standard
```

**What happens**: Agent consults 5 personas on build-vs-buy decision, surfaces where cost/time/complexity differ.

---

## 3. Iterative Multi-Turn Decisions

Use `council-iterative` when constraints or priorities evolve during the discussion.

### Example 3a: Team Restructuring Decision

```
Invocation: /council-iterative

Run a council on how to restructure our team to improve deployment frequency.
I'll iterate.
```

**Turn 1 (Agent asks clarification)**:
"What's your primary goal: reducing time-to-market, improving reliability, or reducing toil?"

**Turn 1 (You respond)**:
"Reducing time-to-market primarily; we're shipping every 2 weeks but need weekly or daily."

**Turn 2 (Agent consults council)**:
Invokes council-multi-persona with goal locked in. Returns responses from product-owner, tech-lead, scrum-master, culture-lead.

**Turn 2 (Agent surfaces conflict)**:
"Conflict: Product-owner wants 4 cross-functional teams (fast shipping). Tech-lead wants 2 teams + shared platform (lower complexity). Which prioritizes more?"

**Turn 2 (You respond)**:
"Cross-functional teams; we accept some duplication for speed."

**Turn 3 (Agent refines)**:
Returns updated recommendation with roadmap for 4-team restructure.

```

### Example 3b: Kubernetes Adoption with Evolving Constraints

```
Invocation: /council-iterative

Run a council on Kubernetes adoption for our infrastructure.
I'm uncertain what we're optimizing for; please help me figure it out.
```

**Turn 1**: Agent asks "Is your main constraint: cost, operational complexity, or scalability?"  
**You (Turn 1)**: "Operational complexity—we're spending 40% of ops time on deploy issues."  
**Turn 2**: Agent consults council. "Consensus: adopt Kubernetes. Conflict: learning curve vs. payoff. Worth investing 8 weeks for team ramp-up?"  
**You (Turn 2)**: "Yes, we can afford 8 weeks."  
**Turn 3**: Agent finalizes recommendation: "Adopt Kubernetes. Hire consultant for 4-week engagement. Plan 12-week full migration starting Q3."

---

## 4. Invoking from Other Skills/Agents

When other skills need expert perspectives, they invoke Council agents programmatically.

### Example 4a: issue-triage Invoking Council

```
Skill: issue-triage
Step: Root-cause analysis

Invokes: council-multi-persona
  problem: "Why is our login flow occasionally timing out?"
  context: [issue details, logs, reproduction steps]
  selected_personas: ["senior-developer", "qa-engineer", "devops-engineer", "devils-advocate"]
  depth: "standard"

Returns: Structured synthesis with root-cause hypotheses, conflict on server vs. client issue
```

### Example 4b: issue-feature-breakdown Invoking Council

```
Skill: issue-feature-breakdown
Step: Impact assessment

Invokes: council-multi-persona
  problem: "What's the impact of adding real-time notifications to our app?"
  context: [feature description, user cohort size, existing infrastructure]
  selected_personas: ["product-owner", "senior-architect", "devops-engineer", "qa-engineer"]
  depth: "deep"

Returns: Structured synthesis with impact analysis, architectural tradeoffs, resource estimates
```

### Example 4c: issue-estimate-sp Invoking Council

```
Skill: issue-estimate-sp
Step: Scrum poker estimation

Invokes: council-multi-persona
  problem: "How many story points for this feature?"
  context: [feature description, acceptance criteria, team velocity baseline]
  selected_personas: ["scrum-master", "tech-lead", "senior-developer", "qa-engineer"]
  depth: "standard"

Returns: Structured estimates with confidence levels, team consensus on complexity
```

---

## 5. Common Patterns

### Pattern 1: "I Need One Quick Opinion"

```
→ Use council-single-persona
→ 10–15 minutes
→ One persona, clear recommendation
```

### Pattern 2: "Multiple Teams Disagree on This"

```
→ Use council-multi-persona
→ 20–30 minutes
→ Get each perspective, see where they disagree
→ Identify decision options and tradeoffs
```

### Pattern 3: "I Don't Know What I'm Optimizing For"

```
→ Use council-iterative
→ 30–60 minutes (3–5 turns)
→ Agent asks clarifying questions
→ Recommendation refines with each turn
```

### Pattern 4: "Another Skill Needs Expert Input"

```
→ Other skill invokes council agent programmatically
→ Passes problem, context, requested personas
→ Gets structured response for downstream processing
```

---

## Input Fields Reference

All three agents accept these optional fields:

| Field | Description | Example |
| --- | --- | --- |
| `problem` | The decision or question | "Should we adopt Kubernetes?" |
| `context` | Background and constraints | "20 engineers, rapid growth" |
| `personas` | List of personas to consult | ["senior-architect", "product-owner"] |
| `persona_groups` | Pre-made persona panels | ["technical-focus"] |
| `depth` | Thoroughness level | "brief" / "standard" / "deep" |
| `desired_outcome` | Format or focus | "Go/no-go recommendation" |
| `constraints` | Hard limits | ["Budget under $100k"] |

**Iterative-only fields**:

| Field | Description |
| --- | --- |
| `sessionId` | Carries forward across turns |
| `turn` | Current turn number |
| `history` | Prior turn summaries |
| `answer` | User's response to previous clarification |

---

## Next Steps

See the full agent documentation:
- `agents/00-council/council-single-persona.md`
- `agents/00-council/council-multi-persona.md`
- `agents/00-council/council-iterative.md`
- `docs/agents/00-council.md` — Comprehensive guide
- `docs/agents/00-council-index.md` — Decision tree
