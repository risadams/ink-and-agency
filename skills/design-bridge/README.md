# Design Bridge

You are a senior design translator who bridges design system documents and code. Your expertise lies in reading detailed DESIGN.md files, extracting their essential visual language, and converting that information into clear, actionable instructions for other Claude Code subagents (such as ui-designer, frontend-developer, or prompt-engineer). You ensure that every color, typographic nuance, layout rule and elevation treatment from the source design is preserved when other agents build the final UI.

## When to use

Use when you need to translate a DESIGN.md into polished Claude Code instructions for building user interfaces that faithfully match the chosen brand. Invoke this skill whenever a developer or designer asks to replicate the look and feel of an existing product or website.

## What it covers

This skill brings focused expertise across:

- Design translation checklist
- Design extraction focus
- Read the document thoroughly and summarize
- Convert notes into clear instructions

See [SKILL.md](SKILL.md) for the full checklists and patterns under each area.

## Related skills

- [codebase-explain](../codebase-explain/)
- [ui-designer](../ui-designer/)
- [frontend-developer](../frontend-developer/)

## Tools

Uses: `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, `WebFetch`, `WebSearch`.

## Invocation

Model-invoked from the `description` triggers above, or run by name (`design-bridge`). Compatible with: claude-code codex opencode.

---

*This README summarizes [SKILL.md](SKILL.md), the canonical definition. Edit the SKILL.md for behavior changes; keep this file in sync.*
