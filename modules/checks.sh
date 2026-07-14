#!/bin/bash
############################################
# Pre-flight checks module
# - Network selection
# - SSH key presence
# - VMID availability
# - Dry-run mode
############################################

log "Performing pre-flight checks..."

############################################
# Network selection
############################################
log "Selecting network bridge based on net-type..."

case "$NET_TYPE" in
    private) BRIDGE="vmbr2" ;;
    mgmt)    BRIDGE="vmbr1" ;;
    public)  BRIDGE="vmbr0" ;;
    *)
        err "Invalid net-type: '$NET_TYPE', defaulting to private"
        NET_TYPE="private"
        BRIDGE="vmbr2"
        ;;
esac

ok "Network type '$NET_TYPE' mapped to bridge '$BRIDGE'."

############################################
# SSH key check
############################################
log "Checking SSH key file: $ANSIBLE_KEY_FILE"

if [ ! -f "$ANSIBLE_KEY_FILE" ]; then
    err "SSH key not found: $ANSIBLE_KEY_FILE"
    exit 1
fi

ok "SSH key found."

############################################
# VMID existence check
############################################
log "Checking if VMID $VMID already exists..."

if qm status "$VMID" >/dev/null 2>&1; then
    if [ "$FORCE" = true ]; then
        log "VMID exists. FORCE enabled → deleting VM $VMID..."
        qm stop "$VMID" >/dev/null 2>&1 || true
        qm destroy "$VMID"
        ok "Existing VM destroyed."
    else
        err "VMID already exists. Use --force to delete."
        exit 1
    fi
else
    ok "VMID $VMID is available."
fi

############################################
# Dry-run mode
############################################
if [ "$DRY_RUN" = true ]; then
    ok "Dry-run mode enabled → stopping before modifications."
    exit 0
fi

ok "Pre-flight checks completed."
