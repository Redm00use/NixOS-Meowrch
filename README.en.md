<div align="center">
    <img src=".meta/logo.png" width="300px">
    <h1>Meowrch NixOS</h1>
    <p>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/stargazers">
            <img src="https://img.shields.io/github/stars/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=star&color=cba6f7&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/network/members">
            <img src="https://img.shields.io/github/forks/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=git&color=f38ba8&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://t.me/meowrch">
            <img src="https://img.shields.io/badge/Telegram-Meowrch-blue?style=for-the-badge&logo=telegram&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!NOTE]
> This is a **port of the original [Meowrch](https://github.com/meowrch/meowrch) (Arch Linux)** to **NixOS**.
> Full Nix ecosystem compatibility, reproducibility, and stability.

## 🚀 About

**Meowrch NixOS** is a beautiful, minimalist, and optimized configuration for NixOS 25.11. We have brought the aesthetics and user experience of the original Meowrch to the powerful declarative foundation of NixOS.

### ✨ Features
- **Base:** NixOS 25.11 (Stable) + Flakes + Home Manager.
- **Interface:** Hyprland with animations and blur.
- **Theme:** Catppuccin Mocha (unified style for all apps).
- **Performance:** Optimized for AMD GPU (RADV).
- **Convenience:** Automated installer, Rofi app menu, Dunst notifications.
- **Unique:** Includes custom scripts and tools from the original Meowrch.

## ⌨️ Hotkeys & Commands

### Hyprland Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Open Terminal (Kitty) |
| `Super + A` | Application Launcher (Rofi) |
| `Super + E` | File Manager (Nemo) |
| `Super + Q` | Close active window |
| `Super + K` | Kill window process |
| `Super + Space` | Toggle floating mode |
| `Alt + Return` | Fullscreen mode |
| `Super + 1-0` | Switch Workspace |
| `Super + Shift + 1-0` | Move window to Workspace |
| `Super + Arrows` | Focus window (left/right/up/down) |
| `Super + L` | Lock Screen |
| `Super + X` | Power Menu |
| `Super + W` | Select Wallpaper |
| `Super + T` | Select Theme (Pawlette) |
| `Super + V` | Clipboard Manager |
| `Super + C` | Color Picker (Eye dropper) |
| `Super + Shift + B` | Toggle Status Bar (Mewline) |
| `Super + /` | Hotkeys Cheat Sheet (HotkeyHub) |
| `Super + Shift + H` | Hotkeys Cheat Sheet (HotkeyHub) |
| `Super + N` | Notification Center (SwayNC) |
| `Super + Alt + S` | Move window to hidden workspace |
| `Super + S` | Show hidden workspace |
| `Print` | Area Screenshot |
| `Super + Print` | Fullscreen Screenshot |
| `XF86Audio*` | Volume Controls |
| `XF86MonBrightness*` | Brightness Controls |

### Terminal Aliases (Fish)

| Alias | Command | Description |
|-------|---------|-------------|
| `rebuild` | `sudo nixos-rebuild switch...` | Rebuild system from flake |
| `update-pkgs` | `./scripts/update-pkg-hashes.sh && ...` | Update all package hashes and rebuild |
| `update` | `nix flake update && rebuild` | Update flake.lock and rebuild system |
| `cleanup` | `sudo nix-collect-garbage -d` | Remove old generations and garbage |
| `optimize` | `sudo nix-store --optimise` | Optimize Nix store (save disk space) |
| `generations` | `sudo nix-env --list-generations` | List all system versions (generations) |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Revert to previous working state |
| `cls` | `clear` | Clear terminal screen |
| `ll` | `ls -la` | Detailed file list |
| `validate` | `./validate-config.sh` | Check configuration syntax |

## 🛠 Installation

Simple and automated installation process:

```bash
# 1. Clone the repository
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch

# 2. Run the installer
chmod +x install.sh
./install.sh
```

**The installer will automatically:**
- Detect your hardware.
- Ask for your desired hostname and username.
- Configure the system and build the configuration.

## 👤 Credits and Support

This project is a port of the original work by the Meowrch team.

- **Original Project:** [Meowrch (Arch Linux)](https://github.com/meowrch/meowrch)
- **NixOS Port & Maintainer:** [@Redm00us](https://t.me/Redm00us)
- **Telegram Channel:** [@meowrch](https://t.me/meowrch)

<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
</div>
