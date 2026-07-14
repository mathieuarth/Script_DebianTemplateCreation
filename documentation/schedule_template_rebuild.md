# Schedule template rebuild

## Purpose

This script installs a weekly cron job that re-executes the main template build pipeline automatically.

## What it does

- verifies that the main pipeline script exists,
- ensures the log directory exists,
- makes the main script executable,
- creates or updates the user crontab,
- adds a cron entry tagged with a clear marker so it can be removed later if needed.

## Default schedule

By default, the task runs every Monday at 03:00:

```text
0 3 * * 1
```

You can override it by setting the `SCHEDULE` environment variable before running the script.

## Example

```bash
SCHEDULE='0 6 * * 2' bash schedule_template_rebuild.sh
```

This changes the execution to every Tuesday at 06:00.

## Logging

The cron output is redirected to:

```text
/var/log/template_rebuild.log
```

You can override this path with:

```bash
LOG_FILE=/path/to/your/log bash schedule_template_rebuild.sh
```

## Usage

```bash
bash schedule_template_rebuild.sh
```
