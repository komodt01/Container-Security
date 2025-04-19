# AWS Container Security Lab (with Azure Reference)

## Overview
This project designs a secure container architecture using AWS ECS Fargate, implementing DevSecOps best practices like vulnerability scanning (ECR), rootless containers, and least-privilege IAM roles. It demonstrates secure cloud workloads, Zero Trust, and compliance with NIST 800-53/PCI-DSS. An Azure AKS/ACI implementation showcases cross-cloud expertise.

## Design Objectives
- **AWS Focus**:
  - Deploy secure containers on ECS Fargate with non-root users, immutable tags, and Secrets Manager.
  - Integrate ECR vulnerability scanning in a DevSecOps pipeline.
  - Enforce Zero Trust with IAM roles and Security Groups.
  - Automate with Terraform for auditability and scalability.
- **Azure Reference**:
  - Deploy containers on AKS/ACI with non-root users, read-only filesystems, and Trivy scanning.
  - Use Entra ID RBAC and Key Vault for Zero Trust.

## Architecture Diagrams
- **AWS**: ![AWS Container Architecture](docs/aws-container-diagram.png)
  - ECS Fargate: Runs containers.
  - ECR: Stores images with scanning.
  - IAM: Least-privilege roles.
  - Secrets Manager: Credential injection.
  - VPC/Security Groups: Traffic isolation.
  - CloudWatch: Logs.
- **Azure**: ![Azure Container Architecture](docs/azure-container-diagram.png)
  - AKS/ACI: Hosts non-root containers.
  - ACR: Stores secure images.
  - Trivy: Scans images in CI/CD.
  - Entra ID: Secures access with RBAC.
  - VNet/NSG: Restricts traffic.
  - Key Vault: Injects secrets.
  - Azure Monitor: Collects logs.

## Tools and Files
- **AWS**:
  - ECS Fargate, ECR, Secrets Manager, IAM, CloudWatch
  - Terraform: `terraform/aws/`
  - Container Definitions: `aws/container-definitions.json`
- **Azure**:
  - AKS, ACI, ACR, Entra ID, Key Vault, VNet/NSG, Azure Monitor
  - Terraform: `terraform/azure/`
  - Kubernetes YAML: `kubernetes/deployment.yaml`, `kubernetes/service.yaml`
- **Shared**:
  - Dockerfile: `Dockerfile`
  - Trivy: Vulnerability scanning
  - Linux: `aws`, `az`, `docker`, `trivy`, `kubectl`

## Setup
- AWS: [docs/setup-aws.md](docs/setup-aws.md)
- Azure: [docs/setup-azure.md](docs/setup-azure.md)

## Results
- AWS: [docs/results-aws.md](docs/results-aws.md)
- Azure: [docs/results-azure.md](docs/results-azure.md)

## Business Value
- **Security**: Non-root containers, scans, and Zero Trust reduce vulnerabilities.
- **Compliance**: Aligns with NIST 800-53 (AC-6, AU-2, SI-2) and PCI-DSS.
- **DevSecOps**: Automated scanning and IaC enhance CI/CD efficiency.
- **Scalability**: Terraform ensures repeatable, auditable deployments.

## Compliance Mappings
[docs/nist-iso-mapping.md](docs/nist-iso-mapping.md)

## GitHub
https://github.com/komodt01/Container-Security

## Contact
Karl Omodt | LinkedIn: [insert link]
