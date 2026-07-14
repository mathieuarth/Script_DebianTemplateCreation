# Module image

## Rôle

Le module image prépare l’image cloud Debian en y ajoutant les composants nécessaires au template final.

## Commandes utilisées

- `wget -q "$IMG_URL" -O "$IMG_ORIG"` : télécharge l’image cloud Debian.
- `virt-customize -a "$IMG_ORIG" --install ...` : installe des paquets dans l’image.
- `--timezone "Europe/Paris"` : configure le fuseau horaire.
- `--root-password password:"$ROOT_PASS"` : définit le mot de passe root de l’image.
- `virt-customize -a "$IMG_ORIG" --run-command ...` : applique des modifications via des commandes shell à l’intérieur de l’image.
- `qemu-img convert -O qcow2 -c "$IMG_ORIG" "$IMG_SHRINK"` : compresse l’image finale en format qcow2.

## Modifications réalisées

Ce module installe des paquets utiles (`qemu-guest-agent`, `python3`, `curl`, `sudo`, `fail2ban`, etc.), configure le clavier FR, applique un durcissement SSH et système, puis produit une image compressée prête à être utilisée.
