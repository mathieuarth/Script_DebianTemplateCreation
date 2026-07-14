# Checks module

## Role

The checks module performs the prerequisite validation before creating the VM or template.

## Commands used

- `case "$NET_TYPE" in`: maps a network type to a Proxmox bridge (`private`, `mgmt`, `public`).
- `if [ ! -f "$ANSIBLE_KEY_FILE" ]; then`: verifies that the expected SSH key exists.
- `qm status "$VMID"`: checks whether a VM with this ID already exists.
- `qm stop "$VMID"`: stops the VM if it exists and the `--force` option is used.
- `qm destroy "$VMID"`: removes the existing VM.
- `exit 0`: stops the pipeline in `--dry-run` mode without making changes.

## Behavior

This module helps prevent VM collisions, validates the presence of the SSH key, and ensures the context is ready before continuing.
