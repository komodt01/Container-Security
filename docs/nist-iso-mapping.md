# NIST 800-53 and ISO 27001 Security Alignment

This document identifies how the security capabilities demonstrated in this project can support selected NIST SP 800-53 and ISO/IEC 27001 security objectives.

The mappings are architectural references rather than statements of compliance. Implementing a cloud service, Terraform configuration, or container security control does not by itself satisfy a NIST or ISO requirement. Compliance depends on organizational scope, policies, procedures, implementation evidence, control effectiveness, risk decisions, and ongoing governance.

## NIST SP 800-53 Alignment

### Access Control

The project demonstrates identity and access concepts through AWS IAM roles, Azure managed identities and RBAC, and Google Cloud Workload Identity and IAM.

These capabilities can support access-control objectives such as:

- AC-2 — Account Management
- AC-3 — Access Enforcement
- AC-6 — Least Privilege

The relevant architectural principle is to provide workloads and platform components only the permissions required for their intended functions.

## Configuration Management

Terraform is used to define cloud infrastructure in a repeatable and reviewable form.

Infrastructure as code can support configuration-management objectives such as:

- CM-2 — Baseline Configuration
- CM-3 — Configuration Change Control
- CM-6 — Configuration Settings

Terraform does not itself satisfy these controls. Production implementation would also require appropriate source control, review, approval, testing, deployment governance, drift management, and exception processes.

## System and Information Integrity

Container image scanning, vulnerability visibility, and security monitoring can support system and information integrity objectives such as:

- SI-2 — Flaw Remediation
- SI-4 — System Monitoring
- SI-7 — Software, Firmware, and Information Integrity

Image scanning identifies potential vulnerabilities, but findings still require risk evaluation and a defined remediation or exception process.

## Audit and Accountability

AWS CloudWatch and CloudTrail, Azure Log Analytics and platform diagnostics, and Google Cloud Logging and monitoring capabilities provide telemetry that can support audit and accountability objectives such as:

- AU-2 — Event Logging
- AU-6 — Audit Record Review, Analysis, and Reporting
- AU-12 — Audit Record Generation

Production environments would also need decisions around required event sources, retention, access protection, alerting, correlation, investigation, and telemetry-health monitoring.

## System and Communications Protection

Network segmentation, security groups, subnet controls, firewall capabilities, private workload placement, and controlled ingress and egress can support objectives within the System and Communications Protection family.

The implementation differs across AWS, Azure, and Google Cloud, but the architectural objective remains consistent:

**Define the trust boundary, determine permitted communication, restrict unnecessary paths, and generate evidence of security-relevant activity.**

## ISO/IEC 27001 Alignment

The project also demonstrates technical capabilities relevant to ISO/IEC 27001:2022 Annex A areas, including:

- Identity management
- Access control
- Authentication information
- Configuration management
- Logging
- Monitoring activities
- Network security
- Segregation of networks
- Use of cryptography
- Management of technical vulnerabilities
- Secure development and deployment practices

These capabilities can contribute evidence to an organization's broader information security management system, but they do not independently establish ISO 27001 conformity.

## Cross-Cloud Architecture Perspective

The three cloud platforms do not need identical services or configurations to support the same security objective.

For this project, the architecture approach is:

**Security Requirement → Risk → Required Capability → Cloud-Native Implementation → Evidence → Monitoring → Remediation or Exception**

For example, workload identity may be implemented differently through AWS IAM roles, Azure managed identities, and Google Cloud Workload Identity. The technologies differ, while the security objective of minimizing persistent credentials and enforcing least-privilege workload access remains consistent.

## Compliance Boundary

This project should not be interpreted as a formal NIST SP 800-53 assessment, ISO 27001 certification assessment, or complete compliance implementation.

A production assessment would require additional organizational, procedural, governance, personnel, physical, and technical controls beyond the container security capabilities demonstrated here.

The purpose of this mapping is to show how architecture decisions can support broader security and compliance requirements while keeping the distinction clear between:

**Security Capability → Control Support → Evidence → Formal Compliance Assessment**
