# Skill Create

Create new agent skills with proper structure, progressive disclosure (SKILL.md → REFERENCE.md / EXAMPLES.md / scripts/), and well-formed YAML frontmatter that the agent can actually trigger on. The skill walks the user through requirements, drafts the SKILL.md (and supporting files when warranted), and reviews the result against a checklist before considering it done.

## Why this exists

The hardest part of writing a skill isn't the workflow — it's the description. The description is the only thing the agent sees when deciding which skill to load, and a vague description makes the skill effectively invisible. The second-hardest part is knowing when to split into supporting files: a SKILL.md over 100 lines is a sign that some content belongs elsewhere. This skill handles both: it asks the requirements questions that produce a good description, and it knows when to factor out a REFERENCE.md or EXAMPLES.md instead of letting the SKILL.md balloon.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "create a new skill"
  - "build a skill for {capability}"
  - "write a skill that does X"
  - "I have an idea for a skill"
- Running the slash command: `/skill-create`

## What it does

The skill runs a 3-step process: gather requirements (task/domain, use cases, scripts vs instructions, reference materials), draft the skill (SKILL.md + supporting files if needed), review with the user (does it cover the use cases, anything missing, more/less detail). It produces a properly-structured skill folder with valid frontmatter, a description that includes specific triggers, supporting files when content exceeds the 100-line SKILL.md threshold, and utility scripts when operations are deterministic enough to benefit from them.

### Inputs

- **Skill capability description** — free-form. What should the skill do?
- **Use cases** — specific scenarios the skill should handle.
- **Optional reference material** — existing docs, examples, scripts to incorporate.

### Outputs

- A new skill folder under `~/.claude/skills/{skill-name}/` with:
  - `SKILL.md` (required, with proper frontmatter)
  - Optional: `REFERENCE.md`, `EXAMPLES.md`
  - Optional: `scripts/` directory with utilities

### External systems used

- Local filesystem (creates the skill folder and files)

## How to use it

A typical session looks like this:

```text
You: I want a new skill that takes a markdown file and converts it
     to a presentation outline.

Skill: Step 1 — Gathering requirements.
       1. What task does the skill cover? Specifically, "convert markdown
          to presentation outline" — what input and output format?
You: Markdown file in, returns a JSON outline structured like {slides: [...]}.

Skill: 2. What use cases?
You: Blog posts I want to give as talks; design docs I want to present.

Skill: 3. Does this need executable scripts (deterministic transformation)
       or just instructions (Claude does the work)?
You: Probably scripts — the JSON structure is rigid.

Skill: 4. Any reference materials? Schema for the JSON, prior examples?
You: I have a Python script that does roughly this. Here's the file path.

Skill: Step 2 — Drafting.
       Folder: ~/.claude/skills/markdown-to-slides/

       Files I'll create:
       - SKILL.md (~80 lines): description + workflow + JSON schema
       - scripts/convert.py: refactored from your existing script
       - REFERENCE.md: full JSON schema with all field types

       Frontmatter:
       ---
       name: markdown-to-slides
       description: Convert a markdown file to a presentation outline
         in JSON format. Use when working with .md files that need to
         become slides, or when user mentions "presentation outline,"
         "talk prep," or "slides from markdown."
       ---

       Look right? I'll write the files on confirmation.

You: yes — but the description should also trigger on "deck outline."

Skill: [Updates description, writes the three files, runs review checklist]

       Step 3 — Review:
       ✓ Description includes triggers
       ✓ SKILL.md under 100 lines
       ✓ Concrete examples included
       ✓ References one level deep
       ✗ No time-sensitive info — verified
       ✗ Consistent terminology — verified

       Skill ready at ~/.claude/skills/markdown-to-slides/.
```

## Getting the most out of it

- **Spend time on the description.** The description is the entire user interface from the agent's perspective. "Helps with documents" loses to "Convert markdown files to presentation outlines in JSON format. Use when..." every time.
- **Use scripts for deterministic operations.** If the skill would otherwise produce the same code on every invocation, factor it into a script. Saves tokens; improves reliability.
- **Split files when SKILL.md crosses 100 lines.** Over 100 lines is a smell. Either the workflow needs reference docs (REFERENCE.md) or the examples need their own file (EXAMPLES.md).
- **Keep folder names stable.** Once a skill is published, the folder name is part of its API (slash commands, cross-skill references). Renaming breaks everything that references it.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Write a vague description.** "Helps with X" produces an invisible skill. The skill enforces "Use when [specific triggers]" as part of the description.
- ❌ **Cram everything into SKILL.md.** Over 100 lines means split. The progressive-disclosure pattern (SKILL.md → REFERENCE.md → EXAMPLES.md → scripts/) exists to keep the entry point scannable.
- ❌ **Add scripts for non-deterministic operations.** Scripts make sense for validation, format conversion, deterministic processing. They're noise for tasks Claude does better with judgment.
- ❌ **Create deeply-nested references.** One level of reference (SKILL.md → REFERENCE.md) is fine. Two levels (REFERENCE.md → ADVANCED.md → ADVANCED-PART-2.md) defeats the point.

