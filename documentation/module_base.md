# Module base

## Rôle

Le module base initialise les variables globales du pipeline et prépare les paramètres du déploiement.

## Commandes et mécanismes utilisés

- `if [[ $EUID -ne 0 ]]; then` : vérifie que le script est exécuté en tant que root.
- `exit 1` : stoppe l’exécution si l’utilisateur n’a pas les privilèges nécessaires.
- `VMID="9999"` et autres variables : définissent les valeurs par défaut utilisées par le pipeline.
- `while [[ $# -gt 0 ]]; do ... esac` : parse les options passées en ligne de commande.
- `--vmid`, `--name`, `--storage`, `--memory`, `--cores`, `--disk-size`, `--user-key`, `--root-pass`, `--force`, `--verbose`, `--dry-run`, `--log-file` : options d’entrée configurables.
- `set -x` : active le mode verbeux pour afficher chaque commande exécutée.

## Comportement

Ce module ne fait pas de modifications système directes ; il sert surtout à préparer le contexte d’exécution du pipeline.
