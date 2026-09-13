# Technical Case Study — Multi-Cloud Container Security Architecture

## Purpose

This case study examines how I would secure containerized workloads across AWS, Azure, and Google Cloud while maintaining consistent security requirements across platforms with different architectures.

The project includes practical implementations using:

- AWS ECS with Fargate
- Azure Kubernetes Service
- Google Kubernetes Engine
- Amazon ECR
- Azure Container Registry
- Google Artifact Registry
- Terraform
- Docker
- Cloud-native identity, networking, and monitoring capabilities

The objective was not to make the three environments technically identical.

Instead, I used a common architecture process:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

I then evaluated those controls across the container lifecycle:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

This case study distinguishes between controls demonstrated in the project and additional controls I would evaluate for a production environment.

---

## 1. Architecture Problem

A multi-cloud container environment creates a security consistency problem.

AWS ECS/Fargate does not operate like AKS or GKE. Identity models differ. Network controls differ. Registry integrations differ. Kubernetes introduces controls that do not apply directly to ECS.

Trying to make every implementation identical would hide those differences rather than manage them.

For this scenario, I would define the security requirements centrally and allow each platform to satisfy them through the most appropriate native capability.

The questions I would use throughout the design are:

1. What asset or business process am I protecting?
2. What can go wrong?
3. What security outcome is required?
4. Where should the control be enforced?
5. Which platform capability provides that control?
6. What evidence proves the control is operating?
7. What happens when the control or dependency fails?

---

## 2. Architecture Scope

The project covers security decisions around:

- Container image construction
- Image storage
- Vulnerability scanning
- Workload identity
- Registry authorization
- Secrets
- Network boundaries
- Kubernetes and container runtime hardening
- Infrastructure as code
- Logging and monitoring
- Deployment decisions
- Resilience
- Security exceptions

The portfolio implementation demonstrates selected controls within those areas.

It is not intended to represent a complete production container platform.

---

## 3. Cross-Cloud Control Model

I mapped common requirements to platform-specific capabilities rather than treating cloud services as direct equivalents.

| Security Capability | AWS | Azure | Google Cloud |
|---|---|---|---|
| Container runtime | ECS/Fargate | AKS | GKE |
| Image registry | ECR | ACR | Artifact Registry |
| Workload identity | IAM task roles | Managed Identity / RBAC | Workload Identity |
| Network foundation | VPC / Security Groups | VNet / NSG | VPC / firewall capabilities |
| Secrets capability | Secrets Manager / Parameter Store | Key Vault | Secret Manager |
| Logging / monitoring | CloudWatch | Azure Monitor / Log Analytics | Cloud Logging / Monitoring |
| Infrastructure | Terraform | Terraform | Terraform |

The architecture requirement stays consistent even when the implementation changes.

For example:

**Requirement: Workloads must not depend on long-lived cloud credentials.**

That becomes:

**AWS IAM Role**

or

**Azure Managed Identity**

or

**Google Workload Identity**

The technology is different.

The required security outcome is not.

---

# 4. Build Stage

## Security Objective

The container artifact should contain only what the application requires and should not introduce unnecessary runtime privileges or embedded credentials.

## Implementation

The project Dockerfile uses:

- `node:20-slim`
- Production-only dependencies through `npm ci --omit=dev`
- A dedicated non-root application user
- A non-login shell
- Explicit application startup

The container therefore does not require root as its normal runtime identity.

## Architecture Decision

I kept the Dockerfile relatively simple rather than trying to place every container security control inside the image.

Some controls belong at build time.

Others belong at deployment or runtime.

For example:

**Dockerfile**
- Base image
- Application dependencies
- Runtime user

**Kubernetes workload configuration**
- Read-only filesystem
- Privilege escalation
- Linux capabilities
- Seccomp
- Resource limits

This keeps control ownership aligned with the stage where the control is actually enforced.

## Evidence

I would examine:

- Dockerfile
- Base-image version
- Dependency lock file
- Image build output
- Runtime user
- Image metadata
- Vulnerability scan results

## Failure Example

