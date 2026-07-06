# Writing Draft Article

A top-level writing skill that takes the user from a raw idea, topic, or existing draft all the way to a publishable article. The skill grills you on thesis, audience, angle, and format; builds an outline; drafts section by section; polishes; and delegates to sibling skills (humanize, shape, beats, fragments) when the situation calls for it.

## Why this exists

Most writing tools are too small to be useful or too big to start. A tool that just polishes prose can't help you find your thesis; a tool that just brainstorms can't get you to "ready to publish." This skill is the opinionated through-line: it forces you through the questions you'd avoid (audience, angle, what you're actually arguing) and refuses to let weak claims or boring openings survive into the draft. It also knows when to step aside and delegate — to fragments when you don't have enough material, to beats when the shape wants to be narrative, to humanize when the prose has gotten algorithmic.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "help me write an article"
  - "draft a blog post about {topic}"
  - "polish this draft to publishable"
  - "I want to write something about {idea}"
- Running the slash command: `/writing-draft-article`

## What it does

The skill runs a 5-phase pipeline: clarify (force answers on thesis, audience, angle, format, length, evidence, voice, goal), outline (structural skeleton, grilled), draft (section by section), polish (read whole, diagnose, surgically rewrite), pre-publish check (a 9-item readiness list). It supports four output formats: blog post, social media post/thread, long-form essay, newsletter — each with different expectations. It delegates to sibling skills when the situation matches, and it never invents facts, quotes, or statistics — when something needs a source it can't find, it flags it.

### Inputs

- **Starting point** — one of: raw idea, topic, existing draft. Free-form.
- **Format** — blog / social / long-form / newsletter. Asked or inferred.
- **Voice sample** — optional. Sample of user's previous writing for voice matching.

### Outputs

