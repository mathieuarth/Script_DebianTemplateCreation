# Base module

## Role

The base module initializes the pipeline's global variables and prepares deployment parameters.

## Commands and mechanisms used

- `if [[ $EUID -ne 0 ]]; then`: verifies that the script is run as root.
- `exit 1`: stops execution if the user does not have the required privileges.
- `VMID="9999"` and other variables: define the default values used by the pipeline.
- `while [[ $# -gt 0 ]]; do ... esac`: parses command-line options.
- `--vmid`, `--name`, `--storage`, `--memory`, `--cores`, `--disk-size`, `--user-key`, `--root-pass`, `--force`, `--verbose`, `--dry-run`, `--log-file`: configurable input options.
- `set -x`: enables verbose mode to display each executed command.

## Behavior

This module does not make direct system changes; it mainly prepares the execution context for the pipeline.
