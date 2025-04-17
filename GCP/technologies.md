# Technologies Used in GCP Container Security Project

## 🚀 GKE (Google Kubernetes Engine) Standard
- Manages containerized workloads with more control over node pools compared to Autopilot.

## 📦 Artifact Registry
- Stores and manages Docker container images securely within GCP.
- Used to simulate a real-world deployment by pushing a custom NGINX image.

## 🔐 GCP Secret Manager
- Centralized secrets management service used with CSI driver to inject API keys securely into pods.

## 🔧 Terraform
- Automates the creation of infrastructure including VPCs, subnets, GKE clusters, and IAM roles.

## 🧩 Kubernetes YAML
- Defines the deployment and service for the containerized app.
- Includes secret volume mounting for secure runtime config.

## 🌐 VPC + Firewall Rules
- GCP VPC and custom firewall rules restrict access and define HTTP egress/inbound behavior.

## 📊 Cloud Logging and Monitoring
- Native GCP observability stack for logs, metrics, and alerting.