## Examples

### Example: A simple skill (no scripts, no references)

```text
You: create a skill that decodes ambiguous Slack messages.

Skill: [Step 1 — Requirements gathering]
       Use cases? "Per my last email" reads as passive aggressive,
       short messages that could be sincere or annoyed, etc.

       Scripts needed? No — it's interpretation, not deterministic.

       [Step 2 — Drafting]
       Folder: ~/.claude/skills/decode-message/
       Single file: SKILL.md (~60 lines)

       ---
       name: decode-message
       description: Decode ambiguous Slack and email messages into
         plain language with tone analysis. Use when user says "what
         does this mean," "decode this," "break it down," or pastes
         a message they want analyzed.
       ---

       (Workflow + output format for plain-language section + tone table)

       [Step 3 — Review checklist all pass]
       Skill ready.
```

When the skill is small and self-contained, a single SKILL.md is correct.

### Example: A skill with reference + script

```text
You: create a skill for generating valid Postgres migration files.

Skill: [Step 1 — Requirements gathering]
       Use cases? Add column, drop column, create table, add index, etc.
       Scripts? Yes — the file naming convention and SQL structure are
       deterministic. A script ensures correctness.
       Reference materials? Yes — the SQL idioms vary; we want a
       reference doc separate from the SKILL.

       [Step 2 — Drafting]
       Folder: ~/.claude/skills/postgres-migration/
       Files:
       - SKILL.md (~70 lines): workflow + when to use which idiom
       - REFERENCE.md: full SQL idiom catalog with examples
       - scripts/new-migration.py: generates the file with proper naming
       - scripts/validate.py: checks SQL syntax before commit

       (Drafts and writes files)

       [Step 3 — Review checklist passes]
       Skill ready at ~/.claude/skills/postgres-migration/.
```

The split is justified: scripts for deterministic operations, REFERENCE.md for the catalog, SKILL.md as the entry point.

## Internals

The skill follows a 3-step workflow:

1. **Gather requirements** — task/domain, specific use cases, scripts vs instructions, reference materials.
2. **Draft the skill** — folder, SKILL.md with frontmatter (name + description), supporting files when content warrants split.
3. **Review with user** — does it cover the use cases, anything missing or unclear, sections to expand or trim.

Skill structure pattern:

```text
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (when needed)
├── EXAMPLES.md        # Usage examples (when needed)
└── scripts/           # Utility scripts (when needed)
    └── helper.py
```

SKILL.md template:

```markdown
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

Description requirements:

- Max 1024 chars
- Third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

When to add scripts:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

When to split files:

- SKILL.md exceeds 100 lines
- Content has distinct domains (e.g., finance vs sales schemas)
- Advanced features are rarely needed

Review checklist:

- Description includes triggers ("Use when...")
- SKILL.md under 100 lines
- No time-sensitive info
- Consistent terminology
- Concrete examples included
- References one level deep

## FAQ

**Q: Why is the description so important?**
A: The agent sees only the description when deciding which skill to load. A vague description means the skill is effectively invisible — the agent never picks it. The triggers in the description are the user-interface contract.

**Q: When should a skill be split into multiple files?**
A: When SKILL.md exceeds 100 lines, when content has distinct domains, or when advanced features are rarely needed. The progressive-disclosure pattern keeps the entry point scannable.

**Q: When should a skill have scripts?**
A: For deterministic operations — validation, format conversion, reproducible transformations. Skills that rely on judgment shouldn't have scripts; skills that produce identical code every invocation should.

**Q: Can I edit a skill after creation?**
A: Yes — directly. Just don't rename the folder once it's published; folder names are stable identifiers used by other skills and slash commands.

**Q: What's the right length for a SKILL.md?**
A: Under 100 lines is the soft limit. Over 100 is a signal to split, not necessarily a problem. Some skills genuinely need more (e.g., a 200-line skill with 26 documented patterns is fine — see [writing-humanize](../writing-humanize/)).

## Related skills

- All other skills in this pack are examples of what this skill produces.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (process, structure, templates, checklist)
