# Setup Instructions for Azure Container Security Project

## Prerequisites
- Azure account
- Ubuntu 22.04 VM
- Tools: Docker, Terraform, Azure CLI
- Git configured

## Steps
1. **Clone Repository**
   ``bash
   git clone https://github.com/komodt01/Container-Security.git
   cd Container-Security
   ``

2. **Install Tools**
   ``bash
   sudo apt update
   sudo apt install -y git unzip docker.io curl
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   curl -fsSL https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip -o terraform.zip
   unzip terraform.zip
   sudo mv terraform /usr/local/bin/
   ``

3. **Apply Linux Hardening**
   - See [linux-hardening.md](linux-hardening.md).
   ``bash
   sudo apt update && sudo apt upgrade -y
   sudo systemctl disable bluetooth cups
   sudo passwd -l root
   echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
   sudo apt install auditd -y
   sudo systemctl enable auditd
   sudo auditctl -e 1
   ``

4. **Build and Push Image**
   ``bash
   az login
   az acr login --name secureacr12345
   docker build -t myapp:latest .
   docker tag myapp:latest secureacr12345.azurecr.io/myapp:latest
   docker push secureacr12345.azurecr.io/myapp:latest
   ``

5. **Deploy Infrastructure**
   - Update 	erraform/azure/variables.tf.
   ``bash
   cd terraform/azure
   terraform init
   terraform apply -auto-approve
   ``

6. **Validate**
   ``bash
   az aks get-credentials --resource-group secure-aks-rg --name secure-aks
   kubectl get pods
   kubectl get svc
   ``

7. **Document Results**
   - Save logs and screenshots to docs/results-azure.md.

## Notes
- Ensure the ACR name secureacr12345 matches your Terraform configuration.
- See [results-azure.md](results-azure.md) for validation details.