A container may be configured as non-root in Kubernetes but still contain unnecessary packages or vulnerable dependencies.

Conversely, a minimal image does not protect against an overly privileged runtime configuration.

Container security therefore cannot stop at the Dockerfile.

---

# 5. Scan Stage

## Security Objective

Known vulnerabilities should be identified before a workload reaches production.

## Implementation

The AWS configuration enables ECR scan-on-push.

The broader architecture supports registry or pipeline-based vulnerability scanning across the platforms.

I would not treat the existence of a scanner as sufficient evidence that an image is safe.

The important question is what happens after a finding is discovered.

## Deployment Decision Model

I would evaluate findings using:

**Finding → Severity → Exploitability → Exposure → Business Criticality → Mitigation → Decision**

Possible decisions include:

**ALLOW**

**BLOCK**

**REMEDIATE**

**APPROVED EXCEPTION**

A critical vulnerability in an externally exposed production workload should not necessarily receive the same treatment as the same vulnerability in an isolated development workload.

## Production Considerations

A production vulnerability-management process would need:

- Defined severity criteria
- Exploitability context
- Remediation SLAs
- Image ownership
- Registry rescanning
- Newly disclosed CVE handling
- Exception approval
- Exception expiration
- Image rebuilding
- Deployment enforcement

## Failure Example

A build can pass its vulnerability gate on Monday and contain a newly disclosed vulnerability on Wednesday.

That means:

**Pre-deployment scanning alone is insufficient.**

Registry rescanning and deployed-workload vulnerability management would also be required.

---

# 6. Store Stage

## Security Objective

Only authorized users and workloads should be able to push or retrieve approved container artifacts.

## AWS

Amazon ECR is used for container storage.

The revised configuration uses:

- Private ECR repository
- Immutable image tags
- Scan-on-push
- IAM authorization
- Encryption at rest

Using immutable tags reduces the risk that the artifact associated with an existing tag is silently replaced.

## Azure

Azure Container Registry provides the Azure image repository.

The architecture disables:

`admin_enabled`

and instead uses Azure identity and RBAC.

AKS receives explicit `AcrPull` authorization.

The trust path becomes:

**AKS Identity → Azure RBAC → ACR → Container Image**

## Google Cloud

Artifact Registry provides the GCP image repository.

Access is governed through Google Cloud IAM.

## Architecture Decision

The common requirement is not:

**Use the same registry technology everywhere.**

It is:

**Only authorized identities may publish or retrieve approved artifacts.**

## Evidence

I would examine:

- Registry configuration
- Registry IAM/RBAC
- Image tags or digests
- Push and pull activity
- Vulnerability results
- Administrative access
- Image provenance where implemented

## Failure Example

A private registry with overly broad write permissions could still allow an unauthorized or compromised identity to replace an application image.

Private does not automatically mean trusted.

---

# 7. Authenticate Stage

## Security Objective

Applications should authenticate to cloud resources without carrying long-lived credentials.

## AWS

The revised ECS architecture separates:

**ECS Task Execution Role**

from:

**Application Task Role**

The execution role supports platform activities such as retrieving images and sending logs.

The task role represents permissions required by the application itself.

I would add only application permissions actually required by the workload.

## Azure

AKS uses Azure managed identity and RBAC.

The architecture explicitly grants the AKS kubelet identity `AcrPull` access to the registry rather than enabling ACR administrative credentials.

## Google Cloud

GKE enables Workload Identity.

The architecture provides the foundation for Kubernetes workloads to authenticate to Google Cloud APIs without embedding service-account keys in containers.

## Architecture Principle

The common model is:

**Workload → Trusted Identity → Least-Privilege Authorization → Required Resource**

## Evidence

I would examine:

- IAM policies
- Azure role assignments
- Google IAM bindings
- Workload identity configuration
- Authentication logs
- Privileged access activity
- Unused permissions

## Failure Example

Using workload identity does not automatically create least privilege.

A correctly authenticated workload can still have excessive authorization.

Identity architecture therefore requires both:

**Who are you?**

and

**What are you allowed to do?**

---

