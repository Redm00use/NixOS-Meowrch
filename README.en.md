<div align="center">
    <img src=".meta/logo.png" width="300px">
    <h1>🐱 Meowrch NixOS</h1>
    <p><i>A beautiful, declarative, and reproducible NixOS configuration based on <a href="https://github.com/meowrch/meowrch">Meowrch</a></i></p>
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
        <a href="./docs/ALIASES.md">
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
- [🔧 Usage & Updates](#-usage--updates)
- [📦 Package Management Guide](#-package-management-guide)
- [📖 Meowrch Wiki](#-meowrch-wiki)
- [⌨️ Keybindings & Commands](#️-keybindings--commands)
- [🎨 Theming](#-theming)

## ✨ Features

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) with animations and blur |
| **Status Bar** | Mewline (Dynamic Island) |
| **Launcher** | Rofi with custom menus |
| **Terminal** | Kitty with Catppuccin Mocha |
| **Shell** | Fish + Starship prompt |
| **Notifications** | Mewline (Systemd service) |
| **Lock Screen** | Swaylock / Hyprlock |
| **Theme** | Catppuccin Mocha (GTK + Qt + terminal) |
| **Icons** | Papirus Dark / Adwaita |
| **Cursor** | Bibata Modern Classic |
| **GPU** | AMD / Nvidia / Intel (auto-detection) |
| **Audio** | PipeWire |
| **Gaming** | Steam + Gamemode + MangoHud |

## 📁 Project Structure

```text
NixOS-Meowrch/
├── hosts/meowrch/                         # Machine-specific configurations
├── modules/                               # Nix modules (NixOS & Home Manager)
├── config/                                # Raw application configurations (symlinks)
├── assets/                                # Static resources (SDDM, themes, wallpapers)
├── scripts/                               # Consolidated system scripts
├── pkgs/                                  # Custom package definitions
└── flake.nix                              # Flake entry point
```

## 🚀 Installation

### 1. Preparation (Important!)
Before you begin, ensure you have NixOS installed.

You will need **Git** to clone this repository:
```bash
nix-shell -p git
```

> [!CAUTION]
> **IMPORTANT:** Do NOT delete or move the repository folder (`~/NixOS-Meowrch`) after installation! 

### 2. Installation

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## 🔧 Usage & Updates

### Main Commands (Aliases)
Convenient short commands are available (aliases):

| Command | Desc | Description |
|---------|------|-------------|
| `u`     | Update | **Full Update**: git pull + update hashes + flake update + rebuild |
| `b`     | Build  | **Fast Rebuild**: apply current config changes |
| `clean` | Cleanup| **Cleanup**: remove old generations and collect garbage |
| `rollback`| Rollback| **Rollback**: return to previous successful state |

## ⌨️ Keybindings & Commands

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Q` | Close window |
| `Super + D` | App Launcher (Rofi) |
| `Super + E` | File Manager (Nemo) |
| `Super + V` | Clipboard Manager |
| `Super + W` | Wallpaper Selector |
| `Super + Shift + T` | Theme Selector (Pawlette) |
| `Super + X` | Power Menu |
| `Super + L` | Lock Screen |
| `Super + Shift + B` | Toggle Status Bar (Mewline) |

## 📦 Package Management Guide

In NixOS, packages are not installed via `apt`. They are declared in configuration files.

### 1. Where to find packages?
Use the official search: **[search.nixos.org](https://search.nixos.org/packages)**.

### 2. Where to add them?
Edit files using **Zed IDE** (command `zed`).

Main configuration files:
*   **User Applications** (Recommended):
    File: `hosts/meowrch/home.nix` → `home.packages` section.
*   **System Tools & Drivers**:
    File: `modules/nixos/packages/packages.nix` → `environment.systemPackages` section.

### 3. How to apply?
Run the command:
`b`

## 📖 Meowrch Wiki

Welcome to the knowledge base!

### 1. Configuration Files
Main Hyprland settings are now located at:
`modules/home/hypr-configs/`

*   `keybindings.conf` — hotkeys.
*   `windowrules.conf` — window rules.
*   `monitors.conf` — monitor settings.
*   `autostart.conf` — autostart apps.

### 2. Adding Hotkeys
Open `modules/home/hypr-configs/keybindings.conf` in Zed.
Syntax: `bind = MODIFIER, KEY, ACTION, COMMAND`

## 🎨 Theming

The entire system uses **Catppuccin Mocha** with a **Blue** accent.

---
<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
