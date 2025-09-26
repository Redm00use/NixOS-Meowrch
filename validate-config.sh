#!/usr/bin/env bash

# Meowrch NixOS Configuration Validation Script
# This script helps validate your NixOS configuration before applying it

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    print_error "flake.nix not found. Please run this script from the NixOS configuration directory."
    exit 1
fi

print_status "🐱 Meowrch NixOS Configuration Validator"
echo

# Check if nix is available
if ! command -v nix &> /dev/null; then
    print_error "Nix is not installed or not in PATH"
    exit 1
fi

# Check flake syntax
print_status "Checking flake syntax..."
if nix flake show --json > /dev/null 2>&1; then
    print_success "Flake syntax is valid"
else
    print_error "Flake syntax error detected"
    exit 1
fi

# Check for common configuration issues
print_status "Checking for common configuration issues..."

# Check for systemd.user.startServices (invalid option)
if grep -r "systemd\.user\.startServices" . --include="*.nix" > /dev/null 2>&1; then
    print_error "Found invalid systemd.user.startServices option (this is home-manager specific)"
    echo "  This option should be removed from NixOS configuration files"
else
    print_success "No invalid systemd.user.startServices found"
fi

# Check for deprecated hardware.opengl option
if grep -r "hardware\.opengl" . --include="*.nix" > /dev/null 2>&1; then
    print_error "Found deprecated hardware.opengl option"
    echo "  Replace with hardware.graphics in NixOS 24.05+"
else
    print_success "No deprecated hardware.opengl option found"
fi

# Check for deprecated services.logind.enable
if grep -r "services\.logind\.enable" . --include="*.nix" > /dev/null 2>&1; then
    print_error "Found invalid services.logind.enable option"
    echo "  logind is always enabled in NixOS, this option doesn't exist"
else
    print_success "No invalid logind configuration found"
fi

# Check for string values that should be boolean
if grep -r 'dnssec = "true"' . --include="*.nix" > /dev/null 2>&1; then
    print_error "Found dnssec with string value, should be boolean"
    echo "  Change dnssec = \"true\" to dnssec = true"
else
    print_success "DNS configuration looks correct"
fi

# Check for old X11 configuration when using Wayland
if grep -r "services\.xserver\.enable = true" . --include="*.nix" > /dev/null 2>&1; then
    print_warning "Found X11 server enabled while using Wayland"
    echo "  Consider disabling X11 if using pure Wayland setup"
fi

# Check for proper file system configuration
if [[ -f "hardware-configuration.nix" ]]; then
    if grep -q "fileSystems\.\"/\"" hardware-configuration.nix; then
        print_success "Root file system configuration found"
    else
        print_error "Root file system not configured in hardware-configuration.nix"
        echo "  This will cause the boot to fail"
    fi
fi

# Check for duplicate module imports
print_status "Checking for duplicate module imports..."
if grep -A 20 "imports = \[" configuration.nix | grep -E "(audio|bluetooth|graphics|networking|security|services|fonts)\.nix" > /dev/null 2>&1; then
    print_warning "Potential duplicate module imports detected in configuration.nix"
    echo "  These modules are already imported in flake.nix"
else
    print_success "No duplicate module imports detected"
fi

# Check hardware-configuration.nix
if [[ -f "hardware-configuration.nix" ]]; then
    print_success "hardware-configuration.nix found"
else
    print_warning "hardware-configuration.nix not found"
    echo "  This file should be generated during NixOS installation"
    echo "  You can generate it with: nixos-generate-config"
fi

# Validate flake structure
print_status "Validating flake structure..."
if nix flake check 2>&1 | grep -q "error:"; then
    print_error "Flake check failed:"
    nix flake check
    exit 1
else
    print_success "Flake structure is valid"
fi

# Check for required inputs
print_status "Checking flake inputs..."
required_inputs=("nixpkgs" "home-manager" "hyprland")
for input in "${required_inputs[@]}"; do
    if grep -q "$input" flake.nix; then
        print_success "Input '$input' found"
    else
        print_error "Required input '$input' not found in flake.nix"
    fi
done

# Check system configuration
print_status "Checking system configuration..."
if grep -q 'system = "x86_64-linux"' flake.nix; then
    print_success "System architecture specified"
else
    print_warning "System architecture not clearly specified"
fi

# Check for NixOS 25.05 compatibility
if grep -q "25.05" flake.nix; then
    print_success "NixOS 25.05 version specified"
else
    print_warning "NixOS version not clearly specified"
fi

# Check for proper unstable overlay usage
if grep -q "overlay-unstable" flake.nix; then
    print_success "Unstable overlay configured"
else
    print_warning "Consider adding unstable overlay for latest packages"
fi

# Check for modern service configurations
print_status "Checking for modern NixOS 25.05 service options..."

# Check for zram-generator availability
if grep -r "zram-generator" . --include="*.nix" > /dev/null 2>&1; then
    print_success "Modern zram-generator configuration found"
fi

# Check for earlyoom availability
if grep -r "services\.earlyoom" . --include="*.nix" > /dev/null 2>&1; then
    print_success "EarlyOOM configuration found"
fi

# Check for proper graphics configuration
if grep -r "hardware\.graphics" . --include="*.nix" > /dev/null 2>&1; then
    print_success "Modern graphics configuration (hardware.graphics) found"
fi

# Check for proper bootloader configuration
print_status "Checking bootloader configuration..."
if grep -r "boot\.loader\.systemd-boot\.enable = true" . --include="*.nix" > /dev/null 2>&1; then
    print_success "systemd-boot bootloader configured"

    # Check for EFI variables access
    if grep -r "boot\.loader\.efi\.canTouchEfiVariables = true" . --include="*.nix" > /dev/null 2>&1; then
        print_success "EFI variables access enabled"
    else
        print_warning "EFI variables access not configured"
        echo "  Consider enabling boot.loader.efi.canTouchEfiVariables"
    fi
else
    print_warning "systemd-boot not found"
    echo "  This configuration is designed for systemd-boot"

    # Check if GRUB is accidentally enabled
    if grep -r "boot\.loader\.grub\.enable = true" . --include="*.nix" > /dev/null 2>&1; then
        print_error "GRUB bootloader detected - conflicts with systemd-boot"
        echo "  Disable GRUB or switch to systemd-boot for this configuration"
    fi
fi

# Final validation attempt
print_status "Performing final validation..."
if nix build .#nixosConfigurations.meowrch.config.system.build.toplevel --dry-run > /dev/null 2>&1; then
    print_success "Configuration builds successfully (dry-run)"
else
    print_error "Configuration failed to build"
    echo "  Run the following command for detailed error information:"
    echo "  nix build .#nixosConfigurations.meowrch.config.system.build.toplevel --dry-run"
    exit 1
fi

echo
print_success "🎉 Configuration validation completed successfully!"
echo
print_status "⚠️  IMPORTANT: Before applying this configuration:"
print_status "1. Generate proper hardware configuration:"
print_status "   sudo nixos-generate-config --root /mnt --dir ."
print_status "2. Edit hardware-configuration.nix to match your actual disk setup"
print_status "3. Replace UUID placeholders with your actual partition UUIDs"
echo
print_status "To apply this configuration:"
print_status "  sudo nixos-rebuild switch --flake .#meowrch"
echo
print_status "To update inputs:"
print_status "  nix flake update"
echo
print_status "To check what will be built:"
print_status "  nixos-rebuild dry-build --flake .#meowrch"
echo
print_status "To find your disk UUIDs:"
print_status "  lsblk -f"
print_status "  blkid"
