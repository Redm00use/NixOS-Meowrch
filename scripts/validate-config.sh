#!/usr/bin/env bash
#
# Meowrch NixOS Configuration Validator
# ===================================================================
# Performs deep inspection of the configuration for errors
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${BLUE}🐱 Meowrch NixOS Configuration Validator${NC}\n"

# 1. Check Flake Syntax
print_info "Checking flake syntax..."
if nix flake show --json --impure &>/dev/null; then
    print_success "Flake syntax is valid"
else
    print_error "Flake syntax is invalid!"
    exit 1
fi

# 2. Check Core Files
CONF_FILE="hosts/meowrch/configuration.nix"
HOME_FILE="hosts/meowrch/home.nix"

if [[ ! -f "$CONF_FILE" ]]; then
    print_error "Configuration file missing: $CONF_FILE"
    exit 1
fi

# 3. Check for deprecated options
print_info "Checking for deprecated options..."
if grep -q "hardware\.opengl" "$CONF_FILE"; then
    print_warning "Found hardware.opengl (deprecated). Use hardware.graphics for 24.11+"
fi

# 4. Check Symlinks Paths
print_info "Validating home-manager symlinks..."
grep "source =" "$HOME_FILE" | while read -r line; do
    path=$(echo "$line" | cut -d'=' -f2 | tr -d ' ;"' | sed 's|../../||')
    if [[ ! -e "$path" && "$path" != *pkgs* ]]; then
        print_warning "Symlink source might be broken: $path"
    fi
done

# 5. Dry run build
print_info "Performing dry-run build..."
if nix build .#nixosConfigurations.meowrch.config.system.build.toplevel --dry-run --impure &>/dev/null; then
    print_success "Configuration builds successfully"
else
    print_error "Build check failed!"
fi

echo -e "\n${GREEN}🎉 Validation completed!${NC}"
