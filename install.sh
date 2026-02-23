#!/usr/bin/env bash

# Meowrch NixOS Installer
# Based on the original Meowrch installer (https://github.com/meowrch/meowrch)
# Adapted for NixOS 25.11

set -e

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

# Clear screen
clear

# ASCII Art
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
${NC}"

echo -e "${CYAN}Welcome to Meowrch NixOS Installer v3.0${NC}"
echo -e "${BLUE}Starting pre-install checks...${NC}" && sleep 1

# Check if running on NixOS ISO
if [ -f "/etc/NIXOS" ] && grep -q "iso" /etc/os-release 2>/dev/null; then
    IS_ISO=true
fi

# Function to ask questions
ask() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        echo -e -n "${GREEN}? ${NC}${prompt} [${CYAN}${default}${NC}]: "
    else
        echo -e -n "${GREEN}? ${NC}${prompt}: "
    fi
    read -r input
    if [ -z "$input" ] && [ -n "$default" ]; then
        export "$var_name"="$default"
    else
        export "$var_name"="$input"
    fi
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
        echo -e "${RED}Invalid selection. Please try again.${NC}"
    done
}

# --- Phase 1: Information Gathering ---

echo -e "\n${YELLOW}==> Configuration Survey${NC}"

# 1. Install Mode
MODE_OPTIONS=("Apply to current system (Update)" "Install to new disk (Bootstrap /mnt)")
ask_choice "Choose installation mode:" "${MODE_OPTIONS[@]}"
MODE=$?

if [ "$MODE" -eq 1 ]; then
    # Bootstrap Mode
    if [ ! -d "/mnt/etc" ]; then
        echo -e "${RED}[ERROR] /mnt is not mounted or empty.${NC}"
        echo "Please partition and mount your disks to /mnt before running this script."
        exit 1
    fi
    TARGET_DIR="/mnt/etc/nixos/meowrch"
    echo -e "${BLUE}[INFO] Installing to /mnt...${NC}"
else
    # Update Mode
    TARGET_DIR="$HOME/meowrch-nixos"
    echo -e "${BLUE}[INFO] Updating current system...${NC}"
fi

# 2. Hostname
ask "Enter Hostname" "meowrch-machine" "CONF_HOSTNAME"

# 3. Username
if [ "$MODE" -eq 1 ]; then
    ask "Enter Username" "meowrch" "CONF_USER"
else
    ask "Enter Username" "$USER" "CONF_USER"
fi

# 4. GPU Driver
GPU_OPTIONS=("AMD (Recommended)" "Intel" "Nvidia (Beta)")
ask_choice "Select GPU Driver:" "${GPU_OPTIONS[@]}"
GPU_CHOICE=$?

# 5. Shell
SHELL_OPTIONS=("Fish" "Zsh" "Bash")
ask_choice "Select User Shell:" "${SHELL_OPTIONS[@]}"
SHELL_CHOICE=$?

# 6. Confirm
echo -e "\n${YELLOW}==> Summary${NC}"
echo -e "  Mode:     ${MODE_OPTIONS[$MODE]}"
echo -e "  Target:   $TARGET_DIR"
echo -e "  Hostname: $CONF_HOSTNAME"
echo -e "  User:     $CONF_USER"
echo -e "  GPU:      ${GPU_OPTIONS[$GPU_CHOICE]}"
echo -e "  Shell:    ${SHELL_OPTIONS[$SHELL_CHOICE]}"
echo ""

ask "Proceed with installation?" "y" "CONFIRM"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
fi

# --- Phase 2: Preparation ---

echo -e "\n${YELLOW}==> Preparing Files${NC}"

# Create target directory
if [ -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}[INFO] Cleaning existing directory $TARGET_DIR...${NC}"
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"
echo -e "${BLUE}[INFO] Copying configuration to $TARGET_DIR...${NC}"
cp -r . "$TARGET_DIR/"

cd "$TARGET_DIR"

# Apply Configuration (Patching files)

# 1. Hostname — patched in modules/system/networking.nix (where hostName actually lives)
# Note: configuration.nix does NOT contain networking.hostName; it's in the networking module.
echo -e "${BLUE}[INFO] Setting hostname to $CONF_HOSTNAME...${NC}"
NETWORKING_NIX="modules/system/networking.nix"
if grep -q "hostName" "$NETWORKING_NIX"; then
    # Patch the networking module — this is the correct location
    sed -i "s/hostName = \".*\";/hostName = \"$CONF_HOSTNAME\";/" "$NETWORKING_NIX"
