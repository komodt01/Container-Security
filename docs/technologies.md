# Technologies Used

This project uses cloud-native container services across AWS, Azure, and Google Cloud to demonstrate how common container security requirements can be implemented differently on each platform.

The technologies listed as implemented below are represented in the project configuration or deployment artifacts. Additional production capabilities are discussed separately in the security requirements and risk documentation.

---

## AWS

### Amazon Elastic Container Registry (ECR)

**What it is:** AWS-managed private container image registry.

**How it works:** ECR stores application container images and integrates with AWS IAM for access control. The project enables image scanning and uses ECR as the image source for ECS.

**Why it is used:** To provide controlled container image storage and vulnerability visibility within the AWS environment.

---

### Amazon ECS with AWS Fargate

**What it is:** AWS container orchestration with serverless container compute.

**How it works:** ECS manages container tasks and services while Fargate provides the underlying compute without requiring management of EC2 container hosts.

**Why it is used:** To demonstrate an AWS-native container architecture with workload identity, VPC networking, Security Groups, centralized logging, and separation between the application entry point and container workload.

---

### AWS IAM

**What it is:** AWS identity and authorization service.

**How it works:** IAM roles and policies determine what ECS platform components and application workloads are authorized to access.

**Why it is used:** To separate platform execution permissions from application workload permissions and support least-privilege access.

---

### Amazon CloudWatch

**What it is:** AWS logging, metrics, and monitoring service.

**How it works:** ECS application logs are sent to a CloudWatch log group for operational visibility and investigation.

**Why it is used:** To provide centralized application telemetry for the AWS workload.

AWS CloudTrail would be an additional production telemetry source for administrative and API activity.

---

### AWS VPC, Security Groups, and Application Load Balancer

**What they are:** AWS networking and application traffic-control capabilities.

**How they work:** The revised architecture separates the public application entry point from the ECS workload. Security Groups restrict which components can communicate with the container tasks.

**Why they are used:** To establish explicit network trust boundaries rather than exposing container workloads directly to unrestricted internet traffic.

The intended application path is:

**Client → Application Load Balancer → Security Group → ECS/Fargate Workload**

---

## Azure

### Azure Container Registry (ACR)

**What it is:** Azure-managed private container registry.

**How it works:** ACR stores application container images and uses Azure identity and RBAC for authorization.

**Why it is used:** To provide controlled image storage for the AKS environment without relying on registry administrative credentials.

---

### Azure Kubernetes Service (AKS)

**What it is:** Azure-managed Kubernetes service.

**How it works:** AKS runs Kubernetes workloads on managed node pools integrated with Azure networking, identity, and monitoring services.

**Why it is used:** To demonstrate how container security requirements apply to a managed Kubernetes platform.

---

### Azure Managed Identity and RBAC

**What they are:** Azure capabilities for workload identity and authorization.

**How they work:** Managed identities allow Azure resources to authenticate without embedded credentials, while Azure RBAC determines which actions those identities may perform.

In the revised architecture, AKS receives explicit `AcrPull` authorization to retrieve container images from ACR.

**Why they are used:** To demonstrate identity-based registry access and reduce reliance on persistent credentials.

---

### Azure Virtual Network and Network Security Groups

**What they are:** Azure networking and network access-control capabilities.

**How they work:** AKS is deployed into a dedicated subnet, and the Network Security Group is associated with that subnet to provide network-level controls.

**Why they are used:** To establish a defined network boundary around the Kubernetes environment.

Additional production architecture would evaluate ingress, egress, private connectivity, Kubernetes Network Policies, and application-layer protection according to workload requirements.

---

### Azure Monitor and Log Analytics

**What they are:** Azure monitoring and centralized log-analysis capabilities.

**How they work:** AKS diagnostic telemetry is sent to a Log Analytics workspace for operational visibility and investigation.

**Why they are used:** To provide centralized platform telemetry for the Azure container environment.

---

## Google Cloud

### Artifact Registry

**What it is:** Google Cloud's managed artifact and container image repository.

**How it works:** Artifact Registry stores container images in repositories protected through Google Cloud IAM.

