# Prototype

Build **throwaway code that answers a question** — then throw it away and keep the answer. Two shapes, picked by the question: a hand-driven terminal app for logic and state models, or several radically different UI variations you flip between in the browser.

## Why this exists

Some design questions can't be settled on paper. A state machine looks fine until you push it through the case where two things happen at once; three layout ideas all sound reasonable until you see them next to real data. Arguing about them is slower than building a rough version and driving it for five minutes.

The failure mode this skill guards against is the prototype that quietly becomes the product: no question written down, no budget, tests creeping in, and eventually a branch nobody can throw away. Every rule here exists to keep the code cheap and the answer durable.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "prototype this" / "build me a quick prototype"
  - "does this state model actually work?"
  - "show me a few options for this page"
  - "I want to feel out the API before writing it"
- Running the slash command: `/prototype`
- Automatically, when `/work-plan` resolves a ticket labelled `workplan:prototype`.

## What it does

Picks a branch from the question, frames the question and a budget in writing, then builds the smallest artifact that answers it.

- **[LOGIC.md](LOGIC.md)** — a lightweight TUI over a **pure, portable logic module** (reducer, state machine, or function set). The shell is throwaway; the module behind it is the thing that gets lifted into real code once the question is settled.
- **[UI.md](UI.md)** — N structurally different variants (default 3, cap 5) on one route, switched by a `?variant=` param and a floating bar. Strongly prefers mounting variants inside an *existing* page — variants judged in an empty route always look fine.

### Inputs

- **A design question** — what you're unsure about, ideally phrased so it can come back true or false.
- **The surrounding code** — the module or page the prototype sits next to. This is also the tiebreaker when the branch is ambiguous.

### Outputs

- A prototype runnable in **one command**, located next to what it prototypes and named so nobody mistakes it for production.
- **The answer** — the verdict and the question it settled — recorded on the issue or in a commit.
- The prototype itself preserved as a **primary source** on a throwaway branch, with a pointer to it from the implementation issue. Main keeps only the validated decision.

### External systems used

- The project's existing task runner and runtime. No external services, no real database, no live mutations.

## How to use it

```text
You: /prototype — I'm not sure our booking hold model handles two overlapping tentative slots

Skill: Question: "can a booking hold two overlapping tentative slots, and what
       expires first?" Budget: one reducer + one TUI file.
       Logic branch — reducer behind a pure interface, TUI over the top.
       Run it with: pnpm prototype:holds

You: [drives it] wait — expiring the 09:00 hold shouldn't release 09:30
Skill: That's the bug in the idea. Two options for the expiry rule: ...
```

## Getting the most out of it

- **Write the question down first.** The one-paragraph question at the top of the prototype is what makes it checkable later — and what stops the prototype drifting into a general-purpose build.
- **Drive it yourself.** The value is in the moments where you say "wait, that shouldn't be possible". Reading the code back doesn't produce those.
- **Ask for more actions.** If a case you care about isn't reachable from the keyboard shortcuts, say so — prototypes evolve within their question.
- **Steal across variants.** "The header from B with the sidebar from C" is the most common — and most useful — outcome of the UI branch.
- **Kill it on budget.** A prototype that outgrew its budget without answering has told you something too: the question was bigger than you thought. Re-scope rather than press on.

## Non-interactive runs

Both branches assume a human drives the artifact. When there's no TTY and no browser — a background agent, a scheduled run, a sandboxed host — the skill still builds the artifact, then drives it itself and saves a **transcript** (a scripted action sequence with state dumps for logic; screenshots or written walkthroughs per variant for UI). It reports observations, never a verdict — the judgement call stays with you.

## It's working if

- You can say in one sentence what question the prototype exists to answer — and it's written at the top of the artifact, not just in your head.
- Someone who doesn't read code can drive it and describe what they see in their own words.
- Someone says "wait, that shouldn't be possible" or "huh, I assumed X". That's a bug in the *idea*, which is the entire point.
- The UI variants disagree about layout and information hierarchy, not just colour and copy — and the feedback is "the header from B with the sidebar from C".
- It's answered in one sitting. Still building it a day later means the question was too big.
- It refused the job when the design was already settled, or when "prototype the whole app" was the ask.
- When it's over, main holds the decision and none of the prototype, and the issue points at the branch that still has it.

## Anti-patterns

- ❌ **Adding tests.** A prototype that needs tests is no longer a prototype.
- ❌ **Wiring to the real database or real mutations.** Use an in-memory store or a stub, unless persistence *is* the question.
- ❌ **Generalising.** No "what if we want X later". The prototype answers one question.
- ❌ **Blurring logic and TUI.** A reducer that references terminal escape codes can't be lifted into real code.
- ❌ **Variants that differ only in colour or copy.** That's a tweak. Real variants disagree about structure.
- ❌ **Promoting prototype code straight to production.** It was written with no tests and no error handling. Rewrite it when you fold it in.
- ❌ **Leaving losing variants and the switcher on main.** They rot fast and confuse the next reader. They belong on the throwaway branch.

## Related skills

- **[work-plan](../work-plan/)** — charts decision tickets; the ones labelled `prototype` are resolved by this skill.
- **[implement](../implement/)** — builds the real thing once the question is answered (its `prototype` preset is a *pipeline* setting, not this skill).
- **[tdd](../tdd/)** — puts real behaviour tests around the validated logic module after it's lifted out.
- **[plan-to-spec](../plan-to-spec/)** — inlines decision-rich prototype snippets (state machine, schema, type shape) into a written spec.
- **[ui-designer](../ui-designer/)** — design-system, hierarchy, and accessibility judgement on the winning variant.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (branch selection, shared rules, quality loop)
- **[LOGIC.md](LOGIC.md)** — Logic/state-model branch: pure module + hand-driven TUI
- **[UI.md](UI.md)** — UI branch: N structural variants + floating switcher

## Host portability

Runs on Claude Code, Codex, and opencode. Everything the skill does is file writes plus "ask the user" — there are no host-specific tools in the instructions. The Codex picker metadata in `agents/openai.yaml` is generated from the `SKILL.md` frontmatter; never edit it by hand. See [PORTABILITY.md](../PORTABILITY.md).
