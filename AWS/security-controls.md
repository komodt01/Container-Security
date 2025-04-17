# 🔐 Key Security Features Implemented

This document outlines the key container security controls implemented in the AWS container security project, along with their mappings to NIST and ISO/IEC 27001 standards.

---

### ✅ IAM Roles with Least Privilege
- **Implementation**: Created a dedicated IAM role (`aws-owasp`) with scoped permissions required only for container operations.
- **Mapped to**:
  - **NIST**: AC-6 (Least Privilege)
  - **ISO/IEC 27001**: A.9.2.3 (Management of privileged access rights)

---

### ✅ CloudWatch Centralized Logging
- **Implementation**: Enabled CloudWatch logging for container output, audit events, and system operations.
- **Mapped to**:
  - **NIST**: AU-2 (Audit Events)
  - **ISO/IEC 27001**: A.12.4.1 (Event logging)

---

### ✅ Secrets Manager for Container Credentials
- **Implementation**: Stored sensitive credentials (e.g., database/API secrets) in AWS Secrets Manager and injected into containers securely.
- **Mapped to**:
  - **NIST**: SC-12 (Cryptographic Key Establishment)
  - **ISO/IEC 27001**: A.10.1.2 (Key management)

---

### ✅ ECR Vulnerability Scans
- **Implementation**: Enabled Amazon ECR vulnerability scanning to detect security flaws in container images.
- **Mapped to**:
  - **NIST**: SI-2 (Flaw Remediation)
  - **ISO/IEC 27001**: A.12.6.1 (Technical Vulnerability Management)
