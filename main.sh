#!/bin/bash
set -e

source modules/logging.sh

log "Starting template build pipeline..."

log "Loading base module..."
source modules/base.sh
ok "Base module loaded."

log "Running pre-flight checks..."
source modules/checks.sh
ok "Pre-flight checks completed."

log "Processing image module..."
source modules/image.sh
ok "Image module completed."

log "Running VM provisioning module..."
source modules/vm.sh
ok "VM provisioning completed."

ok "Template build pipeline finished successfully!"
