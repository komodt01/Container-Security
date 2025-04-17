# Linux Hardening for Container Security

## Patching [NIST SI-2 / ISO A.12.6.1]
apt update && apt upgrade -y

## Disable Unused Services [NIST SC-7 / ISO A.13.1.1]
systemctl disable bluetooth
systemctl disable cups

## Restrict Root Login [NIST SC-13 / ISO A.10.1.2]
passwd -l root
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

## Enable Audit Logging [NIST AU-6 / ISO A.12.4.3]
apt install auditd -y
systemctl enable auditd
auditctl -e 1
