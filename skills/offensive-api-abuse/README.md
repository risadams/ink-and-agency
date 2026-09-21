# API Abuse

Advanced API exploitation methodology focused on business logic abuse and sophisticated attack patterns that bypass traditional security controls. Covers business logic bypass through API call chaining and workflow manipulation. Addresses GraphQL-specific attacks including batching for credential brute-force, query depth exploitation, and introspection abuse. Includes pagination exploitation for data exfiltration, webhook hijacking for SSRF and data interception, and resource exhaustion through algorithmic complexity attacks. Covers race conditions in API transactions using parallel request techniques. Provides comprehensive JWT manipulation including algorithm confusion, kid injection, jku/x5u abuse, and claim tampering. Details API key leakage detection across source repositories, client-side code, and error messages. Covers undocumented endpoint discovery through predictable naming, debug routes, and source map analysis. Tooling includes Arjun, ParamSpider, jwt_tool, and GraphQL Voyager. Designed for authorized penetration testers targeting business logic layers that automated scanners miss. Use when performing authorized red-team, pentest, or research work involving api abuse.

## When to use

Use when performing authorized red-team, pentest, or research work involving api abuse.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
