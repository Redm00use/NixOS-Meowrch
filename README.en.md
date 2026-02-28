<div align="center">
    <img src=".meta/logo.png" width="300px">
    <h1>🐱 Meowrch NixOS</h1>
    <p><i>Beautiful, declarative, and reproducible NixOS configuration based on <a href="https://github.com/meowrch/meowrch">Meowrch</a></i></p>
    <p>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/stargazers">
            <img src="https://img.shields.io/github/stars/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=star&color=cba6f7&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/network/members">
            <img src="https://img.shields.io/github/forks/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=git&color=f38ba8&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-25.11-blue?style=for-the-badge&logo=nixos&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://t.me/meowrch">
            <img src="https://img.shields.io/badge/Telegram-Meowrch-blue?style=for-the-badge&logo=telegram&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
    <p>
        <a href="#-installation">
            <img src="https://img.shields.io/badge/Install-Meowrch_NixOS-success?style=for-the-badge&logo=nixos&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-package-management-guide">
            <img src="https://img.shields.io/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-meowrch-wiki">
            <img src="https://img.shields.io/badge/Wiki-Config_System-blue?style=for-the-badge&logo=bookstack&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!NOTE]
> A port of the original **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) to **NixOS**.
> Full compatibility with the Nix ecosystem, declarativity, reproducibility, and stability.

