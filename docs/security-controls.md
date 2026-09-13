# Security Controls

This document summarizes the security controls demonstrated or considered across the AWS, Azure, and Google Cloud container environments.

The objective is to maintain consistent security outcomes across the container lifecycle while allowing each cloud platform to use its native security capabilities.

Not every production control listed below was implemented in the original lab. The distinction between demonstrated controls and production architecture considerations is intentional.

## Identity and Access Control

### Demonstrated

**AWS**
- IAM roles for ECS platform access.
- Separate execution and workload role concepts in the revised architecture.

**Azure**
- AKS managed identity.
- Azure role-based access control.
- Identity-based ACR access rather than registry administrator credentials in the revised architecture.

**Google Cloud**
- GKE Workload Identity in the revised architecture.
- Google Cloud IAM as the authorization layer for cloud resources.

### Production Architecture Considerations

- Least-privilege workload permissions.
- Separation of administrative, deployment, and runtime identities.
- Short-lived credentials where supported.
- Workload identity rather than embedded service credentials.
- Periodic access review.
- Monitoring of privileged activity.

## Container Image Security

### Demonstrated

- Private cloud container registries.
- Amazon ECR image scanning capability.
- Minimal Node.js container base image.
- Non-root application runtime.
- Container images stored through ECR, ACR, or Artifact Registry depending on the platform.

### Production Architecture Considerations

- Vulnerability scanning throughout the image lifecycle.
- Immutable image references.
- Image signing and integrity verification where required.
- Software Bill of Materials (SBOM) generation where appropriate.
- Defined vulnerability remediation thresholds.
- Controlled risk exceptions.
- Admission policies that prevent unapproved images from being deployed.

A scan finding should feed a risk decision rather than automatically being treated as proof that an image is safe or unsafe.

**Image → Scan → Evaluate → Allow / Block / Exception → Deploy**

## Network Security

### AWS

The revised architecture separates the public application entry point from the ECS workload.

The intended flow is:

**Internet → Application Load Balancer → Security Group → Private ECS Task**

The ECS workload accepts application traffic from the approved upstream component rather than directly from unrestricted internet sources.

### Azure

AKS uses a dedicated virtual network and subnet with Network Security Group controls.

Production architecture would additionally evaluate the required ingress architecture, private cluster access, Kubernetes Network Policies, private endpoints, and egress restrictions.

### Google Cloud

GKE uses a custom VPC and subnet rather than relying on an automatically created network.

Production architecture would additionally evaluate private nodes, control-plane access, firewall policy, Kubernetes Network Policies, load balancing, ingress, and egress requirements.

## Secrets Management

Secrets should not be stored directly in source code, container images, or Terraform configuration.

The revised Google Cloud example provisions a Secret Manager resource without embedding the secret value in Terraform.

Production implementations would evaluate:

- AWS Secrets Manager or Parameter Store.
- Azure Key Vault.
- Google Secret Manager.
- Workload identity for secret access.
- Least-privilege authorization.
- Secret rotation.
- Secret-access auditing.

The preferred access model is:

**Workload Identity → Authorization → Secret Store → Authorized Secret**

## Logging and Monitoring

### AWS

CloudWatch provides application and platform logging for the ECS workload. AWS platform audit telemetry can provide additional visibility into administrative and configuration activity.

### Azure

AKS diagnostic telemetry is sent to Log Analytics and can be analyzed through Azure monitoring capabilities.

### Google Cloud

GKE integrates with Google Cloud logging and monitoring services.

### Production Architecture Considerations

Monitoring requirements should be driven by the threats and operational requirements of the workload.

Relevant telemetry may include:

- Administrative activity.
- Authentication and authorization failures.
- Registry activity.
- Container platform changes.
- Workload failures.
- Network-security events.
- Vulnerability findings.
- Policy violations.
- Loss of expected telemetry.

## Runtime Security

The application Dockerfile demonstrates a basic runtime-hardening control by running the application process as a non-root user.

Production environments would also evaluate controls such as:

- Privileged-container restrictions.
- Host namespace restrictions.
- Filesystem restrictions.
- Linux capability restrictions.
- Kubernetes Pod Security controls.
- Admission policies.
- Runtime threat detection.

These controls should be selected based on workload requirements rather than applied simply because the platform supports them.

## Infrastructure as Code

Terraform provides repeatable and reviewable infrastructure definitions across the cloud environments.

Infrastructure as code supports consistency, but it does not guarantee secure configuration.

The security objective is:

**Defined Requirement → Reviewed Configuration → Controlled Deployment → Validation → Drift Detection**

Production environments would additionally require appropriate source control, review, approval, testing, state protection, deployment governance, and exception handling.

## Availability and Resilience

The original project used minimal infrastructure suitable for demonstrating container deployment.

The architecture review identified additional production considerations including:

- Multiple tasks, pods, or nodes.
- Health checks.
- Autoscaling.
- Availability-zone or regional architecture.
- Controlled deployment and rollback.
- Dependency failure.
- Registry availability.
- Monitoring failure.
- Backup and recovery requirements.

Availability is part of security architecture and should be evaluated alongside confidentiality and integrity requirements.

## Control Model

Across all three cloud environments, the security controls map to the same container lifecycle:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

The implementation differs by cloud provider.

The architecture objective is therefore not:

**Same Technology Everywhere**

It is:

**Same Security Requirement → Appropriate Cloud-Native Control → Verifiable Security Outcome**

This allows AWS ECS/Fargate, Azure AKS, and Google GKE to use different technical implementations while remaining governed by a consistent container security model.
