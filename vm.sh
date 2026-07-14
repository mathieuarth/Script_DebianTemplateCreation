#!/bin/bash
############################################
# VM creation module
# - Create VM
# - Import disk
# - Resize disk
# - Configure Cloud-Init
# - Convert to template
############################################

log "Starting VM creation..."

############################################
# Create VM
############################################
log "Creating VM $VMID ($VM_NAME)..."

qm create "$VMID" \
  --name "$VM_NAME" \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --sockets "$SOCKETS" \
  --numa 1 \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --net0 virtio,bridge="$BRIDGE",firewall=1 \
  --agent enabled=1 \
  --ostype l26 \
  --serial0 socket \
  --vga serial0 \
  --rng0 source=/dev/urandom \
  --scsihw virtio-scsi-single

ok "VM created."

############################################
# Import disk
############################################
log "Importing disk into storage: $STORAGE"

qm importdisk "$VMID" "$IMG_SHRINK" "$STORAGE"
DISK_VOL=$(qm config "$VMID" | awk '/unused0/ {print $2}')

if [ -z "$DISK_VOL" ]; then
    err "No unused0 disk found after import. Aborting."
    exit 1
fi
ok "Found imported disk: $DISK_VOL"

log "Attaching disk volume: $DISK_VOL"

qm set "$VMID" --scsi0 "$DISK_VOL",discard=on,iothread=1,ssd=1
qm resize "$VMID" scsi0 "$DISK_SIZE"

ok "Disk imported and resized."

# -------------------------
# ADD EFI + TPM + CLOUD-INIT
# -------------------------
log "Adding EFI disk..."
qm set "$VMID" --efidisk0 "$STORAGE:1",efitype=4m

log "Adding TPM v2.0..."
qm set "$VMID" --tpmstate0 "$STORAGE:4",version=v2.0

log "Adding cloud-init drive on snippet storage..."
qm set "$VMID" --ide2 "$STORAGE:cloudinit"

qm set "$VMID" --boot order=scsi0

ok "Disk and cloud-init configured."


############################################
# Cloud-Init
############################################
log "Configuring Cloud-Init..."

qm set "$VMID" --ciuser ansible
qm set "$VMID" --cipassword "$ROOT_PASS"
qm set "$VMID" --sshkey "$ANSIBLE_KEY_FILE"
qm set "$VMID" --ipconfig0 "ip=dhcp"

ok "Cloud-Init configured."

############################################
# Convert to template
############################################
log "Converting VM to template..."

qm template "$VMID"

ok "Template created."

log "VM creation completed successfully."
