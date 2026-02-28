#!/usr/bin/env bash

# Meowrch NixOS Installer
# Based on the original Meowrch installer (https://github.com/meowrch/meowrch)
# Adapted for NixOS 25.11

set -e

# Logging setup
LOG_FILE="$(pwd)/install.log"
# Clear or create log file with header
echo "--- Meowrch NixOS Installation Log: $(date) ---" > "$LOG_FILE"
# Redirect stdout and stderr to both console and log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Error handling
trap 'echo -e "\n${RED}[ERROR] Installation failed at line $LINENO. Check $LOG_FILE for details.${NC}"' ERR

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
                                 By Redm00use
${NC}"

echo -e "${CYAN}Welcome to Meowrch NixOS Installer v3.4.0${NC}"
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
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
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
    TARGET_DIR="$HOME/NixOS-Meowrch"
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

# 1. Hostname — patched in modules/nixos/system/networking.nix
echo -e "${BLUE}[INFO] Setting hostname to $CONF_HOSTNAME...${NC}"
NETWORKING_NIX="modules/nixos/system/networking.nix"
CONF_NIX="hosts/meowrch/configuration.nix"
HOME_NIX="hosts/meowrch/home.nix"

if grep -q "hostName" "$NETWORKING_NIX"; then
    sed -i "s/hostName = \".*\";/hostName = \"$CONF_HOSTNAME\";/" "$NETWORKING_NIX"
elif grep -q "networking.hostName" "$CONF_NIX"; then
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$CONF_HOSTNAME\";/" "$CONF_NIX"
else
    sed -i "s/^}$/  networking.hostName = \"$CONF_HOSTNAME\";\n}/" "$CONF_NIX"
fi

# 2. Username
echo -e "${BLUE}[INFO] Setting username to $CONF_USER...${NC}"
if [ "$CONF_USER" != "meowrch" ]; then
    # Patch configuration.nix
    sed -i "s/users\.meowrch/users.$CONF_USER/g" "$CONF_NIX"
    sed -i "s/group = \"meowrch\"/group = \"$CONF_USER\"/" "$CONF_NIX"
    sed -i "s/groups\.meowrch/groups.$CONF_USER/g" "$CONF_NIX"
    sed -i "s/description = \"Meowrch User\"/description = \"$CONF_USER\"/" "$CONF_NIX"

    # Patch home.nix
    sed -i "s/home.username = lib.mkForce \"meowrch\"/home.username = lib.mkForce \"$CONF_USER\"/" "$HOME_NIX"
    sed -i "s|home.homeDirectory = lib.mkForce \"/home/meowrch\"|home.homeDirectory = lib.mkForce \"/home/$CONF_USER\"|g" "$HOME_NIX"
    sed -i "s|/home/meowrch/|/home/$CONF_USER/|g" "$HOME_NIX"

    # Patch sddm.nix
    sed -i "s|/home/meowrch/|/home/$CONF_USER/|g" "modules/nixos/desktop/sddm.nix"
    sed -i "s|meowrch users|${CONF_USER} users|g" "modules/nixos/desktop/sddm.nix"

    # Patch flake.nix
    sed -i "s/home-manager.users.meowrch/home-manager.users.$CONF_USER/g" flake.nix
    sed -i "s/homeConfigurations.meowrch/homeConfigurations.$CONF_USER/g" flake.nix
fi

# 3. Rename Configuration to match Hostname
if [ "$CONF_HOSTNAME" != "meowrch" ]; then
    echo -e "${BLUE}[INFO] Renaming configuration to $CONF_HOSTNAME...${NC}"
    sed -i "s/nixosConfigurations.meowrch/nixosConfigurations.$CONF_HOSTNAME/g" flake.nix
    sed -i "s|\.#meowrch|.#$CONF_HOSTNAME|g" "$HOME_NIX"
    sed -i "s|\.#meowrch|.#$CONF_HOSTNAME|g" "$CONF_NIX"
fi

# 4. GPU — swap the GPU-specific module in configuration.nix
echo -e "${BLUE}[INFO] Configuring GPU driver...${NC}"
case "$GPU_CHOICE" in
    0)
        sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-amd.nix # GPU_MODULE_LINE|' "$CONF_NIX"
        sed -i '/nvidia\.acceptLicense/d' "$CONF_NIX"
        sed -i '/nvidia\.acceptLicense/d' flake.nix
        ;;
    1)
        sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-intel.nix # GPU_MODULE_LINE|' "$CONF_NIX"
        sed -i '/nvidia\.acceptLicense/d' "$CONF_NIX"
        sed -i '/nvidia\.acceptLicense/d' flake.nix
        ;;
    2)
        sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-nvidia.nix # GPU_MODULE_LINE|' "$CONF_NIX"
        if ! grep -q "nvidia.acceptLicense" "$CONF_NIX"; then
            sed -i '/allowUnfreePredicate/a \    nvidia.acceptLicense = true;' "$CONF_NIX"
        fi
        if ! grep -q "nvidia.acceptLicense" flake.nix; then
            sed -i '/config\.allowUnfree = true;/a \      config.nvidia.acceptLicense = true;' flake.nix
        fi
        ;;
esac

# --- Phase 3: Hardware Config ---

echo -e "\n${YELLOW}==> Generating Hardware Configuration${NC}"
HW_CONF_PATH="hosts/meowrch/hardware-configuration.nix"

if [ "$MODE" -eq 1 ]; then
    TMP_CONFIG=$(mktemp -d)
    nixos-generate-config --root /mnt --dir "$TMP_CONFIG"
    cp "$TMP_CONFIG/hardware-configuration.nix" "$HW_CONF_PATH"
    rm -rf "$TMP_CONFIG"
else
    nixos-generate-config --show-hardware-config > "$HW_CONF_PATH"
fi

# Add hardware-config to git (needed for flake)
if [ ! -d .git ]; then
    git init >/dev/null
    git add --all >/dev/null
else
    git add --force "$HW_CONF_PATH" >/dev/null
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
    echo -e "${BLUE}Detailed logs are saved to: $LOG_FILE${NC}"
    echo "You can now reboot into your new Meowrch NixOS system."
    echo "Type 'reboot' to restart."
else
    echo -e "${BLUE}[INFO] Starting 'nixos-rebuild boot'...${NC}"
    echo "This may take a while."
    sudo env NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild boot --flake ".#$CONF_HOSTNAME"

    echo -e "\n${GREEN}Update Complete!${NC}"
    echo -e "${BLUE}Detailed logs are saved to: $LOG_FILE${NC}"
    echo "Changes will be applied on next boot. Please reboot your system."
fi