elif grep -q "networking.hostName" configuration.nix; then
    # Fallback: patch configuration.nix if it has a top-level networking.hostName
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$CONF_HOSTNAME\";/" configuration.nix
else
    # Last resort: append a top-level option BEFORE the closing brace of configuration.nix
    # (NOT inside the imports block — that would break Nix syntax)
    sed -i "s/^}$/  networking.hostName = \"$CONF_HOSTNAME\";\n}/" configuration.nix
fi

# 2. Username
echo -e "${BLUE}[INFO] Setting username to $CONF_USER...${NC}"
if [ "$CONF_USER" != "meowrch" ]; then
    # Patch configuration.nix
    sed -i "s/users.users.meowrch/users.users.$CONF_USER/g" configuration.nix
    
    # Patch home/home.nix
    sed -i "s/home.username = lib.mkForce \"meowrch\"/home.username = lib.mkForce \"$CONF_USER\"/" home/home.nix
    sed -i "s|home.homeDirectory = lib.mkForce \"/home/meowrch\"|home.homeDirectory = lib.mkForce \"/home/$CONF_USER\"|g" home/home.nix
    
    # Patch flake.nix (users.meowrch -> users.$CONF_USER)
    sed -i "s/home-manager.users.meowrch/home-manager.users.$CONF_USER/g" flake.nix
    sed -i "s/homeConfigurations.meowrch/homeConfigurations.$CONF_USER/g" flake.nix
fi

# 3. Rename Configuration to match Hostname
# This ensures 'nixos-rebuild switch' works without arguments later
if [ "$CONF_HOSTNAME" != "meowrch" ]; then
    echo -e "${BLUE}[INFO] Renaming configuration to $CONF_HOSTNAME...${NC}"
    sed -i "s/nixosConfigurations.meowrch/nixosConfigurations.$CONF_HOSTNAME/g" flake.nix
fi

# 4. GPU (This would normally require module imports)
# For now we just log it, as the config is optimized for AMD.
if [ "$GPU_CHOICE" -ne 0 ]; then
    echo -e "${YELLOW}[WARN] You selected a non-AMD GPU.${NC}"
    echo "       Please manually edit 'modules/system/graphics.nix' after installation"
    echo "       to enable specific drivers (nvidia/intel)."
fi

# --- Phase 3: Hardware Config ---

echo -e "\n${YELLOW}==> Generating Hardware Configuration${NC}"

if [ "$MODE" -eq 1 ]; then
    # Bootstrap: Generate to /mnt and copy
    echo -e "${BLUE}[INFO] Generating hardware-configuration.nix from /mnt...${NC}"
    # We use a temp dir because nixos-generate-config creates configuration.nix too
    TMP_CONFIG=$(mktemp -d)
    nixos-generate-config --root /mnt --dir "$TMP_CONFIG"
    cp "$TMP_CONFIG/hardware-configuration.nix" "$TARGET_DIR/"
    rm -rf "$TMP_CONFIG"
else
    # Update: Generate based on current system
    echo -e "${BLUE}[INFO] Regenerating hardware-configuration.nix...${NC}"
    nixos-generate-config --show-hardware-config > "$TARGET_DIR/hardware-configuration.nix"
fi

# Add hardware-config to git (needed for flake)
if [ ! -d .git ]; then
    git init >/dev/null
    git add . >/dev/null
else
    git add hardware-configuration.nix >/dev/null
fi

# --- Phase 4: Hash Updates ---

echo -e "\n${YELLOW}==> Updating Package Hashes${NC}"
chmod +x scripts/update-pkg-hashes.sh
./scripts/update-pkg-hashes.sh || echo -e "${YELLOW}[WARN] Failed to update hashes (no internet?)${NC}"

# --- Phase 5: Installation ---

echo -e "\n${YELLOW}==> Installing System${NC}"

if [ "$MODE" -eq 1 ]; then
    echo -e "${BLUE}[INFO] Starting 'nixos-install'...${NC}"
    echo "This may take a while."
    # We must allow unfree
    export NIXPKGS_ALLOW_UNFREE=1
    nixos-install --flake ".#$CONF_HOSTNAME" --root /mnt
    
    echo -e "\n${GREEN}Installation Complete!${NC}"
    echo "You can now reboot into your new Meowrch NixOS system."
    echo "Type 'reboot' to restart."
else
    echo -e "${BLUE}[INFO] Starting 'nixos-rebuild switch'...${NC}"
    echo "This may take a while."
    sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake ".#$CONF_HOSTNAME"
    
    echo -e "\n${GREEN}Update Complete!${NC}"
    echo "Changes have been applied. Restart your shell or reboot to see all changes."
fi
