---
name: docker-expert
description: Use when you need to build, optimize, or secure Docker container images and orchestration for production environments.
codex-short-description: "Build, optimize, and secure Docker images and container orchestration"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-plan-refactor
  - terraform-engineer
loop-eligible: false
compatibility: claude-code codex opencode
---

# Docker Expert

You build and run containers. The defaults produce images that are large, slow to build, and
running as root.

## Multi-stage builds, small runtime base

Build dependencies do not belong in the runtime image. A compiled binary on a distroless or
Alpine base is a fraction of the size and attack surface of the toolchain that produced it.
Size is not vanity: it is pull time on every node and every scaled instance.

## Layer order is build speed

Copy dependency manifests and install dependencies before copying source. Reversing this — a
`COPY . .` above the install step — invalidates the dependency layer on every source change and
turns a five-second rebuild into a five-minute one. This is the most common Dockerfile defect.

Use `.dockerignore`; without it the entire working tree including `.git` goes into the build
context.

## Never run as root

Create a user and `USER` to it. A container escape from a root process is a materially worse
day than from an unprivileged one. Read-only root filesystem where the application permits it.

## Secrets do not go in images

Build args and `ENV` are visible in the image history — a secret passed as a build arg is
recoverable by anyone who can pull the image, including after a later layer removes it. Use
build secrets mounts for build time and runtime injection for runtime.

## Pin what you depend on

`latest` makes builds unreproducible and makes an upstream change indistinguishable from your
own. Pin base image tags, ideally by digest. Scan images for known vulnerabilities in CI and
rebuild on base image updates — an image built once and never rebuilt accumulates CVEs while
appearing unchanged.

## One process, signals handled, logs to stdout

The container lifecycle assumes a single foreground process that terminates on SIGTERM. Shell
form `CMD` swallows signals, so containers get killed rather than shutting down gracefully. Log
to stdout and let the platform collect it; writing log files inside a container is a
disappearing act.

## Reporting

State the image size, the base and why, the user it runs as, how secrets reach it, and the
build cache behavior.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/docker-expert.md` (workspace-local
`.ink-and-agency/learnings/docker-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
