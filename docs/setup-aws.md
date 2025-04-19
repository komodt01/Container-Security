# Setup Instructions for AWS Container Security Project

## Prerequisites
- AWS account
- Ubuntu 22.04 VM
- Tools: Docker, Terraform, AWS CLI
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
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
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
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   docker build -t myapp:latest .
   docker tag myapp:latest <account-id>.dkr.ecr.<region>.amazonaws.com/myapp-repo:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/myapp-repo:latest
   ``

5. **Deploy Infrastructure**
   - Update 	erraform/aws/variables.tf.
   ``bash
   cd terraform/aws
   terraform init
   terraform apply -auto-approve
   ``

6. **Validate**
   ``bash
   aws ecs describe-services --cluster secure-ecs-cluster --services myapp-service
   aws logs tail /ecs/myapp > ecs-logs.txt
   ``

7. **Document Results**
   ``bash
   git add ecs-logs.txt
   git commit -m "Added AWS ECS deployment and logs"
   git push origin main
   ``

## Notes
- Replace <region>, <account-id> with your AWS values.
- See [aws-container-teardown.md](aws-container-teardown.md) for cleanup.
