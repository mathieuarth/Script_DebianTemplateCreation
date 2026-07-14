# Script Debian Template Creation

Ce projet contient un ensemble de scripts Bash pour automatiser la création et la préparation d’un template Debian, avec une logique de validation, de réparation et de construction automatisée.

## Objectif

Le dépôt vise à fournir une base structurée pour :

- préparer une image Debian cloud,
- appliquer des personnalisations système,
- créer ou préparer une machine virtuelle Proxmox,
- valider la cohérence du pipeline,
- corriger automatiquement les problèmes courants.

## Structure du projet

```text
.
├── main.sh
├── repair.sh
├── validation.sh
├── modules/
│   ├── base.sh
│   ├── checks.sh
│   ├── image.sh
│   ├── logging.sh
│   ├── motd.sh
│   └── vm.sh
└── documentation/
    └── *.md
```

## Scripts principaux

### main.sh

Point d’entrée du pipeline. Il charge successivement les modules suivants :

1. `modules/logging.sh`
2. `modules/base.sh`
3. `modules/checks.sh`
4. `modules/image.sh`
5. `modules/vm.sh`

### validation.sh

Vérifie la présence des modules attendus, leurs permissions, leurs shebangs, ainsi que la présence de `main.sh`.

### repair.sh

Corrige automatiquement les problèmes courants du projet :

- renommage des modules mal nommés,
- conversion des fichiers en format Unix,
- correction des permissions,
- correction du shebang,
- restauration d’un `main.sh` de base si nécessaire.

## Documentation par module

Chaque module a un rôle précis dans le pipeline :

- [documentation/module_logging.md](documentation/module_logging.md) : fonctions de log et d’affichage.
- [documentation/module_base.md](documentation/module_base.md) : variables globales, options et préparation du contexte.
- [documentation/module_checks.md](documentation/module_checks.md) : vérifications préalables avant création.
- [documentation/module_image.md](documentation/module_image.md) : téléchargement et personnalisation de l’image.
- [documentation/module_motd.md](documentation/module_motd.md) : installation d’un banner dynamique.
- [documentation/module_vm.md](documentation/module_vm.md) : préparation de la VM finale.

## Utilisation

### Valider le projet

```bash
bash validation.sh
```

### Réparer le projet

```bash
bash repair.sh
```

### Lancer le pipeline principal

```bash
bash main.sh
```

## Notes

- Les scripts utilisent Bash et doivent être exécutés avec les droits appropriés.
- Le pipeline est pensé pour être modulable et facilement extensible.
- Les commandes Proxmox et les opérations système sont à intégrer dans les modules selon les besoins du déploiement.
