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

```
NixOS-Meowrch/
├── flake.nix                              # Entry point (flake)
├── configuration.nix                      # System configuration
├── home/                                  # Home Manager settings
├── pkgs/                                  # Custom packages (Mewline, HotkeyHub...)
├── dotfiles/                              # App configurations
└── scripts/                               # Maintenance scripts
```

## 🚀 Installation

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

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

### Terminal Aliases (Fish)

| Alias | Command | Description |
|-------|---------|-------------|
| `rebuild` | `sudo nixos-rebuild switch...` | Rebuild system from flake |
| `update-pkgs` | `./scripts/update-pkg-hashes.sh && ...` | Update all package hashes & rebuild |
| `update` | `nix flake update && rebuild` | Update flake.lock & rebuild |
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
