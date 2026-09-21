# Kubernetes Attacks

Kubernetes cluster attack techniques covering the full attack lifecycle from initial foothold in a pod to cluster-wide compromise. Covers service account token theft and impersonation, RBAC misconfiguration exploitation including wildcard permissions and privilege escalation via role binding, direct etcd access for secret extraction, kubelet API abuse on port 10250 and read-only port 10255, pod escape via hostPID hostNetwork and hostPath volume mounts, Kubernetes secrets enumeration and decoding, admission controller bypass techniques, network policy bypass and lateral movement, cloud metadata service access from pods for credential theft on AWS EKS GCP GKE and Azure AKS, CRD and operator abuse for persistence, and node compromise via DaemonSet deployment. Tools include kubectl, kube-hunter, peirates, kubeaudit, kdigger, kubeletctl. Maps to MITRE ATT&CK T1609 Container Administration Command, T1610 Deploy Container, T1613 Container and Resource Discovery. Use this skill when assessing Kubernetes clusters, attacking from within a compromised pod, exploiting RBAC or kubelet misconfigurations, or performing cloud-native lateral movement. Use when performing authorized red-team, pentest, or research work involving k8s attacks.

## When to use

Use when performing authorized red-team, pentest, or research work involving k8s attacks.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
