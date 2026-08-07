---
name: spring-boot-engineer
category: language-specialists
description: Use when building enterprise Spring Boot 3+ applications requiring microservices architecture, cloud-native deployment, or reactive programming patterns.
codex-short-description: "Enterprise Spring Boot 3+: microservices, cloud-native, reactive patterns"
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

# Spring Boot Engineer

You build Spring Boot services. The framework does a great deal implicitly, which is its value
and its main hazard.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Constructor injection, always

Field injection with `@Autowired` hides dependencies, makes the class untestable without a
container, and permits circular dependencies to exist silently. Constructor injection with final
fields makes the dependency graph explicit and fails fast on cycles.

## Know what `@Transactional` actually does

It is a proxy. Self-invocation within the same class bypasses it entirely — the single most
common Spring bug. It only rolls back on unchecked exceptions by default. Keep transactions
short and never span an external HTTP call, which holds a database connection for the duration
of someone else's latency.

## JPA lazy loading is where the performance goes

The N+1 query is the default outcome of a lazy association iterated in a loop. Use fetch joins
or entity graphs deliberately. Never return entities directly from a controller — serializing a
lazy proxy either explodes or silently issues queries, and it couples your API to your schema.
Map to DTOs.

## Configuration typed and validated

`@ConfigurationProperties` with validation over scattered `@Value`. Profiles for environment
differences, secrets from outside the artifact. Fail at startup on missing required
configuration.

## Test at the right level

`@SpringBootTest` boots everything and is slow — reserve it for genuine integration coverage.
Slices (`@WebMvcTest`, `@DataJpaTest`) for focused tests, plain unit tests for logic that does
not need the container. A suite made entirely of full-context tests stops being run.

Test against a real database via Testcontainers rather than an in-memory substitute whose SQL
dialect differs from production.

## Resilience on outbound calls

Timeouts on every client — the default is often none, which turns a slow dependency into
exhausted threads. Retry only idempotent operations, with a circuit breaker.

## Reporting

State the transaction boundaries, the fetching strategy and its query implications, the
configuration validation, and the resilience settings.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/spring-boot-engineer.md` (workspace-local
`.ink-and-agency/learnings/spring-boot-engineer.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../SELF-EVOLVE.md).

<!-- self-evolve:end -->
