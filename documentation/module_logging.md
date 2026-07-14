# Module logging

## Rôle

Le module logging fournit les fonctions d’affichage et d’écriture de journal pour l’ensemble du pipeline.

## Commandes utilisées

- `echo` : affiche un message dans le terminal.
- `echo -e` : permet d’ajouter des couleurs ANSI dans les messages.
- `date '+%Y-%m-%d %H:%M:%S'` : ajoute un horodatage au log.
- `>> "$LOG_FILE"` : écrit la ligne dans un fichier de journal.
- `2>/dev/null || true` : ignore les erreurs d’écriture sans interrompre le script.

## Comportement

Le module définit trois fonctions principales :

- `log()` : affiche un message d’information et l’enregistre.
- `ok()` : affiche un message de succès et l’enregistre.
- `err()` : affiche un message d’erreur et l’enregistre.

Le fichier de log est défini par défaut dans `/var/log/template_builder.log`.
