#!/bin/bash
############################################
# Image preparation module
# Downloads the Debian cloud image, customizes it,
# applies hardening settings, and compresses the result.
############################################

log "Starting image preparation..."

############################################
# Download image
############################################
log "Downloading Debian cloud image from: $IMG_URL"
wget -q "$IMG_URL" -O "$IMG_ORIG"
ok "Image downloaded: $IMG_ORIG"

############################################
# Base customization
############################################
log "Customizing image with packages and timezone..."

virt-customize -a "$IMG_ORIG" \
  --install qemu-guest-agent,python3,python3-apt,curl,sudo,lsb-release,figlet,fail2ban \
  --timezone "Europe/Paris" \
  --root-password password:"$ROOT_PASS"

ok "Base packages installed and timezone set."

############################################
# SSH hardening
############################################
log "Applying SSH hardening..."

virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config"
#virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
virt-customize -a "$IMG_ORIG" --run-command "echo 'PrintMotd no' >> /etc/ssh/sshd_config"
virt-customize -a "$IMG_ORIG" --run-command "echo 'PrintLastLog no' >> /etc/ssh/sshd_config"

ok "SSH hardening applied."

############################################
# Pam.d module
############################################
virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^session.*pam_lastlog.so/#&/' /etc/pam.d/sshd"
virt-customize -a "$IMG_ORIG" --run-command "sed -i 's/^session.*pam_motd.so/#&/' /etc/pam.d/sshd"

############################################
# Keyboard layout
############################################
log "Configuring keyboard layout (FR)..."

virt-customize -a "$IMG_ORIG" --run-command "echo 'XKBLAYOUT=\"fr\"' > /etc/default/keyboard"

ok "Keyboard layout configured."

############################################
# journald + sysctl hardening
############################################
log "Applying journald and sysctl hardening..."

virt-customize -a "$IMG_ORIG" --run-command "mkdir -p /etc/systemd/journald.conf.d"
virt-customize -a "$IMG_ORIG" --run-command "cat > /etc/systemd/journald.conf.d/limits.conf << 'EOF'
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=100M
EOF"

virt-customize -a "$IMG_ORIG" --run-command "cat > /etc/sysctl.d/99-hardening.conf << 'EOF'
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
kernel.kptr_restrict=1
kernel.randomize_va_space=2
EOF"

ok "journald + sysctl hardening applied."

############################################
# MOTD installation
############################################
log "Installing dynamic MOTD..."
source modules/motd.sh
ok "Dynamic MOTD installed."

############################################
# Compress image
############################################
log "Compressing image to: $IMG_SHRINK"
qemu-img convert -O qcow2 -c "$IMG_ORIG" "$IMG_SHRINK"
ok "Image compressed."

log "Image preparation completed."