## 📑 Table of Contents
- [✨ Features](#-features)
- [📁 Project Structure](#-project-structure)
- [🚀 Installation](#-installation)
- [🔧 Daily Usage & Updates](#-daily-usage)
- [📦 Package Management](#-package-management-guide)
- [📖 Meowrch Wiki](#-meowrch-wiki)
- [⌨️ Hotkeys & Commands](#️-hotkeys--commands)
- [🎨 Theming](#-theming)

## ✨ Features

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) with animations and blur |
| **Status Bar** | Mewline (Dynamic Island) |
| **Launcher** | Rofi with custom menus |
| **Terminal** | Kitty with Catppuccin Mocha |
| **Shell** | Fish + Starship prompt |
| **Notifications** | SwayNC / Dunst |
| **Lock Screen** | Swaylock / Hyprlock |
| **Theme** | Catppuccin Mocha (GTK + Qt + terminal) |
| **Icons** | Papirus Dark |
| **Cursor** | Bibata Modern Classic |
| **GPU** | AMD / Nvidia / Intel (auto-detection) |
| **Audio** | PipeWire |
| **Gaming** | Steam + Gamemode + MangoHud |

## 📁 Project Structure

```text
NixOS-Meowrch/
├── flake.nix                       # Main entry point (Flake)
├── flake.lock                      # Fixed dependency versions
├── hosts/                          # Machine-specific configurations
│   └── meowrch/                    # Host 'meowrch'
│       ├── configuration.nix       # System settings
│       ├── hardware-configuration.nix # Hardware scan result
│       └── home.nix                # User settings (Home Manager)
├── modules/                        # Modular Nix logic
│   ├── nixos/                      # NixOS system modules
│   │   ├── desktop/                # Environment (Hyprland, SDDM, Theming)
│   │   ├── system/                 # Core (Audio, Fonts, Security, Networking)
│   │   └── packages/               # Global packages & Flatpak
│   └── home/                       # Home Manager modules
│       ├── fish.nix                # Shell config
│       ├── starship.nix            # Prompt config
│       ├── kitty.nix               # Terminal settings
│       └── ...                     # Rofi, GTK, Waybar
├── config/                         # Raw application configurations (symlinks)
│   ├── hypr/                       # Hyprland settings
│   ├── kitty/                      # Kitty settings
│   ├── fish/                       # Fish settings
│   ├── fastfetch/                  # Fastfetch settings
│   ├── btop/                       # Btop settings
│   ├── meowrch/                    # Meowrch Python tool configs
│   └── dconf/                      # GSettings dumps
├── assets/                         # Static system resources
│   ├── sddm/                       # Login screen theme (Qt6)
│   ├── themes/                     # UI Themes (Catppuccin)
│   └── misc/                       # Misc (.face.icon, logos)
├── scripts/                        # Consolidated system scripts
│   ├── rofi-menus/                 # Rofi scripts (Power, VPN, Wallpaper)
│   ├── color-scripts/              # ASCII art collection
│   ├── system-update.sh            # System update script
│   └── ...                         # Utilities (volume, backlight)
├── pkgs/                           # Custom package definitions (Derivations)
│   ├── mewline/                    # Mewline Status Bar
│   ├── pawlette/                   # Theme switcher
│   ├── hotkeyhub/                  # Hotkey utility
│   └── ...                         # Fabric, libcvc, libgray
├── packages/                       # Nix derivations for local folders
├── overlays/                       # System patches (GBM fix, etc.)
├── docs/                           # Documentation and log archives
└── install.sh                      # System installer
```

## 🚀 Installation

### 1. Preparation (Important!)
Before you begin, ensure you have NixOS installed (any version works: Minimal ISO, GNOME, or KDE).

You will need **Git** to clone this repository. If you don't have it yet, run:
```bash
# Temporarily install git
nix-shell -p git
```

> [!CAUTION]
> **IMPORTANT:** Do NOT delete or move the repository folder (`~/NixOS-Meowrch`) after installation! 
> In a Flake-based NixOS setup, this folder is the source code of your system. Without it, you won't be able to update or change settings.

### 2. Installation

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## 🔧 Daily Usage

### How to update the system?

Thanks to Flakes, you can get updates for our Meowrch port directly from GitHub:

```bash
# 1. Enter the folder and pull the latest code changes
cd ~/NixOS-Meowrch && git pull

# 2. Update package hashes and rebuild the system with one command
update-pkgs
```

### Main Commands (Aliases)
*   `rebuild` — Rebuild the system after config changes.
*   `update-pkgs` — Complete update of all Meowrch components.
*   `cleanup` — Remove old system generations (frees disk space).
*   `rollback` — Revert to the previous working version if something breaks.

## ⌨️ Hotkeys & Commands

### Hyprland Keybindings

| Key | Action |
|-----|--------|
| **General** | |
| `Super + Return` | Terminal (Kitty) |
| `Super + Q` | Close window |
| `Super + K` | Kill window process |
| `Super + Space` | Toggle floating mode |
| `Alt + Return` | Fullscreen mode |
| `Super + Delete` | Exit Hyprland |
| `Ctrl + Shift + R` | Reload Hyprland config |
| **Navigation** | |
| `Super + Arrows` | Focus window (← ↓ ↑ →) |
| `Super + 1-0` | Switch to Workspace 1-10 |
| `Super + Shift + 1-0` | Move window to Workspace 1-10 |
| `Super + Shift + Arrows` | Resize active window |
| `Super + Ctrl + Left/Right` | Previous/Next workspace |
| **Apps & Menus** | |
| `Super + D` | App Launcher (Rofi) |
| `Super + E` | File Manager (Nemo) |
| `Super + V` | Clipboard Manager |
| `Super + W` | Select Wallpaper (Rofi) |
| `Super + T` | Select Theme (Pawlette) |
| `Super + X` | Power Menu |
| `Super + code:60` (.) | Emoji menu |
| `Super + /` | Hotkeys Cheat Sheet |
| `Super + Shift + H` | Hotkeys Cheat Sheet |
| **System & Utils** | |
| `Super + L` | Lock Screen |
| `Super + C` | Color Picker (Eye dropper) |
| `Super + Shift + B` | Toggle Status Bar (Mewline) |
| `Super + N` | Notification Center (SwayNC) |
| `Print` | Area Screenshot |
| `Super + Alt + Shift + 3` | Fullscreen Screenshot |
| `Super + Alt + Shift + 4` | Area Screenshot |
| **Mewline (Dynamic Island)** | |
| `Super + Alt + P` | Open Power Menu |
| `Super + Alt + D` | Open Date/Notifications |
| `Super + Alt + B` | Open Bluetooth |
| `Super + Alt + A` | Open App Launcher |
| `Super + Alt + W` | Open Wallpapers |
| `Super + Alt + code:60` | Open Emoji |

## 📦 Package Management Guide

In NixOS, packages are not installed via `apt install` or `pacman -S`. Instead, they are **declared** in the configuration files.

### 1. Where to find packages?
Use the official search engine: **[search.nixos.org](https://search.nixos.org/packages)**.
*   Select the **25.11** channel.
*   Copy the package name (e.g., `telegram-desktop`).

### 2. Where to add them?
Use the pre-installed **Zed IDE** to edit your configuration (run `zed` in terminal).

There are two main places in this configuration:

*   **User Applications** (Recommended):
    File: `home/home.nix` → `home.packages` section.
*   **System Utilities**:
    File: `modules/packages/packages.nix` → `environment.systemPackages` section.

### 3. How to apply?
After adding the package name to the list, save the file and run:
```bash
rebuild
```

## 📖 Meowrch Wiki

Welcome to the knowledge base for configuring your system!

### 1. Configuration File Locations
`home/modules/hypr-configs/`

*   `keybindings.conf` — Manage keyboard shortcuts.
*   `windowrules.conf` — Define window behaviors.
*   `monitors.conf` — Display layouts.
*   `autostart.conf` — Auto-launch apps.

### 2. How to add a Custom Keybinding
Open `home/modules/hypr-configs/keybindings.conf` in **Zed IDE**.
Syntax: `bind = MODIFIER, KEY, ACTION, COMMAND`

### 3. How to set Window Rules
Edit `home/modules/hypr-configs/windowrules.conf`.
Example: `windowrule = float, ^(telegram-desktop)$`

### 4. Applying Changes
```bash
rebuild
```

### Terminal Aliases (Fish)

| Alias | Command | Description |
|-------|---------|-------------|
| `rebuild` | `sudo nixos-rebuild switch...` | Rebuild system from flake |
| `update-pkgs` | `./scripts/update-pkg-hashes.sh && ...` | Update all package hashes & rebuild |
| `update` | `nix flake update & rebuild` | Update flake.lock & rebuild |
| `cleanup` | `sudo nix-collect-garbage -d` | Remove old generations and garbage |
| `optimize` | `sudo nix-store --optimise` | Optimize Nix store (save space) |
| `generations` | `sudo nix-env --list-generations` | List all system versions |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Rollback to previous state |
| `cls` | `clear` | Clear screen |
| `ll` | `ls -la` | Detailed file list |
| `validate` | `./validate-config.sh` | Check configuration syntax |

## 🎨 Theming

The entire system uses **Catppuccin Mocha** with **Blue** accent.

## 👤 Credits

- **Original Project:** [Meowrch (Arch Linux)](https://github.com/meowrch/meowrch)
- **NixOS Port & Maintainer:** [@Redm00use](https://t.me/Redm00use)
- **Telegram Channel:** [@meowrch](https://t.me/meowrch)

<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
