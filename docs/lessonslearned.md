# Lessons Learned

This project reinforced that container security is not a single control or product. Security decisions span the full container lifecycle, from building and storing an image through deployment, runtime access, monitoring, and eventual remediation.

## AWS

The AWS implementation highlighted the importance of separating public application access from the container workload itself. Rather than exposing ECS tasks directly to the internet, the stronger architecture places the load balancer at the public boundary and keeps the Fargate tasks in private subnets.

Security group design also matters. Inbound access to the application workload should come from the expected upstream component, such as the Application Load Balancer, rather than from unrestricted internet sources.

ECR image scanning provides useful vulnerability visibility, but scanning alone does not determine whether an image should be deployed. In a production environment, I would also need to define how vulnerability severity, exploitability, workload exposure, business criticality, and available mitigations affect deployment decisions.

Separating the ECS execution role from the application task role also reinforced the importance of distinguishing platform permissions from workload permissions.

## Azure

The Azure implementation reinforced the value of managed identity rather than registry administrator credentials. AKS access to Azure Container Registry can be granted through an explicit AcrPull role assignment instead of embedding or distributing registry credentials.

Network controls also need to be connected to the resources they are intended to protect. Creating a Network Security Group without associating it with the appropriate subnet does not provide the intended enforcement.

AKS also demonstrated that Kubernetes security extends beyond cluster creation. A production environment would require additional decisions around workload identity, secrets, network policies, ingress, admission controls, vulnerability management, monitoring, and administrative access.

## Google Cloud

The GKE implementation reinforced that secrets should not be embedded directly in Terraform configuration. Terraform can provision the Secret Manager resource, while the secret value should be populated through an approved secrets-management process.

GKE Workload Identity provides a stronger model for workload authentication than distributing service account credentials to applications.

The project also highlighted the importance of separating network design from application exposure. A broad firewall rule should not be created simply because an application listens on a particular port. Ingress should be designed around the actual load-balancing, trust-boundary, and application-access requirements.

## Cross-Cloud Architecture

One of the strongest lessons from the project was that consistent container security does not require identical cloud implementations.

AWS ECS/Fargate, Azure AKS, and Google GKE use different identity, networking, registry, logging, and workload-security models. The architecture therefore needs to start with the required security outcome and then determine how each cloud platform should implement it.

The common lifecycle I used to evaluate the environments was:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

This provides a consistent security framework while still allowing each cloud platform to use its native capabilities.

## Infrastructure as Code

Terraform improves repeatability and makes infrastructure decisions visible and reviewable, but infrastructure as code does not automatically make an environment secure.

Security still depends on the configuration being deployed. Public exposure, excessive permissions, embedded secrets, weak identity design, insufficient logging, or inadequate resilience can all be reproduced consistently if they are encoded into Terraform.

The more useful architectural goal is therefore controlled and reviewable infrastructure rather than automation alone.

## Final Takeaway

The project reinforced a business-first approach to container security:

**Security Requirement → Container Lifecycle Stage → Risk → Required Control → Cloud-Native Implementation → Evidence → Monitoring and Response**

The cloud services differ, but the security questions remain consistent. The architect's role is to determine which controls are required, where they should be enforced, how they interact, what happens when they fail, and how the organization can verify that they are working as intended.
