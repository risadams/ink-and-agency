# Debug

A six-phase discipline for hard bugs and performance regressions. The skill's core claim is that **the feedback loop is the fix**: once you have a tight, deterministic, red-capable signal that goes red on *this* bug and green when it's gone, bisection, hypothesis-testing, and instrumentation are just mechanics that consume it. The skill forces you to build that loop first and refuses to let you theorise about a cause before it exists.

## Why this exists

The dominant failure mode in debugging is jumping straight to a hypothesis — reading code, building a theory, patching the first plausible suspect — before there's any way to *check* the theory. That produces confident wrong fixes and hours lost to bugs that were never reproduced. This skill inverts the order: no red-capable command, no hypothesising. It treats the reproduction loop as a product to be tightened (faster, sharper, more deterministic) because a 2-second deterministic loop is a debugging superpower and a 30-second flaky one is barely a loop at all.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "diagnose this" / "debug this"
  - "why is this failing / throwing / crashing"
  - "this is broken" / "this regressed"
  - "why is this so slow all of a sudden"
- Running the slash command: `/debug`

## What it does

The skill runs a strict six-phase loop. **Phase 1 (build a feedback loop)** is the whole skill — it lists ten ways to construct a pass/fail signal, in rough order of preference, and defines a completion criterion (one command, already run, that is red-capable + deterministic + fast + agent-runnable). **Phase 2 (reproduce + minimise)** runs the loop until it goes red on the user's *exact* symptom, then shrinks the repro to only load-bearing elements. **Phase 3 (hypothesise)** generates 3–5 ranked, falsifiable hypotheses and shows them to the user before testing. **Phase 4 (instrument)** probes one variable at a time with tagged debug logs (or a profiler for perf). **Phase 5 (fix + regression test)** writes the test before the fix when a correct seam exists — and treats the *absence* of a seam as a finding. **Phase 6 (cleanup + post-mortem)** removes instrumentation, confirms the original repro is dead, and asks what would have prevented the bug.

### Inputs

- **A bug report** — an error, wrong output, crash, or slowdown. The more precisely the symptom is stated, the sharper the loop.
- **Access to reproduce it** — a runnable environment, a failing input, or a captured artifact (HAR, log dump, core dump, trace).
- **Optional: `CONTEXT.md` and ADRs** — read to build a mental model of the affected modules before exploring.

### Outputs

- A tight, deterministic reproduction command (the Phase 1 artifact).
- A minimised repro where every remaining element is load-bearing.
- A ranked list of falsifiable hypotheses.
- A fix plus a regression test at a correct seam — or a documented finding that no correct seam exists.
- A post-mortem naming the correct hypothesis (in the commit/PR) and, when architectural change is warranted, a hand-off to `/codebase-improve-architecture`.

### External systems used

- Local test runners, dev servers, REPLs/debuggers, and profilers — whatever builds the loop.
- **`scripts/hitl-loop.template.sh`** — a human-in-the-loop harness for the last-resort case where a human must click; keeps the loop structured and feeds captured output back to the agent.
- **[codebase-improve-architecture](../codebase-improve-architecture/)** — handed the specifics when the root cause is architectural.

## How to use it

A typical session looks like this:

```text
You: debug this — the export endpoint returns 500 on CSVs over ~10k rows

Skill: Phase 1 — before any theory, I need a red-capable loop.
       Building a curl script against the dev server with a 12k-row fixture,
       asserting HTTP 200 + a non-empty body.

       $ ./repro.sh
       → HTTP 500, "stream closed" — reproduces. Loop is red-capable,
         deterministic (same verdict 5/5 runs), ~3s. Phase 1 done.

Skill: Phase 2 — minimising. Cutting columns, then rows...
       Still red at 10,001 rows / 1 column. Green at 10,000. That
       boundary is load-bearing — keeping it.

Skill: Phase 3 — ranked hypotheses (falsifiable):
       1. Response buffer flushed at a 10k chunk boundary → if so, raising
          the chunk size makes the bug move, not vanish.
       2. Cursor times out mid-stream → if so, a slow 9k export also fails.
       3. Off-by-one in pagination at the 10k page size.
       Which looks likely? (You just changed #1's chunk logic last week?)

You: yeah we touched the streamer. go with #1.
```

## Getting the most out of it

