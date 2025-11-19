# Security Requirements – Multi-Cloud Container Platform

This document captures **cross-cloud security requirements** for running containerized workloads on AWS, Azure, and GCP. It is intentionally platform-agnostic so it can be mapped to native services in each provider.

---

## 1. Identity & Access Management

1.1 **No long-lived static credentials** are allowed in code, images, or configuration.  
1.2 **Workload identities** (IAM roles, managed identities, Workload Identity) must be used for container-to-API access.  
1.3 **Least privilege** policies must be applied for:
- Pulling images from registries  
- Accessing secrets  
- Writing logs / metrics  

1.4 **Human access** to cloud consoles or shells must be:
- Federated from an enterprise IdP (where available)  
- Protected with MFA  
- Logged centrally for audit.

---

## 2. Network Security

2.1 All container runtimes must reside in **private subnets / VNets / VPCs**; direct public exposure is only via controlled entry points (ALB/NLB, Application Gateway, GCLB, etc.).  

2.2 **Ingress and egress** must be restricted using:
- Security groups / NSGs / firewall rules  
- Kubernetes Network Policies (for AKS/EKS/GKE where used)  

2.3 Management access (SSH, RDP, kubectl) must:
- Use bastion / jumpbox / SSM Session Manager where possible  
- Be limited to trusted IP ranges or VPN endpoints.

---

## 3. Data Protection

3.1 All container images and persistent volumes must be **encrypted at rest** with customer-managed or provider-managed keys:
- AWS KMS, Azure Key Vault keys, or Google Cloud KMS.  

3.2 All communication between services and to registries must use **TLS**.  

3.3 Secrets (API keys, passwords, tokens) must **never** be stored:
- In images
- In plaintext configuration
- In source control  

They must be stored in **Secrets Manager, Key Vault, or Secret Manager** and accessed via IAM.

---

## 4. Workload Hardening

4.1 Containers must **not** run as root unless there is a justified and documented exception.  

4.2 Root file systems must be **read-only** where supported; writable volumes should be explicit and minimized.  

4.3 Privileged containers, hostPath mounts, and unsafe capabilities must be blocked using:
- Pod / workload security controls (PSPs replacement, OPA/Gatekeeper, etc.)  
- Admission policies or equivalent mechanisms.

4.4 Base images should be **minimal, vendor-supported, and regularly patched**.  

4.5 Only images from approved registries (ECR, ACR, Artifact Registry) are allowed to run in clusters.

---

## 5. Vulnerability Management

5.1 All images must be **scanned for vulnerabilities** before deployment using:
- Native registry scanning and/or tools like Trivy.  

5.2 Builds must **fail or be blocked** when:
- Critical vulnerabilities exist with no documented risk acceptance, or  
- High vulnerabilities exceed agreed thresholds.

5.3 Regular **re-scans** must occur for images in registries to detect newly disclosed CVEs.

---

## 6. Logging, Monitoring & Detection

6.1 Container logs, platform logs, and audit logs must be **centralized**:
- AWS: CloudWatch + CloudTrail  
- Azure: Log Analytics + Activity Logs  
- GCP: Cloud Logging + Audit Logs  

6.2 Logs must be **retained** for an agreed period to meet audit and incident response needs (e.g., 90–365 days).  

6.3 Security-relevant events (denied auth, policy violations, anomalous activity) must trigger **alerts** to security operations or an on-call channel.

---

## 7. Compliance & Governance

7.1 The architecture should be **mappable** to frameworks such as:
- NIST 800-53
- ISO 27001
- CIS Benchmarks (Docker/Kubernetes/Cloud)  

7.2 All Terraform and Kubernetes manifests must be stored in **source control** with code review.  

7.3 Changes to security-sensitive resources (IAM, network, registries) require **peer review** and must be auditable.

---

## 8. Business & Operational Requirements

8.1 The platform must support **segregation of environments** (dev, test, prod) with separate cloud accounts/subscriptions/projects where feasible.  

8.2 Security controls must be designed to **enable delivery**, not block it:
- Automate checks in CI/CD
- Provide clear feedback to developers  

8.3 A tested **rollback path** must exist for infrastructure and application updates.

