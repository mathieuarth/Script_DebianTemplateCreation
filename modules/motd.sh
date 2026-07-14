#!/bin/bash

############################################
# Dynamic MOTD installation module
# This module installs a fully dynamic,
# POSIX-compliant MOTD system using run-parts.
#
# It creates:
#   - color definitions
#   - banner (hostname + distro)
#   - system info
#   - network info
#   - storage info
#   - ansible info
#   - update status
#
# All scripts are placed in /etc/update-motd.d/
############################################
log "Installing MOTD banner script for VM..."

workdir=$(mktemp -d "${TMPDIR:-/tmp}/motd.XXXXXX")
trap 'rm -rf "$workdir"' EXIT

cat > "$workdir/00-custom-motd.sh" <<'EOF'
#!/bin/bash

# Couleurs
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Fonctions utilitaires
status_icon() {
    if systemctl is-active --quiet "$1"; then
        echo -e "${GREEN}●${RESET}"
    else
        echo -e "${RED}✖${RESET}"
    fi
}

alert_value() {
    local value=$1
    local warn=$2
    local crit=$3

    if (( value >= crit )); then
        echo -e "${RED}${value}${RESET}"
    elif (( value >= warn )); then
        echo -e "${YELLOW}${value}${RESET}"
    else
        echo -e "${GREEN}${value}${RESET}"
    fi
}

# Informations système
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p)

LOAD1=$(cut -d " " -f1 /proc/loadavg)
LOAD5=$(cut -d " " -f2 /proc/loadavg)
LOAD15=$(cut -d " " -f3 /proc/loadavg)

MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_PCT=$(( MEM_USED * 100 / MEM_TOTAL ))

DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PCT=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

CPU_CORES=$(nproc)

# Alertes
LOAD_ALERT=$(alert_value ${LOAD1%.*} $((CPU_CORES/2)) $CPU_CORES)
MEM_ALERT=$(alert_value $MEM_PCT 70 90)
DISK_ALERT=$(alert_value $DISK_PCT 70 90)

# Services VM
SSH_STATUS=$(status_icon ssh)
FAIL2BAN_STATUS=$(status_icon fail2ban)
CRON_STATUS=$(status_icon cron)
NETWORK_STATUS=$(status_icon NetworkManager)

# Nombre de bans Fail2ban
if command -v fail2ban-client >/dev/null 2>&1; then
    FAIL2BAN_BANS=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}')
else
    FAIL2BAN_BANS="N/A"
fi

# Ping gateway + Internet
GATEWAY=$(ip route | awk '/default/ {print $3}')
PING_GW=$(ping -c1 -W1 "$GATEWAY" >/dev/null 2>&1 && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")
PING_NET=$(ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")

# État des interfaces réseau
IFACES=$(ip -o link show | awk -F': ' '{print $2}')
IFACE_STATUS=""
for iface in $IFACES; do
    state=$(cat /sys/class/net/$iface/operstate)
    if [[ "$state" == "up" ]]; then
        IFACE_STATUS+=" $iface: ${GREEN}UP${RESET}"
    else
        IFACE_STATUS+=" $iface: ${RED}DOWN${RESET}"
    fi
done

# Mises à jour disponibles
UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
UPDATES_ALERT=$(alert_value $UPDATES 10 50)

# Dernières erreurs systemd
SYSTEMD_ERRORS=$(journalctl -p 3 -n 5 --no-pager 2>/dev/null | sed 's/^/ • /')

echo -e "${GREEN}"
figlet ${HOSTNAME}
echo -e "${RESET}"
echo -e "${CYAN}==============================================${RESET}"

echo -e "${YELLOW}Kernel:     ${RESET}${KERNEL}"
echo -e "${YELLOW}Uptime:     ${RESET}${UPTIME}"

echo -e "${YELLOW}Load Avg:   ${RESET}${LOAD1} ${LOAD5} ${LOAD15} (Alert: ${LOAD_ALERT})"
echo -e "${YELLOW}Memory:     ${RESET}${MEM_USED}MB / ${MEM_TOTAL}MB (Alert: ${MEM_ALERT}%)"
echo -e "${YELLOW}Disk (/):   ${RESET}${DISK_USED} / ${DISK_TOTAL} (Alert: ${DISK_ALERT}%)"

echo -e "${CYAN}----------------------------------------------${RESET}"
echo -e "${GREEN} Services Status${RESET}"
echo -e " SSH:          ${SSH_STATUS}"
echo -e " Fail2ban:     ${FAIL2BAN_STATUS}"
echo -e " Cron:         ${CRON_STATUS}"
echo -e " Network:      ${NETWORK_STATUS}"
echo -e "${CYAN}----------------------------------------------${RESET}"

echo -e "${GREEN} Network Health${RESET}"
echo -e " Gateway ($GATEWAY): $PING_GW"
echo -e " Internet (1.1.1.1): $PING_NET"
echo -e " Interfaces: $IFACE_STATUS"
echo -e "${CYAN}----------------------------------------------${RESET}"

echo -e "${GREEN} Security & Updates${RESET}"
echo -e " Fail2ban bans: $FAIL2BAN_BANS"
echo -e " Updates available: $UPDATES_ALERT"
echo -e "${CYAN}----------------------------------------------${RESET}"

echo -e "${GREEN} Last Systemd Errors${RESET}"
echo -e "${SYSTEMD_ERRORS:-No recent errors}"
echo -e "${CYAN}----------------------------------------------${RESET}"

echo -e "${CYAN}==============================================${RESET}"
EOF

log "Copying MOTD banner script into the VM image..."
virt-customize -a "$IMG_ORIG" --copy-in "$workdir/00-custom-motd.sh:/etc/profile.d/"
virt-customize -a "$IMG_ORIG" --run-command "chmod +x /etc/profile.d/00-custom-motd.sh"
virt-customize -a "$IMG_ORIG" --run-command "chmod -x /etc/update-motd.d/*"
virt-customize -a "$IMG_ORIG" --run-command "truncate -s 0 /etc/motd"

ok "VM MOTD banner installed successfully."
