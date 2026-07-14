# Work Plan

Plan a chunk of work too big for one agent session — and too foggy to see the route through — as a **shared map of decision tickets** on your issue tracker. The skill (internally "Work-plan") charts the map, then works its tickets one at a time, each resolving a *decision* rather than executing a slice of a build, until the way from here to the destination is clear. It's wayfinding, not charging at the goal: the output is a route made of resolved decisions, not a finished deliverable.

## Why this exists

Some efforts are too large to hold in a single context window and too uncertain to plan top-to-bottom up front — the destination is visible but the *way there* is wrapped in fog. Traditional planning fails here twice: it either over-specifies a route through unknowns that dissolve on contact, or it dives into building before the key decisions are made. Work-plan handles the fog explicitly. It records what's decided, what's a sharp-enough question to ticket, what's still too dim to phrase (the "fog of war"), and what's been ruled out of scope — all as a live map on the tracker that multiple sessions and humans can read and advance concurrently. Each session clears a little more fog, one decision at a time, until nothing's left to decide before someone goes and does the thing.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "help me plan this big piece of work"
  - "this is too big for one session — chart it"
  - "work-plan this" / "map out this effort"
  - "let's work through the map" (to resolve the next ticket)
- Running the slash command: `/work-plan`

> **Note:** This skill sets `disable-model-invocation: true` — it runs only when explicitly invoked. Charting a map is a deliberate, multi-session commitment, not something to trigger mid-task.

## What it does

