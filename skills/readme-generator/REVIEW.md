# README review rubric

Score a drafted or existing README against these. Each line is pass/fail — no partial credit.
Report failures with the specific line or section at fault, then fix them.

## Gate 1 — Truth

Any failure here blocks delivery.

- [ ] Every command appears in the repo's scripts, manifest, CI config, or a `--help` output
      that was actually captured.
- [ ] Every env var and config key is traceable to source, a schema, or a `.env.example`.
- [ ] Version numbers and prerequisites match the manifest / lockfile / CI matrix.
- [ ] Every internal link resolves to a file that exists.
- [ ] Every badge points at a real, current service and reflects the default branch.
- [ ] Anything the repo could not answer is marked `<!-- TODO: … -->` rather than filled in.

## Gate 2 — The 30-second test

Read only the first screen, as a stranger:

- [ ] **What** it is — answered in the first sentence.
- [ ] **Why** you would use it — answered before any install instruction.
- [ ] **How** to run it — a copy-pasteable command visible without scrolling past ~1.5 screens.
- [ ] The first code block runs on a clean machine given only the stated prerequisites.

## Gate 3 — Readability

- [ ] Every required section from [STRUCTURE.md](STRUCTURE.md) is present, in order.
- [ ] No section exceeds ~8 lines of unbroken prose; longer content is a table, list, or link.
- [ ] Headings alone convey the document's shape.
- [ ] Consistent naming — the project, its binary, and its package are called the same thing
      everywhere.
- [ ] Config documented as a table with name, default, and required?.
- [ ] A visual is present, or its absence is deliberate for this project type.

## Gate 4 — Voice

- [ ] Active voice, second person, present tense throughout.
- [ ] No filler openers ("In today's fast-paced world"), no unearned superlatives
      ("blazingly fast", "seamless") unless a benchmark in the repo backs the claim.
- [ ] No em-dash-heavy, triad-heavy AI cadence — the `writing-humanize` pass in step 5 of
      [SKILL.md](SKILL.md) covers this; confirm here that it ran and took.
- [ ] Nothing dates: no "recently", "new in the latest version", "coming soon" without a
      version number or issue link.

## Reporting

When reviewing an existing README (rather than drafting one), return:

1. **Verdict** — Ship / Fix first / Rewrite.
2. **Failures** — grouped by gate, each with the offending line and the concrete fix.
3. **Missing sections** — from the ladder, with why each matters for this project type.
4. **Cut list** — sections that are stale, duplicated elsewhere, or pure filler.
