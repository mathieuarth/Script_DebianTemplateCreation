# Module checks

## Rôle

Le module checks effectue les contrôles préalables avant la création de la VM ou du template.

## Commandes utilisées

- `case "$NET_TYPE" in` : associe un type de réseau à un bridge Proxmox (`private`, `mgmt`, `public`).
- `if [ ! -f "$ANSIBLE_KEY_FILE" ]; then` : vérifie que la clé SSH attendue existe bien.
- `qm status "$VMID"` : vérifie si une VM avec cet ID existe déjà.
- `qm stop "$VMID"` : arrête la VM si elle existe et si l’option `--force` est utilisée.
- `qm destroy "$VMID"` : supprime la VM existante.
- `exit 0` : arrête le pipeline en mode `--dry-run` sans apporter de modifications.

## Comportement

Ce module sert à éviter les collisions de VM, à valider la présence de la clé SSH et à s’assurer que le contexte est prêt avant d’aller plus loin.
