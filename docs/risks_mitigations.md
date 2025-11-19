# Risks and Mitigations – Multi-Cloud Container Security

This document summarizes key risks for running containers in AWS, Azure, and GCP, and how this project’s architecture mitigates them.

---

## 1. Compromised Container Image

**Risk:** An image with known vulnerabilities or embedded secrets is deployed to production.  

**Mitigations:**
- Use private registries (ECR, ACR, Artifact Registry) with restricted access.  
- Run image scanning (Trivy / native scanners) in CI/CD and on stored images.  
- Block or fail builds when critical/high vulnerabilities exceed thresholds.  

---

## 2. Unauthorized Access to Registries

**Risk:** An attacker pulls images or pushes malicious images into a registry.  

**Mitigations:**
- Enforce IAM / Azure AD / Google IAM roles with least privilege for push/pull.  
- Use network controls (private endpoints, VPC peering, firewall rules).  
- Monitor registry access logs and alert on unusual locations or identities.

---

## 3. Lateral Movement Inside the Cluster

**Risk:** An attacker who compromises one pod can move laterally to other services.  

**Mitigations:**
- Apply Kubernetes Network Policies to restrict pod-to-pod traffic.  
- Use security groups / NSGs / firewall rules around node pools.  
- Isolate environments and sensitive workloads in separate clusters or namespaces.

---

## 4. Credential Leakage

**Risk:** Secrets are stored in images, code, or plain text configuration.  

**Mitigations:**
- Store secrets only in AWS Secrets Manager, Azure Key Vault, or GCP Secret Manager.  
- Permit secret access only via workload identities and least-privilege policies.  
- Scan IaC and repositories periodically for hard-coded credentials.

---

## 5. Privilege Escalation from Containers

**Risk:** A container gains host-level privileges and compromises the node.  

**Mitigations:**
- Prevent privileged containers and disallow `hostPID`, `hostNetwork`, `hostPath` where possible.  
- Run containers as non-root with read-only root file systems.  
- Use admission policies / Pod Security settings to enforce constraints.

---

## 6. Inadequate Logging and Monitoring

**Risk:** Security incidents go undetected due to missing or fragmented logs.  

**Mitigations:**
- Centralize logs in CloudWatch/CloudTrail, Log Analytics, and Cloud Logging.  
- Enable audit trails for API calls and configuration changes in each cloud.  
- Configure alerts for denied authentications, policy violations, and unusual activity.

---

## 7. Misconfigured Network Exposure

**Risk:** A service intended to be internal becomes exposed to the internet.  

**Mitigations:**
- Use private subnets and internal load balancers where possible.  
- Require explicit configuration for public endpoints and review security groups/NSGs.  
- Periodically run perimeter reviews or cloud security posture checks.

---

## 8. Drift Between Clouds

**Risk:** Security posture diverges between AWS, Azure, and GCP due to inconsistent configurations.  

**Mitigations:**
- Capture requirements in `security_requirements.md` and apply them consistently.  
- Use Terraform and version control so changes are tracked and repeatable.  
- Document cloud-specific differences clearly in sub-folder READMEs.

---

## 9. Overly Restrictive Controls Blocking Delivery

**Risk:** Security controls are implemented in a way that slows or blocks teams, leading to bypasses.  

**Mitigations:**
- Integrate checks into CI/CD with clear feedback to developers.  
- Provide exception and risk-acceptance processes where necessary.  
- Start with monitor/alert mode before enforcing hard blocks on new controls.

