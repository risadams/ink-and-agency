# Anti Forensics

Anti-forensics and evidence destruction techniques for red team operators conducting authorized engagements. Covers log clearing on Windows (wevtutil, Clear-EventLog, ETW provider patching) and Linux (journal truncation, utmp/wtmp binary editing, syslog manipulation), timestamp manipulation via Timestomp and SetMACE to defeat timeline analysis, filesystem-level anti-forensics including NTFS Alternate Data Streams for payload hiding and secure deletion with sdelete/shred, memory artifact removal to counter live forensics, disk artifact manipulation targeting MFT entries and USN journal records, network forensics evasion through encrypted C2 channels and DNS-over-HTTPS tunneling, and anti-VM/sandbox detection to avoid dynamic analysis environments. Tools: Timestomp, wevtutil, sdelete, shred, MimiPenguin, Invoke-Phant0m. Aligns to MITRE ATT&CK T1070 (Indicator Removal), T1027 (Obfuscated Files or Information), T1497 (Virtualization/Sandbox Evasion). Each technique includes the forensic artifact it targets, the destruction or manipulation method, and the defender perspective so operators understand detection gaps they must account for. Use when performing authorized red-team, pentest, or research work involving anti forensics.

## When to use

Use when performing authorized red-team, pentest, or research work involving anti forensics.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
