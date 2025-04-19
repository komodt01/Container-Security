Purpose: Unified entry point, prioritizing Azure, with diagram references and links to all files.
Content:

# Azure Container Security Lab (with AWS Reference)

## Overview
This project designs a secure container architecture using Azure Kubernetes Service (AKS) and Azure Container Instances (ACI), implementing DevSecOps best practices like vulnerability scanning (Trivy), rootless containers, and Entra ID-based access controls. It aligns with CAQH’s requirements for secure cloud workloads, Zero Trust, and NIST 800-53/PCI-DSS compliance. An AWS ECS Fargate implementation demonstrates cross-cloud expertise.

## Design Objectives
- **Azure Focus**:
  - Deploy secure containers on AKS/ACI with non-root users, read-only filesystems, and immutable tags.
  - Integrate Trivy vulnerability scanning in a DevSecOps pipeline.
  - Enforce Zero Trust with Entra ID RBAC and Network Security Groups (NSGs).
  - Automate with Terraform for auditability and scalability.
- **AWS Reference**:
  - Deploy containers on ECS Fargate with least-privilege IAM roles and Secrets Manager.
  - Enable ECR vulnerability scanning and CloudWatch logging.

## Architecture Diagrams
- **Azure**: ![Azure Container Architecture](docs/azure-container-diagram.png)
  - AKS/ACI: Hosts non-root containers.
  - ACR: Stores secure images.
  - Trivy: Scans images in CI/CD.
  - Entra ID: Secures access with RBAC.
  - VNet/NSG: Restricts traffic.
  - Key Vault: Injects secrets.
  - Azure Monitor: Collects logs.
- **AWS**: ![AWS Container Architecture](docs/aws-container-diagram.png)
  - ECS Fargate: Runs containers.
  - ECR: Stores images with scanning.
  - IAM: Least-privilege roles.
  - Secrets Manager: Credential injection.
  - VPC/Security Groups: Traffic isolation.
  - CloudWatch: Logs.

## Tools and Files
- **Azure**:
  - AKS, ACI, ACR, Entra ID, Key Vault, VNet/NSG, Azure Monitor
  - Terraform: `terraform/azure/`
  - Kubernetes YAML: `kubernetes/deployment.yaml`, `kubernetes/service.yaml`
- **AWS**:
  - ECS Fargate, ECR, Secrets Manager, IAM, CloudWatch
  - Terraform: `terraform/aws/`
  - Container Definitions: `aws/container-definitions.json`
- **Shared**:
  - Dockerfile: `Dockerfile`
  - Trivy: Vulnerability scanning
  - Linux: `az`, `aws`, `docker`, `trivy`, `kubectl`

## Setup
- Azure: [docs/setup-azure.md](docs/setup-azure.md)
- AWS: [docs/setup-aws.md](docs/setup-aws.md)

## Results
- Azure: [docs/results-azure.md](docs/results-azure.md)
- AWS: [docs/results-aws.md](docs/results-aws.md)

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
