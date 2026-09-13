# Executive Case Study — Multi-Cloud Container Security Architecture

## Executive Summary

Organizations adopting containers across multiple cloud providers face a security challenge that is easy to underestimate.

The business may want consistent security and governance, but AWS, Azure, and Google Cloud do not implement container platforms, workload identity, networking, registries, or monitoring in the same way.

For this scenario, I did not try to force the three platforms into an identical technical architecture.

Instead, I started with the security outcomes the organization would need and mapped those requirements to the appropriate capabilities in each cloud.

The architecture decision model was:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

This allowed AWS ECS/Fargate, Azure AKS, and Google GKE to use different technologies while still supporting a common container security model.

---

## Business Problem

Assume an organization is expanding containerized applications across AWS, Azure, and Google Cloud.

Different teams may select platforms based on application requirements, existing cloud investments, technical skills, or business strategy.

That creates several security and operational concerns:

- How do we maintain consistent security requirements across different container platforms?
- How do we prevent credentials from becoming embedded in applications or deployment configuration?
- How do we control which container images are allowed into the environment?
- How do we limit application exposure and reduce lateral movement?
- How do we obtain sufficient telemetry for investigation and incident response?
- How do we introduce security controls without unnecessarily slowing application delivery?
- How do we prevent cloud-specific implementation differences from creating governance gaps?

The architecture therefore needed to provide consistency at the **security-requirement level**, not necessarily at the technology level.

---

## Architecture Approach

I organized the problem around the container lifecycle:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

At each stage, I asked the same basic questions:

- What are we protecting?
- What could go wrong?
- What security outcome is required?
- Where should the control be enforced?
- Which cloud-native capability best provides that control?
- What evidence would show that the control is operating?
- What happens if the control fails?

This created a common security architecture while allowing each cloud implementation to remain native to its platform.

---

## Consistent Outcomes, Different Implementations

The three environments deliberately do not use identical technology.

### AWS

AWS uses ECS with Fargate and ECR.

The revised architecture places the application behind an HTTPS Application Load Balancer while keeping ECS tasks in private subnets.

IAM separates the ECS execution role from the application task role, and private AWS service access can be provided through VPC endpoints.

The traffic model becomes:

**Internet → HTTPS Load Balancer → Security Group → Private ECS/Fargate Workload**

### Azure

Azure uses AKS and Azure Container Registry.

The architecture disables ACR administrative credentials and uses identity-based authorization for AKS to retrieve images.

AKS runs within a dedicated subnet with an associated Network Security Group, while Azure Monitor and Log Analytics provide platform visibility.

The identity model is:

**AKS Identity → Azure Authorization → ACR → Approved Container Image**

### Google Cloud

Google Cloud uses GKE and Artifact Registry.

The environment uses a custom VPC and subnet, with Workload Identity providing the foundation for workload authentication.

Secret Manager is represented as the approved location for sensitive values while keeping the secret itself outside Terraform.

These implementations differ, but they support common security objectives around identity, image protection, network boundaries, telemetry, and workload security.

---

## Identity as a Foundation

One of the most important architecture decisions was to avoid treating credentials as application configuration.

The common requirement is:

**Workload → Trusted Identity → Least-Privilege Authorization → Required Resource**

AWS implements this through IAM roles.

Azure uses managed identity and RBAC.

Google Cloud uses Workload Identity and IAM.

The technologies differ, but the security outcome is the same: applications should not depend on long-lived cloud credentials embedded in source code, container images, or infrastructure configuration.

This also creates a stronger foundation for secrets access, registry authorization, logging, and auditability.

---

## Container Image Risk

A private registry does not automatically make an image safe.

The architecture therefore treats vulnerability information as an input into a risk decision rather than simply asking whether an image was scanned.

The decision model is:

**Finding → Severity → Exploitability → Exposure → Business Criticality → Mitigation → Allow / Block / Exception**

For example, a critical vulnerability in an internet-facing production application would likely produce a different deployment decision than the same finding in an isolated development workload with compensating controls.

A production organization would define those thresholds, ownership rules, remediation expectations, and exception procedures according to its risk tolerance.

---

## Network Boundaries

Another important lesson from the project was that opening an application port is not a network architecture.

The more useful question is:

**Who needs access? → Through which entry point? → To which workload? → On which protocol and port?**

The revised AWS design demonstrates this directly by separating the public load balancer from private ECS tasks.

