# Azure Container Security Setup

This document provides setup and validation steps for the Azure portion of the multi-cloud container security project.

These instructions are intended to reproduce the portfolio implementation. They should not be interpreted as a complete production AKS deployment procedure. Production architecture considerations are documented separately in the project's security requirements, risks, and architecture documentation.

## Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI
- Docker
- Terraform
- kubectl
- Git
- A supported local development environment or Linux system

Azure authentication should use an approved identity method. Long-lived credentials should not be stored in this repository.

## 1. Clone the Repository

```bash
git clone https://github.com/komodt01/Container-Security.git
cd Container-Security
```

## 2. Verify Required Tools

```bash
az version
docker --version
terraform --version
kubectl version --client
git --version
```

Installation procedures vary by operating system. Use the current vendor-supported installation method for each tool rather than relying on version-specific installation commands in this repository.

## 3. Authenticate to Azure

```bash
az login
```

Verify the active subscription:

```bash
az account show
```

Confirm that the intended Azure subscription and identity are active before creating resources.

## 4. Initialize Terraform

Navigate to the Azure Terraform directory:

```bash
cd terraform/azure
terraform init
```

Review the proposed infrastructure:

```bash
terraform plan
```

## 5. Deploy the Azure Infrastructure

After reviewing the Terraform plan:

```bash
terraform apply
```

The Terraform configuration provisions the Azure resources used by the container example, including:

- Azure Kubernetes Service
- Azure Container Registry
- Virtual network and AKS subnet
- Network Security Group
- Managed identity
- ACR pull authorization
- Log Analytics workspace
- AKS diagnostic telemetry

## 6. Retrieve the ACR Login Server

After deployment:

```bash
terraform output acr_login_server
```

The registry name in this portfolio example is `secureacr12345`.

Azure Container Registry names must be globally unique. If that name is unavailable, update the Terraform configuration before deployment.

## 7. Authenticate to ACR

```bash
az acr login --name secureacr12345
```

The architecture disables the ACR administrative account. Registry access should use Azure identity and authorization rather than persistent registry administrator credentials.

## 8. Build the Container Image

Return to the repository root and build the application using a versioned tag:

```bash
docker build -t myapp:v1 .
```

The project Dockerfile uses a minimal Node.js base image and runs the application process as a non-root user.

## 9. Tag the Image for ACR

```bash
docker tag myapp:v1 \
  secureacr12345.azurecr.io/myapp:v1
```

## 10. Push the Image

```bash
docker push \
  secureacr12345.azurecr.io/myapp:v1
```

Verify that the expected image appears in ACR.

## 11. Connect to AKS

Retrieve the AKS credentials:

```bash
az aks get-credentials \
  --resource-group secure-aks-rg \
  --name secure-aks
```

Verify access:

```bash
kubectl get nodes
```

## 12. Deploy or Validate the Application

Apply the Kubernetes application manifests used by the project, if they have not already been deployed.

Then validate the workload:

```bash
kubectl get pods
kubectl get svc
```

Confirm that the expected pods are running and that the application is exposed only through the intended service or ingress path.

## 13. Validate Workload Logs

Review application logs:

```bash
kubectl logs <pod-name>
```

AKS platform telemetry can also be reviewed through Azure Monitor and Log Analytics.

## 14. Validate Identity and Registry Access

Verify that AKS has the intended authorization to pull images from ACR.

The architecture uses identity-based access rather than enabling ACR administrative credentials.

The intended model is:

**AKS Identity → Azure Authorization → ACR → Approved Container Image**

Production validation should also confirm that unnecessary identities cannot push, pull, or administer registry content.

## 15. Validate Network Controls

Confirm that the Network Security Group is associated with the intended AKS subnet.

Review the expected application traffic path rather than validating only that the application is reachable.

The architecture question is:

**Who needs access? → Through which entry point? → To which workload? → On which protocol and port?**

Broad network access should not be added simply because an application listens on a particular port.

## 16. Validate Monitoring

Confirm that AKS diagnostic telemetry is reaching the configured Log Analytics workspace.

Production validation would additionally define required telemetry for:

- Administrative activity
- Authentication and authorization
- Kubernetes API activity
- Workload failures
- Registry activity
- Network-security events
- Security policy violations
- Loss of expected telemetry

## 17. Validate the Security Architecture

The deployment should be reviewed against the intended architecture rather than validating only that AKS and the application are operational.

Relevant questions include:

- Is ACR administrative access disabled?
- Does AKS use identity-based access to ACR?
- Are workload permissions limited to required resources?
- Is the NSG associated with the intended subnet?
- Is application exposure limited to the intended access path?
- Is the container running as a non-root user?
- Is the deployed image the expected version?
- Are sensitive credentials absent from source code and Terraform?
- Is AKS telemetry reaching Log Analytics?
- Is there sufficient workload redundancy for the intended availability requirement?

The validation flow is:

**Deploy → Verify Functionality → Verify Security Controls → Review Evidence → Identify Gaps**

## 18. Production Architecture Considerations

The portfolio implementation demonstrates selected AKS security capabilities.

A production implementation would additionally require evaluation of:

- Private AKS API access
- Private ACR connectivity
- Workload Identity
- Kubernetes Network Policies
- Secrets management through Azure Key Vault or another approved platform
- Admission controls
- Image vulnerability management
- Ingress and WAF architecture
- Egress controls
- Autoscaling
- Availability zones
- Backup and recovery
- Deployment rollback
- Security alerting
- Organizational governance requirements

These are production architecture considerations rather than controls claimed as part of the original lab deployment.

## Architecture Note

The original project demonstrated a functional AKS container deployment. The later architecture review identified opportunities to strengthen registry authentication, network boundaries, workload identity, resilience, monitoring, and production governance.

The purpose of these setup instructions is to reproduce and validate the implementation while keeping that distinction clear:

**Lab Implementation ≠ Complete Production Architecture**
