# Lessons Learned: AWS Container Security Project

## 🔐 Security Implementation Takeaways

- Using **ECS Fargate** allowed us to eliminate server patching responsibilities while improving container isolation.
- Created IAM roles with **least privilege**, specifically separating the task execution role from other identities.
- Injecting secrets through **AWS Secrets Manager** removed the need to hardcode sensitive credentials in source code or Terraform files.
- All infrastructure was provisioned with **Terraform**, enabling auditability, rollback, and compliance alignment.
- Network isolation via **custom VPC**, **public subnet**, **internet gateway**, and **security groups** helped enforce traffic restrictions and segment trust boundaries.

## ⚠️ Challenges Encountered

- Terraform failed initially due to missing IAM role references — resolved by manually referencing an existing role.
- AWS CloudShell ran out of space during state locking, highlighting the importance of cleaning up `.terraform` directories and old files.
- Secrets injection required a correct ARN format and an accurate JSON container definition; invalid formatting broke deployments.

## ✅ Validation Steps

- Verified ECS container logs in **CloudWatch Logs**
- Confirmed `API_KEY` was injected via ECS environment variable
- Used `terraform plan` to ensure changes were properly previewed

## 🛠 Recommendations

- Consider using **remote Terraform state** (e.g., S3 backend) for better reliability
- Expand monitoring using **AWS GuardDuty** or **Falco**
- Implement an **Application Load Balancer** and WAF for public-facing workloads
