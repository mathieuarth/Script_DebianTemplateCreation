# VM module

## Role

The VM module configures the final VM from the prepared image and the parameters defined at the start of the pipeline.

## Commands used

The actual content of the module is still minimal, but it is intended to integrate the steps for creating and configuring the virtual machine through Proxmox.

## Expected behavior

This module runs at the end of the pipeline and should allow:

- creation or update of the VM,
- association of the prepared image with the VM,
- definition of storage, memory, CPU, and network settings,
- configuration of the final system based on the provided options.

## Notes

For future extension of the project, this is the right place to add Proxmox commands such as `qm create`, `qm set`, `qm start`, or `qm template`.
