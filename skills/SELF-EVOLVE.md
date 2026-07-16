# Self-Evolve Loop

Every skill in this pack learns across invocations. The **Quality Loop**
([CLAUDE.md](CLAUDE.md)) evaluates output *before returning it*; the Self-Evolve Loop
is its cross-invocation sibling: at the end of each run the skill evaluates how the
run actually went, persists what it learned, and routes ideas for improving the skill
itself. Each `SKILL.md` carries a short `## Self-Evolve Loop` footer pointing here —
the footer is machine-maintained by `scripts/add-self-evolve.ps1` (see
[Maintainer notes](#maintainer-notes)); this document is the contract it points to.

## The learnings journal

Learnings live in **one journal per skill**. Two locations exist, and they layer:

```text
~/.ink-and-agency/learnings/<skill-name>.md    # user-global — follows the user across projects
.ink-and-agency/learnings/<skill-name>.md      # workspace-local — at the current repo/workspace root
```

Why two: the home directory follows the user everywhere, but not every host lets a
skill write there — Codex's default `workspace-write` sandbox confines writes to the
current workspace. The plugin install location is never an option: both hosts run
skills from a read-only versioned cache.

- **Reading (step 0):** read whichever of the two exist; on conflict, workspace-local
  guidance wins (it is more specific).
- **Writing (step 3):** prefer the user-global journal. If the sandbox forbids
  writing outside the workspace, write to the workspace-local journal instead —
  don't fight the sandbox, and don't request escalation just to save a learning.
  When creating a workspace-local journal inside a git repo, suggest adding
  `.ink-and-agency/` to the repo's local ignore (`.git/info/exclude`) so it never
  pollutes the project.

Journals are **per skill, not per project**: skill names are globally unique in the
pack, and lessons usually transfer across projects. An entry that is
project-specific says so in its text.

Journal structure (create the file on first write):

```markdown
# Learnings: <skill-name>

## Standing guidance

<!-- distilled, always-apply lessons; promoted from recurring journal entries -->

- Prefer X over Y when Z — promoted 2026-07-16 from three entries.

## Suggested skill improvements

<!-- tier-3 routing target: proposed changes to the skill itself, not yet applied -->

- 2026-07-16 — The "…" step routinely confuses users; suggest rewording to "…".

## Journal

<!-- dated entries, newest first; only signal-bearing runs get one -->

- **2026-07-16** (project: acme-api) — Misfired: assumed pytest; project used
  unittest. Next time: check the test runner before writing examples.
```

**Pruning:** keep the Journal at roughly 40 entries. When it grows past that, distill
recurring lessons into Standing guidance and delete the entries they came from, then
drop the oldest of what remains. The journal steers future runs; it must never bloat
the context it is trying to improve.

## The loop

**Step 0 — at invocation start.** If the journal exists, read it. Apply Standing
guidance always; apply journal entries that match the current situation. This step is
silent — mention a learning only when it visibly changes what you do.

**Step 1 — at invocation end: silent self-evaluation.** Judge whether the run served
its purpose, from observable signals: did the user correct, rephrase, or abandon the
output? Did they build on it or thank you? Did any step of the skill's own workflow
misfire (wrong assumption, missing input, awkward ordering)? Where the skill defines
Quality Loop criteria, reuse them here.

**Step 2 — optional user feedback.** Prompting the user is **always optional and
never blocking**. Ask at most **one** short question, and only when *all* of these
hold: the session is interactive, the self-evaluation is genuinely uncertain or the
run had visible friction, and asking wouldn't interrupt something the user moved on
to. A good shape: "Before I close out — did this land the way you needed, or should
the skill do something differently next time?" If the user declines, ignores it, or
the conditions don't hold, skip — silence costs nothing.

**Step 3 — capture.** Append a journal entry **only when there is signal**: something
misfired, the user gave feedback, or a pattern emerged worth keeping. The test:
*would this change how the next invocation behaves?* Routine clean runs get no entry.

**Step 4 — route skill improvements.** When a learning implies the **skill's own
definition** should change (not just this user's context), route it by tier:

1. **Canonical checkout is right here** — the working directory is inside the pack's
   source repo (its git remote contains `risadams/ink-and-agency`, or its
   `.claude-plugin/plugin.json` has `"name": "ink-and-agency"`). Propose the concrete
   edit, get the user's confirmation, then edit the canonical `SKILL.md` directly.
   Leave the change uncommitted for review, and run (or remind the user to run)
   `pwsh ./scripts/convert-agents-to-codex.ps1` so generated artifacts stay in sync.
2. **Canonical checkout is configured** — `~/.ink-and-agency/config.md` names a
   `canonical-repo:` path that exists on this machine. Same rules as tier 1, applied
   to that checkout.
3. **No canonical checkout** — record the suggestion under
   `## Suggested skill improvements` in the journal and surface it to the user in
   your closing message. With the user's consent, offer to file it as an issue on
   `github.com/risadams/ink-and-agency`.

**Never edit the running copy of a skill inside a plugin cache or bundle** (for
example `~/.claude/plugins/cache/...`). A cache is not a source: edits there are
silently lost on the next update and diverge from the canonical repo. If the only
copy you can see is a cache, you are in tier 2 or 3.

`~/.ink-and-agency/config.md` format:

```markdown
# ink-and-agency config

canonical-repo: A:/ink-and-agency
```

When you find yourself in tier 1 and no config file exists, offer (once) to record
the checkout's path there so tier 2 works from other projects.

## Skip conditions

Skip the user prompt (step 2) **entirely** — and capture (step 3) only on strong
signal — when any of these hold:

- The invocation runs under `/loop` or any recurring/scheduled execution.
- You are a subagent or otherwise running AFK — no human is present to answer, and a
  self-evolve loop that answers its own feedback question has broken the contract.
- The session is non-interactive.

Skip the whole loop for trivial invocations — a one-line answer with no workflow has
nothing to evolve.

> **Host portability:** every operation in this contract is plain file reads/writes
> plus "ask the user", so it runs on any host — map tool names by intent per
> [PORTABILITY.md](PORTABILITY.md). The journal deliberately does **not** use
> host-specific facilities: Claude Code auto-memory and `${CLAUDE_PLUGIN_DATA}` have
> no Codex analog reachable from skill prose, and Codex's `~/.codex/memories/` is
> host-managed — none of them follow the user across hosts. Neither host fires a
> portable end-of-invocation event, which is why this loop rides as prompt-level
> instructions in each `SKILL.md` rather than as hooks. A host-specific note in a
> skill *may* additionally mirror a pointer into host memory, but the journal is the
> source of truth.

## Maintainer notes

- The per-skill footer lives between `<!-- self-evolve:start -->` and
  `<!-- self-evolve:end -->` markers at the end of each `SKILL.md`. It is
  **script-maintained**: edit the template in `scripts/add-self-evolve.ps1` and
  re-run it (idempotent — it syncs every footer to the current template). Never
  hand-edit a footer.
- A skill opts out with `self-evolve: false` in its frontmatter (for skills where
  end-of-run evaluation is nonsense — pure lookups, session-ending compactions). The
  sweep script then strips/withholds its footer.
- `scripts/lint-skills.ps1` enforces the invariant: every `SKILL.md` carries the
  footer unless it opts out.
