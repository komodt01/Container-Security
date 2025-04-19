# Linux Hardening Steps

## Steps
1. **Update System**
   ``bash
   sudo apt update && sudo apt upgrade -y
   ``

2. **Disable Unused Services**
   ``bash
   sudo systemctl disable bluetooth cups
   ``

3. **Secure SSH**
   ``bash
   sudo passwd -l root
   echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ``

4. **Enable Auditing**
   ``bash
   sudo apt install auditd -y
   sudo systemctl enable auditd
   sudo auditctl -e 1
   ``

## References
- Aligns with NIST 800-53 CM-6, AC-3.
