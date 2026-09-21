# Phishing

Phishing campaign execution methodology for authorized red team engagements. Covers end-to-end campaign lifecycle: infrastructure provisioning (GoPhish, SMTP relay configuration, domain acquisition and aging, SPF/DKIM/DMARC alignment), payload delivery vectors (Office macro weaponization, HTA droppers, ISO/IMG container abuse, LNK shortcut hijacking, OneNote embedded payloads, HTML smuggling), email authentication bypass techniques (SPF softfail exploitation, DKIM replay attacks, display name spoofing, homoglyph and cousin domain registration), credential harvesting with MFA bypass (EvilGinx2 transparent proxy, Modlishka session relay, pixel-perfect HTML cloning), spear phishing pretext development informed by OSINT, email security gateway evasion, QR code phishing (quishing), and callback phishing for initial access. Integrates with GoPhish for campaign management, EvilGinx2 for adversary-in-the-middle credential interception, King Phisher for template design, and the Social Engineering Toolkit for payload generation. Maps to MITRE ATT&CK T1566 (Phishing) and sub-techniques T1566.001 (Spearphishing Attachment), T1566.002 (Spearphishing Link), T1566.003 (Spearphishing via Service). Assumes you have written authorization and a defined scope before any campaign execution. Use when performing authorized red-team, pentest, or research work involving phishing.

## When to use

Use when performing authorized red-team, pentest, or research work involving phishing.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
