# CI/CD Secrets

Comprehensive secrets extraction methodology targeting CI/CD environments across all major platforms. Covers environment variable extraction from build contexts, exploitation of vault and secrets-manager misconfigurations (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager), runner and agent token abuse for lateral movement, OIDC federation attacks exploiting trust relationships between CI/CD providers and cloud platforms, build log leakage analysis for inadvertently exposed credentials, cache poisoning techniques for credential exfiltration, platform-specific credential store exploitation (GitHub Actions secrets, GitLab CI variables, Jenkins credential providers), service connection and service account abuse in Azure DevOps and GCP, and Docker registry credential theft from build environments. Maps to MITRE ATT&CK T1552 (Unsecured Credentials) and its sub-techniques. Each section provides enumeration procedures, extraction techniques, and post-exploitation pivoting guidance for using recovered secrets to expand access. Use when performing authorized red-team, pentest, or research work involving cicd secrets.

## When to use

Use when performing authorized red-team, pentest, or research work involving cicd secrets.

Vendored from [risadams/Claude-Red](https://github.com/risadams/Claude-Red) (MIT — see `LICENSE`), originally published as [SnailSploit/claude-red](https://github.com/SnailSploit/claude-red).
