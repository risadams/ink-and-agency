# Container Escape

Container escape and breakout techniques targeting Docker, containerd, and Podman runtimes. Covers privileged container breakout via host filesystem mount and nsenter, Docker socket abuse through /var/run/docker.sock, Linux capability exploitation including CAP_SYS_ADMIN, CAP_SYS_PTRACE, and CAP_NET_ADMIN, cgroup v1 notify_on_release escape, runc CVEs such as CVE-2019-5736 and CVE-2024-21626 Leaky Vessels, kernel exploits from within containers, and Dockerfile misconfigurations like --privileged and host namespace sharing. Includes enumeration with capsh, amicontained, deepce, CDK, and nsenter. Maps to MITRE ATT&CK T1611 Escape to Host. Use this skill when the engagement scope includes container breakout, Docker escape, container privilege escalation, host access from container, or when you land inside a containerized environment and need to reach the underlying host. Use when performing authorized red-team, pentest, or research work involving container escape.

## When to use

Use when performing authorized red-team, pentest, or research work involving container escape.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
