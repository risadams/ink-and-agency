# Writing Humanize

Remove signs of AI-generated writing from text. The skill scans for 29 named patterns drawn from Wikipedia's "Signs of AI writing" guide — inflated significance, promotional language, em-dash overuse, rule-of-three, vague attributions, sycophantic tone, and more — then rewrites with natural alternatives, preserves meaning, matches voice, and runs a final "what still sounds AI-generated?" pass.

## Why this exists

Modern AI-assisted writing has a fingerprint. Em-dashes appear in clusters; sentences sprout `-ing` participles to fake depth; conclusions land with "the future looks bright"; vague authorities ("industry observers note") substitute for citations. Readers detect this without being able to name what they're detecting — they just trust the writing less. The patterns are mechanical, which means they're fixable mechanically. This skill is the cleanup pass: name the patterns, rewrite the offending sections, and audit again until the prose stops trying to sound smart and starts sounding like a person.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "humanize this"
  - "this sounds AI-generated"
  - "remove AI patterns"
  - "make this sound less like ChatGPT"
- Running the slash command: `/writing-humanize`

## What it does

The skill identifies AI patterns across 29 categories spanning content (significance inflation, promotional language, vague attributions), language/grammar (AI vocabulary words, copula avoidance, negative parallelisms, rule of three, false ranges, passive voice), style (em-dashes, boldface overuse, inline-header lists, title case, emojis, curly quotes), communication (chatbot artifacts, knowledge-cutoff disclaimers, sycophantic tone), and filler/hedging (filler phrases, hedging, generic positive conclusions, hyphenated word pairs, persuasive authority tropes, signposting, fragmented headers). It rewrites problematic sections with natural alternatives and runs a self-audit pass: "what makes this still sound AI-generated?" then revises.

### Inputs

- **Text to humanize** — inline or via file path.
- **Voice sample** — optional. A sample of the user's previous writing for voice matching.

### Outputs

- A draft rewrite, an audit of remaining tells, a final revised version, and an optional summary of changes made.

### External systems used

- Local filesystem (read input, write output)

## How to use it

A typical session looks like this:

```text
You: humanize this paragraph:
     "Our team has been working diligently to enhance the user experience.
     The new dashboard serves as a testament to our commitment to
     delivering high-quality, data-driven solutions. Through the
     incorporation of cutting-edge technologies and the optimization of
     existing workflows, we have successfully streamlined operations
     while fostering a culture of continuous improvement."

Skill: AI patterns detected:
       - "serves as a testament to" — copula avoidance + significance
         inflation (#1, #8)
       - "commitment to delivering" — promotional (#4)
       - "high-quality, data-driven" — hyphenated word pair overuse (#26)
       - "Through the incorporation of... and the optimization of..." —
         elegant variation + filler (#11, #23)
       - "successfully streamlined" — superficial -ing analysis (#3)
       - "fostering a culture of" — AI vocabulary (#7)
       - Rule of three at the end (#10)

       Draft rewrite:
       "We rebuilt the dashboard. It loads in 400ms instead of 2.1s and
       shows team-level metrics that used to require pulling three
       separate reports."

       What makes the below still sound AI-generated?
       - The voice is still neutral; sounds like marketing talking to
         marketing.

       Final rewrite:
       "We rebuilt the dashboard. The old one took 2.1 seconds to load
       and didn't show the metrics anyone actually wanted; the new one
       takes 400ms and replaces three separate reports we used to pull
       by hand."
```

## Getting the most out of it

- **Provide a voice sample.** A paragraph of your previous writing tells the skill what *your* voice sounds like. Without it, the rewrite trends generic-natural — readable, but not yours.
- **Don't fight the audit.** The audit pass ("what still sounds AI?") is the most valuable step. The first rewrite usually fixes the easy patterns; the audit catches the subtler ones (rhythm, voicelessness, plausible-but-fabricated quotes).
- **Use specific examples.** The skill replaces vague claims with specific evidence wherever possible. If you don't have specifics to provide, the skill will name the gap rather than invent.
- **Run it on your own writing too.** AI patterns aren't unique to AI output — humans drift into them under deadline pressure. Run the skill on your own first drafts before publishing.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Invent facts to replace vague claims.** When "industry observers note X" gets flagged for vague attribution, the skill won't fabricate a citation — it asks for one or recommends cutting the claim.
- ❌ **Strip all opinion to be "neutral."** Voicelessness is itself an AI pattern. The skill adds opinion when the original was sterile, not the other way around.
- ❌ **Match a different voice than yours.** Without a voice sample, defaults to "natural and varied." With one, matches it. It won't impose a voice on you.
- ❌ **Flag every em-dash.** Em-dashes are fine in moderation. The skill flags em-dash *overuse* — clusters and patterns — not isolated uses where the dash works.

