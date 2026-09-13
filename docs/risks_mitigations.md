# Risks and Mitigations — Multi-Cloud Container Security

This document identifies key security risks associated with running containerized workloads across AWS, Azure, and Google Cloud and describes how I would address those risks architecturally.

Some controls are demonstrated directly in this portfolio project, while others represent controls I would evaluate or require when moving the architecture into a production environment.

The objective is not to make AWS, Azure, and Google Cloud implementations identical. The objective is to achieve consistent security outcomes using the capabilities appropriate to each platform.

---

## 1. Compromised Container Image

**Risk:** A vulnerable, malicious, or improperly configured image is deployed into the environment.

### Demonstrated in This Project

- Private cloud container registries.
- Container image scanning capabilities.
- Minimal application container image.
- Application container configured to run as a non-root user.

### Production Architecture Considerations

I would define a vulnerability-response policy that determines whether an image can proceed based on factors such as:

- Vulnerability severity.
- Known exploitability.
- Workload exposure.
- Business criticality.
- Availability of a remediation.
- Existing compensating controls.
- Approved risk exceptions.

A critical or high-severity finding should therefore not automatically produce the same decision in every situation.

The decision flow would be:

**Image → Scan → Evaluate Risk → Allow / Block / Exception → Deploy**

---

## 2. Unauthorized Registry Access

**Risk:** An unauthorized identity pulls sensitive images or pushes malicious or unapproved images into a container registry.

### Demonstrated in This Project

The architecture uses cloud-native registries:

- Amazon ECR.
- Azure Container Registry.
- Google Artifact Registry.

The revised architecture also favors workload identities and IAM authorization rather than persistent registry credentials.

### Production Architecture Considerations

I would evaluate:

- Least-privilege push and pull permissions.
- Separation between build identities and runtime identities.
- Administrative access restrictions.
- Private registry connectivity where appropriate.
- Registry audit logging.
- Detection of unusual push, pull, or administrative activity.
- Image immutability and artifact-integrity controls.

---

## 3. Lateral Movement Between Workloads

**Risk:** An attacker compromises one workload and uses its network access or identity permissions to reach other workloads or services.

### Demonstrated in This Project

The cloud environments use dedicated networking and cloud-native network controls around the container platforms.

### Production Architecture Considerations

For Kubernetes environments, I would evaluate:

- Kubernetes Network Policies.
- Namespace and workload segmentation.
- Separate environments for workloads with different trust requirements.
- Controlled east-west communication.
- Service-to-service identity where appropriate.

For AWS ECS/Fargate, I would use Security Groups and network architecture to restrict workload communication to required paths.

The architectural objective is:

**Explicitly Required Communication → Allowed**

**Unnecessary Communication → Denied**

---

## 4. Credential and Secret Exposure

**Risk:** Credentials or secrets are embedded in source code, container images, Terraform configuration, environment files, or other insecure locations.

### Demonstrated in This Project

The architecture uses workload identity concepts across the cloud platforms and includes Google Secret Manager as an example of external secret storage.

Secret values are intentionally excluded from the revised Terraform configuration.

### Production Architecture Considerations

I would evaluate:

- AWS Secrets Manager or Parameter Store.
- Azure Key Vault.
- Google Secret Manager.
- Workload identities instead of persistent credentials.
- Least-privilege secret access.
- Secret rotation requirements.
- Repository and infrastructure-as-code secret scanning.
- Audit logging for secret access.

The preferred model is:

**Workload Identity → Authorization → Secret Manager → Authorized Secret**

rather than distributing long-lived credentials to workloads.

---

## 5. Excessive Container Privileges

**Risk:** A compromised container obtains permissions that allow it to affect the underlying host, cluster, or other workloads.

### Demonstrated in This Project

The application Dockerfile runs the Node.js process as a non-root user.

### Production Architecture Considerations

Depending on the container platform, I would evaluate controls such as:

- Preventing privileged containers.
- Restricting host namespace access.
- Restricting host filesystem mounts.
- Read-only root filesystems where compatible with the application.
- Linux capability restrictions.
- Kubernetes Pod Security controls.
- Admission policies.
- Runtime security monitoring.

These controls would need to be tested against application requirements rather than applied indiscriminately.

---

## 6. Inadequate Logging and Monitoring

**Risk:** Security-relevant activity occurs without sufficient telemetry for detection, investigation, or response.

### Demonstrated in This Project

The architecture includes cloud-native logging and monitoring capabilities such as:

