#!/usr/bin/env bash

# Meowrch NixOS Installer
# Based on the original Meowrch installer (https://github.com/meowrch/meowrch)
# Adapted for NixOS 25.11

set -e

# Logging setup
LOG_FILE="$(pwd)/install.log"
echo "--- Meowrch NixOS Installation Log: $(date) ---" > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# Error handling
trap 'echo -e "\n\033[0;31m[ERROR] Installation failed at line $LINENO. Check $LOG_FILE for details.\033[0m"' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# State
TARGET_DIR=""
IS_ISO=false
FLAKE_NAME="meowrch"

clear
echo -e "${PURPLE}
                          ▄▀▄     ▄▀▄           ▄▄▄▄▄
                         ▄█░░▀▀▀▀▀░░█▄         █░▄▄░░█
                     ▄▄  █░░░░░░░░░░░█  ▄▄    █░█  █▄█
                    █▄▄█ █░░▀░░┬░░▀░░█ █▄▄█  █░█
███╗░░░███╗███████╗░█████╗░░██╗░░░░░░░██╗██████╗░░█████╗░██╗░░██╗
████╗░████║██╔════╝██╔══██╗░██║░░██╗░░██║██╔══██╗██╔══██╗██║░░██║
██╔████╔██║█████╗░░██║░░██║░╚██╗████╗██╔╝██████╔╝██║░░╚═╝███████║
██║╚██╔╝██║██╔══╝░░██║░░██║░░████╔═████║░██╔══██╗██║░░██╗██╔══██║
██║░╚═╝░██║███████╗╚█████╔╝░░╚██╔╝░╚██╔╝░██║░░██║╚█████╔╝██║░░██║
╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝
                                 By Redm00use
${NC}"

echo -e "${CYAN}Welcome to Meowrch NixOS Installer v3.5.0${NC}"
echo -e "${BLUE}Starting pre-install checks...${NC}" && sleep 1

if [ -f "/etc/NIXOS" ] && grep -q "iso" /etc/os-release 2>/dev/null; then
    IS_ISO=true
fi

ask() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    echo -e -n "${GREEN}? ${NC}${prompt} [${CYAN}${default}${NC}]: "
    read -r input
    eval "$var_name=\"${input:-$default}\""
}

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    echo -e "${GREEN}? ${NC}${prompt}"
    for i in "${!options[@]}"; do
        echo -e "  [${CYAN}$((i+1))${NC}] ${options[$i]}"
    done
    while true; do
        echo -e -n "${GREEN}> ${NC}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            return $((choice-1))
        fi
        echo -e "${RED}Invalid selection.${NC}"
    done
}

echo -e "\n${YELLOW}==> Configuration Survey${NC}"
MODE_OPTIONS=("Apply to current system (Update)" "Install to new disk (Bootstrap /mnt)")
ask_choice "Choose installation mode:" "${MODE_OPTIONS[@]}"
MODE=$?

if [ "$MODE" -eq 1 ]; then
    if [ ! -d "/mnt/etc" ]; then
        echo -e "${RED}[ERROR] /mnt is not mounted or empty.${NC}"
        exit 1
    fi
    TARGET_DIR="/mnt/etc/nixos/meowrch"
else
    TARGET_DIR="$HOME/NixOS-Meowrch"
fi

ask "Enter Hostname" "meowrch-machine" "CONF_HOSTNAME"
ask "Enter Username" "${USER:-meowrch}" "CONF_USER"

GPU_OPTIONS=("AMD (Recommended)" "Intel" "Nvidia (Beta)")
ask_choice "Select GPU Driver:" "${GPU_OPTIONS[@]}"
GPU_CHOICE=$?

echo -e "\n${YELLOW}==> Summary${NC}"
echo -e "  Mode:     ${MODE_OPTIONS[$MODE]}"
echo -e "  Target:   $TARGET_DIR"
echo -e "  Hostname: $CONF_HOSTNAME"
echo -e "  User:     $CONF_USER"
echo -e "  GPU:      ${GPU_OPTIONS[$GPU_CHOICE]}"
echo ""

