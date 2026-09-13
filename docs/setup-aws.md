# AWS Container Security Setup

This document provides setup and validation steps for the AWS portion of the multi-cloud container security project.

These instructions are intended to reproduce the portfolio implementation. They should not be interpreted as a complete production deployment procedure. Production architecture considerations are documented separately in the project's security requirements, risks, and architecture documentation.

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI
- Docker
- Terraform
- Git
- A supported local development environment or Linux system

AWS authentication should use an approved identity method. Long-lived AWS credentials should not be stored in this repository.

## 1. Clone the Repository

```bash
git clone https://github.com/komodt01/Container-Security.git
cd Container-Security
```

## 2. Verify Required Tools

```bash
aws --version
docker --version
terraform --version
git --version
```

Installation procedures vary by operating system. Use the current vendor-supported installation method for each tool rather than relying on version-specific installation commands in this repository.

## 3. Authenticate to AWS

Verify the AWS identity being used for the deployment:

```bash
aws sts get-caller-identity
```

Confirm that the intended AWS account and role are active before creating resources.

## 4. Initialize Terraform

Navigate to the AWS Terraform directory:

```bash
cd terraform/aws
terraform init
```

Review the proposed infrastructure before deployment:

```bash
terraform plan
```

## 5. Deploy the AWS Infrastructure

After reviewing the Terraform plan:

```bash
terraform apply
```

The Terraform configuration provisions the AWS infrastructure required by the container example, including the ECS environment, ECR repository, networking, IAM roles, logging, and application entry-point components defined by the current architecture.

## 6. Retrieve the ECR Repository

After deployment, obtain the repository URL:

```bash
terraform output ecr_repository_url
```

Return to the repository root before building the application image.

## 7. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region <region> \
  | docker login \
  --username AWS \
  --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
```

Replace `<region>` and `<account-id>` with the values for the AWS environment.

## 8. Build the Container Image

Build the application image using a versioned tag:

```bash
docker build -t myapp:v1 .
```

The project Dockerfile uses a minimal Node.js base image and runs the application process as a non-root user.

## 9. Tag the Image for ECR

```bash
docker tag myapp:v1 \
  <account-id>.dkr.ecr.<region>.amazonaws.com/myapp-repo:v1
```

Versioned image tags are used instead of `latest` so that deployments can reference a specific application artifact.

## 10. Push the Image

```bash
docker push \
  <account-id>.dkr.ecr.<region>.amazonaws.com/myapp-repo:v1
```

Verify that the image appears in the ECR repository.

## 11. Review Image Scan Results

If ECR image scanning is enabled, review the scan results before deploying the image.

A production environment would require defined criteria for determining whether vulnerability findings result in:

**Allow → Remediate → Block → Approved Exception**

The decision should consider severity, exploitability, workload exposure, business criticality, available remediation, and compensating controls.

## 12. Deploy the Application

Ensure that the ECS task definition references the intended versioned container image.

Apply any required Terraform changes:

```bash
cd terraform/aws
terraform plan
terraform apply
```

## 13. Validate ECS

Verify the ECS service:

```bash
aws ecs describe-services \
  --cluster secure-ecs-cluster \
  --services myapp-service
```

Confirm that the expected tasks are running and healthy.

## 14. Validate Logging

Review application logs:

```bash
aws logs tail /ecs/myapp
```

Confirm that expected application activity is reaching CloudWatch.

Production validation would also include verifying that required platform, identity, network, and administrative telemetry is available.

## 15. Validate the Security Architecture

The deployment should be reviewed against the intended architecture rather than validating only that the application runs.

Relevant questions include:

- Is the application reachable only through the intended entry point?
- Are ECS workloads protected from unnecessary direct public exposure?
- Do Security Groups permit only required traffic paths?
- Are execution and workload permissions separated appropriately?
- Is the container running as a non-root user?
- Is the deployed image the expected version?
- Are image scanning results available?
- Are application logs reaching CloudWatch?
- Are sensitive credentials absent from source code and Terraform?
- Can the environment be safely removed when testing is complete?

The validation flow is:

**Deploy → Verify Functionality → Verify Security Controls → Review Evidence → Identify Gaps**

## 16. Cleanup

When the environment is no longer required, follow:

`docs/aws-container-teardown.md`

Terraform-managed resources should normally be removed through Terraform so that infrastructure state remains consistent.

## Architecture Note

The original project demonstrated a functional ECS container deployment. The later architecture review identified improvements such as private workload placement, controlled ingress, immutable container artifacts, clearer workload identity boundaries, improved resilience, and stronger monitoring requirements.

The purpose of these setup instructions is to reproduce and validate the implementation while keeping that distinction clear:

**Lab Implementation ≠ Complete Production Architecture**
