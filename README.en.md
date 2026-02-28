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

> [!NOTE]
> A port of the original **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) to **NixOS**.
> Full compatibility with the Nix ecosystem, declarativity, reproducibility, and stability.

## 📑 Table of Contents
- [✨ Features](#-features)
- [📁 Project Structure](#-project-structure)
- [🚀 Installation](#-installation)
- [🔧 Usage & Updates](#-usage--updates)
- [📦 Beginner Guide: Installing Apps](#-beginner-guide-installing-apps)
- [📖 Meowrch Wiki: Customization](#-meowrch-wiki-customization)
- [⌨️ Keybindings & Commands](#️-keybindings--commands)
- [🛠️ Help! I broke something!](#-help-i-broke-something)

---

## 🔧 Usage & Updates

| Alias | Desc | Description |
|-------|------|-------------|
| `u`     | `г`  | **Full Update**: git pull + update hashes + flake update + rebuild |
| `b`     | `и`  | **Fast Rebuild**: apply current config changes |
| `clean` | -    | **Cleanup**: remove old generations and collect garbage |
| `rollback`| -  | **Rollback**: return to previous successful state |

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
Search at **[search.nixos.org](https://search.nixos.org/packages)**. 

**How to apply?**
Just type in the terminal: `b`

---

## 📖 Meowrch Wiki: Customization

Learn how to tweak the look and feel of your Meowrch system.

### 🖼️ UI Management (Hyprland)
Main configuration files are located in `modules/home/hypr-configs/`.

*   **Keybindings**: Edit `keybindings.conf`. Change defaults or add your own shortcuts.
*   **Window Rules**: In `windowrules.conf`, you can force apps to open on specific workspaces or set their opacity.
*   **Animations**: The `appearance.conf` file contains `animations` settings. Make your system lightning fast or buttery smooth.
*   **Monitors**: Configure resolution, refresh rates, and position in `monitors.conf`.

### 🎨 Themes, Wallpapers & Fonts
*   **Wallpapers**: To add your own images to the wallpaper menu (`Super + W`), drop them into `assets/wallpapers/`.
*   **Theming**: The system uses **Catppuccin Mocha**. To tweak terminal or bar colors, look into `assets/themes/`.
*   **Fonts**: Change the primary system font in `modules/nixos/system/fonts.nix`.

### ⚙️ Scripts & Autostart
*   **Scripts**: All "system brains" (volume control, theme switchers) live in the `scripts/` folder. Use them in your custom keybindings.
*   **Autostart**: To launch an app automatically on login, add it to `modules/home/hypr-configs/autostart.conf`.

### 📝 Zed Editor (Your Main Tool)
**Zed IDE** comes pre-configured for the best experience:
*   Full Nix support (syntax highlighting, auto-formatting).
*   Built-in Git integration: see your changes in real-time.
*   Handy shortcuts like `Ctrl + /` for comments.

---

## 🛠️ Help! I broke something!

In NixOS, it is **impossible** to permanently "kill" your system via software!

1.  **If it won't boot**: Reboot and select a previous "Generation" from the boot menu.
2.  **If it's buggy**: Run the command `rollback` in your terminal.
3.  **Build Error (`b`)**: Read the error message carefully. Nix usually tells you exactly which file and line caused the issue.

---

## ⌨️ Keybindings (Cheat Sheet)

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal |
| `Super + Q` | Close window |
| `Super + E` | File Manager |
| `Super + D` | App Launcher |
| `Super + Z` | Browser |
| `Super + T` | Telegram |
| `Super + L` | Lock Screen |
| `Super + Shift + B` | Toggle Status Bar |

---
<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
