# Data Exfiltration

Dense methodology covering DNS exfiltration (dnscat2, iodine, dns2tcp), HTTPS tunneling (domain fronting, CDN abuse, legitimate service channels), ICMP tunneling (icmpsh, ptunnel-ng), cloud storage dead drops (S3 presigned URLs, Azure Blob SAS tokens, GCS signed URLs), email-based exfil (SMTP, EWS, draft method), steganography (image, audio, document metadata), encoding/encryption (base64 chunking, XOR, AES), covert channels (custom protocol tunneling, HTTP header encoding, timing channels), and data staging (compression, splitting, encryption). Tools: dnscat2, iodine, dns2tcp, PacketWhisper, chisel, stunnel, icmpsh, ptunnel-ng, steghide, zsteg, OpenStego. MITRE ATT&CK: T1048 (Exfiltration Over Alternative Protocol), T1041 (Exfiltration Over C2 Channel), T1567 (Exfiltration Over Web Service), T1029 (Scheduled Transfer), T1030 (Data Transfer Size Limits), T1132 (Data Encoding), T1001 (Data Obfuscation). Use when planning or executing data exfiltration during authorized red team engagements or post-exploitation.

## When to use

Use when planning or executing data exfiltration during authorized red team engagements or post-exploitation.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
