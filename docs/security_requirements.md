# Security Requirements — Multi-Cloud Container Platform

This document defines cross-cloud security requirements for containerized workloads running across AWS, Azure, and Google Cloud.

The requirements are intentionally platform-agnostic. The objective is to establish consistent security outcomes first and then determine how each cloud platform should implement them using its native capabilities.

These requirements represent the target architecture for a production container platform. The portfolio implementation demonstrates selected portions of the requirements and should not be interpreted as a complete production implementation.

The architecture model is:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

---

## 1. Identity and Access Management

### 1.1 Workload Identity

Containerized workloads should use platform-supported workload identities rather than long-lived static credentials.

Examples include:

- AWS IAM roles for ECS tasks or Kubernetes workloads.
- Azure managed identities and Workload Identity.
- Google Cloud Workload Identity.

Long-lived cloud credentials should not be embedded in:

- Source code.
- Container images.
- Terraform configuration.
- Kubernetes manifests.
- Application configuration.

### 1.2 Least Privilege

Workload permissions should be limited to the resources and actions required by the application.

This includes permissions for:

- Pulling container images.
- Accessing secrets.
- Calling cloud APIs.
- Accessing storage or databases.
- Writing logs and metrics.

Build, deployment, administrative, and runtime identities should be separated where practical.

### 1.3 Human Administrative Access

Human administrative access should use enterprise identity controls where available.

Production requirements should include:

- Federation through the organization's identity provider.
- MFA.
- Role-based access.
- Privileged-access controls where required.
- Centralized audit logging.
- Periodic access review.

The intended model is:

**Identity → Authentication → Authorization → Resource Access → Audit Evidence**

---

## 2. Network Security

### 2.1 Workload Exposure

Container workloads should not be directly exposed to the internet unless there is an explicit architecture requirement.

Public application access should pass through an approved entry point appropriate to the platform and workload, such as a load balancer, application gateway, ingress controller, API gateway, or other controlled service.

The intended flow is:

**Client → Approved Entry Point → Network/Security Control → Container Workload**

### 2.2 Network Segmentation

Network communication should be restricted to required traffic paths using controls such as:

- AWS Security Groups and VPC controls.
- Azure NSGs and VNet controls.
- Google Cloud firewall policies and VPC controls.
- Kubernetes Network Policies where Kubernetes is used.

East-west and north-south traffic should be evaluated separately.

### 2.3 Egress

Outbound connectivity should also be evaluated rather than assuming unrestricted internet access.

Production architecture should determine:

- Which external services workloads require.
- Whether private service connectivity is available.
- Whether outbound filtering is required.
- How DNS traffic is controlled and monitored.
- How unexpected outbound activity is detected.

### 2.4 Administrative Access

Administrative access to container platforms should use controlled management paths.

Depending on the platform, this may include:

- Private control-plane access.
- AWS Systems Manager.
- Bastion or controlled administrative hosts where necessary.
- VPN or private connectivity.
- Restricted Kubernetes API access.
- Strong identity and MFA.

Direct SSH access to container workloads should not be treated as the normal administration model.

---

## 3. Data and Secrets Protection

### 3.1 Encryption at Rest

Container registries, persistent storage, logs, secrets, and other sensitive platform data should use encryption at rest.

Provider-managed encryption may be appropriate for some workloads. Customer-managed keys should be evaluated where regulatory, contractual, separation-of-duties, or key-governance requirements justify them.

The existence of a customer-managed key should not automatically be treated as more secure without considering operational requirements and risk.

### 3.2 Encryption in Transit

Sensitive communication should use encrypted transport appropriate to the application and trust boundary.

TLS requirements should be defined for:

- External application traffic.
- Service-to-service communication where required.
- Registry communication.
- Administrative interfaces.
- Cloud API access.

### 3.3 Secrets

Secrets must not be stored in:

- Container images.
- Source control.
- Plaintext Terraform configuration.
- Unprotected configuration files.

Production architectures should use approved secret-management capabilities such as:

- AWS Secrets Manager or Parameter Store.
- Azure Key Vault.
- Google Secret Manager.

The preferred access model is:

**Workload Identity → Authorization → Secret Store → Authorized Secret**

Secret rotation, access logging, ownership, expiration, and emergency replacement requirements should also be defined.

---

## 4. Workload Hardening

### 4.1 Non-Root Execution

Containers should run as non-root unless the workload has a documented technical requirement and an approved exception.

### 4.2 Runtime Privileges

Production environments should evaluate restrictions on:

- Privileged containers.
- Host namespace access.
- Host filesystem mounts.
- Linux capabilities.
- Writable root filesystems.
- Container privilege escalation.

Controls should be selected according to workload requirements rather than applied indiscriminately.

### 4.3 Admission Control

Kubernetes platforms should evaluate admission controls that can prevent workloads violating defined security requirements from being deployed.

Depending on the platform, this may include:

- Kubernetes Pod Security controls.
- Native cloud admission capabilities.
- Policy engines.
- Organizational deployment policies.

### 4.4 Base Images

Application images should use approved, maintained, and appropriately minimal base images.

Base-image governance should consider:

- Vendor support.
- Patch availability.
- Package footprint.
- Known vulnerabilities.
- Image provenance.
- Required application dependencies.

---

## 5. Container Image and Vulnerability Management

### 5.1 Image Scanning

Container images should be scanned before production deployment using approved scanning capabilities.

Scanning may occur through:

- CI/CD security tooling.
- Cloud registry scanning.
- Independent container scanning tools.

### 5.2 Deployment Decisions

