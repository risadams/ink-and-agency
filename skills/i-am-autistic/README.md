# I Am Autistic

An output-shaping skill, sibling to [i-have-adhd](../i-have-adhd/). It makes the agent explicit rather than shorter: nothing load-bearing rides on implication, every instruction says whether it's required or optional, uncertainty gets a number instead of a hedge, and language stays literal unless an analogy is flagged as one.

## Why this exists

Default agent prose is written in a register that leans hard on implicature. It softens a "no" into "you might consider whether…", floats optional suggestions in the same voice as required steps, and uses "probably fine" as a politeness marker rather than a probability claim. A reader who parses that register literally — which is the correct, more careful reading — gets a different message than the one intended.

Five facts drive the ruleset:

1. **Implication is unreliable freight.** Anything important carried by subtext may not arrive.
2. **Unlabeled suggestions become unresolvable decisions.** "You could also add an index" is a question with no stated answer: do I have to?
3. **Hedges read as data.** If "probably" is going to be parsed as a probability, it should be one.
4. **Predictable structure is cheap.** Same section order every turn means attention goes to content, not to re-orienting.
5. **Demanded social performance is a tax.** "Does that make sense?" obliges a reply that costs energy and carries no information.

## Not a request for simpler output

The most common way to get this wrong is to hear "autistic reader" and produce shorter, flatter, more basic content. That's the opposite. Autistic readers typically want **more** precision: the criteria behind the verdict, the edge case that was considered and dismissed, the exact confidence level. The rules govern how things are *stated*, never how much is said.

## Triggers

- Saying "I'm autistic", "be literal with me", "say it directly", "stop hedging"
- Running the slash command: `/i-am-autistic`

Applies to every subsequent message in the session. For always-on behaviour, add a pointer line to `CLAUDE.md` or `~/.claude/CLAUDE.md` — same approach as [i-have-adhd's](../i-have-adhd/README.md#making-it-permanent).

## Stacking with i-have-adhd

Many people need both, and the two collide in three places. The resolution order is **safety → explicitness → brevity**:

| Collision | Resolution |
| :--- | :--- |
| ADHD rule 10 cuts hedges; autistic rule 4 needs the uncertainty | Replace the hedge with a **number** — satisfies both |
| ADHD rule 8 caps lists at five; autistic rule 6 needs full criteria | **Rank and split** into "do now" / "later"; never silently drop one |
| ADHD rule 1 leads with the action; autistic rule 2 labels modality | Lead with the **required** action, labeled |

Invoke both; the composing section in [SKILL.md](SKILL.md#composing-with-i-have-adhd) is the authority.

## What it does

### Inputs

- None. It reshapes whatever the current response would have been.

### Outputs

- Every response for the rest of the session: direct, modality-labeled, literal, with quantified confidence and explicit subtext.

### External systems used

- None.

## Examples

### Example: an answer that was really a "no"

**Before**

> You might want to consider whether this approach is the best fit here. There are some tradeoffs with using a global mutable store in this context, and you could also look at a few alternatives, though it depends on your situation.

**After**

> **No — don't use a global mutable store here.**
>
> **Fact:** three request handlers write to it concurrently (`src/api/*.ts`), and there's no lock.
> **Inference:** under load you'll get interleaved writes. I haven't reproduced this — ~85% confident based on reading the call sites.
> **Required:** move the state into the request context.
> **Optional:** add a lock instead, if you specifically need cross-request sharing.

### Example: hedging replaced with a number

**Before**

> That should probably work, but it might have some issues with larger inputs.

**After**

> ~70% confident it works as written.
>
> **Verified:** inputs up to 10k rows, in the test I just ran.
> **Not verified:** anything above that — the sort is O(n²) and I haven't measured where it becomes a problem.
> **Recommended:** run it against a 100k-row fixture before trusting it in production.

### Example: naming the subtext

**Before**

> Your manager says "no rush on this, whenever you get a chance."

**After**

> Literal content: no stated deadline.
>
> **Unstated expectation:** "no rush" from a manager who brought it up unprompted usually means "this week, not today." ~65% confident — it depends on their normal register, which I don't have.
> **Optional:** ask "is end of week okay?" — that converts the guess into a fact for the cost of one message.

## Anti-patterns

- ❌ **Simplifying instead of clarifying.** Fewer syllables is not the goal. Fewer inferences is.
- ❌ **Stripping all warmth.** Literal is not cold. The ban is on unflagged figurative language in explanations, not on friendliness.
- ❌ **Manufacturing false confidence to avoid hedging.** "I don't know" satisfies rule 4. A confident guess does not.
- ❌ **Labeling everything "Required."** If the modality labels don't discriminate, they carry no information.
- ❌ **Applying rule 3 to creative work.** If metaphor is the deliverable, metaphor is the deliverable.

## FAQ

**Q: Won't labeling every instruction get repetitive?**
A: Yes, in the way a type signature is repetitive. The repetition is the feature — it means you never have to work out which mode a sentence is in.

**Q: What if I like idioms and jokes?**
A: Then use them, and the agent will match your tone. The rule targets explanations and instructions, where a misparsed idiom costs real work.

**Q: Why does it say "~80% confident" instead of just being sure?**
A: Because the alternative isn't certainty, it's an unstated confidence level you'd have to infer. A number you can argue with beats a hedge you can't.

**Q: Can I use this without i-have-adhd?**
A: Yes. They're independent; the composing section only matters if both are active.

## Related skills

- **[i-have-adhd](../i-have-adhd/)** — the sibling shaper; action-first, state-carrying output.
- **[break-it-down](../break-it-down/)** — decode a single inbound message into plain language.
- **[writing-tone-check](../writing-tone-check/)** — predict how your own draft will land before you send it.
- **[meeting-decompression](../meeting-decompression/)** — process a meeting where the subtext cost more than the content.
- **[rejection-sensitivity-check](../rejection-sensitivity-check/)** — when a message stung and you need evidence separated from interpretation.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the ten rules, composing rules, overrides, pre-send check)
