# 🧹 AWS Container Security Project Teardown Guide

This document provides the **correct order** and **commands** to systematically tear down AWS services created for the container security project to avoid orphaned resources and unexpected charges.

---

## ⚠️ Important Notes

- Ensure that you have backed up any data or logs before deletion.
- Execute these commands using AWS CLI or integrate into Terraform destroy if used with infrastructure as code.

---

## ✅ Teardown Order and Steps

### 1. **Delete ECS Services and Cluster**
```bash
aws ecs update-service --cluster <cluster-name> --service <service-name> --desired-count 0
aws ecs delete-service --cluster <cluster-name> --service <service-name> --force
aws ecs delete-cluster --cluster <cluster-name>
```

---

### 2. **Deregister and Delete Task Definitions**
```bash
# Optional: List task definitions
aws ecs list-task-definitions

# Optional: Deregister if needed
aws ecs deregister-task-definition --task-definition <task-def-name>
```

---

### 3. **Delete IAM Role**
```bash
aws iam detach-role-policy --role-name aws-owasp --policy-arn <policy-arn>
aws iam delete-role --role-name aws-owasp
```

---

### 4. **Delete ECR Repository**
```bash
aws ecr delete-repository --repository-name <repo-name> --force
```

---

### 5. **Remove Secrets from AWS Secrets Manager**
```bash
aws secretsmanager delete-secret --secret-id <secret-name> --force-delete-without-recovery
```

---

### 6. **Delete CloudWatch Log Groups**
```bash
aws logs describe-log-groups
aws logs delete-log-group --log-group-name <log-group-name>
```

---

### 7. **Tear Down VPC/Subnets (if custom created)**
```bash
# These must be deleted last if other services depend on them
aws ec2 delete-subnet --subnet-id <subnet-id>
aws ec2 delete-vpc --vpc-id <vpc-id>
```

---

## ✅ Optional: Terraform Destroy (If Used)
```bash
terraform destroy -auto-approve
```

Ensure Terraform state is preserved and updated if using remote backends.

---

## 🧾 Clean Completion Check
- No ECS clusters, ECR repositories, or secrets should remain.
- Confirm via AWS Console or AWS CLI.