A vulnerability finding should trigger a risk decision rather than automatically producing the same result for every workload.

Deployment criteria should consider:

- Severity.
- Exploitability.
- Workload exposure.
- Business criticality.
- Availability of remediation.
- Compensating controls.
- Organizational risk tolerance.

The decision model is:

**Finding → Severity → Exploitability → Exposure → Business Impact → Mitigation → Allow / Block / Exception**

Critical findings without an approved exception would normally prevent production deployment.

High-severity findings should be evaluated against defined organizational thresholds.

### 5.3 Continuous Vulnerability Management

Previously approved images may become vulnerable after deployment as new vulnerabilities are disclosed.

Production environments therefore need a process for:

- Registry rescanning.
- Newly disclosed vulnerability detection.
- Ownership assignment.
- Remediation timelines.
- Image rebuilding.
- Risk acceptance and exception expiration.

---

## 6. Logging, Monitoring, and Detection

### 6.1 Required Telemetry

Security-relevant telemetry should be captured from appropriate sources, including:

- Container workloads.
- Container orchestration platforms.
- Cloud administrative APIs.
- Identity systems.
- Container registries.
- Network controls.
- Vulnerability-management systems.

Cloud-native sources may include:

**AWS**
- CloudWatch.
- CloudTrail.
- ECS/EKS platform telemetry.

**Azure**
- Azure Monitor.
- Log Analytics.
- Azure Activity Logs.
- AKS diagnostic telemetry.

**Google Cloud**
- Cloud Logging.
- Cloud Audit Logs.
- GKE telemetry.

### 6.2 Retention

Log retention should be based on:

- Incident-response requirements.
- Regulatory obligations.
- Audit requirements.
- Investigation timelines.
- Storage cost.

A single retention period should not be assumed for every organization or telemetry source.

### 6.3 Detection and Alerting

Production monitoring should define actionable alerts for security-relevant conditions such as:

- Repeated authentication failures.
- Unauthorized administrative activity.
- Policy violations.
- Unexpected registry activity.
- Suspicious network behavior.
- Critical vulnerability findings.
- Unexpected workload changes.

### 6.4 Telemetry Health

Loss of security telemetry is itself a security condition.

The architecture should detect situations where expected logs or metrics stop arriving.

---

## 7. Infrastructure as Code and Change Governance

### 7.1 Infrastructure as Code

Infrastructure definitions should be maintained in version control where appropriate.

Terraform and Kubernetes configuration provide repeatability and reviewability, but infrastructure as code does not automatically make an environment secure.

### 7.2 Change Review

Security-sensitive changes should be subject to appropriate review.

Examples include:

- IAM policies.
- Network exposure.
- Registry permissions.
- Secrets configuration.
- Kubernetes security policies.
- Logging configuration.

### 7.3 Validation

Deployment processes should validate that the intended security configuration actually exists after deployment.

The lifecycle is:

**Requirement → Configuration → Review → Deployment → Validation → Monitoring**

### 7.4 Drift

Production environments should have a method for identifying configuration drift or unauthorized changes.

---

## 8. Environment Segregation

Development, testing, and production environments should be separated according to business risk.

Depending on organizational scale and requirements, separation may use:

- AWS accounts.
- Azure subscriptions.
- Google Cloud projects.
- Separate clusters.
- Separate networks.
- Separate identities and permissions.

The objective is to reduce blast radius and prevent lower-trust environments from becoming an unintended path into production.

---

## 9. Availability and Resilience

Container security requirements must account for availability as well as confidentiality and integrity.

Production architecture should evaluate:

- Multiple tasks, pods, or nodes.
- Availability zones or regional deployment.
- Health checks.
- Autoscaling.
- Deployment rollback.
- Registry availability.
- Dependency failures.
- Control-plane failures.
- Monitoring failures.
- Backup and recovery requirements.

Resilience requirements should be driven by business availability and recovery objectives rather than by the availability of a particular cloud feature.

---

## 10. Security Exceptions

Not every security requirement will be technically or operationally appropriate for every workload.

Where a requirement cannot be met, the architecture should provide a controlled exception process.

An exception should identify:

- The requirement being waived.
- Business justification.
- Security risk.
- Compensating controls.
- Risk owner.
- Approval.
- Expiration or review date.

Exceptions should not silently become permanent architecture.

---

## 11. Compliance and Governance

The container architecture should be capable of supporting broader organizational security and compliance requirements.

Relevant frameworks may include:

- NIST SP 800-53.
- ISO/IEC 27001.
- CIS Benchmarks.
- Organization-specific security standards.

Cloud services and technical controls should not be treated as direct evidence of compliance by themselves.

The relationship is:

**Business / Regulatory Requirement → Security Control Objective → Architecture → Implementation → Evidence → Assessment**

---

## 12. Business and Delivery Requirements

Security controls should protect the organization without unnecessarily preventing legitimate delivery.

Where appropriate, security checks should be integrated into delivery workflows and provide actionable feedback to developers and platform teams.

The architecture should support:

- Clear deployment criteria.
- Defined security ownership.
- Controlled exceptions.
- Risk-based security gates.
- Rollback paths.
- Evidence explaining why a deployment was allowed or blocked.

The objective is not maximum restriction.

The objective is to reduce risk while allowing the business to operate.

---

## Cross-Cloud Architecture Principle

AWS ECS/Fargate, Azure AKS, and Google GKE do not use identical identity, networking, registry, monitoring, or runtime-security models.

They do not need to.

The common architecture model is:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence → Monitoring and Response**

This provides consistent security governance without forcing technically artificial equivalence between the cloud platforms.
