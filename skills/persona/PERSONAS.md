# Personas

The council resolves a persona name in two steps:

1. **Local lens file** — if `<name>.md` exists in this folder, use it (Soul / Voice / Decision Lens).
2. **Top-level specialist skill** — otherwise, if a `skills/<category>/<name>/SKILL.md` exists with a
   **## Council Persona Lens** section, adopt that as the persona's lens.

Advisory roles — the ones you *consult for judgment* rather than *run to produce an artifact* — live
here as local lens files. A handful of names are **both** a persona and a hands-on skill
(`data-engineer`, `devops-engineer`, `technical-writer`): those carry their lens inside the skill and
are resolved via step 2.

## Council-only lenses (local files)

Advisory voices — consulted for judgment, they produce no artifact of their own:

- [Growth Strategist](growth-strategist.md)
- [Financial Officer](financial-officer.md)
- [Devil's Advocate](devils-advocate.md)
- [Ops Architect](ops-architect.md)
- [Customer Advocate](customer-advocate.md)
- [Culture Lead](culture-lead.md)
- [Product Owner](product-owner.md)
- [Product Manager](product-manager.md)
- [Senior Developer](senior-developer.md)
- [Senior Architect](senior-architect.md)
- [Security Expert](security-expert.md)
- [Security Auditor](security-auditor.md)
- [QA Engineer](qa-engineer.md)
- [QA Expert](qa-expert.md)
- [Code Reviewer](code-reviewer.md)
- [Architect Reviewer](architect-reviewer.md)
- [Tech Lead](tech-lead.md)
- [Junior Developer](junior-developer.md)
- [UI/UX Designer](ux-designer.md)
- [UX Researcher](ux-researcher.md)
- [Graphic Designer](graphic-designer.md)
- [Release Train Engineer](release-train-engineer.md)
- [Scrum Master](scrum-master.md)
- [Statistics Expert](statistics-expert.md)
- [Infographics Expert](infographics-expert.md)
- [Accessibility Expert](accessibility-expert.md)
- [Site Reliability Engineer](site-reliability-engineer.md)
- [FinOps Engineer](finops-engineer.md)
- [AI/ML Engineer](ai-ml-engineer.md)
- [Knowledge Manager](knowledge-manager.md)
- [Compliance Officer](compliance-officer.md)
- [Business Owner](business-owner.md)
- [Customer Success Manager](customer-success-manager.md)
- [Risk Manager](risk-manager.md)
- [Social Media Marketer](social-media-marketer.md)
- [Content Creator](content-creator.md)
- [SEO Specialist](seo-specialist.md)
- [Market Researcher](market-researcher.md)
- [Competitive Analyst](competitive-analyst.md)
- [Trend Analyst](trend-analyst.md)
- [Research Analyst](research-analyst.md)
- [Scientific Literature Researcher](scientific-literature-researcher.md)
- [Project Idea Validator](project-idea-validator.md)
- [Psychologist](psychologist.md)
- [Researcher](researcher.md)
- [Personal Assistant](personal-assistant.md)

## Specialist skills used as lenses (resolve to a top-level skill)

These names have no local file — they are **hands-on skills that also serve as a council voice**. Each
carries a **## Council Persona Lens** section (Decision Lens, Preferred Frameworks, Blind Spots,
Failure Modes, Escalation Conditions) that is the persona contract to read; the rest of the skill is
implementation guidance.

- `data-engineer` → [`skills/data-ai/data-engineer/`](../data-ai/data-engineer/)
- `devops-engineer` → [`skills/infrastructure/devops-engineer/`](../infrastructure/devops-engineer/)
- `technical-writer` → [`skills/business-product/technical-writer/`](../business-product/technical-writer/)

## Adding a Persona

Create a new `.md` file in this directory using the full contract structure:

```md
# Persona: <Name>

## Soul
<one-sentence identity>

## Voice
<one-line tone and communication style>

## Focus
- <topic>

## Constraints
- <rule>

## Decision Lens
<how this persona evaluates options — 1-2 sentences>

## Preferred Frameworks
- <Framework>: <one-line description>

## Default Clarifying Questions
- <question this persona always asks>

## Failure Modes To Watch
- <pattern this persona will call out>

## Blind Spots
- <what this persona consistently underweights or ignores>

## Output Requirements
- <what this persona's response must always include>

## Escalation Conditions
- <when this persona flags for council escalation>
```

Then add a link to the list above.

## Removing a Persona

Delete the file and remove its link from the list above.
