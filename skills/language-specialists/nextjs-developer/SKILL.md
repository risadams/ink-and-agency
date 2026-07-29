---
name: nextjs-developer
description: >
  Use when building production Next.js 14+ applications — App Router, server components,
  server actions, Core Web Vitals, and SEO-optimized deployment.
codex-short-description: "Next.js 14+: App Router, server components and actions, Core Web Vitals, SEO"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-explain
  - codebase-plan-refactor
loop-eligible: false
compatibility: claude-code codex opencode
---

# Next.js Developer

You build Next.js applications where the server/client boundary is the central design decision.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Know which side every component runs on

Server Components are the default in the App Router and cannot use state, effects, or browser
APIs. `'use client'` marks a boundary, and everything imported below it joins the client
bundle — a single misplaced directive high in the tree can pull most of the application to the
client. Push client boundaries as deep as possible.

## Never leak secrets across the boundary

Server Components can read environment variables and databases directly. Anything passed as a
prop to a Client Component is serialized into the HTML and is visible to the user. This is the
mistake with the worst consequences in this framework — check what crosses the boundary.

## Caching is the thing that will confuse you

Next.js caches at several layers, and defaults have changed across versions. Be explicit about
revalidation rather than relying on defaults, and know which layer is serving a stale value
before debugging the data source. "It works in dev but shows old data in production" is almost
always this.

## Server Actions are public endpoints

They look like function calls and are HTTP handlers. Authenticate and authorize inside every
one, and validate the arguments — the client controls them entirely, regardless of what the
calling component does.

## Fetch where the data is needed

Fetch in the Server Component that renders it rather than threading data down. Parallelize
independent requests instead of awaiting sequentially — sequential awaits in a server component
are a common and invisible latency cost. Suspense boundaries so a slow section does not block
the page.

## Images, fonts, and Core Web Vitals

`next/image` with dimensions to prevent layout shift, `next/font` to avoid the flash, and
explicit `dynamic` imports for heavy client-side libraries. These are the defaults that decide
the metrics.

## Reporting

State which components are server versus client and why, the caching and revalidation strategy,
and how Server Actions are secured.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/nextjs-developer.md` (workspace-local
`.ink-and-agency/learnings/nextjs-developer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
