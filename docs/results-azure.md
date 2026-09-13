# Azure Deployment Results

This document captures the results and observations from the Azure portion of the container security project.

## Deployment Details

The Azure implementation deployed the application using Azure Kubernetes Service (AKS) with Azure Container Registry (ACR) for container image storage.

Resources and capabilities used during the deployment included:

- AKS cluster: `secure-aks`
- Azure Container Registry for application container images
- Azure virtual network and subnet for AKS networking
- Network Security Group for network access control
- Managed identity for the AKS cluster
- Azure role-based access control
- Log Analytics and Azure Monitor for platform telemetry

## Validation

The application pods successfully ran in the AKS environment.

The original deployment exposed the application through a Kubernetes LoadBalancer service and validated application connectivity.

Cluster and workload activity could be reviewed using Kubernetes logging and Azure monitoring capabilities.

## Deployment Challenge

One challenge encountered during the deployment involved AKS role-based access control.

Additional role configuration was required before the intended access worked correctly.

This reinforced the importance of evaluating identity as part of the complete access path rather than simply enabling RBAC.

The relevant architecture flow is:

**Identity → Authentication → Role Assignment → Authorization → Kubernetes Resource**

A platform can have RBAC enabled while still granting too much access, too little access, or access to the wrong identity.

## Architecture Evolution

The original deployment demonstrated the ability to deploy and operate a containerized workload using AKS, ACR, Azure networking, managed identity, RBAC, and centralized monitoring.

During the later architecture review, I identified several areas where I would strengthen the design for a production environment.

These included:

- Disable ACR administrative credentials and use identity-based access.
- Explicitly grant the AKS workload the required ACR pull permissions.
- Ensure Network Security Groups are associated with the intended subnet.
- Avoid broad application ingress unless required by the approved ingress architecture.
- Run multiple worker nodes for basic workload availability.
- Evaluate private AKS API access and private connectivity to ACR.
- Use workload identity for application access to Azure resources.
- Evaluate Kubernetes network policies and admission controls.
- Define an ingress and WAF strategy based on application exposure.
- Establish secrets-management requirements rather than embedding credentials in application or infrastructure configuration.
- Define vulnerability-response, monitoring, autoscaling, backup/recovery, and deployment-governance requirements.

These are architecture improvements identified through review of the original implementation rather than controls claimed as part of the original deployment.

## Evidence

Kubernetes workload logs can be reviewed using:

```bash
kubectl logs <pod-name>
```

Azure Monitor and Log Analytics can provide additional platform telemetry for investigation and operational monitoring.

Relevant deployment evidence may also include AKS cluster status, pod status, role assignments, ACR repository information, Terraform output, and Log Analytics events.

## Key Takeaway

The Azure deployment reinforced that managed Kubernetes security depends on more than successfully creating a cluster and running a workload.

Identity, network boundaries, registry access, workload authorization, telemetry, and resilience all need to be evaluated together.

The architecture progression is:

**Functional AKS Deployment → Validate Identity and Network Controls → Identify Gaps → Strengthen Production Architecture**