# 8. Secrets

## Security Objective

Sensitive values should remain outside source code, container images, and infrastructure definitions.

## Implementation

The GCP Terraform creates a Secret Manager resource but intentionally does not create the secret value in Terraform.

That distinction is important.

Terraform state can contain values supplied through Terraform resources. Moving a plaintext secret from application code into Terraform does not automatically solve the secret-management problem.

## Production Pattern

The preferred model is:

**Workload Identity → Authorization → Secret Store → Authorized Secret**

Cloud-native options include:

- AWS Secrets Manager or Parameter Store
- Azure Key Vault
- Google Secret Manager

The project does not claim that all three secret integrations were implemented.

## Production Requirements

I would also evaluate:

- Secret rotation
- Secret ownership
- Expiration
- Access logging
- Emergency replacement
- Least-privilege retrieval
- Separation between human and workload access

## Failure Example

A secret may be safely stored in a secret manager but still be exposed if the workload identity has excessive permissions or the application writes the value into logs.

Secret storage is only one part of secret protection.

---

# 9. Deploy Stage

## Security Objective

Only intended artifacts and approved configurations should reach the runtime environment.

Terraform provides repeatable infrastructure configuration across all three clouds.

Kubernetes manifests define the AKS/GKE workload configuration.

## Architecture Decision

I treat infrastructure as code as a governance mechanism, not as a security control by itself.

The process is:

**Requirement → Configuration → Review → Deployment → Validation → Monitoring**

Terraform makes the architecture visible and repeatable.

It does not prove that the configuration is secure.

## Image References

The revised workload configuration uses versioned image references rather than `latest`.

For production, I would evaluate stronger artifact integrity mechanisms such as immutable digests, signing, provenance, and admission enforcement depending on organizational requirements.

## Evidence

I would examine:

- Terraform plans
- Source-control history
- Peer review
- Kubernetes manifests
- Deployment history
- Image references
- Post-deployment validation

## Failure Example

A Terraform deployment can complete successfully while creating an insecure environment.

`terraform apply` proves that infrastructure was created.

It does not prove that the architecture meets the security requirement.

---

# 10. AWS Network Architecture

The AWS implementation showed one of the clearest areas where the original deployment could be improved through architecture review.

## Revised Traffic Flow

The target design is:

**Internet → HTTPS ALB → ALB Security Group → ECS Security Group → Private Fargate Task**

The ALB is placed in public subnets.

The ECS workloads are placed in private subnets and do not receive public IP addresses.

The ECS Security Group accepts application traffic only from the ALB Security Group.

## AWS Service Dependencies

Private ECS tasks still need access to AWS services to start and operate.

Instead of assuming that "private subnet" solves the problem, I also considered the dependency path.

The revised architecture includes VPC endpoints for:

- ECR API
- ECR Docker registry
- S3
- CloudWatch Logs

The dependency flow becomes:

**Private ECS Task → VPC Endpoint → Required AWS Service**

This allows the example to avoid giving the tasks public IP addresses simply so they can retrieve an image or send logs.

## Architecture Lesson

Private placement alone is not sufficient.

The question is:

**What dependencies does the workload require, and how will it reach them?**

Without that analysis, a secure-looking network architecture can create an application that cannot start.

## Evidence

I would validate:

- Subnet placement
- Public-IP assignment
- Security Group rules
- ALB listener
- Target-group health
- VPC endpoint configuration
- ECS task health
- ECR connectivity
- CloudWatch log delivery

## Failure Paths

Examples include:

**ALB healthy, task unhealthy**

Possible causes:
- Application not listening
- Security Group mismatch
- Health-check failure
- Incorrect target port

**Task cannot start**

Possible causes:
- ECR access failure
- IAM execution-role failure
- Missing endpoint/dependency
- Invalid image reference

**Application works but logs disappear**

Possible causes:
- CloudWatch connectivity
- Execution-role permissions
- Logging configuration
- Application failure

This is why I would validate both the positive path and the dependency/failure paths.

---

# 11. Azure Network and Identity Architecture

The Azure implementation uses:

