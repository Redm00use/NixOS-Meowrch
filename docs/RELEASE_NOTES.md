# NixOS-Meowrch Release History

## 🐱 V3.4.1 (Portability & Modernization) - 2026-03-01

This release focuses on system-wide path audits, total portability for any username, and a major modernization of the display manager.

### 🚀 Highlights
- **SDDM Qt6 Rewrite**: The Meowrch SDDM theme has been completely rewritten for Qt6, ensuring compatibility with the latest NixOS 25.11+ standards. Added Antigravity dependency and fixed MediaPlayer API.
- **Total Portability**: Hardcoded `/home/kotlin` paths have been purged. The system now dynamically detects the username, making it truly "out-of-the-box" for any machine.
- **Mewline Evolution**: Enhanced power-profiles-daemon integration, added laptop brightness detection, and improved window rule stability.
- **Path Audit**: Comprehensive audit of all 50+ system scripts. Fixed broken shebangs, absolute symlinks, and validator logic.
- **Simplified CLI**: Added `u` (and `г`) alias for a one-command full system update cycle (flake update + rebuild).
- **Theming Fixes**: Major patch for `pawlette` to fix Nemo dynamic theming and symlink logic in the Nix Store.

### 🛠 Technical Changes
- Updated **SDDM** to use `sddm-astronaut` pattern with `propagatedBuildInputs`.
- Switched installer from `switch` to `boot` to prevent D-Bus activation errors during live sessions.
- Removed **Waybar** and all redundant legacy components to reduce closure size.
- Restored original **Kitty** and **Fish** minimalist aesthetics.

## 🐱 V3.4.0 (The Stability Update) - 2026-02-25

This release focuses on stability, correct system integration, and user convenience.

### 🚀 Highlights
- **Universal Wayland Session Manager (UWSM)**: Full integration for faster and more stable sessions.
- **Mewline Anti-Crash System**: Mewline is now a managed systemd service. If it ever crashes, systemd detects it and restarts the bar automatically within seconds.
- **Simplified Maintenance**: New `update-pkgs` command to sync all custom Meowrch components in one click.
- **Visual Polish**: Fixed broken emojis and icons across the entire system (Fastfetch, Powermenu, Brightness, Network Manager) to match modern Nerd Font 3.0+ standards.
- **Dark Mode Enforcement**: GTK4/Libadwaita apps (like GNOME Settings and HotkeyHub) now strictly respect dark theme.
- **Clean Configuration**: Removed experimental/unused browsers and components to slim down the build.

### 🛠 Technical Changes
- Updated `mewline` to **v1.4.1**.
- Updated `meowrch-tools` to **v3.1.1** (flattened bin structure).
- Updated `meowrch-settings` to **v3.1.3** (NixOS-specific udev patches).
- Restored original **Rofi** layout and styling.
- Comprehensive **README** overhaul with beginner-friendly guides and accurate keybindings.

---

# Meowrch v3.0 (NixOS Edition) - Legacy Notes

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
