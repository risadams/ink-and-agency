# Lateral Movement

Comprehensive lateral movement tradecraft for authorized red team engagements covering credential-based movement (pass-the-hash, pass-the-ticket, overpass-the-hash), NTLM relay attacks (ntlmrelayx with PetitPotam, DFSCoerce, PrinterBug coercion), remote execution protocols (WMI, WinRM, DCOM, PsExec and alternatives), RDP session hijacking, and network pivoting through tunneling tools (chisel, ligolo-ng, SSH tunnels, SOCKS proxies). Provides operator-ready command sequences for mimikatz, crackmapexec/netexec, impacket suite, and evil-winrm with emphasis on OPSEC considerations, SMB signing bypass, and detection evasion. Maps to MITRE ATT&CK T1021 (Remote Services), T1550 (Use Alternate Authentication Material), and sub-techniques. Includes defender-perspective detection guidance for blue team awareness and a rapid engagement cheatsheet for common lateral movement scenarios encountered during internal penetration tests and assumed-breach exercises. Use when performing authorized red-team, pentest, or research work involving lateral movement.

## When to use

Use when performing authorized red-team, pentest, or research work involving lateral movement.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
