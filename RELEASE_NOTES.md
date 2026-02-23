# Meowrch v3.0 (NixOS Edition) - Release Notes

This release brings the visual and functional overhaul of **Meowrch v3.0** (originally Arch-based) to NixOS.

## 🚀 Key Features

### 1. Dynamic Status Bar (Mewline)
- Ported **Mewline** (Dynamic Island style bar) to NixOS.
- Implemented as a custom package in `pkgs/mewline`.
- Replaces legacy Waybar configs for a cleaner, animated experience.

### 2. Theming System (Pawlette)
- Ported **Pawlette** functionality.
- **NixOS Adaptation**: Unlike the Arch version which uses git branching for themes, this version uses a smart wrapper script that updates your Nix configuration and rebuilds the system.
- Usage: `pawlette select <theme_name>` (e.g., `catppuccin-mocha`).

### 3. Modular Hyprland Configuration
- Complete refactor of Hyprland configs to match v3.0 structure.
- Configuration is now split into granular files:
  - `monitors.conf`
  - `input.conf`
  - `keybindings.conf`
  - `windowrules.conf`
  - `appearance.conf`
- These are installed via `xdg.configFile` and sourced automatically.

### 4. Gaming & Utility Tools
- Added **HotKeyHub**: Interactive cheatsheet for keybindings (`pkgs/hotkeyhub`).
- Added **Meowrch Tools**: Includes `meowrch-game-run` for optimized gaming execution.
- Added **System Optimizations**: `meowrch-settings` package applies CachyOS-like kernel parameters and udev rules.

## 🛠️ Build & Automation (Important)

Since we are porting external Arch packages (AUR) which don't have official Nix flakes, we implemented a **Self-Updating Build System**:

- **Automated Hashing**: `install.sh` now automatically runs `scripts/update-pkg-hashes.sh` before installation.
- **How it works**:
    1. It fetches the latest source code from Meowrch GitHub repositories.
    2. Calculates the SHA256 hashes.
    3. Updates `pkgs/*/default.nix` automatically.
    4. Ensures the build never fails due to "hash mismatch".

## 🧹 Cleanup
- Removed all legacy **BSPWM** configurations.
- Default session is pure **Hyprland**.

## 📦 Installation
```bash
git checkout 3.0
./install.sh --user meowrch
```
