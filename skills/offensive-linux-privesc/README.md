# Linux Privesc

Comprehensive Linux privilege escalation methodology for offensive security engagements. Covers the full attack surface from a low-privilege shell to root: SUID/SGID binary abuse via GTFOBins, Linux capabilities exploitation (cap_setuid, cap_dac_override, cap_dac_read_search), sudo misconfigurations including NOPASSWD rules and Baron Samedit (CVE-2021-3156), cron job abuse through writable scripts, PATH hijacking, and wildcard injection with tar/rsync/chown. Includes writable /etc/passwd attacks, NFS no_root_squash exploitation, kernel exploits (DirtyPipe CVE-2022-0847, DirtyCow CVE-2016-5195, PwnKit CVE-2021-4034), Docker group container escapes, LD_PRELOAD and LD_LIBRARY_PATH hijacking for shared library injection, systemd service misconfigurations, and sensitive file enumeration for credential harvesting. Integrates automated enumeration with LinPEAS, linux-exploit-suggester, pspy for process monitoring, and GTFOBins for binary exploitation. Each technique includes detection signatures and defender-side visibility to support purple team operations. Maps to MITRE ATT&CK T1548 (Abuse Elevation Control Mechanism) and related sub-techniques. Designed for authorized penetration testing, red team engagements, and CTF competitions where you hold a low-privilege shell and need to escalate to root. Use when performing authorized red-team, pentest, or research work involving linux privesc.

## When to use

Use when performing authorized red-team, pentest, or research work involving linux privesc.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
