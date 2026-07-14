#!/bin/bash
set -e

############################################
# Repair helper script
# Restores the expected project structure and file format
# for the Debian template build pipeline.
############################################

echo "=== AUTOMATIC PROJECT REPAIR ==="

MODULES_DIR="modules"
REQUIRED_MODULES=("logging.sh" "base.sh" "checks.sh" "image.sh" "motd.sh" "vm.sh")

echo "[1] Creating the modules directory if missing..."
mkdir -p "$MODULES_DIR"
echo "✔ OK"

echo "[2] Correcting file names..."
# Rename legacy module names to the expected module names.
if [ -f "$MODULES_DIR/cxeck.sh" ]; then
    mv "$MODULES_DIR/cxeck.sh" "$MODULES_DIR/checks.sh"
    echo "✔ Renamed cxeck.sh → checks.sh"
fi

if [ -f "$MODULES_DIR/check.sh" ]; then
    mv "$MODULES_DIR/check.sh" "$MODULES_DIR/checks.sh"
    echo "✔ Renamed check.sh → checks.sh"
fi

echo "[3] Fixing Windows line endings (CRLF)..."
# Normalize the shell scripts to Unix line endings.
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        dos2unix "$MODULES_DIR/$mod" 2>/dev/null || true
        echo "✔ CRLF fixed in $mod"
    fi
done

echo "[4] Fixing permissions..."
# Ensure the helper scripts are executable.
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        chmod +x "$MODULES_DIR/$mod"
        echo "✔ Permissions fixed: $mod"
    fi
done

echo "[5] Fixing shebang..."
# Restore the expected Bash shebang on each shell script.
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        sed -i '1s|.*|#!/bin/bash|' "$MODULES_DIR/$mod"
        echo "✔ Shebang fixed: $mod"
    fi
done

echo "[6] Checking main.sh..."
if [ ! -f main.sh ]; then
    echo "❌ main.sh missing → creating a template stub."
    cat > main.sh << 'EOF'
#!/bin/bash
set -e
source modules/logging.sh
source modules/base.sh
source modules/checks.sh
source modules/image.sh
source modules/motd.sh
source modules/vm.sh
EOF
    chmod +x main.sh
    echo "✔ main.sh created."
else
    echo "✔ main.sh present."
fi

echo "=== REPAIR COMPLETE ==="
echo "✔ The project is now consistent and functional."
