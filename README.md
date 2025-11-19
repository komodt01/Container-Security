# Multi-Cloud Container Security Architecture (AWS, Azure, GCP)

## Project Purpose

This project demonstrates how to design and implement a **hardened, multi-cloud container platform** across **AWS, Azure, and Google Cloud Platform (GCP)**.

The focus is security architecture, not just deployment. Each cloud uses its **native container and registry services**, wired into:

- Identity and Access Management (IAM)
- Private networking and restricted ingress
- Encryption at rest and in transit
- Centralized logging and monitoring
- Image scanning and least-privilege runtime

> **Note:** This is a portfolio / learning project, not a production blueprint. Real-world deployments must be driven by business requirements, regulatory obligations, and organization-specific risk tolerance.

---

## High-Level Architecture

Each cloud follows the same security pattern:

- **Build & Scan**
  - Images built in CI/CD
  - Pushed to cloud-native registries
  - Scanned for vulnerabilities (Trivy / native scanners)

- **Store & Protect**
  - Registries private by default
  - Access via IAM roles/identities only
  - Encryption at rest with KMS / Key Vault / Cloud KMS

- **Deploy & Run**
  - Containers run on hardened platforms:
    - **AWS:** EKS or ECS with IAM roles for tasks
    - **Azure:** AKS with managed identities
    - **GCP:** GKE with Workload Identity
  - Network policies / security groups restrict east-west and north-south traffic
  - Runtime config blocks privileged containers and writable root file systems

- **Observe & Respond**
  - Centralized logging into:
    - **AWS:** CloudWatch / CloudTrail
    - **Azure:** Log Analytics / Activity Logs
    - **GCP:** Cloud Logging / Cloud Audit Logs
  - Alerts on suspicious or denied actions

See `diagrams/container_security_architecture.png` for a conceptual view.

---

## Repository Layout

```text
.
├── README.md
├── diagrams/
│   └── container_security_architecture.png
├── docs/
│   ├── technologies.md
│   ├── security_requirements.md
│   └── risks_and_mitigations.md
├── aws/
│   ├── terraform/         # ECR/ECS or EKS, IAM, logging, KMS
│   └── k8s-or-taskdefs/   # Kubernetes YAML or ECS task definitions
├── azure/
│   ├── terraform/         # ACR, AKS, managed identities, diagnostics
│   └── k8s/               # AKS workload manifests
└── gcp/
    ├── terraform/         # Artifact Registry, GKE, Workload Identity, logging
    └── k8s/               # GKE workload manifests
