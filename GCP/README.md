# GCP Container Security Project (GKE Standard)

This project mirrors a secure container deployment in AWS, implemented using Google Kubernetes Engine (GKE Standard), Artifact Registry, Secret Manager, and Terraform.

## 🔧 Components

- GKE Standard Cluster (Terraform-managed)
- Custom VPC, Subnet, Firewall Rules
- Artifact Registry for container images
- GCP Secret Manager with CSI injection
- Kubernetes YAML deployment for secure container app

## 📦 Container Image Workflow

1. Build a custom NGINX-based image.
2. Tag and push to Artifact Registry:
   ```
   docker tag secure-nginx us-central1-docker.pkg.dev/YOUR_PROJECT_ID/container-secure-repo/secure-nginx:latest
   docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/container-secure-repo/secure-nginx:latest
   ```
3. Update your `deployment.yaml` image reference.

## 🚀 Deployment Steps

1. Update `terraform/variables.tf` with your project ID, region, and zone.
2. Deploy infrastructure:
   ```
   terraform init
   terraform apply
   ```
3. Connect to your GKE cluster:
   ```
   gcloud container clusters get-credentials gke-standard-cluster --zone=us-central1-c
   ```
4. Deploy the app:
   ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   ```

## 📜 Notes

- Secrets are injected using the Secrets Store CSI driver with GCP Secret Manager.
- Logging and monitoring are enabled through GKE + Cloud Logging.