- A final article saved to a markdown file the user specifies (or chosen with the user's input).

### External systems used

- Local filesystem (read voice samples, write the article)
- Web (optional — for research and fact-checking, only if the user wants)

## How to use it

A typical session looks like this:

```text
You: I want to write a blog post about why our team adopted async standups

Skill: Phase 1 — Clarify.
       - Thesis: what are you actually arguing?
You: That async standups freed us from meeting tax without losing alignment.
Skill: - Audience: be specific. "Engineers" isn't enough.
You: Engineering managers at 20-100 person companies considering the switch.
Skill: - Angle: your take, not the neutral summary.
You: Most teams adopt async badly because they keep the standup format
     instead of redesigning the artifact.
Skill: - Format: blog?
You: Blog post, 1200 words, on Medium.

       Phase 2 — Outline. Working title: "We Killed Standups. The
       Alternative Wasn't What We Expected."

       ## Hook — the failure of our first attempt at async (2 paragraphs)
       ## Section 1 — what async standups got wrong (the format)
       ## Section 2 — what we replaced them with (the artifact)
       ## Section 3 — what we lost and didn't notice for a month
       ## Conclusion — when async works, when it doesn't

       Section 3 is doing real work — the honesty about what was lost is
       what makes this not just "we're great." Want to keep it?

You: Yes.

       Phase 3 — Draft. Writing the hook first.
       [...drafts section by section, grilling along the way...]

       Phase 4 — Polish. Running through the humanizer to clean AI patterns.
       [...delegates to writing-humanize...]

       Phase 5 — Pre-publish check. 9 items. All pass.
       Saved to articles/async-standups.md.
```

## Getting the most out of it

- **Engage the Phase 1 questions honestly.** "I want to write about X" gets you nowhere; "I want to argue Y to audience Z because of evidence W" gets you a finished article. Skipping the clarify phase produces vague drafts.
- **Bring a voice sample.** A paragraph of your own previous writing tells the skill what your voice sounds like. Without it, the skill defaults to a natural-but-generic style and you spend the polish phase course-correcting.
- **Don't pre-write the article in your head.** The grilling will surface things you hadn't noticed. If you arrive with the article fully formed, the skill produces a slightly polished version of what you already had — which isn't what you came for.
- **Trust the delegation.** When the skill says "you have raw material; let's run fragments first" or "this needs the humanizer," it's reading the situation correctly. Resist the urge to push through.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Invent facts, quotes, or statistics.** When evidence is needed and not available, the skill names the gap. It will not fabricate citations.
- ❌ **Coddle weak arguments.** The grilling pushes back on vague claims and unearned conclusions. If you want a stenographer, this isn't the skill.
- ❌ **Produce placeholder drafts.** No `[TBD]`, no `[add citation]` in the final file. If something needs to be there, it is — or the section was cut.
- ❌ **Skip the pre-publish check.** The 9-item check catches the things that would embarrass you on publish (missing transitions, generic conclusions, AI patterns that snuck back in). Do it.

## Examples

### Example: Starting from a draft

```text
You: I have a draft. It's not landing. Help me push it to publishable.

Skill: Reading the full draft first.

       Diagnosis:
       - Hook is a summary, not a hook (the first paragraph announces what
         the post is about instead of pulling the reader in).
       - Section 2 and Section 4 argue the same thing twice.
       - Conclusion is a generic "what's next" that doesn't land.
       - Voice is yours through Section 3, then drifts to corporate-blog
         tone in Section 4.

       Salvageable. Start over from the ideas; rewrite to a sharper thesis?
       Or surgical fixes to the existing draft?

You: surgical.

Skill: Rewriting the hook to lead with the moment of failure that prompted
       the post. Cutting Section 4 and folding the unique parts into 2.
       Rewriting the conclusion to land on a question instead of a summary.
       [...continues with grilling...]
```

The diagnosis is specific. "It's not landing" gets a specific answer.

### Example: Delegating to fragments

```text
You: I want to write about why I left my last job

Skill: Phase 1 — Clarify.
       What's the thesis?
You: I'm not sure yet. Maybe something about culture?

Skill: You don't have a thesis yet — you have a topic. We'd produce a
       polished essay with no spine. Let's mine for raw material first.

       Switching to fragments mode. We'll come back here once you have
       something to shape.
       [...delegates to writing-fragments...]
```

The skill recognizes when the upstream work isn't done and steps aside.

## Internals

The skill follows a 5-phase pipeline:

1. **Clarify** — force answers on Thesis, Audience, Angle, Format, Length, Evidence, Voice, Goal. Gaps become questions to fill.
2. **Outline** — structural skeleton (Hook + sections + Conclusion). Grill the outline before writing anything.
3. **Draft** — section by section, in order. Hook first. Pull from user's knowledge; name gaps explicitly.
4. **Polish** — read whole, diagnose (structure / clarity / voice / evidence), surgical rewrites. Delegate to humanize if AI patterns crept in.
5. **Pre-publish check** — 9 items: hook hooks, evidence/opinion framing, clear argument, transitions, ending lands, no AI patterns, citations complete, voice consistent, title matches.

Format expectations:

- **Blog (800-2000 words)**: hook + descriptive subheadings + mix of argument/example/evidence + conversational-but-precise + clear takeaway/CTA.
- **Social (200-600 words or thread)**: hook is the entire first line + each line a beat + short paragraphs + opinionated + sharp closer.
- **Long-form (2000-5000+)**: scene/story/paradox or direct argument + deep single-idea exploration + nuance + landing not summary.
- **Newsletter (500-1500)**: personal tone + direct address + personal story or observation + practical takeaways.

Delegation rules:

- Pile of raw thoughts, no structure → [writing-fragments](../writing-fragments/)
- Has notes/fragments, wants paragraph-by-paragraph → [writing-shape](../writing-shape/)
- Wants narrative/journey structure → [writing-beats](../writing-beats/)
- Draft sounds AI-generated → [writing-humanize](../writing-humanize/)
- Wants stress-test on plan/thesis → [grill-me](../grill-me/)

## FAQ

**Q: What if I don't have a voice sample?**
A: The skill writes in a natural, opinionated style and asks after the first section: "does this sound like you?" Iterate from there.

**Q: Can it research for me?**
A: It can search the web if you want, but it will not fabricate citations. If a claim needs evidence and the search comes up empty, the skill flags the gap and either gets you to fill it or cuts the claim.

**Q: How long does a typical session take?**
A: A 1200-word blog post takes 30-60 minutes of back-and-forth. The clarify phase is the longest; once the thesis is sharp, drafting is fast.

**Q: Can I start over mid-session?**
A: Yes — say "let's restart with a different thesis" and the skill rewinds to Phase 1 with the existing material as input.

**Q: What if I disagree with the diagnosis in Phase 4?**
A: Push back. The skill will explain why it called something out; if your reasoning is stronger, override.

## Related skills

- **[writing-fragments](../writing-fragments/)** — for the upstream work when you don't have material yet.
- **[writing-shape](../writing-shape/)** — paragraph-by-paragraph shaping with format arguments. Delegated to from Phase 3 when material is plentiful and structure is the question.
- **[writing-beats](../writing-beats/)** — narrative shaping for choose-your-own-adventure articles.
- **[writing-humanize](../writing-humanize/)** — Phase 4 delegates to this when AI patterns are detected.
- **[grill-me](../grill-me/)** — Phase 1 can delegate here for deeper thesis stress-testing.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (instructions Claude follows)
