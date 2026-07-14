#!/bin/bash
############################################
# Logging helper module
# Provides shared logging helpers for all other modules.
# The functions print to stdout and optionally append
# entries to a log file when LOG_FILE is set.
############################################

# Colors used by the logging helpers.
INFO="\e[36m[INFO]\e[0m"
OK="\e[32m[OK]\e[0m"
ERR="\e[31m[ERROR]\e[0m"

# Optional log file path.
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

# Blind version: never returns an error.
log_file() {
    if [ -n "$LOG_FILE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>/dev/null || true
    fi
    return 0
}
