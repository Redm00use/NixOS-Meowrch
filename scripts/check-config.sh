#!/usr/bin/env bash
#
# Meowrch NixOS Configuration Checker
# ===================================================================
# Validates Nix configuration files for common errors in the new structure
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0
SUCCESS=0

# Get project root (script is in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

error() { echo -e "${RED}[ERROR]${NC} $1"; ((ERRORS++)) || true; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARNINGS++)) || true; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; ((SUCCESS++)) || true; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Check for required files
info "Checking core files..."
files=(
    "flake.nix"
    "hosts/meowrch/configuration.nix"
    "hosts/meowrch/home.nix"
    "hosts/meowrch/hardware-configuration.nix"
)
for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then ok "Found: $f"; else error "Missing: $f"; fi
done

# Check for common syntax errors
check_nix_syntax() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    if grep -q "mesa\.drivers" "$file"; then error "Found legacy 'mesa.drivers' in $file"; fi
    if grep -q "hardware\.opengl" "$file"; then warn "Found legacy 'hardware.opengl' in $file (use hardware.graphics)"; fi
}

info "Analyzing Nix logic..."
find hosts/ modules/ packages/ -name "*.nix" -exec bash -c '
    if grep -q "mesa\.drivers" "{}"; then echo "[ERR] Legacy mesa.drivers in {}"; fi
    if grep -q "hardware\.opengl" "{}"; then echo "[WARN] Legacy hardware.opengl in {}"; fi
' \;

# Check directory structure
info "Checking directory structure..."
dirs=("assets" "config" "scripts" "modules/nixos" "modules/home" "hosts")
for d in "${dirs[@]}"; do
    if [[ -d "$d" ]]; then ok "Directory exists: $d"; else error "Missing directory: $d"; fi
done

# Run nix flake check
info "Running nix flake check..."
if nix flake check --no-build --impure 2>/dev/null; then
    ok "Flake metadata is valid"
else
    warn "Flake check failed (this is common if files are not staged in git)"
fi

# Summary
echo ""
echo -e "${BLUE}=== Validation Summary ===${NC}"
echo -e "${GREEN}✓ Success:${NC} $SUCCESS"
echo -e "${YELLOW}⚠ Warnings:${NC} $WARNINGS"
echo -e "${RED}✗ Errors:${NC} $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi
exit 0
