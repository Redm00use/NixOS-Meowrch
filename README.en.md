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
- [⌨️ Keybindings (Cheat Sheet)](#️-keybindings-cheat-sheet)
- [🛠️ Help! I broke something!](#-help-i-broke-something)

---

## ✨ Features
*   **Hyprland + UWSM**: Modern Wayland environment with maximum smoothness and session stability.
*   **Mewline**: Unique status bar in the style of Dynamic Island.
*   **Declarative**: Your system is always the same, reproducible on any hardware.
*   **Safety**: Roll back to previous versions directly from the boot menu.

## 📁 Project Structure
*   `hosts/meowrch/` — **The heart of your system**. Main files: `configuration.nix` (system) and `home.nix` (user).
*   `modules/` — Advanced settings (drivers, themes, services).
*   `config/` — App configurations (the files you usually look for in `~/.config`).
*   `scripts/` — A set of useful scripts for system management.

---

## 🔧 Usage & Updates

We created "Super Aliases" so you don't have to memorize complex commands:

| Alias | Description |
|-------|-------------|
| `u`     | **Full Update**. Pulls the latest code from GitHub and rebuilds the system. |
| `b`     | **Apply Settings**. Run this every time you change something in your config files. |
| `clean` | **Cleanup**. Removes old system versions and frees up disk space. |

---

## 📦 Beginner Guide: Installing Apps

In NixOS, you add packages to lists. There are two main ones:

### 1. Personal Apps (Browsers, Players, Games)
Open the file `hosts/meowrch/home.nix` in your editor (command: `zed ~/NixOS-Meowrch/hosts/meowrch/home.nix`).
Look for the `home.packages` section and add the app name:
```nix
home.packages = with pkgs; [
  telegram-desktop
  vlc
  discord
];
```

### 2. System Tools (Drivers, Low-level utilities)
Open `modules/nixos/packages/packages.nix`. Add packages to `environment.systemPackages`.

**How to find the package name?**
Visit **[search.nixos.org](https://search.nixos.org/packages)** and type the name. Use the "Attribute name" (e.g., `firefox`, not `Firefox Browser`).

**How to apply?**
After saving the file, just type in the terminal:
`b`

---

## 📖 Meowrch Wiki: Customization

Meowrch is very flexible. Here is where to change the appearance:

### 1. Keybindings (Hotkeys)
File: `modules/home/hypr-configs/keybindings.conf`
Want to change `Super+D` to something else? Go here.

### 2. Autostart
File: `modules/home/hypr-configs/autostart.conf`
Add a line like `exec-once = app_name`.

### 3. Wallpapers & Themes
Use the built-in menus:
*   `Super + W` — Change Wallpaper.
*   `Super + Shift + T` — Change Color Theme.

---

## 🛠️ Help! I broke something!

This is NixOS; it is **impossible** to permanently "kill" your system via software!

1.  **If the system won't boot**: Reboot. In the boot menu (GRUB/Systemd-boot), select a previous entry (Generation). You will boot into the version that worked before your changes.
2.  **If you are in the system but it's buggy**: Run the command `rollback` (or `sudo nixos-rebuild switch --rollback`).

---

## ⌨️ Keybindings Cheat Sheet

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal |
| `Super + Q` | Close window |
| `Super + E` | File Manager (Nemo) |
| `Super + D` | App Launcher |
| `Super + Z` | Browser |
| `Super + Shift + B` | Toggle Status Bar |
| `Super + L` | Lock Screen |

---
<div align="center">
    <p><i>Made with ❤️ for those who are not afraid of something new. Welcome to the Meowrch family!</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
