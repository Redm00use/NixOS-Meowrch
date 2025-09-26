#!/usr/bin/env bash

# Script to create necessary directory structure for Meowrch NixOS configuration

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             Meowrch NixOS Directory Structure Setup            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

# Create dotfiles structure
echo -e "${YELLOW}Creating dotfiles structure...${NC}"

# Create base directories
mkdir -p dotfiles/bin
mkdir -p dotfiles/meowrch
mkdir -p dotfiles/wallpapers
mkdir -p dotfiles/themes
mkdir -p dotfiles/icons
mkdir -p dotfiles/sddm_theme

# Message
echo -e "${GREEN}✓ Base directory structure created${NC}"

# Copy existing resources if available
if [ -d "../home/bin" ]; then
    echo -e "${YELLOW}Copying scripts from home/bin...${NC}"
    cp -r ../home/bin/* dotfiles/bin/
    chmod +x dotfiles/bin/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓ Scripts copied${NC}"
else
    echo -e "${RED}× home/bin directory not found - scripts not copied${NC}"
fi

if [ -d "../home/.config/meowrch" ]; then
    echo -e "${YELLOW}Copying meowrch theme management scripts...${NC}"
    cp -r ../home/.config/meowrch/* dotfiles/meowrch/
    chmod +x dotfiles/meowrch/*.py 2>/dev/null || true
    echo -e "${GREEN}✓ Theme management scripts copied${NC}"
else
    echo -e "${RED}× meowrch theme scripts not found${NC}"
fi

# Copy wallpapers if available
if [ -d "../home/.local/share/wallpapers" ]; then
    echo -e "${YELLOW}Copying wallpapers...${NC}"
    cp -r ../home/.local/share/wallpapers/* dotfiles/wallpapers/
    echo -e "${GREEN}✓ Wallpapers copied${NC}"
else
    echo -e "${YELLOW}Creating sample wallpaper...${NC}"
    # Create a placeholder wallpaper
    echo "This is a placeholder for wallpapers" > dotfiles/wallpapers/README.md
    echo -e "${GREEN}✓ Sample wallpaper placeholder created${NC}"
fi

# Note: GRUB theme not used - system configured with systemd-boot
echo -e "${BLUE}ℹ System uses systemd-boot (no GRUB theme needed)${NC}"

# Copy SDDM theme if available
if [ -d "../misc/sddm_theme" ]; then
    echo -e "${YELLOW}Copying SDDM theme...${NC}"
    cp -r ../misc/sddm_theme/* dotfiles/sddm_theme/
    echo -e "${GREEN}✓ SDDM theme copied${NC}"
else
    echo -e "${YELLOW}Creating placeholder SDDM theme...${NC}"
    echo "This is a placeholder for the SDDM theme" > dotfiles/sddm_theme/README.md
    echo -e "${GREEN}✓ SDDM theme placeholder created${NC}"
fi

# Create dummy wallpaper
echo -e "${YELLOW}Creating sample default wallpaper...${NC}"
cat > dotfiles/wallpapers/default.jpg << EOF
This is a placeholder for the default wallpaper.
In a real setup, this would be a JPG image file.
EOF
echo -e "${GREEN}✓ Sample default wallpaper placeholder created${NC}"

# Final message
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Directory Setup Complete!                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo -e "${GREEN}The dotfiles directory structure is now ready.${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Add actual theme files, wallpapers, and other resources"
echo -e "2. Run the NixOS configuration build with: nixos-rebuild switch --flake .#meowrch"
echo -e "${YELLOW}Happy Nixing! ≽ܫ≼${NC}"
