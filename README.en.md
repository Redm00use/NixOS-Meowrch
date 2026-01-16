<div align="center">
	<img src=".meta/logo.png" width="300px">
	<h1> Meowrch NixOS ≽ܫ≼</h1>
	<a href="https://github.com/Redm00use/NixOS-Meowrch/issues">
		<img src="https://img.shields.io/github/issues/Redm00use/NixOS-Meowrch?color=ffb29b&labelColor=1C2325&style=for-the-badge">
	</a>
	<a href="https://github.com/Redm00use/NixOS-Meowrch/stargazers">
		<img src="https://img.shields.io/github/stars/Redm00use/NixOS-Meowrch?color=fab387&labelColor=1C2325&style=for-the-badge">
	</a>
	<a href="./LICENSE">
		<img src="https://img.shields.io/github/license/Redm00use/NixOS-Meowrch?color=FCA2AA&labelColor=1C2325&style=for-the-badge">
	</a>
	<br>
	<br>
	<a href="./README.md">
		<img src="https://img.shields.io/badge/README-RU-blue?color=cba6f7&labelColor=1C2325&style=for-the-badge">
	</a>
	<a href="./README.en.md">
		<img src="https://img.shields.io/badge/README-ENG-blue?color=C9CBFF&labelColor=C9CBFF&style=for-the-badge">
	</a>
	<br>
	<br>
	<a href="./ALIASES.md">
		<img src="https://img.shields.io/badge/📋_Aliases_&_Commands-Reference-purple?color=a6e3a1&labelColor=1C2325&style=for-the-badge">
	</a>
</div>

<div align="center">
  <div style="max-width:880px;margin:0 auto;">
    <div style="background:#2a0d10;border:2px solid #ff4d4f;border-radius:14px;padding:16px 22px;text-align:left;font-family:Segoe UI,system-ui,sans-serif;">
      <div style="font-weight:700;font-size:16px;letter-spacing:.5px;color:#ff6b6b;display:flex;align-items:center;gap:8px;">
        <span style="font-size:20px;">🚨</span> IMPORTANT: AMD GPU ONLY (CURRENT STAGE)
      </div>
      <div style="margin-top:10px;line-height:1.45;font-size:14.5px;color:#ffd9d9;">
        This project is optimized and tested for <strong>AMD (RADV / AMDVLK)</strong>.  
        NVIDIA support is currently in development.
      </div>
    </div>
  </div>
</div>

***

<table align="right">
	<tr><td colspan="2" align="center">System Parameters</td></tr>
	<tr><th>Component</th><th>Name</th></tr>
	<tr><td>OS</td><td><a href="https://nixos.org/">NixOS 25.05</a></td></tr>
	<tr><td>WM</td><td><a href="https://hyprland.org/">Hyprland</a></td></tr>
	<tr><td>Bar</td><td><a href="https://github.com/Alexays/Waybar">Waybar</a></td></tr>
	<tr><td>Terminal</td><td><a href="https://github.com/kovidgoyal/kitty">Kitty</a></td></tr>
	<tr><td>App Launcher</td><td><a href="https://github.com/davatorium/rofi">Rofi</a></td></tr>
	<tr><td>Shell</td><td><a href="https://github.com/fish-shell/fish-shell">Fish</a></td></tr>
	<tr><td>Audio</td><td><a href="https://pipewire.org/">PipeWire</a></td></tr>
	<tr><td>Theme</td><td><a href="https://catppuccin.com/">Catppuccin</a></td></tr>
</table>

### 📝 About the project
**Meowrch NixOS** — a beautiful and optimized NixOS configuration (Hyprland + Catppuccin).  
**Features:**
• Reproducible builds (Flakes + Home Manager)  
• Gaming ready (Steam, Flatpak)  
• Automated installation via script  

<!-- IMAGES -->
<table align="center">
  <tr><td colspan="4"><img src=".meta/assets/1.png"></td></tr>
  <tr>
    <td colspan="1"><img src=".meta/assets/2.png"></td>
    <td colspan="1"><img src=".meta/assets/3.png"></td>
    <td colspan="1"><img src=".meta/assets/4.png"></td>
  </tr>
</table>

## 🛠 Installation

Installation is simplified. The script will handle user configuration, hardware detection, and system building.

### 1. Clone the repository
```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
```

### 2. Run the installer
```bash
chmod +x install.sh
./install.sh
```

**Follow the on-screen instructions.**  
The script offers:
- Full installation (recommended)
- Hardware config generation
- System build only

> [!IMPORTANT]
> You must reboot your system after the installation completes.

## 💻 Keybindings (Main)

| Action | Combination |
|---|---|
| Terminal | `Super + Enter` |
| Application Menu | `Super + D` |
| Files | `Super + E` |
| Browser | `Super + Shift + F` |
| Close Window | `Super + Q` |
| Change Wallpaper | `Super + W` |
| Change Theme | `Super + T` |

*See full list in the code or help.*

## 🤝 Support

- **[Telegram Channel](https://t.me/meowrch)** / **[Chat](https://t.me/Redm00us)**
- **[Issues](https://github.com/Redm00use/NixOS-Meowrch/issues)** — bugs and suggestions
- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)**

<div align="center">
<p><strong>Made with 💜</strong></p>
</div>
