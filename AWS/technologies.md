# Technologies Used in AWS Container Security Project

## 🚀 ECS (Elastic Container Service) with Fargate
- A serverless container compute engine that runs containers without managing servers.
- Aligns with NIST isolation and container orchestration recommendations.

## 📦 Terraform
- Infrastructure as Code (IaC) tool used to automate deployment.
- Enables repeatable, secure, and auditable infrastructure creation.

## 🔐 AWS Secrets Manager
- Securely stores sensitive information like API keys.
- Injected secrets into ECS tasks without hardcoding them.

## 🔐 IAM Roles
- Used to grant ECS tasks least-privilege access to pull images, write logs, and access secrets.

## 🌐 VPC, Subnets, Internet Gateway
- Custom networking for isolation and outbound internet access.
- Ensured that containers only run in defined network segments.

## 🔒 Security Groups
- Virtual firewalls attached to ECS tasks that define allowed traffic.
- Allowed inbound HTTP traffic and unrestricted outbound traffic.

## 📊 CloudWatch Logs
- Collected logs from the ECS container using the awslogs driver.
- Enabled centralized monitoring and log review for compliance.

## 📂 container-definitions.json
- JSON configuration used to define how the container runs, including secrets, ports, and logging.

## 🌍 AWS Console + CloudShell
- Used CloudShell to deploy the infrastructure.
- Verified deployments, secrets, and ECS service tasks through the AWS Console.
