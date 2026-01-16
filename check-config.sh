#!/usr/bin/env bash
#
# Meowrch NixOS Configuration Checker
# ===================================================================
# Validates Nix configuration files for common errors
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
SUCCESS=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Meowrch NixOS Configuration Validation                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERRORS++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

ok() {
    echo -e "${GREEN}[OK]${NC} $1"
    ((SUCCESS++))
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if file exists
check_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        ok "File exists: $file"
        return 0
    else
        error "Missing file: $file"
        return 1
    fi
}

# Check for common syntax errors in Nix files
check_nix_syntax() {
    local file="$1"

    if ! [[ -f "$file" ]]; then
        return
    fi

    # Check for mesa.drivers (doesn't exist)
    if grep -q "mesa\.drivers" "$file" 2>/dev/null; then
        error "Found 'mesa.drivers' in $file - this attribute doesn't exist"
    fi

    # Check for hardware.opengl (deprecated in 24.11+)
    if grep -q "hardware\.opengl" "$file" 2>/dev/null; then
        warn "Found 'hardware.opengl' in $file - consider using 'hardware.graphics' for NixOS 24.11+"
    fi

    # Check for programs.gamescope.enable (doesn't exist)
    if grep -q "programs\.gamescope\.enable" "$file" 2>/dev/null; then
        error "Found 'programs.gamescope.enable' in $file - this option doesn't exist"
    fi

    # Check for duplicate bluetooth configuration
    if [[ "$file" == *"audio.nix" ]] && grep -q "hardware\.bluetooth\.enable" "$file" 2>/dev/null; then
        warn "Bluetooth configuration in $file may duplicate bluetooth.nix"
    fi
}

# Check flake.nix
info "Checking flake.nix..."
if check_file_exists "flake.nix"; then
    check_nix_syntax "flake.nix"

    # Check for correct NixOS version references
    if grep -q "nixos-25\.05" "flake.nix" 2>/dev/null; then
        ok "Using NixOS 25.05 channel"
    elif grep -q "nixos-24\.11" "flake.nix" 2>/dev/null; then
        ok "Using NixOS 24.11 channel"
    else
        warn "Could not verify NixOS channel version in flake.nix"
    fi
fi
echo ""

# Check configuration.nix
info "Checking configuration.nix..."
if check_file_exists "configuration.nix"; then
    check_nix_syntax "configuration.nix"

    # Check stateVersion
    if grep -q 'stateVersion = "25\.05"' "configuration.nix" 2>/dev/null; then
        ok "stateVersion is set to 25.05"
    elif grep -q 'stateVersion = "24\.11"' "configuration.nix" 2>/dev/null; then
        ok "stateVersion is set to 24.11"
    else
        warn "Could not verify stateVersion in configuration.nix"
    fi
fi
echo ""

# Check home.nix files
info "Checking home-manager configurations..."
for home_file in home.nix home/home.nix; do
    if [[ -f "$home_file" ]]; then
        ok "Found: $home_file"
        check_nix_syntax "$home_file"
    fi
done
echo ""

# Check modules
info "Checking system modules..."
for module in modules/system/*.nix; do
    if [[ -f "$module" ]]; then
        check_nix_syntax "$module"
    fi
done

for module in modules/desktop/*.nix; do
    if [[ -f "$module" ]]; then
        check_nix_syntax "$module"
    fi
done

for module in modules/packages/*.nix; do
    if [[ -f "$module" ]]; then
        check_nix_syntax "$module"
    fi
done
echo ""

# Check for required directories
info "Checking directory structure..."
for dir in modules home dotfiles; do
    if [[ -d "$dir" ]]; then
        ok "Directory exists: $dir"
    else
        error "Missing directory: $dir"
    fi
done
echo ""

# Check flake.lock
info "Checking flake.lock..."
if [[ -f "flake.lock" ]]; then
    ok "flake.lock exists"

    # Check if flake.lock is up to date
    if [[ "flake.nix" -nt "flake.lock" ]]; then
        warn "flake.nix is newer than flake.lock - consider running 'nix flake update'"
    else
        ok "flake.lock appears up to date"
    fi
else
    warn "flake.lock not found - run 'nix flake update' to generate it"
fi
echo ""

# Try nix flake check if available
info "Running 'nix flake check'..."
if command -v nix &> /dev/null; then
    if nix flake check --no-build 2>&1 | tee /tmp/flake-check.log; then
        ok "nix flake check passed (metadata only)"
    else
        error "nix flake check failed - see /tmp/flake-check.log for details"
        cat /tmp/flake-check.log
    fi
else
    warn "nix command not found - skipping flake check"
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                            Validation Summary                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Success:${NC} $SUCCESS"
echo -e "${YELLOW}⚠ Warnings:${NC} $WARNINGS"
echo -e "${RED}✗ Errors:${NC} $ERRORS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Configuration has errors that must be fixed!${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Configuration has warnings - review and fix if needed.${NC}"
    exit 0
else
    echo -e "${GREEN}Configuration looks good!${NC}"
    echo -e "${GREEN}You can now run:${NC}"
    echo -e "  ${BLUE}sudo nixos-rebuild switch --flake .#meowrch${NC}"
    exit 0
fi
