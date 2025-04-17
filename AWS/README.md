# Secure Container Deployment (AWS)

This project secures a containerized application on AWS using ECS Fargate. It aligns with NIST 800-53 and ISO/IEC 27001 frameworks for container security, identity management, and monitoring.

## 🔐 Key Security Features

- IAM Roles with least privilege [NIST AC-6, ISO A.9.2.3]
- CloudWatch centralized logging [NIST AU-2, ISO A.12.4.1]
- Secrets Manager for container credentials [NIST SC-12, ISO A.10.1.2]
- ECR vulnerability scans [NIST SI-2, ISO A.12.6.1]

## 📁 Structure

- `terraform/`: IaC for ECS + networking
- `linux-hardening.md`: Commands for base image hardening
- `nist-iso-mapping.md`: Control-to-implementation references

## 🚧 To-Do

- Add Azure and GCP container security equivalents
- Integrate image signing and CI/CD policy enforcement