- Dedicated VNet
- AKS subnet
- Associated Network Security Group
- Managed identity
- Azure RBAC
- ACR
- Log Analytics

## Registry Access

The ACR administrative account is disabled.

AKS receives explicit `AcrPull` authorization through its identity.

That removes the need to use persistent registry administrator credentials for normal AKS image retrieval.

## Network Boundary

The NSG is associated with the AKS subnet.

However, the current portfolio configuration does not claim detailed segmentation through custom restrictive NSG rules.

That would require workload-specific traffic requirements.

For a production environment, I would evaluate:

- Private AKS API access
- Private ACR connectivity
- Kubernetes Network Policies
- Ingress architecture
- WAF requirements
- Egress controls
- Private endpoints
- Administrative access paths

## Architecture Lesson

The presence of an NSG is not the same as having a network-security design.

The design begins with the required traffic flow.

**Source → Entry Point → Destination → Protocol → Port → Business Requirement**

The control is then configured to permit that required path and restrict unnecessary access.

---

# 12. Google Cloud Network and Identity Architecture

The GCP implementation uses:

- Custom VPC
- Custom subnet
- Private Google access
- GKE
- Artifact Registry
- Workload Identity
- Secret Manager
- Cloud Logging and Monitoring

## Network Foundation

The project disables automatic subnet creation and explicitly creates the network used by GKE.

That gives the architecture a defined network foundation instead of relying on a default network.

## Workload Identity

Workload Identity is enabled at the cluster level, and the node configuration uses GKE workload metadata.

This provides the foundation for workload-specific cloud authentication.

## Production Considerations

The portfolio configuration is not a private GKE architecture.

For production I would evaluate:

- Private nodes
- Control-plane exposure
- Authorized administrative networks
- Kubernetes Network Policies
- Ingress architecture
- Egress restrictions
- Firewall policies
- Admission controls
- Binary Authorization or other image-integrity controls
- Regional cluster requirements

## Architecture Lesson

`private_ip_google_access = true` does not mean the GKE cluster itself is private.

Architecture documentation needs to distinguish the exact control that exists from a stronger architecture that may be recommended later.

---

# 13. Protect at Runtime

The Kubernetes deployment demonstrates several runtime controls:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

The pod also uses:

```yaml
seccompProfile:
  type: RuntimeDefault
```

## Why These Controls Matter

### Non-Root Execution

Reduces the privileges available to the application process.

### Read-Only Root Filesystem

Reduces the ability of a compromised application to modify the container filesystem.

### No Privilege Escalation

Prevents the process from gaining additional privileges through mechanisms such as setuid binaries.

### Drop Linux Capabilities

Removes kernel capabilities that the application does not require.

### RuntimeDefault Seccomp

Applies the runtime's default syscall filtering profile.

## Architecture Decision

These are strong defaults for this simple application.

I would still validate that the workload operates correctly before making them mandatory across every container.

Some applications legitimately require additional capabilities or writable paths.

Those cases should result in an explicit requirement or exception rather than quietly weakening the platform baseline.

---

# 14. Kubernetes Service Exposure

The original Kubernetes Service used:

`type: LoadBalancer`

That made the service itself the external exposure mechanism.

The revised workload uses:

`type: ClusterIP`

This keeps the application service internal to the cluster.

External access can then be designed separately through an approved ingress architecture.

The intended flow is:

**Client → Approved Entry Point → Ingress / Security Control → Kubernetes Service → Pod**

This creates a cleaner separation between:

- Application workload
- Internal service discovery
- External exposure
- Edge security

For production, the actual ingress architecture would depend on the cloud, application requirements, TLS termination, WAF requirements, authentication, availability, and operational model.

---

# 15. Monitor Stage

## Security Objective

The organization must be able to determine what happened, whether security controls are functioning, and whether investigation is required.

## AWS

The project uses CloudWatch for ECS application logging.

CloudTrail would be an important production source for administrative and API activity.

## Azure

AKS uses Log Analytics and Azure Monitor.

The revised configuration distinguishes between:

