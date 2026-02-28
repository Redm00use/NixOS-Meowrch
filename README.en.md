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
</div>

> [!NOTE]
> A port of the original **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) to **NixOS**.
> Full compatibility with the Nix ecosystem, declarativity, reproducibility, and stability.

## 📑 Table of Contents
- [✨ Features](#-features)
- [📁 Project Structure](#-project-structure)
- [🚀 Installation](#-installation)
- [🔧 Usage & Updates](#-usage--updates)
- [📦 Package Management](#-package-management)
- [📖 Meowrch Wiki (Configuration)](#-meowrch-wiki-configuration)
- [⌨️ Keybindings & Commands](#️-keybindings--commands)

## ✨ Features

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) with UWSM for superior stability |
| **Status Bar** | Mewline (Dynamic Island) — runs as a systemd service |
| **Launcher** | Rofi with custom theme and wallpaper selectors |
| **Session Manager** | UWSM (Universal Wayland Session Manager) |
| **Display Manager** | SDDM with **Qt6** Meowrch theme |
| **Terminal** | Kitty (0.8 opacity) + Fish shell |
| **Shell** | Fish + Starship (minimalist prompt) |
| **Memory** | ZRAM enabled by default |
| **Theming** | Catppuccin Mocha (GTK4/Libadwaita forced dark) |
| **GPU** | Intelligent AMD / Nvidia / Intel support |

## 📁 Project Structure

```text
NixOS-Meowrch/
├── flake.nix                       # Main entry point (Flake)
├── hosts/                          # Machine-specific configurations
│   └── meowrch/                    # Host 'meowrch' (System + Home Manager)
├── modules/                        # Modular Nix logic
│   ├── nixos/                      # NixOS system modules (drivers, services)
│   └── home/                       # Home Manager modules (apps, configs)
├── config/                         # Raw application configurations (symlinks)
│   ├── hypr/                       # Hyprland settings
│   ├── kitty/                      # Kitty settings
│   └── ...                         # Fish, Fastfetch, Btop
├── assets/                         # Static resources (SDDM, themes, wallpapers)
├── scripts/                        # Consolidated system scripts
└── pkgs/                           # Custom package definitions
```

## 🚀 Installation

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## 🔧 Usage & Updates

Convenient aliases are available for system management:

| Alias | Desc | Description |
|-------|------|-------------|
| `u`     | Update | **Full Update**: git pull + update hashes + flake update + rebuild |
| `b`     | Build  | **Fast Rebuild**: apply current configuration changes |
| `clean` | Cleanup| **Cleanup**: remove old generations and collect garbage |
| `rollback`| Rollback| **Rollback**: return to the previous successful state |

## 📦 Package Management

In NixOS, packages are not installed via `apt` or `pacman`. They are declared in configuration files.

1.  **User Applications** (Firefox, Telegram, etc.):
    File: `hosts/meowrch/home.nix` → `home.packages` section.
2.  **System Utilities & Drivers**:
    File: `modules/nixos/packages/packages.nix` → `environment.systemPackages` section.

After editing, run `b` to apply changes.

## 📖 Meowrch Wiki (Configuration)

Main Hyprland configuration files are now located here:
`modules/home/hypr-configs/`

*   `keybindings.conf` — edit hotkeys.
*   `windowrules.conf` — window rules (floating, opacity).
*   `monitors.conf` — monitor and resolution settings.
*   `autostart.conf` — startup applications.

## ⌨️ Keybindings & Commands

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Kitty + Fish) |
| `Super + Q` | Close window |
| `Super + E` | File Manager (Nemo) |
| `Super + D` | App Launcher (Rofi) |
| `Super + Z` | Browser (Firefox) |
| `Super + T` | Telegram (Materialgram) |
| `Super + W` | Wallpaper Selector |
| `Super + Shift + T` | Theme Selector (Pawlette) |
| `Super + X` | Power Menu (Powermenu) |
| `Super + L` | Lock Screen |
| `Super + Shift + B` | Toggle Status Bar (Mewline) |
| `Super + C` | Color Picker |
| `Super + Shift + H` | Hotkeys Cheat Sheet |
| `Ctrl + Shift + R` | Reload Hyprland |
| `Super + Delete` | Logout |

---
<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
