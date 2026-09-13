# Multi-Cloud Container Security Architecture

## Project Overview

This project explores how common container security requirements can be applied across AWS, Azure, and Google Cloud while still using each platform's native architecture.

The goal is not to make the three cloud environments identical.

The goal is to establish consistent security outcomes across the container lifecycle:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

The project combines practical container deployments with a later architecture review that identifies how the original implementations would need to evolve for stronger production security.

> **Scope Note:** This is a portfolio and learning project, not a production reference architecture or compliance implementation. Some controls are demonstrated directly in the project, while others are documented as production architecture requirements or recommendations. Actual implementations would need to be driven by business requirements, workload characteristics, regulatory obligations, availability requirements, and organizational risk tolerance.

---

## Architecture Problem

Organizations operating containers across multiple cloud providers face a common problem:

**How do you maintain consistent container security requirements when each cloud uses different identity, networking, registry, orchestration, and monitoring technologies?**

Trying to force identical technical implementations across AWS, Azure, and Google Cloud can create unnecessary complexity.

For this project, I used a different approach:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

That allows the security objective to remain consistent while the implementation changes according to the platform.

---

## Cloud Platforms

### AWS

The AWS implementation uses:

- Amazon ECS with Fargate
- Amazon ECR
- AWS IAM roles
- Amazon VPC
- Security Groups
- Application Load Balancer
- Amazon CloudWatch

The revised architecture separates the public application entry point from the container workload:

**Internet → HTTPS Application Load Balancer → Security Group → Private ECS/Fargate Tasks**

The ECS execution role and application task role are separated so that platform permissions and workload permissions can be managed independently.

Private AWS service access is designed through VPC endpoints for required services such as ECR, S3, and CloudWatch rather than requiring public IP addresses on the application tasks.

---

### Azure

The Azure implementation uses:

- Azure Kubernetes Service
- Azure Container Registry
- Azure Managed Identity
- Azure RBAC
- Azure Virtual Network
- Network Security Group
- Azure Monitor
- Log Analytics

The architecture disables the ACR administrative account and uses identity-based authorization between AKS and ACR.

The intended identity flow is:

**AKS Identity → Azure Authorization → ACR → Approved Container Image**

AKS is deployed into a dedicated subnet with an associated Network Security Group. Additional production controls such as private cluster access, network policies, workload identity, secrets integration, ingress protection, and egress controls would require further implementation.

---

### Google Cloud

The Google Cloud implementation uses:

- Google Kubernetes Engine
- Artifact Registry
- Google Cloud VPC
- Workload Identity
- Secret Manager
- Cloud Logging
- Cloud Monitoring

The GKE environment uses a custom VPC and subnet rather than relying on an automatically created network.

Workload Identity provides the foundation for allowing Kubernetes workloads to authenticate to Google Cloud services without embedding long-lived service-account credentials.

The project also creates a Secret Manager resource while intentionally keeping the actual secret value outside Terraform.

Production architecture would require additional evaluation of private nodes and control-plane access, network policies, admission controls, ingress and egress controls, image integrity, resilience, and other workload-specific requirements.

---

## Container Workload Security

The project Docker image uses:

- A minimal Node.js base image
- Production-only dependencies
- A dedicated non-root runtime user

The Kubernetes workload configuration demonstrates additional runtime controls including:

- Non-root execution
- Read-only root filesystem
- Prevention of privilege escalation
- Dropped Linux capabilities
- Runtime-default seccomp profile
- CPU and memory requests and limits
- Multiple replicas in the revised workload definition

These controls reduce unnecessary container privileges while keeping the example understandable.

---

## Image Security

Each cloud uses its native private container registry:

| Cloud | Registry |
|---|---|
| AWS | Amazon ECR |
| Azure | Azure Container Registry |
| Google Cloud | Artifact Registry |

The architecture treats image scanning as one input into a deployment decision rather than assuming every vulnerability produces the same response.

A production decision model would consider:

**Finding → Severity → Exploitability → Exposure → Business Criticality → Mitigation → Allow / Block / Exception**

The AWS implementation enables ECR scan-on-push.

Additional production capabilities could include continuous rescanning, image signing, provenance validation, SBOM generation, admission controls, and defined vulnerability-remediation timelines.

---

## Identity and Secrets

A common requirement across the three environments is to avoid long-lived credentials inside applications and infrastructure configuration.

The platforms implement this differently:

| Security Requirement | AWS | Azure | Google Cloud |
|---|---|---|---|
| Workload identity | IAM task roles | Managed Identity / Azure RBAC | Workload Identity |
| Registry authorization | IAM | AcrPull role | Google Cloud IAM |
| Secret-management capability | Secrets Manager / Parameter Store | Key Vault | Secret Manager |

