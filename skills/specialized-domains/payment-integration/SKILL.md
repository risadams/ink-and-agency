---
name: payment-integration
description: Use when implementing payment systems, integrating payment gateways, or handling financial transactions that require PCI compliance, fraud prevention, and secure transaction processing.
codex-short-description: "Integrate payment gateways with PCI compliance and fraud prevention"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
loop-eligible: false
compatibility: claude-code codex opencode
---

# Payment Integration

You connect an application to systems that move money, where the interesting cases are the ones
that fail halfway.

## Card data should never reach your servers

Tokenize at the client with the processor's hosted fields or SDK, and store the token. The
moment raw card numbers touch your infrastructure, that infrastructure is in PCI scope —
logging, backups, error reports, and everything downstream of them. The cheapest compliance
posture is the one where you have nothing to protect. Verify this by checking what actually gets
logged, since the leak is almost always an error handler or a request dump rather than the
intended path.

## Authorization and capture are separate decisions

Authorize to reserve funds, capture when you have delivered or shipped. Conflating them means
refunding rather than voiding when the order fails, which costs fees and shows on the customer's
statement. Know the authorization expiry window — a hold that lapses before capture leaves you
with an order you cannot collect on.

## A timeout is not a decline

If the gateway does not answer, the transaction may still have succeeded. Never retry blindly
into that ambiguity: send an idempotency key with every attempt so a retry is safe, and resolve
unknowns by querying the processor for the transaction's real state. Treating a timeout as
failure is how customers get charged for orders that were never created.

## Webhooks are the real source of truth, and they are hostile input

Most state changes — settlement, chargeback, dispute, subscription renewal, delayed decline —
arrive asynchronously. Verify the signature on every webhook, handle duplicates and
out-of-order delivery idempotently, return 200 quickly and process off the request path, and
reconcile against the processor's API rather than trusting the payload alone. A webhook endpoint
that trusts its body is an endpoint anyone can use to mark orders paid.

## Fraud controls trade false positives for losses, and that is a business decision

Present the trade rather than picking silently: a rule tuned to catch more fraud declines more
legitimate customers. Use the signals the processor already provides (AVS, CVV, 3-D Secure,
network risk scores) before building anything bespoke, and route liability deliberately — 3-D
Secure shifts chargeback liability, which is frequently worth more than the conversion it costs.

## Money bugs are found by reconciliation, not by tests

Reconcile your records against processor settlement daily, including fees, refunds, and
chargebacks, and make unmatched items someone's job. Amounts are integer minor units with an
explicit currency, never floats. Currency conversion happens at a recorded rate, at a recorded
time.

## Reporting

State where card data flows and what is in PCI scope, the auth/capture model, the idempotency
and timeout-resolution strategy, which webhooks are consumed and how they are verified, the
fraud controls and the false-positive trade they imply, and how reconciliation runs.

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/payment-integration.md` (workspace-local
`.ink-and-agency/learnings/payment-integration.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
