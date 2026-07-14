#!/bin/bash
set -e

############################################
# Validation helper script
# Verifies the project structure, permissions, and shell
# script formatting before the build pipeline is run.
############################################

echo "=== PROJECT VALIDATION ==="

MODULES_DIR="modules"
REQUIRED_MODULES=("logging.sh" "base.sh" "checks.sh" "image.sh" "motd.sh" "vm.sh")

echo "[1] Checking the modules directory..."
if [ ! -d "$MODULES_DIR" ]; then
    echo "❌ Directory 'modules/' not found."
    exit 1
fi
echo "✔ modules/ directory found."

echo "[2] Checking required modules..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ ! -f "$MODULES_DIR/$mod" ]; then
        echo "❌ Missing module: $mod"
        MISSING=true
    else
        echo "✔ Module present: $mod"
    fi
done

if [ "$MISSING" = true ]; then
    echo "❌ One or more modules are missing."
    exit 1
fi

echo "[3] Checking permissions..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ ! -x "$MODULES_DIR/$mod" ]; then
        echo "❌ $mod is not executable."
        PERM_ISSUE=true
    else
        echo "✔ $mod is executable."
    fi
done

echo "[4] Checking Windows line endings (CRLF)..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if file "$MODULES_DIR/$mod" | grep -q "CRLF"; then
        echo "❌ CRLF detected in $mod"
        CRLF_ISSUE=true
    else
        echo "✔ Unix format OK: $mod"
    fi
done

echo "[5] Checking shebang..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if ! head -n 1 "$MODULES_DIR/$mod" | grep -q "#!/bin/bash"; then
        echo "❌ Incorrect shebang in $mod"
        SHEBANG_ISSUE=true
    else
        echo "✔ Shebang OK: $mod"
    fi
done

echo "[6] Checking main.sh..."
if [ ! -f main.sh ]; then
    echo "❌ main.sh not found."
    exit 1
fi

echo "✔ main.sh found."

echo "=== VALIDATION COMPLETE ==="

if [ "$PERM_ISSUE" = true ] || [ "$CRLF_ISSUE" = true ] || [ "$SHEBANG_ISSUE" = true ]; then
    echo "⚠ Problems detected. Run repair.sh."
else
    echo "✔ No problems detected."
fi
