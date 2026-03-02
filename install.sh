#!/usr/bin/env bash

# Meowrch NixOS Installer
# Based on the original Meowrch installer (https://github.com/meowrch/meowrch)
# Adapted for NixOS 25.11 - v3.5.1 (Fixed & Safe Edition)

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

echo -e "${CYAN}Welcome to Meowrch NixOS Installer v3.5.1${NC}"
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
            CHOICE_RESULT=$((choice-1))
            return 0
        fi
        echo -e "${RED}Invalid selection.${NC}"
    done
}

# --- Phase 1: Information Gathering ---

echo -e "\n${YELLOW}==> Configuration Survey${NC}"
MODE_OPTIONS=("Apply to current system (Update)" "Install to new disk (Bootstrap /mnt)")
ask_choice "Choose installation mode:" "${MODE_OPTIONS[@]}"
MODE=$CHOICE_RESULT

if [ "$MODE" -eq 1 ]; then
    if [ ! -d "/mnt/etc" ]; then
        echo -e "${RED}[ERROR] /mnt is not mounted or empty.${NC}"
        exit 1
    fi
    TARGET_DIR="/mnt/etc/nixos/meowrch"
else
    TARGET_DIR="$HOME/NixOS-Meowrch"
fi

# Hostname Validation
while true; do
    ask "Enter Hostname" "meowrch-machine" "CONF_HOSTNAME"
    if [[ "$CONF_HOSTNAME" =~ [/] ]]; then
        echo -e "${RED}Hostname cannot contain slashes. Please try again.${NC}"
    else
        break
    fi
done

# Username Validation
while true; do
    ask "Enter Username" "${USER:-meowrch}" "CONF_USER"
    if [[ "$CONF_USER" =~ [/] ]]; then
        echo -e "${RED}Username cannot contain slashes. Please try again.${NC}"
    else
        break
    fi
done

GPU_OPTIONS=("AMD (Recommended)" "Intel" "Nvidia (Beta)")
ask_choice "Select GPU Driver:" "${GPU_OPTIONS[@]}"
GPU_CHOICE=$CHOICE_RESULT

echo -e "\n${YELLOW}==> Summary${NC}"
echo -e "  Mode:     ${MODE_OPTIONS[$MODE]}"
echo -e "  Target:   $TARGET_DIR"
echo -e "  Hostname: $CONF_HOSTNAME"
echo -e "  User:     $CONF_USER"
echo -e "  GPU:      ${GPU_OPTIONS[$GPU_CHOICE]}"
echo ""

ask "Proceed with installation?" "y" "CONFIRM"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then exit 0; fi

# --- Phase 2: Preparation ---

echo -e "\n${YELLOW}==> Preparing Files${NC}"

# Absolute path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PARENT="$(dirname "$TARGET_DIR")"
mkdir -p "$TARGET_PARENT"
TARGET_ABS="$(cd "$TARGET_PARENT" && pwd)/$(basename "$TARGET_DIR")"

echo -e "${BLUE}[INFO] Source: $SCRIPT_DIR${NC}"
echo -e "${BLUE}[INFO] Target: $TARGET_ABS${NC}"

if [ "$SCRIPT_DIR" == "$TARGET_ABS" ]; then
    echo -e "${BLUE}[INFO] Already in target directory. Skipping clean and copy.${NC}"