- Container/workload monitoring
- AKS control-plane diagnostic telemetry
- Platform metrics

## Google Cloud

GKE integrates with Cloud Logging and Cloud Monitoring.

## Production Telemetry Model

I would define required telemetry by event type rather than simply enabling every available log.

Relevant sources include:

- Workload activity
- Authentication
- Authorization failures
- Administrative changes
- Registry activity
- Kubernetes API activity
- Network-security events
- Vulnerability findings
- Policy violations

I would also monitor for:

**Expected telemetry stops arriving**

because the loss of security visibility may indicate either a technical failure or deliberate interference.

## Evidence

I would validate:

- Expected log sources
- Successful ingestion
- Timestamps
- Identity context
- Retention
- Alert routing
- Telemetry gaps

---

# 16. Respond Stage

Detection is useful only if there is an expected response.

For a production container platform, I would define response paths for conditions such as:

- Critical vulnerability discovered
- Unauthorized registry modification
- Suspicious administrative activity
- Compromised workload identity
- Unexpected network activity
- Runtime policy violation
- Secret exposure
- Loss of security telemetry

Possible actions could include:

- Block deployment
- Remove workload from service
- Revoke identity access
- Rotate credentials or secrets
- Roll back application version
- Isolate network access
- Preserve evidence
- Escalate to incident response

The appropriate response would depend on severity and business impact.

---

# 17. Availability and Resilience

Security architecture also needs to consider whether security controls create new availability dependencies.

The original lab used minimal resources appropriate for demonstrating functionality.

The revised architecture moves toward stronger resilience by using:

- Multiple ECS tasks
- Multiple AKS nodes
- Multiple Kubernetes replicas
- Load-balancer health checks

For production, I would additionally evaluate:

- Availability zones
- Regional architecture
- Autoscaling
- Pod disruption
- Registry availability
- Control-plane availability
- Dependency failures
- Rollback
- Backup and recovery
- Monitoring failure

## Failure Question

For every important control I would ask:

**What happens if this component becomes unavailable?**

For example, blocking all deployments when a vulnerability scanner is unavailable may create an operational outage.

Allowing every deployment when the scanner is unavailable may create a security bypass.

That requires an explicit fail-open, fail-closed, or exception decision based on business risk.

---

# 18. Security Exceptions

Not every workload will satisfy every baseline requirement.

A legacy application may require:

- Writable storage
- A specific Linux capability
- Unusual network connectivity
- A temporarily vulnerable dependency

I would not silently weaken the baseline for everyone.

Instead, I would require an exception containing:

- Requirement being waived
- Technical reason
- Business justification
- Risk
- Compensating controls
- Risk owner
- Approval
- Expiration or review date

That preserves the security baseline while allowing documented business exceptions.

---

# 19. Architecture Evolution from the Original Lab

One of the strongest lessons from this project came from reviewing the original implementation after it worked.

The initial question was largely:

**Can I deploy the workload successfully?**

The architecture review changed the question to:

**Would I approve this design for a production environment, and what would I need to know before doing so?**

That review produced several changes.

| Original / Early Implementation | Architecture Evolution |
|---|---|
| AWS workload exposure was less controlled | Public ALB separated from private ECS workloads |
| ECS task count was minimal | Multiple tasks used in revised architecture |
| Execution/workload identity distinction was limited | Separate execution and task roles |
| Mutable image references | Versioned/immutable image strategy |
| ACR administrator enabled | ACR administrator disabled |
| Registry access less explicit | Identity-based `AcrPull` authorization |
| Azure NSG existed without association | NSG associated with AKS subnet |
| GCP secret value represented in Terraform | Secret value removed from Terraform |
| Kubernetes workload used basic hardening | Added privilege escalation, capabilities, and seccomp controls |
| Kubernetes Service directly exposed through LoadBalancer | Internal ClusterIP with external ingress treated separately |
| Monitoring primarily proved logs existed | Telemetry requirements expanded around security evidence |
| Deployment success was primary validation | Functional + security + failure-path validation |

This progression is important because architecture is not simply adding more security services.

It is understanding:

**What is the requirement?**