## Examples

### Example: Removing significance inflation

Before:
```text
The introduction of the new authentication system marks a pivotal
moment in our security posture, representing a significant step
forward in our ongoing commitment to protecting user data. This
groundbreaking approach underscores our dedication to staying ahead
of evolving threats.
```

After:
```text
We replaced basic auth with OAuth in March. The credential
exfiltration class of bug that hit us in 2024 isn't possible under
the new system — token rotation is automatic.
```

The before-version says nothing concrete; the after-version describes what changed and why it matters in evidence terms.

### Example: Removing the rule of three

Before:
```text
The product offers speed, simplicity, and scale. It empowers
developers, delights designers, and accelerates teams. Users will
find it intuitive, powerful, and indispensable.
```

After:
```text
The product is fast and easy to learn. Most teams hit usable speed
within an afternoon. Whether it's "indispensable" depends on whether
you needed the thing it does — there's a real category of work where
it doesn't apply.
```

Three in a row signals manufactured comprehensiveness. Two beats are usually more honest.

### Example: Removing chatbot artifacts

Before:
```text
Great question! Here is an overview of the deployment process. I hope
this helps! Let me know if you'd like me to expand on any section.

The deployment process consists of three phases. First, we build the
container image. Second, we push it to the registry. Third, the
orchestrator schedules it across the cluster.
```

After:
```text
The deployment has three phases. We build the container image, push
it to the registry, and the orchestrator schedules it across the
cluster.
```

The chatbot frame and the rule-of-three numbering are both AI tells; cutting both also shortens the prose.

## Internals

The skill runs a 9-step process per invocation:

1. **Read the input text carefully.**
2. **Identify all instances of the 29 patterns** (content, language/grammar, style, communication, filler/hedging).
3. **Rewrite each problematic section** with natural alternatives.
4. **Ensure the revised text** sounds natural read aloud, varies rhythm, uses specific details, maintains tone, prefers simple constructions (is/are/has).
5. **Present a draft humanized version.**
6. **Self-audit prompt**: "What makes the below so obviously AI generated?"
7. **Answer briefly** with remaining tells.
8. **Self-audit prompt**: "Now make it not obviously AI generated."
9. **Present the final version** (revised after the audit).

The 29 patterns are grouped:

- **Content (1-6)**: significance inflation, notability claims, superficial -ing, promotional language, vague attributions, formulaic challenges sections.
- **Language and grammar (7-13)**: AI vocabulary, copula avoidance, negative parallelisms, rule of three, elegant variation, false ranges, passive voice.
- **Style (14-19)**: em-dash overuse, boldface overuse, inline-header lists, title case headings, emojis, curly quotes.
- **Communication (20-22)**: chatbot artifacts, knowledge-cutoff disclaimers, sycophantic tone.
- **Filler and hedging (23-29)**: filler phrases, excessive hedging, generic positive conclusions, hyphenated word pairs, persuasive authority tropes, signposting, fragmented headers.

Key constraints:

- **Preserve meaning.** Don't strip the message.
- **Match voice when sample is provided.** Default to natural-and-varied otherwise.
- **No fabricated facts or citations.** Flag gaps; don't invent.

## FAQ

**Q: Where do the patterns come from?**
A: From [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup. The patterns are derived from observations of thousands of AI-generated text instances on Wikipedia.

**Q: Will this make my writing perfect?**
A: No. It removes the AI fingerprint. Whether the underlying ideas are good is your job.

**Q: Does it work on technical writing?**
A: Yes — many AI patterns are worse in technical writing because the genre tolerates more verbosity. The skill cuts ceremonial language without flattening technical content.

**Q: Can it match a specific writer's voice?**
A: Roughly, given a sample. The match is approximate — voice is more than syntactic patterns — but it gets closer than the default.

**Q: How is "voice" different from "tone"?**
A: Tone is formal/casual/technical. Voice is the recurring habits — sentence length patterns, punctuation tics, opinionated asides. The skill matches both when given a sample.

## Related skills

- **[writing-draft-article](../writing-draft-article/)** — Phase 4 of that skill delegates here when AI patterns are detected.
- **[writing-shape](../writing-shape/)** — generated articles often need a humanize pass after shaping.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full pattern catalog with before/after examples)
