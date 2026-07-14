#!/bin/bash
############################################
# Logging module
# Provides file logging functions used by
# all other modules.
############################################

#!/bin/bash

# Couleurs
INFO="\e[36m[INFO]\e[0m"
OK="\e[32m[OK]\e[0m"
ERR="\e[31m[ERROR]\e[0m"

# Fichier de log (optionnel)
LOG_FILE="/var/log/template_builder.log"

log() {
    echo -e "$INFO $1"
    log_file "$1"
}

ok() {
    echo -e "$OK $1"
    log_file "$1"
}

err() {
    echo -e "$ERR $1"
    log_file "$1"
}

# Version blindee : ne retourne JAMAIS une erreur
log_file() {
    if [ -n "$LOG_FILE" ]; then
        # On ignore les erreurs d'ecriture
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>/dev/null || true
    fi
    return 0
}