- **Spend disproportionate effort on Phase 1.** The instinct is to skim it and get to the "real" work. Phase 1 *is* the real work — a tight loop makes the rest mechanical.
- **Assert on the user's exact symptom, not "didn't crash."** A loop that goes green while the real bug persists is worse than no loop; it manufactures false confidence.
- **Make it deterministic before you make it clever.** Pin time, seed RNG, isolate the filesystem, freeze the network. A flaky loop poisons every phase downstream.
- **Show the ranked hypotheses before testing.** The user often re-ranks instantly ("we just deployed #3") — a five-second checkpoint that can save an hour. Don't block on it if they're away.
- **Raise the reproduction rate for flaky bugs.** The goal isn't a clean repro, it's a *debuggable* one. Loop the trigger, parallelise, add stress until a 1% flake becomes a 50% one.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Hypothesise before a red-capable command exists.** This is the exact failure the skill prevents. Reading code to build a theory with no loop is Phase-3 work smuggled into Phase 1.
- ❌ **Fix a nearby bug instead of the reported one.** If the loop goes red on a *different* symptom than the user described, you're about to fix the wrong thing.
- ❌ **Log everything and grep.** Untargeted logging is noise. Each probe maps to one hypothesis; each debug log carries a unique `[DEBUG-xxxx]` tag so cleanup is a single grep.
- ❌ **Ship a regression test at a shallow seam.** A test that can't replicate the chain that triggered the bug gives false confidence. No correct seam is itself a finding — document it.
- ❌ **Declare done with instrumentation still in the tree.** Phase 6 is not optional: tagged logs removed, prototypes deleted, original repro confirmed dead.
- ❌ **Debug performance with logs.** For regressions, measure first (baseline + profiler + bisect), fix second.

## Internals

The six phases, and why each exists:

1. **Build a feedback loop** — the load-bearing phase. Ten construction techniques (failing test → curl → CLI diff → headless browser → trace replay → throwaway harness → property/fuzz → bisection → differential → HITL script). Completion = one command, already run, that is red-capable + deterministic + fast + agent-runnable.
2. **Reproduce + minimise** — confirm the loop reproduces the *user's* symptom, then shrink to the smallest scenario that still goes red. Every remaining element must be load-bearing.
3. **Hypothesise** — 3–5 ranked, falsifiable hypotheses *before* testing any. Each states a prediction ("if X, then changing Y makes it vanish"). Shown to the user to exploit domain knowledge.
4. **Instrument** — one variable at a time, mapped to a specific prediction. Debugger/REPL > targeted logs > never "log everything." Tag every log. Perf gets a measurement branch, not logs.
5. **Fix + regression test** — test before fix *if a correct seam exists*; absence of a seam is a finding to flag.
6. **Cleanup + post-mortem** — checklist: original repro dead, test passing (or seam-absence documented), all `[DEBUG-...]` removed, prototypes deleted, correct hypothesis recorded in the commit. Then: "what would have prevented this?" → optional hand-off to architecture.

## FAQ

**Q: Why can't I just look at the code and spot the bug?**
A: Sometimes you can — for easy bugs, skip the ceremony. This skill is for *hard* bugs, where the code that looks wrong isn't, and the only reliable path is a signal that goes red on the actual failure.

**Q: What if I genuinely can't build a loop?**
A: Stop and say so explicitly. List what you tried and ask for environment access, a captured artifact, or permission to add temporary instrumentation. Do not proceed to hypothesise without a loop.

**Q: The bug is non-deterministic. Do I need a clean repro?**
A: No — you need a *high enough* reproduction rate to debug against. 50% is workable; 1% is not. Loop, parallelise, add stress, narrow timing windows until it's debuggable.

**Q: There's no good place to put a regression test. Is that a failure?**
A: It's a finding. It means the architecture is preventing the bug from being locked down. Document it and, in Phase 6, consider handing off to `/codebase-improve-architecture`.

**Q: When do I recommend an architectural change?**
A: After the fix is in, not before — you know more once the bug is understood. If the root cause was a missing seam, tangled callers, or hidden coupling, hand the specifics to the architecture skill.

## Related skills

- **[codebase-improve-architecture](../codebase-improve-architecture/)** — the Phase 6 hand-off when a bug's root cause is architectural (no test seam, tangled callers, hidden coupling).
- **[codebase-explain](../codebase-explain/)** — build a mental model of an unfamiliar module before diving into a bug in it.
- **[issue-triage](../issue-triage/)** — for the earlier step of ranking *candidate* root causes from a ticket, before you commit to reproducing one.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (the six-phase diagnosis loop)
