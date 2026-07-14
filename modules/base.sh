#!/bin/bash
############################################
# Base module
# Defines the shared defaults, root privilege checks,
# and command-line argument parsing used by the pipeline.
############################################

# Colors
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

############################################
# Root check
############################################
if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root."
    exit 1
fi

############################################
# Default values
############################################
VMID="9999"
VM_NAME="debian13-template-hardened"
STORAGE="iscsi_lvm"
NET_TYPE="private"
BRIDGE="vmbr2"
NET_IFACE="ens18"

MEMORY=4096
CORES=2
SOCKETS=1

IMG_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
IMG_ORIG="debian-13-genericcloud-amd64.qcow2"
IMG_SHRINK="debian-13-genericcloud-amd64-shrink.qcow2"

ROOT_PASS="YourP@sswordH3r3"
ANSIBLE_KEY_FILE="/root/ansible.pub"
DISK_SIZE="4G"

FORCE=false
VERBOSE=false
DRY_RUN=false

############################################
# Argument parsing
############################################
while [[ $# -gt 0 ]]; do
    case "$1" in
        --vmid) VMID="$2"; shift 2 ;;
        --name) VM_NAME="$2"; shift 2 ;;
        --storage) STORAGE="$2"; shift 2 ;;
        --net-type) NET_TYPE="$2"; shift 2 ;;
        --memory) MEMORY="$2"; shift 2 ;;
        --cores) CORES="$2"; shift 2 ;;
        --disk-size) DISK_SIZE="$2"; shift 2 ;;
        --user-key) ANSIBLE_KEY_FILE="$2"; shift 2 ;;
        --root-pass) ROOT_PASS="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --log-file) LOG_FILE="$2"; shift 2 ;;
        *) err "Unknown option: $1"; exit 1 ;;
    esac
done

############################################
# Verbose mode
############################################
if [ "$VERBOSE" = true ]; then
    set -x
fi