For AKS and GKE, the same principle would drive decisions around ingress, private connectivity, network policies, firewall rules, egress, and application-layer protection.

The control may be different on each platform, but the trust-boundary decision remains consistent.

---

## Runtime Security

The container itself also needs to operate with limited privileges.

The project demonstrates controls including:

- Non-root execution
- Read-only root filesystem
- Prevention of privilege escalation
- Dropped Linux capabilities
- Runtime-default seccomp
- Resource requests and limits

Additional runtime restrictions would depend on the workload and platform.

I would not apply every possible hardening control simply because it exists. The control should address an identified risk without unnecessarily interfering with application operation.

---

## Monitoring and Evidence

Security controls are much less useful if the organization cannot determine whether they are working.

The architecture therefore includes cloud-native telemetry:

- AWS CloudWatch
- Azure Monitor and Log Analytics
- Google Cloud Logging and Monitoring

A production implementation would also define which administrative, identity, registry, network, workload, and policy events must be captured.

Retention would be driven by investigation, audit, regulatory, and business requirements rather than by an arbitrary universal value.

I would also treat the unexpected loss of required telemetry as a security event itself.

---

## Security Without Blocking Delivery

Container security can fail operationally when controls are introduced without considering how development teams actually deliver software.

The goal should not be to block as many deployments as possible.

The goal is to make defensible risk decisions.

That means providing:

- Clear security requirements
- Automated checks where appropriate
- Actionable feedback
- Defined deployment criteria
- Controlled exceptions
- Risk ownership
- Rollback capability

A security control that repeatedly produces unnecessary deployment failures will eventually be bypassed, weakened, or ignored.

The architecture therefore needs to balance risk reduction with reliable delivery.

---

## Resilience as a Security Requirement

The original lab implementations were primarily focused on successful deployment and foundational security controls.

Reviewing them from an architecture perspective raised another question:

**What happens when something fails?**

That led to additional considerations around:

- Multiple tasks, pods, and nodes
- Health checks
- Availability zones and regional design
- Autoscaling
- Deployment rollback
- Registry dependencies
- Monitoring failures
- Backup and recovery
- External service dependencies

Availability is part of the security architecture when loss of the application or a critical security dependency affects the business.

---

## Architecture Evolution

One of the useful outcomes of this project was identifying the difference between a working deployment and a production security architecture.

The original implementation proved that the workloads could run across the three cloud environments.

The architecture review then identified where the designs needed to become stronger.

Examples included:

- Moving AWS workloads behind a controlled application entry point
- Keeping ECS tasks private
- Separating ECS execution and workload identities
- Replacing mutable image references
- Disabling ACR administrative access
- Using explicit identity-based registry authorization
- Removing secret values from Terraform
- Strengthening Kubernetes runtime controls
- Increasing workload redundancy
- Expanding monitoring expectations
- Defining vulnerability decision criteria
- Treating ingress and egress as explicit architecture decisions

I view that progression as important.

A successful deployment answers:

**Does it work?**

The architecture review has to answer:

**Should it work this way in production, what can fail, what evidence do we need, and what risk remains?**

---

## Governance and Compliance

The architecture can support broader frameworks such as NIST SP 800-53, ISO/IEC 27001, and CIS guidance.

However, I would not equate the presence of a cloud service or technical configuration with compliance.

The relationship is:

**Business / Regulatory Requirement → Security Control Objective → Architecture → Implementation → Evidence → Assessment**

Formal compliance depends on scope, policies, operating procedures, control effectiveness, evidence, exceptions, and organizational governance in addition to technical architecture.

---

## Business Outcome

The result is a multi-cloud container security model that does not depend on every cloud using the same technology.

Instead, it establishes a consistent way to make security decisions across different platforms.

The common container lifecycle is:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

The common architecture process is:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

That allows cloud teams to use the capabilities that fit their platforms while giving security leadership a consistent way to evaluate risk, governance, control effectiveness, and architecture decisions.

---

## Final Takeaway

The most important lesson from this project was that **multi-cloud security consistency does not mean technical uniformity**.

AWS ECS/Fargate, Azure AKS, and Google GKE can be architecturally different and still meet the same organizational security requirements.

The security architect's role is to define the required outcome, understand the risk, determine where controls belong, evaluate how each platform implements them, and make sure there is evidence that the resulting architecture actually provides the intended protection.