Not every secret-management integration shown in this table is implemented by the lab.

The table represents the cloud-native capability that would satisfy the common security requirement.

The preferred pattern is:

**Workload Identity → Authorization → Secret Store → Authorized Secret**

---

## Network Security

The project treats network security as a traffic-flow and trust-boundary problem rather than simply opening the application's listening port.

The architecture asks:

**Who needs access? → Through which entry point? → To which workload? → On which protocol and port?**

AWS demonstrates this most explicitly through the revised ALB and private ECS architecture.

Azure and Google Cloud establish dedicated network foundations, while additional production ingress, egress, private connectivity, Kubernetes Network Policies, and application-layer protections would be selected according to workload requirements.

---

## Logging and Monitoring

The environments use cloud-native telemetry capabilities:

| Cloud | Telemetry |
|---|---|
| AWS | CloudWatch; CloudTrail as a production administrative telemetry source |
| Azure | Azure Monitor and Log Analytics |
| Google Cloud | Cloud Logging and Cloud Monitoring |

The architecture distinguishes between application telemetry, platform telemetry, identity activity, administrative events, registry activity, and security-control events.

A production implementation would also need to define:

- Required event sources
- Retention requirements
- Alerting criteria
- Incident ownership
- Telemetry health monitoring

Loss of expected security telemetry should itself be treated as a security condition.

---

## Infrastructure as Code

Terraform is used to define the cloud infrastructure for AWS, Azure, and Google Cloud.

Infrastructure as code provides:

- Repeatability
- Reviewability
- Version-controlled changes
- Consistent provisioning
- Easier teardown and reconstruction

However:

**Infrastructure as Code ≠ Secure Infrastructure**

Terraform configuration must still be evaluated against identity, network, data protection, logging, resilience, and business requirements.

The lifecycle is:

**Requirement → Configuration → Review → Deployment → Validation → Monitoring**

---

## Architecture Evolution

The original project focused on successfully deploying container workloads and applying foundational security controls.

Reviewing the implementation from a security architecture perspective identified several areas where a production design would need to go further.

Examples include:

- Moving AWS workloads behind a controlled application entry point
- Keeping ECS tasks in private subnets
- Separating ECS execution and workload roles
- Avoiding mutable `latest` image references
- Disabling Azure Container Registry administrative credentials
- Using explicit identity-based registry authorization
- Removing secret values from Terraform
- Strengthening Kubernetes runtime security
- Increasing workload redundancy
- Defining vulnerability decision criteria
- Expanding telemetry requirements
- Treating ingress and egress as architecture decisions
- Defining rollback and resilience requirements

This distinction is intentional.

The project shows both the implementation and the architectural review of that implementation.

---

## Security Requirements

Cross-cloud requirements are documented in:

`docs/security_requirements.md`

The requirements cover:

- Identity and access management
- Network security
- Data and secrets protection
- Workload hardening
- Container image and vulnerability management
- Logging, monitoring, and detection
- Infrastructure as code and change governance
- Environment segregation
- Availability and resilience
- Security exceptions
- Compliance and governance
- Business and delivery requirements

---

## Risks and Mitigations

Container risks and corresponding architecture considerations are documented in:

`docs/risks_mitigations.md`

The analysis includes:

- Compromised images
- Unauthorized registry access
- Lateral movement
- Credential and secret exposure
- Excessive workload privileges
- Logging and monitoring gaps
- Network exposure
- Cross-cloud configuration drift
- Security controls interfering with delivery
- Availability and resilience failures

---

## Supporting Documentation

Additional project documentation includes:

- `docs/technologies.md` — cloud-native technologies and why they are used
- `docs/security-controls.md` — security controls across the container lifecycle
- `docs/security_requirements.md` — target cross-cloud security requirements
- `docs/risks_mitigations.md` — architecture risks and mitigation strategies
- `docs/results-aws.md` — AWS implementation results and architecture evolution
- `docs/results-azure.md` — Azure implementation results and architecture evolution
- `docs/setup-aws.md` — AWS setup and validation
- `docs/setup-azure.md` — Azure setup and validation
- `docs/aws-container-teardown.md` — AWS cleanup procedure
- `docs/nist-iso-mapping.md` — architectural control-support mapping

---

## What This Project Demonstrates

The most important lesson from this project is that multi-cloud security does not require identical technology.

AWS ECS/Fargate, Azure AKS, and Google GKE have different architectures.

The security architect's job is to preserve the required security outcome across those differences.

For this scenario, the common model is:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

And the architecture decision process is:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

That is the consistency this project is designed to demonstrate.
