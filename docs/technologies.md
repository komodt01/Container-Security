
---

## 2. `docs/technologies.md` (tight, multi-cloud)

```markdown
# Technologies Used

This project focuses on **native cloud services** for container security across AWS, Azure, and GCP. Each entry explains **what it is**, **how it works**, and **why it is used** in this architecture.

---

## AWS

### Amazon Elastic Container Registry (ECR)
**What it is:** Private container image registry for AWS.

**How it works:** Stores container images in private repositories; integrates with IAM, KMS, and ECR image scanning.

**Why we use it:** To keep images inside AWS with strong access control, encryption at rest, and built-in vulnerability scanning.

---

### Amazon EKS / ECS (incl. Fargate)
**What it is:** Managed Kubernetes service (EKS) and container orchestration / serverless containers (ECS/Fargate).

**How it works:** Runs container workloads on clusters or serverless tasks with IAM roles, security groups, and VPC networking.

**Why we use it:** To demonstrate workload isolation, IAM roles for tasks/pods, and network segmentation in AWS.

---

### AWS IAM & KMS
**What it is:** Identity and key management services.

**How it works:** IAM roles and policies control which workloads can pull images, read secrets, and access APIs. KMS manages customer-managed keys for encryption.

**Why we use it:** To enforce least-privilege access and encrypt sensitive data (images, logs, secrets).

---

### Amazon CloudWatch & CloudTrail
**What it is:** Logging, metrics, and audit trail services.

**How it works:** Containers send application and system logs to CloudWatch; CloudTrail captures API calls and configuration changes.

**Why we use it:** To provide observability, incident investigation, and compliance evidence for AWS workloads.

---

## Azure

### Azure Container Registry (ACR)
**What it is:** Private Docker-compatible image registry for Azure.

**How it works:** Stores container images with Azure AD-based access, private endpoints, and optional Content Trust / image scanning.

**Why we use it:** To host images for AKS while enforcing identity-based access and network isolation.

---

### Azure Kubernetes Service (AKS)
**What it is:** Managed Kubernetes service on Azure.

**How it works:** Runs container workloads in node pools integrated with virtual networks, NSGs, managed identities, and Log Analytics.

**Why we use it:** To demonstrate secure Kubernetes deployments using managed identities, network policies, and Azure-native logging.

---

### Azure AD, Managed Identities & Key Vault
**What it is:** Identity platform, identity-as-a-service for workloads, and secret / key store.

**How it works:** AKS nodes and pods can use managed identities to access Key Vault and other services without storing credentials in code.

**Why we use it:** To show credential-less access patterns and centralized secret management in Azure.

---

### Azure Monitor & Log Analytics
**What it is:** Monitoring and log aggregation platform.

**How it works:** Collects metrics and logs from AKS clusters, nodes, and containers into a Log Analytics workspace.

**Why we use it:** To centralize observability for Azure container workloads and support alerting.

---

## GCP

### Artifact Registry (or Container Registry)
**What it is:** Google’s managed container image registry.

**How it works:** Stores images in repositories controlled by IAM; integrates with Cloud KMS for encryption and with scanning tools.

**Why we use it:** To keep container images close to GKE clusters with Google IAM-based control.

---

### Google Kubernetes Engine (GKE)
**What it is:** Managed Kubernetes service on GCP.

**How it works:** Runs pod workloads on clusters integrated with VPC networking, Workload Identity, and GKE security features.

**Why we use it:** To demonstrate secure Kubernetes workloads with identity-aware access and network controls in GCP.

---

### Workload Identity & Cloud KMS
**What it is:** Mechanism for mapping Kubernetes service accounts to Google service accounts, plus key management.

**How it works:** Pods authenticate to GCP APIs via federated service accounts; Cloud KMS manages encryption keys for data and images.

**Why we use it:** To avoid long-lived keys, enforce least-privilege access, and encrypt sensitive assets.

---

### Cloud Logging & Cloud Audit Logs
**What it is:** Central logging and auditing platform for GCP.

**How it works:** GKE and other services stream logs and audit events into Cloud Logging; policies and alerts can be built on top.

**Why we use it:** To provide a unified view of GCP activity, support incident response and compliance reporting.

---

## Cross-Cutting Technologies

### Container Image Scanning (e.g., Trivy / Native Scanners)
**What it is:** Tooling to detect known vulnerabilities (CVEs) in images and file systems.

**How it works:** Scans images in registries or during CI/CD; produces reports on vulnerabilities, misconfigurations, and licenses.

**Why we use it:** To shift security left and ensure only vetted images are deployed.

---

### Kubernetes Network Policies / Security Groups / Firewalls
**What it is:** Network-level access control mechanisms.

**How it works:** Define allowed traffic between pods/services and restrict inbound/outbound access at cluster and subnet level.

**Why we use it:** To prevent lateral movement and reduce blast radius if a container is compromised.

---

### Secret Management (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)
**What it is:** Managed secret storage services.

**How it works:** Applications retrieve secrets at runtime via IAM-based access instead of embedding them in images or configuration.

**Why we use it:** To avoid hard-coded credentials and provide rotation, auditing, and fine-grained control.
