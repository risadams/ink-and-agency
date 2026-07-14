# Personas

The council resolves a persona name in two steps:

1. **Local lens file** — if `<name>.md` exists in this folder, use it (Soul / Voice / Decision Lens).
2. **Top-level specialist skill** — otherwise, if `skills/<name>/SKILL.md` exists, adopt that
   skill's expertise as the persona's lens.

This keeps every capability single-sourced: names that are also full specialist skills (e.g.
`scrum-master`, `product-manager`) live **once**, as the skill — the council borrows them as voices
rather than duplicating a contract here.

## Council-only lenses (local files)

Voices that exist only for council use — no standalone specialist skill:

- [Growth Strategist](growth-strategist.md)
- [Financial Officer](financial-officer.md)
- [Devil's Advocate](devils-advocate.md)
- [Ops Architect](ops-architect.md)
- [Customer Advocate](customer-advocate.md)
- [Culture Lead](culture-lead.md)
- [Product Owner](product-owner.md)
- [Senior Developer](senior-developer.md)
- [Senior Architect](senior-architect.md)
- [Security Expert](security-expert.md)
- [QA Engineer](qa-engineer.md)
- [Tech Lead](tech-lead.md)
- [Junior Developer](junior-developer.md)
- [UI/UX Designer](ux-designer.md)
- [Graphic Designer](graphic-designer.md)
- [Release Train Engineer](release-train-engineer.md)
- [Statistics Expert](statistics-expert.md)
- [Infographics Expert](infographics-expert.md)
- [Accessibility Expert](accessibility-expert.md)
- [Site Reliability Engineer](site-reliability-engineer.md)
- [FinOps Engineer](finops-engineer.md)
- [AI/ML Engineer](ai-ml-engineer.md)
- [Knowledge Manager](knowledge-manager.md)
- [Compliance Officer](compliance-officer.md)
- [Business Owner](business-owner.md)
- [Social Media Marketer](social-media-marketer.md)
- [Content Creator](content-creator.md)
- [Psychologist](psychologist.md)
- [Researcher](researcher.md)
- [Personal Assistant](personal-assistant.md)

## Specialist skills used as lenses (resolve to a top-level skill)

These names have no local file — the council adopts the matching specialist skill's expertise:

- `data-engineer` → [`skills/data-ai/data-engineer/`](../data-ai/data-engineer/)
- `devops-engineer` → [`skills/infrastructure/devops-engineer/`](../infrastructure/devops-engineer/)
- `product-manager` → [`skills/business-product/product-manager/`](../business-product/product-manager/)
- `risk-manager` → [`skills/specialized-domains/risk-manager/`](../specialized-domains/risk-manager/)
- `scrum-master` → [`skills/business-product/scrum-master/`](../business-product/scrum-master/)
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