- Amazon CloudWatch and AWS platform telemetry.
- Azure Log Analytics and Azure Monitor.
- Google Cloud logging and monitoring.

### Production Architecture Considerations

I would define which events are required based on the workload and threat model, including:

- Administrative activity.
- Authentication and authorization events.
- Container platform changes.
- Registry activity.
- Workload failures.
- Network-security events.
- Security policy violations.
- Vulnerability findings.

I would also monitor the monitoring system itself.

Loss of expected telemetry should be detectable rather than silently creating a visibility gap.

---

## 7. Misconfigured Network Exposure

**Risk:** A workload intended for limited or internal access becomes unnecessarily exposed to the internet.

### Demonstrated in This Project

The architecture review identified overly broad ingress as a security concern and revised the AWS design so that the application entry point and container workload have separate trust boundaries.

The Azure and Google Cloud implementations similarly require network access to be tied to the intended application flow rather than opening a workload port simply because the application listens on it.

### Production Architecture Considerations

For each workload, I would determine:

**Who needs access? → From where? → Through what entry point? → To which workload? → On which protocol/port?**

I would then evaluate:

- Public versus private endpoints.
- Load balancers and ingress controllers.
- Security Groups, NSGs, firewall policies, and Kubernetes Network Policies.
- WAF requirements.
- Egress restrictions.
- Private connectivity.
- Periodic exposure reviews.

---

## 8. Security Drift Between Clouds

**Risk:** AWS, Azure, and Google Cloud environments gradually develop different security postures because the underlying services and configuration models differ.

The answer is not necessarily to force identical technical implementations.

### Architecture Approach

I would define common security requirements first and then map them to the appropriate cloud-native capabilities.

For example:

| Security Requirement | AWS | Azure | Google Cloud |
|---|---|---|---|
| Container Registry | ECR | ACR | Artifact Registry |
| Workload Identity | IAM task/workload roles | Managed/Workload Identity | Workload Identity |
| Network Enforcement | Security Groups/VPC controls | NSG/VNet controls | VPC firewall controls |
| Secrets | Secrets Manager | Key Vault | Secret Manager |
| Logging | CloudWatch/CloudTrail | Azure Monitor/Log Analytics | Cloud Logging/Audit Logs |

Terraform and version control can then make those decisions repeatable and reviewable.

The architectural goal is:

**Consistent Security Requirement → Platform-Specific Implementation → Consistent Security Outcome**

---

## 9. Security Controls Blocking Legitimate Delivery

**Risk:** Security controls are implemented without sufficient business context and unnecessarily prevent teams from deploying legitimate changes.

Controls that are routinely bypassed because they do not account for business requirements can ultimately weaken the security program.

### Production Architecture Considerations

I would define:

- Clear deployment criteria.
- Actionable feedback for developers.
- Risk-based vulnerability thresholds.
- Exception and risk-acceptance processes.
- Approval requirements for higher-risk exceptions.
- Expiration and review of exceptions.
- Evidence showing why a deployment was allowed or blocked.

New controls may initially operate in monitoring mode where appropriate so their impact can be understood before enforcement.

The objective is not simply:

**Finding = Block**

The stronger decision model is:

**Finding → Severity → Exploitability → Exposure → Business Criticality → Mitigations → Decision**

---

## 10. Availability and Resilience Failure

**Risk:** Security architecture protects the workload but introduces a single point of failure or prevents the application from recovering when infrastructure fails.

The original lab configurations used minimal infrastructure appropriate for demonstrating deployment. The architecture review identified resilience as an additional production requirement.

### Production Architecture Considerations

Depending on the workload requirements, I would evaluate:

- Multiple container tasks, pods, or nodes.
- Availability-zone or regional architecture.
- Health checks.
- Autoscaling.
- Controlled rollback.
- Registry availability.
- Dependency failure.
- Logging and monitoring failure.
- Backup and recovery requirements.

Security and resilience need to be evaluated together because a control that creates an unacceptable availability risk may not be the correct architecture.

---

## Architecture Perspective

The common container security lifecycle across the three environments is:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

Each stage introduces different risks and requires different controls.

The cloud implementations do not have to be identical. What needs to remain consistent is the reasoning used to determine:

- What are we protecting?
- What could go wrong?
- Which control reduces that risk?
- Where should the control be enforced?
- What evidence shows that it worked?
- What happens if the control fails?
- What is the business impact?

That is the security architecture model used throughout this project.
