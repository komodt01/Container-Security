# AWS Container Teardown

This document provides the cleanup steps used to remove AWS resources associated with the container security project and avoid unnecessary cloud charges.

## Steps

### 1. Destroy Terraform-Managed Infrastructure

```bash
cd terraform/aws
terraform destroy -auto-approve
```

### 2. Verify ECR Cleanup

If the ECR repository remains after the Terraform teardown, remove it manually:

```bash
aws ecr delete-repository \
  --repository-name myapp-repo \
  --force
```

### 3. Verify CloudWatch Log Cleanup

If the log group remains after the Terraform teardown, remove it manually:

```bash
aws logs delete-log-group \
  --log-group-name /ecs/myapp
```

## Validation

After teardown, verify that the project resources have been removed and that no unnecessary AWS resources remain active.

## Note

Terraform-managed resources should normally be removed through Terraform so that infrastructure state remains consistent. Manual cleanup commands are included only for resources that remain or require separate cleanup.
