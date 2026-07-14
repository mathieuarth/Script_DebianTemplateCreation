#!/bin/bash
set -e

echo "=== VALIDATION DU PROJET ==="

MODULES_DIR="modules"
REQUIRED_MODULES=("logging.sh" "base.sh" "checks.sh" "image.sh" "motd.sh" "vm.sh")

echo "[1] Vérification du dossier modules/"
if [ ! -d "$MODULES_DIR" ]; then
    echo "❌ Dossier 'modules/' introuvable."
    exit 1
fi
echo "✔ Dossier modules/ trouvé."

echo "[2] Vérification des modules obligatoires..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ ! -f "$MODULES_DIR/$mod" ]; then
        echo "❌ Module manquant : $mod"
        MISSING=true
    else
        echo "✔ Module présent : $mod"
    fi
done

if [ "$MISSING" = true ]; then
    echo "❌ Un ou plusieurs modules manquent."
    exit 1
fi

echo "[3] Vérification des permissions..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if [ ! -x "$MODULES_DIR/$mod" ]; then
        echo "❌ $mod n'est pas exécutable."
        PERM_ISSUE=true
    else
        echo "✔ $mod est exécutable."
    fi
done

echo "[4] Vérification des retours Windows (CRLF)..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if file "$MODULES_DIR/$mod" | grep -q "CRLF"; then
        echo "❌ CRLF détecté dans $mod"
        CRLF_ISSUE=true
    else
        echo "✔ Format Unix OK : $mod"
    fi
done

echo "[5] Vérification du shebang..."
for mod in "${REQUIRED_MODULES[@]}"; do
    if ! head -n 1 "$MODULES_DIR/$mod" | grep -q "#!/bin/bash"; then
        echo "❌ Shebang incorrect dans $mod"
        SHEBANG_ISSUE=true
    else
        echo "✔ Shebang OK : $mod"
    fi
done

echo "[6] Vérification du main.sh..."
if [ ! -f main.sh ]; then
    echo "❌ main.sh introuvable."
    exit 1
fi

echo "✔ main.sh trouvé."

echo "=== VALIDATION TERMINÉE ==="

if [ "$PERM_ISSUE" = true ] || [ "$CRLF_ISSUE" = true ] || [ "$SHEBANG_ISSUE" = true ]; then
    echo "⚠ Des problèmes ont été détectés. Lance repair.sh."
else
    echo "✔ Aucun problème détecté."
fi