**Why it is used:** To provide controlled image storage for workloads deployed to GKE.

---

### Google Kubernetes Engine (GKE)

**What it is:** Google Cloud's managed Kubernetes service.

**How it works:** GKE runs Kubernetes workloads using Google Cloud networking, identity, logging, and monitoring capabilities.

**Why it is used:** To demonstrate a second managed Kubernetes implementation while applying the same security requirements used for AWS and Azure.

---

### GKE Workload Identity

**What it is:** A workload authentication mechanism for GKE.

**How it works:** Kubernetes workloads can authenticate to Google Cloud services using workload identity rather than relying on embedded service-account keys.

**Why it is used:** To support credential-less workload authentication and least-privilege access to Google Cloud resources.

---

### Google Secret Manager

**What it is:** Google Cloud's managed secrets-storage service.

**How it works:** Secret Manager stores sensitive values separately from application code and infrastructure configuration.

The Terraform example creates the secret resource but intentionally does not embed the secret value in Terraform.

**Why it is used:** To demonstrate separation between infrastructure provisioning and sensitive secret material.

---

### Google Cloud VPC

**What it is:** Google Cloud's software-defined networking platform.

**How it works:** The GKE environment uses a custom VPC and subnet rather than relying on automatically created networks.

**Why it is used:** To provide an explicit network foundation on which workload exposure and segmentation requirements can be designed.

---

### Google Cloud Logging and Monitoring

**What they are:** Google Cloud's platform telemetry capabilities.

**How they work:** GKE integrates with Google Cloud logging and monitoring services to provide visibility into cluster and workload activity.

**Why they are used:** To support operational monitoring, investigation, and security visibility.

---

## Cross-Cutting Technologies

### Docker

**What it is:** Container image build and runtime technology.

**How it works:** The application and its dependencies are packaged into a portable container image.

**Why it is used:** To provide a consistent application artifact that can be stored and deployed across the cloud environments.

The project Dockerfile uses a minimal Node.js base image and runs the application process as a non-root user.

---

### Terraform

**What it is:** Infrastructure-as-code technology.

**How it works:** Cloud resources are defined declaratively and can be reviewed, deployed, changed, and removed through version-controlled configuration.

**Why it is used:** To make infrastructure decisions repeatable and visible across the three cloud environments.

Terraform improves consistency but does not automatically make infrastructure secure. The configuration itself must still be reviewed against security requirements.

---

### Container Image Scanning

**What it is:** Vulnerability analysis of container images and their software dependencies.

**How it works:** Scanning identifies known vulnerabilities that can then be evaluated before deployment.

**Why it is used:** To introduce vulnerability information into the deployment decision.

A production decision should consider more than severity alone:

**Finding → Severity → Exploitability → Exposure → Business Criticality → Mitigation → Allow / Block / Exception**

---

### Cloud-Native Workload Identity

Each cloud provides a different mechanism for allowing workloads to access cloud services without embedding long-lived credentials.

Examples used or represented in the architecture include:

- AWS IAM roles.
- Azure managed identities.
- Google Cloud Workload Identity.

The implementations differ, but the security objective is the same:

**Workload → Trusted Identity → Least-Privilege Authorization → Required Resource**

---

### Network Security Controls

Each platform provides different network-enforcement mechanisms:

- AWS VPC and Security Groups.
- Azure VNet and Network Security Groups.
- Google Cloud VPC and firewall capabilities.
- Kubernetes Network Policies where required in production Kubernetes environments.

These technologies should not be treated as exact equivalents.

They implement a common architecture objective:

**Define Trust Boundary → Identify Required Traffic → Permit Required Paths → Restrict Unnecessary Paths → Monitor**

---

## Technology Selection Principle

The purpose of this project is not to demonstrate that AWS, Azure, and Google Cloud have identical services.

The architecture starts with the security requirement and then selects the appropriate platform capability.

**Security Requirement → Required Capability → Cloud-Native Technology → Configuration → Evidence**

This allows the project to maintain consistent container security objectives while respecting the architectural differences between ECS/Fargate, AKS, and GKE.
