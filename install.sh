#!/bin/bash
set -e

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_UL=$'\033[4m'

# Premium Color Palette
C_RED=$'\033[38;5;196m'      # Bright Red
C_GREEN=$'\033[38;5;46m'     # Neon Green
C_YELLOW=$'\033[38;5;226m'   # Bright Yellow
C_BLUE=$'\033[38;5;39m'      # Deep Sky Blue
C_PURPLE=$'\033[38;5;135m'   # Light Purple
C_CYAN=$'\033[38;5;51m'      # Cyan
C_WHITE=$'\033[38;5;255m'    # Bright White
C_GRAY=$'\033[38;5;245m'     # Gray
C_ORANGE=$'\033[38;5;208m'   # Orange

# Semantic Aliases
C_TITLE=$C_PURPLE
C_CHOICE=$C_CYAN
C_PROMPT=$C_BLUE
C_WARN=$C_YELLOW
C_DANGER=$C_RED
C_STATUS_A=$C_GREEN
C_STATUS_I=$C_GRAY
C_ACCENT=$C_ORANGE



# Must be root
if [[ $EUID -ne 0 ]]; then
 echo -e "${C_RED}⚙️ Error: This script must be run as root.....${C_RESET}"
   exit 1
fi

 apt install jq
 
 echo -e "${C_WHITE}⚙️ Installing VISIBLE TECH MANAGER........${C_RESET}"

# URLs (IPv4 forced to avoid GitHub IPv6 issues)
MENU_URL="https://raw.githubusercontent.com/wavy07/track/main/menu.sh"
SSHD_URL="https://raw.githubusercontent.com/wavy07/track/main/ssh"

# Install menu
wget -4 -q -O /usr/local/bin/menu "$MENU_URL"
chmod +x /usr/local/bin/menu

  echo -e "${C_YELLOW}⚙️ Applying VISIBLE TECH SSH configuration...${C_RESET}"

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.backup.$(date +%F-%H%M%S)"

# Backup current SSH config
cp "$SSHD_CONFIG" "$BACKUP"

# Download VISIBLE TECH  SSH config
wget -4 -q -O "$SSHD_CONFIG" "$SSHD_URL"
chmod 600 "$SSHD_CONFIG"

# Validate SSH config (silent)
if ! sshd -t 2>/dev/null; then
 echo -e "${C_CYAN}⚙️ ERROR: SSH configuration is invalid!!!!!!${C_RESET}"
 echo -e "${C_WHITE}⚙️ Restoring previous configuration...${C_RESET}"
    cp "$BACKUP" "$SSHD_CONFIG"
    exit 1
fi

 echo -e "${C_GRAY}⚙️SSH configuration validated.${C_RESET}"

# Restart SSH quietly and safely
restart_ssh() {
    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart sshd 2>/dev/null \
        || systemctl restart ssh 2>/dev/null \
        || return 1
    elif command -v service >/dev/null 2>&1; then
        service sshd restart 2>/dev/null \
        || service ssh restart 2>/dev/null \
        || return 1
    elif command -v rc-service >/dev/null 2>&1; then
        rc-service sshd restart 2>/dev/null \
        || rc-service ssh restart 2>/dev/null \
        || return 1
    elif [ -x /etc/init.d/sshd ]; then
        /etc/init.d/sshd restart >/dev/null 2>&1
    elif [ -x /etc/init.d/ssh ]; then
        /etc/init.d/ssh restart >/dev/null 2>&1
    else
        return 1
    fi
}

if restart_ssh; then
   echo -e "${C_WHITE}⚙️SSH service restarted.${C_RESET}"
else
     echo -e "${C_RED}⚙️ WARNING: SSH restart not supported on this system.${C_RESET}"
     echo -e "${C_GRAY}⚙️ SSH config applied but service was not restarted automatically.${C_RESET}"
fi

# Run VISIBLE TECH MANAGER setup
bash /usr/local/bin/menu --install-setup

if ! grep -q "/usr/local/bin/menu" /etc/profile
then
echo "/usr/local/bin/menu" >> /etc/profile
fi

echo -e "${C_RED}⚙️ Installation complete!!!!!! ${C_RESET}"
 
echo -e "${C_YELLOW}⚙️ Type 'menu' to start... ${C_RESET}"


echo -e "${C_WHITE}⚙️ AUTO SCRIPT CREATED BY VISIBLE TECH co-founder .Inc🦜~WHATSAPP CONTACT +255 689 000 656${C_RESET}"