**What can fail?**

**Where should the control sit?**

**How do I know it works?**

**What business impact does the decision create?**

---

# 20. Validation Strategy

For a production implementation, I would validate the architecture at multiple levels.

## Functional Validation

Does the application operate?

Examples:

- Tasks/pods running
- Service reachable through intended path
- Image successfully retrieved
- Application responds

## Security Validation

Are the controls operating as intended?

Examples:

- No unintended public workload exposure
- Correct workload identity
- Registry authorization limited
- Non-root container
- Security context enforced
- Secret absent from source and Terraform
- Expected telemetry arriving

## Negative-Path Validation

Do prohibited actions fail?

Examples:

- Unauthorized registry pull
- Unauthorized secret retrieval
- Direct workload access
- Privileged workload deployment
- Unapproved network path

## Failure-Path Validation

What happens when a dependency fails?

Examples:

- Registry unavailable
- Identity authorization fails
- Logging stops
- Load-balancer health check fails
- Vulnerability scanner unavailable
- Node or task fails

## Evidence Validation

Can the organization prove what happened?

Examples:

- IAM/RBAC records
- Terraform configuration
- Registry records
- Container scan results
- Cloud logs
- Kubernetes events
- Deployment history
- Approved exceptions

---

# 21. Key Tradeoffs

## Native Services vs. Standardization

Using native cloud services creates implementation differences but usually provides stronger integration with each platform's identity, networking, and operational model.

I would standardize the requirement and evidence model before trying to standardize every technology.

## Security vs. Delivery

Controls that create excessive false positives or unexplained deployment failures will create pressure to bypass security.

Security gates need risk-based criteria and actionable feedback.

## Private Connectivity vs. Complexity

Private networking reduces exposure but introduces dependencies around DNS, endpoints, routing, administration, and cost.

A private architecture still needs a complete dependency analysis.

## Strong Defaults vs. Application Compatibility

Runtime restrictions such as read-only filesystems and dropped capabilities reduce risk, but they must be tested against legitimate application requirements.

Exceptions should be controlled rather than weakening the baseline globally.

## Security Depth vs. Portfolio Scope

I intentionally did not add every possible cloud security product to this project.

The objective is to demonstrate architecture reasoning and control placement, not to create the largest possible technology list.

---

# 22. Production Architecture Gaps

Before approving this design for production, I would need additional decisions around areas such as:

- Business criticality
- Data classification
- Recovery objectives
- Availability requirements
- Private cluster requirements
- Kubernetes Network Policies
- Ingress and WAF architecture
- Egress filtering
- Secrets integration
- Image signing and provenance
- SBOM requirements
- Admission controls
- Vulnerability remediation SLAs
- Runtime detection
- Central SIEM integration
- Alert ownership
- Backup and recovery
- Autoscaling
- Regional resilience
- Environment separation
- Enterprise identity federation
- Privileged access
- Exception governance

Those decisions cannot be made correctly from the technology alone.

They require business and risk context.

---

# 23. Final Architecture Model

The technical implementation can be summarized through the container lifecycle:

**Build → Scan → Store → Authenticate → Deploy → Protect at Runtime → Monitor → Respond**

At each stage, the architecture decision follows:

**Business Requirement → Risk → Security Requirement → Required Capability → Cloud-Native Implementation → Evidence**

The cloud platforms then implement those requirements differently:

**AWS ECS/Fargate**

**Azure AKS**

**Google GKE**

The objective is not technical uniformity.

The objective is a consistent and defensible security outcome.

---

# Final Takeaway

The biggest distinction I took from this project is the difference between a **working container deployment** and a **security architecture**.

A working deployment tells me that the application can run.

A security architecture requires me to understand the identity path, network path, artifact path, trust boundaries, dependencies, telemetry, failure behavior, remaining risk, and business impact.

That is why I would not evaluate this environment by asking whether AWS, Azure, and Google Cloud use the same controls.

I would evaluate it by asking whether each platform can demonstrate that the organization's security requirements are being met, what evidence supports that conclusion, and what happens when those controls fail.