ask "Proceed with installation?" "y" "CONFIRM"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then exit 0; fi

# Create target directory
if [ -d "$TARGET_DIR" ]; then rm -rf "$TARGET_DIR"; fi
mkdir -p "$TARGET_DIR"
cp -r . "$TARGET_DIR/"
cd "$TARGET_DIR"

# Patch paths and configuration
NETWORKING_NIX="modules/nixos/system/networking.nix"
CONF_NIX="hosts/meowrch/configuration.nix"
HOME_NIX="hosts/meowrch/home.nix"
SDDM_NIX="modules/nixos/desktop/sddm.nix"

echo -e "${BLUE}[INFO] Patching configuration files...${NC}"

# Hostname
if [ -f "$NETWORKING_NIX" ]; then
    sed -i "s/hostName = \".*\";/hostName = \"$CONF_HOSTNAME\";/" "$NETWORKING_NIX"
fi

# Username & Home
if [ "$CONF_USER" != "meowrch" ]; then
    sed -i "s/users\.meowrch/users.$CONF_USER/g" "$CONF_NIX"
    sed -i "s/group = \"meowrch\"/group = \"$CONF_USER\"/" "$CONF_NIX"
    sed -i "s/groups\.meowrch/groups.$CONF_USER/g" "$CONF_NIX"
    sed -i "s/home.username = lib.mkForce \"meowrch\"/home.username = lib.mkForce \"$CONF_USER\"/" "$HOME_NIX"
    sed -i "s|/home/meowrch|/home/$CONF_USER|g" "$HOME_NIX"
    sed -i "s|/home/meowrch|/home/$CONF_USER|g" "$SDDM_NIX"
    sed -i "s|meowrch users|${CONF_USER} users|g" "$SDDM_NIX"
    
    if [ -f "config/meowrch/config.yaml" ]; then
        sed -i "s|/home/meowrch|/home/$CONF_USER|g" "config/meowrch/config.yaml"
        sed -i "s|~/.config/meowrch|/home/$CONF_USER/.config/meowrch|g" "config/meowrch/config.yaml"
    fi
    
    sed -i "s/users.meowrch/users.$CONF_USER/g" flake.nix
fi

# GPU
case "$GPU_CHOICE" in
    0) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-amd.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    1) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-intel.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    2) 
        sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-nvidia.nix # GPU_MODULE_LINE|' "$CONF_NIX"
        sed -i '/allowUnfreePredicate/a \    nvidia.acceptLicense = true;' "$CONF_NIX"
        sed -i '/config\.allowUnfree = true;/a \      config.nvidia.acceptLicense = true;' flake.nix
        ;;
esac

# Fix script permissions and Shebangs
find scripts/ -type f -exec chmod +x {} \;
chmod +x install.sh

# Generate Hardware Config
HW_CONF_PATH="hosts/meowrch/hardware-configuration.nix"
if [ "$MODE" -eq 1 ]; then
    nixos-generate-config --root /mnt --dir "$(mktemp -d)"
    # We copy manually to ensure correct path
    nixos-generate-config --show-hardware-config > "$HW_CONF_PATH"
else
    nixos-generate-config --show-hardware-config > "$HW_CONF_PATH"
fi

# Finalize Git for Flake
git init >/dev/null 2>&1
git add . >/dev/null 2>&1

echo -e "\n${YELLOW}==> Installing System${NC}"
if [ "$MODE" -eq 1 ]; then
    export NIXPKGS_ALLOW_UNFREE=1
    nixos-install --flake ".#meowrch" --root /mnt
else
    sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild boot --flake ".#meowrch" --impure
fi

echo -e "\n${GREEN}Installation Complete!${NC}"
echo "Please reboot your system."
