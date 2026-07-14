# Image module

## Role

The image module prepares the Debian cloud image by adding the components required for the final template.

## Commands used

- `wget -q "$IMG_URL" -O "$IMG_ORIG"`: downloads the Debian cloud image.
- `virt-customize -a "$IMG_ORIG" --install ...`: installs packages into the image.
- `--timezone "Europe/Paris"`: configures the time zone.
- `--root-password password:"$ROOT_PASS"`: sets the root password for the image.
- `virt-customize -a "$IMG_ORIG" --run-command ...`: applies changes through shell commands inside the image.
- `qemu-img convert -O qcow2 -c "$IMG_ORIG" "$IMG_SHRINK"`: compresses the final image in qcow2 format.

## Changes made

This module installs useful packages (`qemu-guest-agent`, `python3`, `curl`, `sudo`, `fail2ban`, etc.), configures the French keyboard layout, applies SSH and system hardening, and produces a compressed image ready for use.
