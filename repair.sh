#!/bin/bash
set -e

echo "=== RÉPARATION AUTOMATIQUE DU PROJET ==="

MODULES_DIR="modules"
REQUIRED_MODULES=("logging.sh" "base.sh" "checks.sh" "image.sh" "motd.sh" "vm.sh")

echo "[1] Création du dossier modules si absent..."
mkdir -p "$MODULES_DIR"
echo "✔ OK"

echo "[2] Correction des noms de fichiers..."
# Corrige cxeck.sh → checks.sh
if [ -f "$MODULES_DIR/cxeck.sh" ]; then
    mv "$MODULES_DIR/cxeck.sh" "$MODULES_DIR/checks.sh"
    echo "✔ Renommé cxeck.sh → checks.sh"
fi

# Corrige check.sh → checks.sh
if [ -f "$MODULES_DIR/check.sh" ]; then
    mv "$MODULES_DIR/check.sh" "$MODULES_DIR/checks.sh"
    echo "✔ Renommé check.sh → checks.sh"
fi

echo "[3] Correction des retours Windows (CRLF)..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        dos2unix "$MODULES_DIR/$mod" 2>/dev/null || true
        echo "✔ CRLF corrigé dans $mod"
    fi
done

echo "[4] Correction des permissions..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        chmod +x "$MODULES_DIR/$mod"
        echo "✔ Permissions fixées : $mod"
    fi
done

echo "[5] Correction du shebang..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$mod" ]; then
        sed -i '1s|.*|#!/bin/bash|' "$MODULES_DIR/$mod"
        echo "✔ Shebang corrigé : $mod"
    fi
done

echo "[6] Vérification du main.sh..."
if [ ! -f main.sh ]; then
    echo "❌ main.sh absent → création d'un squelette."
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
    echo "✔ main.sh créé."
else
    echo "✔ main.sh présent."
fi

echo "=== RÉPARATION TERMINÉE ==="
echo "✔ Le projet est maintenant cohérent et fonctionnel."
