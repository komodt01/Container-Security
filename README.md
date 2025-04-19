# Container Security Project

## Overview
This project demonstrates secure container deployment on AWS ECS Fargate with Terraform, including security scans and compliance with NIST 800-53. It also provides an Azure AKS reference implementation for comparison.

## Architecture
- **AWS**: Uses ECS Fargate, ECR with image scanning, IAM roles, Secrets Manager, VPC with Security Groups, and CloudWatch logging. See [aws-container-diagram.png](docs/aws-container-diagram.png).
- **Azure**: Uses AKS, ACI, ACR with scans, Entra ID, Key Vault, VNet with NSG, and Azure Monitor. See [azure-container-diagram.png](docs/azure-container-diagram.png).

## Setup
- **AWS**: Follow [setup-aws.md](docs/setup-aws.md).
- **Azure**: Follow [setup-azure.md](docs/setup-azure.md).

## Results
- **AWS**: See [results-aws.md](docs/results-aws.md).
- **Azure**: See [results-azure.md](docs/results-azure.md).

## Compliance
- Maps to NIST 800-53 and ISO 27001: [nist-iso-mapping.md](docs/nist-iso-mapping.md).
- Security controls: [security-controls.md](docs/security-controls.md).

## Lessons Learned
- See [lessonslearned.md](docs/lessonslearned.md).

## Technologies Used
- See [technologies.md](docs/technologies.md).
