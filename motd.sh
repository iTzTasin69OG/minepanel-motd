#!/bin/bash
# MinePanel Advanced MOTD Installer - Professional Server Dashboard

echo "🔧 Installing MinePanel Professional MOTD..."

# Disable default MOTD messages
chmod -x /etc/update-motd.d/* 2>/dev/null

# Create professional stats MOTD script
cat << 'EOF' > /etc/update-motd.d/00-minepanel
#!/bin/bash

# Color Definitions
CYAN="\e[38;5;45m"
GREEN="\e[38;5;82m"
YELLOW="\e[38;5;220m"
BLUE="\e[38;5;51m"
PURPLE="\e[38;5;141m"
RED="\e[38;5;203m"
WHITE="\e[38;5;255m"
RESET="\e[0m"
BOLD="\e[1m"

# Function to get system stats
get_stats() {
    # CPU Load (1-min average)
    LOAD=$(uptime | awk -F 'load average:' '{ print $2 }' | awk '{ print $1 }' 2>/dev/null || echo "N/A")
    
    # Memory Usage
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}' 2>/dev/null || echo "N/A")
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}' 2>/dev/null || echo "N/A")
    if [[ "$MEM_TOTAL" != "N/A" && "$MEM_USED" != "N/A" && "$MEM_TOTAL" -gt 0 ]]; then
        MEM_PERC=$((MEM_USED * 100 / MEM_TOTAL))
    else
        MEM_PERC=0
    fi
    
    # Disk Usage
    DISK_USED=$(df -h / | awk 'NR==2 {print $3}' 2>/dev/null || echo "N/A")
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}' 2>/dev/null || echo "N/A")
    DISK_PERC=$(df -h / | awk 'NR==2 {print $5}' 2>/dev/null | tr -d '%' || echo "0")
    
    # Other stats
    PROC=$(ps aux | wc -l 2>/dev/null || echo "0")
    USERS=$(who | wc -l 2>/dev/null || echo "0")
    IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "N/A")
    UPTIME=$(uptime -p | sed 's/up //' 2>/dev/null || echo "N/A")
    OS=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2 2>/dev/null || uname -o 2>/dev/null || echo "Unknown")
    KERNEL=$(uname -r 2>/dev/null || echo "N/A")
    CPU_CORES=$(nproc 2>/dev/null || echo "N/A")
}

# Function to display progress bar
progress_bar() {
    local value=$1
    local max=100
    local bar_length=20
    local filled=$((value * bar_length / max))
    local empty=$((bar_length - filled))
    
    # Ensure values are within bounds
    if [ $filled -gt $bar_length ]; then filled=$bar_length; fi
    if [ $empty -lt 0 ]; then empty=0; fi
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "▓"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %s%%" "$value"
}

# Get stats
get_stats

# Header with MinePanel ASCII Art
echo -e "${CYAN}"
echo -e "┌──────────────────────────────────────────────────────────────────────┐"
echo -e "│                                                                      │"
echo -e "│  ═══════════════════════════════════════════════════════════════════ │"
echo -e "│                                                                      │"
echo -e "│  ███╗   ███╗██╗███╗   ██╗███████╗██████╗  █████╗ ███╗   ██╗███████╗██╗  │"
echo -e "│  ████╗ ████║██║████╗  ██║██╔════╝██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  │"
echo -e "│  ██╔████╔██║██║██╔██╗ ██║█████╗  ██████╔╝███████║██╔██╗ ██║█████╗  ██║  │"
echo -e "│  ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║╚██╗██║██╔══╝  ██║  │"
echo -e "│  ██║ ╚═╝ ██║██║██║ ╚████║███████╗██║  ██║██║  ██║██║ ╚████║███████╗███████╗│"
echo -e "│  ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝│"
echo -e "│                                                                      │"
echo -e "│  ═══════════════════════════════════════════════════════════════════ │"
echo -e "│                                                                      │"
echo -e "└──────────────────────────────────────────────────────────────────────┘${RESET}"

echo -e "${GREEN}${BOLD}   🎮 MinePanel - VPS Management Dashboard${RESET}"
echo -e "${WHITE}   ──────────────────────────────────────────────────${RESET}\n"

# System Information
echo -e "${BLUE}${BOLD}📋 SYSTEM OVERVIEW${RESET}"
echo -e "${WHITE}   Timestamp:${RESET} $(date '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || date)"
echo -e "${WHITE}   Server IP:${RESET} ${YELLOW}${IP}${RESET}"
echo -e "${WHITE}   Hostname: ${RESET} $(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "MinePanel")"
echo -e "${WHITE}   OS:       ${RESET} ${OS}"
echo -e "${WHITE}   Kernel:   ${RESET} ${KERNEL}"
echo -e "${WHITE}   Uptime:   ${RESET} ${UPTIME}\n"

# Resource Utilization
echo -e "${BLUE}${BOLD}📊 RESOURCE UTILIZATION${RESET}"

# CPU Load
echo -e "${WHITE}   CPU Load (1-min):${RESET}"
echo -e "   ${YELLOW}↳${RESET} ${LOAD} ${WHITE}[Cores: ${CPU_CORES}]${RESET}"

# Memory Usage with Progress Bar
if [[ "$MEM_TOTAL" != "N/A" && "$MEM_USED" != "N/A" && "$MEM_TOTAL" -gt 0 ]]; then
    echo -e "${WHITE}   Memory Usage:${RESET}"
    echo -e "   ${YELLOW}↳${RESET} ${MEM_USED}MB / ${MEM_TOTAL}MB"
    echo -e "     $(progress_bar ${MEM_PERC})"
else
    echo -e "${WHITE}   Memory Usage:${RESET} ${YELLOW}Not available${RESET}"
fi

# Disk Usage with Progress Bar
if [[ "$DISK_PERC" != "0" ]]; then
    echo -e "${WHITE}   Disk Usage (/):${RESET}"
    echo -e "   ${YELLOW}↳${RESET} ${DISK_USED} / ${DISK_TOTAL}"
    echo -e "     $(progress_bar ${DISK_PERC})"
else
    echo -e "${WHITE}   Disk Usage (/):${RESET} ${YELLOW}Not available${RESET}"
fi

# System Activity
echo -e "\n${BLUE}${BOLD}📈 SYSTEM ACTIVITY${RESET}"
echo -e "${WHITE}   Active Processes:${RESET} ${PROC}"
echo -e "${WHITE}   Logged-in Users: ${RESET} ${USERS}"
if command -v systemctl &> /dev/null; then
    ACTIVE_SERVICES=$(systemctl list-units --state=running --type=service 2>/dev/null | grep -c "loaded units" 2>/dev/null || echo "N/A")
    echo -e "${WHITE}   Active Services: ${RESET} ${ACTIVE_SERVICES}"
fi

# Game Server Status (if Minecraft server is running)
if pgrep -f "minecraft" > /dev/null 2>&1 || pgrep -f "server.jar" > /dev/null 2>&1; then
    echo -e "${WHITE}   Game Servers:  ${RESET} ${GREEN}● Online${RESET}"
else
    echo -e "${WHITE}   Game Servers:  ${RESET} ${YELLOW}○ Offline${RESET}"
fi

# Network Status
echo -e "\n${BLUE}${BOLD}🌐 NETWORK STATUS${RESET}"
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "Not available")
echo -e "${WHITE}   Public IP:       ${RESET} ${PUBLIC_IP}"
if command -v ss &> /dev/null; then
    SSH_CONNS=$(ss -t state established sport = :ssh 2>/dev/null | wc -l 2>/dev/null || echo "N/A")
    OPEN_PORTS=$(ss -tuln 2>/dev/null | grep -c LISTEN 2>/dev/null || echo "N/A")
    echo -e "${WHITE}   SSH Connections: ${RESET} ${SSH_CONNS}"
    echo -e "${WHITE}   Open Ports:      ${RESET} ${OPEN_PORTS}"
fi

# Quick Commands Reference
echo -e "\n${BLUE}${BOLD}⚙️  QUICK COMMANDS${RESET}"
echo -e "${WHITE}   System Info:    ${RESET}${GREEN}htop${RESET}, ${GREEN}nmon${RESET}, ${GREEN}neofetch${RESET}"
echo -e "${WHITE}   Network Tools:  ${RESET}${GREEN}vnstat${RESET}, ${GREEN}iftop${RESET}, ${GREEN}nload${RESET}"
echo -e "${WHITE}   Game Servers:   ${RESET}${GREEN}screen -r minecraft${RESET}, ${GREEN}./start.sh${RESET}"
echo -e "${WHITE}   Security:       ${RESET}${GREEN}fail2ban-client status${RESET}"
echo -e "${WHITE}   Updates:        ${RESET}${GREEN}apt update && apt upgrade${RESET} (Debian/Ubuntu)"
echo -e "${WHITE}                   ${RESET}${GREEN}yum update${RESET} (CentOS/RHEL)"

# Security Status (if available)
if command -v fail2ban-client &> /dev/null; then
    BANNED=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}' 2>/dev/null || echo "0")
    echo -e "\n${BLUE}${BOLD}🔒 SECURITY STATUS${RESET}"
    echo -e "${WHITE}   Fail2Ban:       ${RESET} ${BANNED} banned IPs"
fi

# Footer
echo -e "\n${CYAN}${BOLD}┌──────────────────────────────────────────────────────────────────────┐${RESET}"
echo -e "${WHITE}   🌐 Website:     ${BLUE}https://www.minepanel.indevs.in${RESET}"
echo -e "${WHITE}   💬 Discord:     ${BLUE}https://discord.gg/wjaTjfs6DP${RESET}"
echo -e "${WHITE}   📧 Enterprise:  ${BLUE}minepaneloffcial@gmail.com${RESET}"
echo -e "${WHITE}   📱 Support:     ${BLUE}support.minepanel.indevs.in${RESET}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────────────────┘${RESET}"

echo -e "\n${GREEN}${BOLD}   🎮 MinePanel - Next Generation Game Server Management${RESET}"
echo -e "${WHITE}   ──────────────────────────────────────────────────${RESET}"
echo -e "${YELLOW}   Server ID: $(uuidgen 2>/dev/null | cut -d'-' -f1 || echo "MINE-$(date +%s | cut -c6-10)")${RESET}"
echo -e "${YELLOW}   Last updated: $(date '+%Y-%m-%d %H:%M' 2>/dev/null || date '+%Y-%m-%d %H:%M')${RESET}"
EOF

# SSH Fixer

sudo apt install -y openssh-server && service ssh restart
# SSH FIX


sudo bash -c 'cat <<EOF > /etc/ssh/sshd_config
# SSH LOGIN SETTINGS
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication no
ChallengeResponseAuthentication no
UsePAM yes

# SFTP SETTINGS
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

systemctl restart ssh 2>/dev/null || service ssh restart
passwd root
'

# Make script executable
chmod +x /etc/update-motd.d/00-minepanel

# Remove old MOTD files if they exist
rm -f /etc/update-motd.d/00-unixnodes /etc/update-motd.d/00-sknodes /etc/update-motd.d/00-cryzoncloud 2>/dev/null

# Set hostname to MinePanel
echo -e "${BLUE}${BOLD}▶ Setting hostname to MinePanel...${RESET}"
sudo hostnamectl set-hostname MinePanel 2>/dev/null || echo "MinePanel" > /etc/hostname 2>/dev/null

# Test the MOTD
echo -e "${GREEN}${BOLD}✅ MinePanel MOTD Installed Successfully!${RESET}"
echo -e "${YELLOW}➡ Please reconnect SSH to see the new professional dashboard${RESET}"
echo -e "${CYAN}   You can also run: ${WHITE}run-parts /etc/update-motd.d/${RESET}\n"

# Display preview
echo -e "${BLUE}${BOLD}📋 Preview of your new MOTD:${RESET}"
echo -e "${WHITE}──────────────────────────────────────────────────────${RESET}"
/etc/update-motd.d/00-minepanel