The skill has two modes. **Chart the map** takes a loose idea and produces the map: it names the **destination** (via `/grilling` and `/domain-modeling`), then grills breadth-first to surface open decisions, creates a single `workplan:map` issue with child **decision tickets**, wires blocking edges using the tracker's native dependency relationships, sketches what it can't yet specify into a **Not yet specified** (fog) section, and fires `/research` subagents for any research tickets — then stops, because charting resolves nothing. **Work through the map** loads the low-resolution map, picks the next frontier ticket (or one the user names), *claims* it by assignment, resolves it (research / prototype / grilling / task, per the ticket's type), records the answer as a resolution comment, closes the issue, appends a one-line gist to **Decisions so far**, and graduates any fog the answer has now made specifiable into fresh tickets. The rule that keeps it honest: **one ticket per session** (research tickets excepted), and refer to everything by its **name**, never a bare id.

### Inputs

- **A loose idea** (chart mode) — the effort to plan. Vague is expected; sharpening it into a destination is the first act.
- **A map reference** (work mode) — the `workplan:map` issue URL or number. A specific ticket is optional; without one, the skill picks the next frontier decision.
- **An issue tracker** — provided to the session. If none, it defaults to a local-markdown tracker.

### Outputs

- **A `workplan:map` issue** — the canonical artifact: Destination, Notes, Decisions-so-far (index), Not yet specified (fog), Out of scope.
- **Child decision tickets** — each a sharp question sized to ~one 100K-token session, labelled by type (`research` / `prototype` / `grilling` / `task`), wired with native blocking edges so the frontier renders visually in the tracker.
- **Resolution comments + a growing Decisions-so-far index** — the route actually walked, each decision living in exactly one place (its ticket) and gisted-plus-linked from the map.

### External systems used

- **An issue tracker with native blocking** — GitHub, GitLab, Jira, or the local-markdown fallback. Blocking edges are essential: they render the frontier in the tracker's own UI.
- **[grill-me](../../research-analysis/grill-me/)** (`/grilling`) and `/domain-modeling` — to name the destination and resolve grilling-type tickets, one question at a time.
- **[research](../../meta-orchestration/research/)** (`/research`) — background subagents that resolve research tickets in parallel.
- **`/prototype`** — to build cheap, concrete artifacts for prototype-type tickets.

## How to use it

Charting, then working — usually across separate sessions:

```text
You: work-plan this — we want to move off the legacy events table onto
     an event-sourced model, but I can't see the whole path.

Skill: [chart mode]
       Step 1 — naming the destination via /grilling + /domain-modeling...
       Destination: "A migration plan + locked schema decision for the
       event-sourced model, ready to hand to a build session."

       Step 2 — breadth-first grill surfaces the open decisions.
       Created map "Event-sourcing migration" (#128) with tickets:
       - "Choose event store: append-only table vs Kafka" (grilling)
       - "How does replay interact with existing projections?" (research)
       - "Snapshot cadence: what's the read-latency budget?" (grilling, blocked)
       Fog (Not yet specified): backfill strategy, dual-write cutover.
       Fired the /research subagent on the replay question. Charting done —
       come back to work a ticket.

--- next session ---

You: let's work the map, #128

Skill: [work mode] Loaded the map. First frontier ticket:
       "Choose event store: append-only table vs Kafka". Claiming it
       (assigned to you). Resolving via /grilling...
       → Decision: append-only table — Kafka's ops cost isn't justified
         at current volume. Recorded, closed, added to Decisions so far.
       Graduated "backfill strategy" out of the fog into a new ticket.
```

## Getting the most out of it

- **Name the destination before anything else.** The destination fixes the scope — it decides what's fog and what's out of scope. Rushing past it produces a map with no edges.
- **Trust the one-ticket-per-session rule.** Each decision is sized to a full session for a reason; cramming two means the second gets a thin, context-starved treatment. (Research tickets are the exception — fire them in parallel.)
- **Let the fog stay foggy.** Don't pre-slice "Not yet specified" into ticket-sized pieces. A fog patch may graduate into several tickets or none once the frontier reaches it — sharpening it early wastes the effort.
- **Use blocking edges, not prose dependencies.** Native blocking makes the frontier *visible* in the tracker UI, so a human sees what's takeable without opening the map. That visibility is half the point.
- **Refer to tickets by name.** A wall of `#42, #43, #44` is illegible; names read at a glance. The id rides inside the name's link — it never stands in for it.
- **Rule things out of scope deliberately.** When a ticket turns out to sit past the destination, close it and leave one line in Out of scope — don't resolve it on the route.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Execute the build.** Work-plan plans by default — tickets resolve *decisions*, and the map is done when nothing's left to decide. The urge to just do the work usually signals you've hit the edge of the map and it's time to hand off. (An effort can override this in its Notes.)
- ❌ **Resolve more than one ticket per session** (research excepted). It defeats the session-sizing that keeps each decision well-considered.
- ❌ **Chart what you can't yet see.** The map is deliberately incomplete. Beyond the live tickets is fog — write the dim view into Not yet specified, don't invent tickets for it.
- ❌ **Refer to tickets by bare id.** `#128` alone is illegible in narration and the map index. Always use the name (with the link inside it).
- ❌ **Restate a decision in the map body.** The map is an index, not a store. A decision lives in exactly one place — its ticket — and the map only gists it and links.
- ❌ **Let out-of-scope work sit in the fog.** Fog gathers only *toward* the destination. Ruled-out work goes in Out of scope and never graduates.
- ❌ **Skip the claim.** Assign the ticket to yourself *before* any work, so concurrent sessions don't collide on it.

## Internals

**The map** is a single `workplan:map` issue — the canonical artifact — with child decision tickets. Its body is a low-resolution index loaded once per session:

- **Destination** — what reaching the end looks like (spec, decision, or in-place change); fixes the scope.
- **Notes** — domain, skills every session should consult, standing preferences.
- **Decisions so far** — one line per closed ticket: gist + link (the index; detail lives in the ticket).
- **Not yet specified** — the fog of war: in-scope questions too dim to ticket yet; graduates as the frontier advances.
- **Out of scope** — work consciously ruled beyond the destination; closed, never graduates.

**Ticket types** — every ticket is HITL (worked *with* a human) or AFK (agent-driven):

| Type | Mode | Resolved by | Use when |
| :--- | :--- | :--- | :--- |
| `research` | AFK | `/research` subagent | knowledge outside the working dir is needed |
| `prototype` | HITL | `/prototype` skill | "how should it look/behave" is the question |
| `grilling` | HITL | `/grilling` + `/domain-modeling` | the default decision case |
| `task` | HITL or AFK | manual work | a decision is blocked until something is *done* (signup, provisioning, data move) |

**Frontier mechanics:** a ticket is *unblocked* when every ticket blocking it is closed; the *frontier* is the open, unblocked, unclaimed children — the edge of the known. Blocking uses the tracker's native dependency relationship so the frontier renders visually. The **fog-or-ticket test**: can you state the question precisely *now* (ticket it, even if blocked) or not yet (leave it in the fog)? — *not* whether you can answer it.

**Tracker-specific operations** (how the map, blocking, and frontier queries physically live) come from the provided tracker doc's "Wayfinding operations" section; absent a tracker, it defaults to local-markdown.

## FAQ

**Q: How is this different from just making a task list or a project plan?**
A: A task list assumes you already know the steps. Work-plan is for when you *don't* — the route is fogged, and the tickets resolve the decisions that reveal it. It plans decisions, not tasks.

**Q: Why decisions instead of build steps?**
A: Because the fog is made of unmade decisions, not unwritten code. Once every decision on the route is made, the build itself is straightforward and hands off to a build session. Work-plan stops at "nothing left to decide."

**Q: Why one ticket per session?**
A: Each ticket is sized to roughly one 100K-token session so it gets full context and a considered resolution. Two per session means the second is starved. Research tickets are excepted because they run in parallel background subagents.

**Q: What's the "fog of war"?**
A: The dim view of decisions you can tell are coming but can't yet phrase sharply, because they hang on still-open questions. It's written into Not yet specified and graduates into real tickets as resolutions clear the fog ahead.

**Q: What if charting surfaces no fog?**
A: Then the way is already clear and the effort is small enough for one session — you don't need a map. The skill stops and asks how you'd like to proceed.

**Q: Can multiple people work the same map at once?**
A: Yes — that's why tickets are *claimed* by assignment and blocking is native. Unblocked, unclaimed tickets can run in parallel across sessions editing the tracker concurrently.

**Q: What if a decision turns out to be beyond the destination?**
A: Rule it out of scope: close the ticket and leave one line in Out of scope. It doesn't go in Decisions so far (which records only the route actually walked) and never graduates unless the destination is later redrawn as a fresh effort.

## Related skills

- **[grill-me](../../research-analysis/grill-me/)** — the one-question-at-a-time discipline behind naming the destination and resolving grilling tickets.
- **[research](../../meta-orchestration/research/)** — background subagents that resolve `research`-type tickets in parallel.
- **[codebase-plan-refactor](../../codebase-build/codebase-plan-refactor/)** — when the effort is specifically an incremental refactor with known steps; produces an executable plan rather than a decision map.
- **[idea-generate](../../research-analysis/idea-generate/)** — when the effort is still upstream of a destination and you're generating the options themselves.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (charting and working the map, ticket types, fog of war)
