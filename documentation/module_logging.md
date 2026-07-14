# Logging module

## Role

The logging module provides display and log-writing functions for the whole pipeline.

## Commands used

- `echo`: prints a message to the terminal.
- `echo -e`: allows ANSI colors to be added to messages.
- `date '+%Y-%m-%d %H:%M:%S'`: adds a timestamp to the log entry.
- `>> "$LOG_FILE"`: writes the line to a log file.
- `2>/dev/null || true`: ignores write errors without stopping the script.

## Behavior

The module defines three main functions:

- `log()`: displays an information message and records it.
- `ok()`: displays a success message and records it.
- `err()`: displays an error message and records it.

The log file is set by default to `/var/log/template_builder.log`.
