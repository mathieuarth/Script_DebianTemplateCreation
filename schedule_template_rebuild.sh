#!/bin/bash
set -euo pipefail

############################################
# Weekly template rebuild scheduler
# Installs a cron job that runs the main pipeline on a regular schedule.
############################################

# Resolve the directory where this script is stored.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main pipeline to execute periodically.
MAIN_SCRIPT="$SCRIPT_DIR/main.sh"

# Log file used by the cron job output.
LOG_FILE="${LOG_FILE:-/var/log/template_rebuild.log}"

# Default schedule: every Monday at 03:00.
SCHEDULE="${SCHEDULE:-0 3 * * 1}"

# Check that the main script exists before creating the cron entry.
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo "[ERROR] main.sh not found: $MAIN_SCRIPT" >&2
    exit 1
fi

# Ensure the log directory exists and the main script is executable.
mkdir -p "$(dirname "$LOG_FILE")"
chmod +x "$MAIN_SCRIPT"

# Create a temporary crontab file to avoid modifying the current one directly.
TMP_CRON="$(mktemp)"
trap 'rm -f "$TMP_CRON"' EXIT

# Load the current crontab if it exists, otherwise start from an empty file.
if crontab -l >/dev/null 2>&1; then
    crontab -l > "$TMP_CRON" 2>/dev/null || true
else
    : > "$TMP_CRON"
fi

# Remove any previous entries inserted by this script.
if [[ -s "$TMP_CRON" ]]; then
    grep -v "# >>> template-rebuild >>>" "$TMP_CRON" | grep -v "# <<< template-rebuild <<<" > "${TMP_CRON}.new" || true
    mv "${TMP_CRON}.new" "$TMP_CRON"
fi

# Append the new cron entry in a clearly identifiable block.
cat >> "$TMP_CRON" <<EOF
# >>> template-rebuild >>>
$SCHEDULE /bin/bash "$MAIN_SCRIPT" >> "$LOG_FILE" 2>&1
# <<< template-rebuild <<<
EOF

# Install the updated crontab.
crontab "$TMP_CRON"

# Display the configuration that was installed.
echo "[OK] Weekly cron job installed."
echo "[INFO] Schedule: $SCHEDULE"
echo "[INFO] Command: /bin/bash $MAIN_SCRIPT"
echo "[INFO] Log file: $LOG_FILE"
