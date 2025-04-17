# Azure Container Security Project (AKS)

This project mirrors a secure AWS container deployment using AKS, ACR, and Azure Key Vault.

## 🚀 Overview

- AKS Standard Cluster (Terraform-managed)
- ACR for storing Docker images
- Key Vault for secrets injection (via CSI driver)
- VNet + Subnet + NSG for traffic control
- Kubernetes YAML deployment with secret mounting

## 🛠️ Deployment Steps

1. Update `terraform/variables.tf` if needed
2. Deploy infrastructure:
   ```
   terraform init
   terraform apply
   ```
3. Connect to AKS:
   ```
   az aks get-credentials --resource-group container-security-rg --name secure-aks-cluster
   ```
4. Deploy app:
   ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   ```

