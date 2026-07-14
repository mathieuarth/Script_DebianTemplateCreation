# MOTD module

## Role

The MOTD module installs a dynamic banner displayed when users connect to the VM.

## Commands used

- `mktemp -d`: creates a temporary directory to store the banner script.
- `cat > "$workdir/00-custom-motd.sh" <<'EOF'`: writes the welcome message script.
- `virt-customize -a "$IMG_ORIG" --copy-in ...`: copies the file into the image.
- `chmod +x`: makes the script executable.
- `chmod -x /etc/update-motd.d/*`: disables default MOTD scripts to avoid conflicts.
- `truncate -s 0 /etc/motd`: clears the current MOTD file.

## Behavior

The script displays information such as the hostname, kernel, uptime, CPU load, memory, disk usage, the status of SSH/fail2ban/cron services, and network and update status.

## Example display

Here is an example of what the user may see at login:

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
