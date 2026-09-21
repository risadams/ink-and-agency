# Security Audit

Source-first security review: finds vulnerabilities that cross a real trust boundary and reports source evidence, safe reproduction, priority, and the smallest effective fix.

## When to use

Security questions, focused reviews, vulnerability research, or a full codebase audit / pen test with report artifacts. Guidance mode is the default; the six-phase full audit runs only on an explicit request.

## What ships

- `SKILL.md` — operating modes, execution safety, planning, workflow
- `RECONNAISSANCE.md`, `HUNTING.md`, `VALIDATION-AND-REPORTING.md`, `ATTACK-CLASSES.md` — the phase guides
- Domain companions: web/auth, client-side, protocols/RPC, cloud, AI/LLM, memory safety, supply chain, data isolation, desktop/mobile, resource exhaustion
- `report-schema.json` plus `validate-findings.cjs` and `validate-coverage-ledger.cjs` (Node.js) with their tests

Vendored from [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) under the MIT license (`LICENSE`).
