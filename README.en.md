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

## 📁 Project Structure

```text
NixOS-Meowrch/
├── flake.nix                       # Main entry point (Flake)
├── hosts/                          # Machine-specific configurations
│   └── meowrch/                    # Host 'meowrch' (NixOS + Home Manager)
├── modules/                        # Modular Nix logic
│   ├── nixos/                      # NixOS system modules
│   └── home/                       # Home Manager modules (Fish, Hyprland, etc.)
├── config/                         # Raw application configurations (symlinks)
├── assets/                         # Static resources (SDDM, themes, wallpapers)
├── scripts/                        # Consolidated system scripts
├── pkgs/                           # Custom package definitions
└── install.sh                      # System installer
```

## 🔧 Usage (Aliases)

Convenient short commands are available (aliases):

| Command | Desc | Description |
|---------|------|-------------|
| `u`     | Update | **Full Update**: git pull + update pkgs + flake update + rebuild |
| `b`     | Build  | **Fast Rebuild**: apply current config changes |
| `clean` | Cleanup| **Cleanup**: remove old generations and collect garbage |
| `search`| Search | **Search**: find a package in nixpkgs |
| `rollback`| Rollback| **Rollback**: return to previous successful state |

## ⌨️ Hyprland Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Q` | Close window |
| `Super + D` | App Launcher (Rofi) |
| `Super + E` | File Manager (Nemo) |
| `Super + V` | Clipboard Manager |
| `Super + W` | Wallpaper Selector (Rofi) |
| `Super + T` | Theme Selector (Pawlette) |
| `Super + X` | Power Menu |
| `Super + L` | Lock Screen |
| `Super + Shift + B` | Toggle Status Bar (Mewline) |

## 📦 Package Management

1.  Search for a package at **[search.nixos.org](https://search.nixos.org/packages)**.
2.  Add it to `hosts/meowrch/home.nix` (for apps) or `modules/nixos/packages/packages.nix` (for system tools).
3.  Run `b` to rebuild the system.

## 📖 Configuration (Wiki)

Main Hyprland settings are located in `modules/home/hypr-configs/`:
*   `keybindings.conf` — hotkeys.
*   `windowrules.conf` — window rules.
*   `monitors.conf` — monitor settings.

---
<div align="center">
    <p><i>Made with ❤️ for the NixOS and Meowrch community</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