else
    # Create target directory
    if [ -d "$TARGET_ABS" ]; then
        echo -e "${BLUE}[INFO] Cleaning existing directory $TARGET_ABS...${NC}"
        # Safety check
        if [[ "$TARGET_ABS" == /mnt/* ]] || [[ "$TARGET_ABS" == "$HOME"/* ]] || [[ "$TARGET_ABS" == /tmp/* ]]; then
            rm -rf "$TARGET_ABS"
        else
            echo -e "${RED}[ERROR] Target $TARGET_ABS is outside safe paths. Aborting.${NC}"
            exit 1
        fi
    fi
    mkdir -p "$TARGET_ABS"
    echo -e "${BLUE}[INFO] Copying configuration to $TARGET_ABS...${NC}"
    cp -a "$SCRIPT_DIR/." "$TARGET_ABS/"
fi

cd "$TARGET_ABS"

# Patch paths and configuration
NETWORKING_NIX="modules/nixos/system/networking.nix"
CONF_NIX="hosts/meowrch/configuration.nix"
HOME_NIX="hosts/meowrch/home.nix"
SDDM_NIX="modules/nixos/desktop/sddm.nix"

# Username & Hostname → пишем в user-local.nix (не отслеживается git)
echo -e "${BLUE}[INFO] Generating configuration for $CONF_USER on $CONF_HOSTNAME...${NC}"
cat > hosts/meowrch/user-local.nix << EOF
# Этот файл создан установщиком.
# Реальные настройки вашего ПК.
{
  meowrch.user = "${CONF_USER}";
  meowrch.hostname = "${CONF_HOSTNAME}";
}
EOF

echo -e "${YELLOW}==> Created user-local.nix with following content:${NC}"
cat hosts/meowrch/user-local.nix
echo ""
ask "Is this correct?" "y" "USER_CONFIRM"
if [[ ! "$USER_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborting to prevent incorrect user configuration."
    exit 1
fi

# GPU
case "$GPU_CHOICE" in
    0) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-amd.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    1) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-intel.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    2)
        sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-nvidia.nix # GPU_MODULE_LINE|' "$CONF_NIX"
        sed -i '/^[[:space:]]*nvidia\.acceptLicense = true;/d' "$CONF_NIX"
        sed -i '/allowUnfreePredicate/a \    nvidia.acceptLicense = true;' "$CONF_NIX"
        sed -i '/^[[:space:]]*config\.nvidia\.acceptLicense = true;/d' flake.nix
        sed -i '/^[[:space:]]*config\.allowUnfree = true;/a \      config.nvidia.acceptLicense = true;' flake.nix
        ;;
esac

# Fix script permissions
find scripts/ -type f -exec chmod +x {} \;
chmod +x install.sh

# --- Phase 3: Hardware Config ---

echo -e "\n${YELLOW}==> Generating Hardware Configuration${NC}"
HW_CONF_PATH="hosts/meowrch/hardware-configuration.nix"
if [ "$MODE" -eq 1 ]; then
    echo -e "${BLUE}[INFO] Generating from /mnt...${NC}"
    nixos-generate-config --show-hardware-config --root /mnt > "$HW_CONF_PATH"
else
    echo -e "${BLUE}[INFO] Regenerating...${NC}"
    nixos-generate-config --show-hardware-config > "$HW_CONF_PATH"
fi

# --- Phase 5: Installation ---

echo -e "\n${YELLOW}==> Installing System${NC}"

# Mandatory for Flakes: stage all files
echo -e "${BLUE}[INFO] Staging files in Git...${NC}"
if [ ! -d .git ]; then git init -q; fi
git add -A --force >/dev/null 2>&1

echo -e "${BLUE}[INFO] Verification of critical files:${NC}"
ls -la flake.nix "$CONF_NIX" "$HOME_NIX" "$HW_CONF_PATH" || echo -e "${RED}[WARN] Critical files missing!${NC}"

if [ "$MODE" -eq 1 ]; then
    echo -e "${BLUE}[INFO] Starting 'nixos-install' with --impure...${NC}"
    export NIXPKGS_ALLOW_UNFREE=1
    nixos-install --flake ".#meowrch" --root /mnt --impure

    echo -e "\n${GREEN}Installation Complete!${NC}"
    echo -e "${BLUE}Detailed logs are saved to: $LOG_FILE${NC}"
    echo "You can now reboot into your new Meowrch NixOS system."
    echo "Type 'reboot' to restart."
else
    echo -e "${BLUE}[INFO] Starting 'nixos-rebuild boot' with --impure...${NC}"
    sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild boot --flake ".#meowrch" --impure

    echo -e "\n${GREEN}Update Complete!${NC}"
    echo -e "${BLUE}Detailed logs are saved to: $LOG_FILE${NC}"
    echo "Changes will be applied on next boot. Please reboot your system."
fi
