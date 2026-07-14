# Debian Template Creation Script

This project contains a set of Bash scripts to automate the creation and preparation of a Debian template, with validation, repair, and automated build logic.

## Goal

The repository provides a structured base for:

- preparing a Debian cloud image,
- applying system customizations,
- creating or preparing a Proxmox virtual machine,
- validating pipeline consistency,
- automatically fixing common issues.

## Project structure

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

## Main scripts

### main.sh

Entry point of the pipeline. It loads the following modules in sequence:

1. `modules/logging.sh`
2. `modules/base.sh`
3. `modules/checks.sh`
4. `modules/image.sh`
5. `modules/vm.sh`

### validation.sh

Checks the presence of the expected modules, their permissions, shebangs, and the presence of `main.sh`.

### repair.sh

Automatically fixes common project issues:

- renaming incorrectly named modules,
- converting files to Unix format,
- fixing permissions,
- correcting the shebang,
- restoring a basic `main.sh` if needed.

## Module documentation

Each module has a specific role in the pipeline:

- [documentation/module_logging.md](documentation/module_logging.md): logging and display functions.
- [documentation/module_base.md](documentation/module_base.md): global variables, options, and context setup.
- [documentation/module_checks.md](documentation/module_checks.md): pre-creation validation checks.
- [documentation/module_image.md](documentation/module_image.md): image download and customization.
- [documentation/module_motd.md](documentation/module_motd.md): dynamic banner installation.
- [documentation/module_vm.md](documentation/module_vm.md): final VM preparation.

## Usage

### Validate the project

```bash
bash validation.sh
```

### Repair the project

```bash
bash repair.sh
```

### Run the main pipeline

```bash
bash main.sh
```

### Schedule weekly template recreation

A dedicated script can add a weekly cron task:

```bash
bash schedule_template_rebuild.sh
```

The script creates a cron entry that runs `main.sh` every week, with logs sent to `/var/log/template_rebuild.log` by default.

Detailed documentation is available in [documentation/schedule_template_rebuild.md](documentation/schedule_template_rebuild.md).

## Notes

- The scripts use Bash and should be executed with the appropriate permissions.
- The pipeline is designed to be modular and easily extensible.
- Proxmox commands and system operations should be integrated into the modules according to deployment needs.
