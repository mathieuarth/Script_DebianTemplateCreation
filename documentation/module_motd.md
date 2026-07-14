# Module motd

## Rôle

Le module motd installe un banner dynamique affiché à la connexion des utilisateurs sur la VM.

## Commandes utilisées

- `mktemp -d` : crée un répertoire temporaire pour stocker le script du banner.
- `cat > "$workdir/00-custom-motd.sh" <<'EOF'` : écrit le script du message d’accueil.
- `virt-customize -a "$IMG_ORIG" --copy-in ...` : copie le fichier dans l’image.
- `chmod +x` : rend le script exécutable.
- `chmod -x /etc/update-motd.d/*` : désactive les MOTD par défaut pour éviter les conflits.
- `truncate -s 0 /etc/motd` : vide le fichier motd courant.

## Comportement

Le script affiche des informations telles que le hostname, le noyau, l’uptime, la charge CPU, la mémoire, l’espace disque, l’état des services SSH/fail2ban/cron, ainsi que l’état du réseau et des mises à jour.

## Exemple d’affichage

Voici un exemple de ce que l’utilisateur peut voir à la connexion :

```text
                 _   _   _   _
                / | | | | | |
               /__/|_| |_| |_|

Hostname: debian-template
Kernel:   6.1.0-20-amd64
Uptime:   2 days, 4 hours

Load Avg: 0.20 0.10 0.05 (Alert: OK)
Memory:   512MB / 2048MB (Alert: OK%)
Disk (/): 15G / 50G (Alert: OK%)

 Services Status
 SSH:          ●
 Fail2ban:     ●
 Cron:         ●
 Network:      ●

 Network Health
 Gateway (192.168.1.1): OK
 Internet (1.1.1.1): OK
 Interfaces: eth0: UP
```
