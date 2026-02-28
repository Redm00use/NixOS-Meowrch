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
        <a href="#-beginner-guide-installing-apps">
            <img src="https://img.shields.io/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="./docs/ALIASES.md">
            <img src="https://img.shields.io/badge/Wiki-Config_System-blue?style=for-the-badge&logo=bookstack&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!IMPORTANT]
> **Welcome to NixOS!** If you are coming from Windows, Ubuntu, or Arch — forget almost everything you know. In NixOS, your system is built from code. You don't "install" apps; you "declare" them in your configuration files.

## 📑 Table of Contents
- [✨ Features](#-features)
- [📁 Project Structure](#-project-structure)
- [🚀 Installation](#-installation)
- [🔧 Usage & Updates](#-usage--updates)
- [📦 Beginner Guide: Installing Apps](#-beginner-guide-installing-apps)
- [📖 Meowrch Wiki: Customization](#-meowrch-wiki-customization)
- [⌨️ Keybindings & Commands](#️-keybindings--commands)
- [🛠️ Help! I broke something!](#-help-i-broke-something)

## ✨ Features

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) with UWSM for stability |
| **Status Bar** | Mewline (Dynamic Island) — systemd service |
| **Launcher** | Rofi with custom theme/wallpaper menus |
| **Terminal** | Kitty (0.8 opacity) + Fish shell |
| **Shell** | Fish + Starship (minimalist prompt) |
| **Theming** | Catppuccin Mocha (GTK4 forced dark) |
| **GPU** | Intelligent AMD / Nvidia / Intel support |

## 📁 Project Structure

```text
NixOS-Meowrch/
├── hosts/meowrch/                         # Machine-specific settings
├── modules/                               # Nix modules (System & User)
├── config/                                # Raw app configs (Hypr, Kitty, Fish...)
├── assets/                                # Static files (SDDM, themes, wallpapers)
├── scripts/                               # Consolidated system scripts
├── pkgs/                                  # Custom package definitions
└── flake.nix                              # Main entry point
```

## 🚀 Installation

### 1. Preparation
Ensure you have NixOS installed. You will need **Git**:
```bash
nix-shell -p git
```

### 2. Installation
```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

---

## 🔧 Usage & Updates

We created "Super Aliases" to make your life easier:

| Alias | Description |
|-------|-------------|
| `u` (or `г`) | **Full Update**. Git pull + update hashes + flake update + rebuild. |
| `b` (or `и`) | **Apply Settings**. Run this after editing any config file. |
| `clean` | **Cleanup**. Removes old system versions and frees disk space. |
| `rollback` | **Rollback**. Return to the previous working state. |

---

## 📦 Beginner Guide: Installing Apps

In NixOS, you don't install packages via `apt install`. You declare them in lists.

### 1. Personal Apps (Browsers, Players, Games)
Open `hosts/meowrch/home.nix` (command `zed ~/NixOS-Meowrch/hosts/meowrch/home.nix`).
Find the `home.packages` section and add the app name:
```nix
home.packages = with pkgs; [
  telegram-desktop
  vlc
];
```

### 2. System Tools (Drivers, Utilities)
Open `modules/nixos/packages/packages.nix` and add packages to `environment.systemPackages`.

**How to find the package name?**
Search at **[search.nixos.org](https://search.nixos.org/packages)**. Use the "Attribute name".

**How to apply?**
Just type in the terminal: `b`

---

## 📖 Meowrch Wiki: Customization

Main Hyprland configuration files are located in `modules/home/hypr-configs/`:

*   `keybindings.conf` — **Hotkeys**. Want to change `Super+Q`? Look here.
*   `windowrules.conf` — **Window Rules**. Opacity, floating windows, etc.
*   `monitors.conf` — **Screens**. Resolution and refresh rate.
*   `autostart.conf` — **Startup**. Apps that launch on login.

---

## 🛠️ Help! I broke something!

In NixOS, it is **impossible** to permanently "kill" your system via software!

1.  **If it won't boot**: Reboot and select a previous "Generation" from the boot menu.
2.  **If it's buggy**: Run the command `rollback`. The system will revert to the state before the last build.

---

## ⌨️ Keybindings (Cheat Sheet)

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Q` | Close window |
| `Super + E` | File Manager (Nemo) |
| `Super + D` | App Launcher (Rofi) |
| `Super + W` | Select Wallpaper |
| `Super + Shift + T` | Select Theme |
| `Super + L` | Lock Screen |
| `Super + Shift + B` | Toggle Status Bar |

---
<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
