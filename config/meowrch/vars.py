from pathlib import Path
from typing import Optional
from os.path import expandvars

HOME = Path.home()
MEOWRCH_DIR = Path(__file__).resolve().parent
MEOWRCH_THEMES: Path = MEOWRCH_DIR / "themes"
OOMOX_TEMPLATES = MEOWRCH_DIR / "oomox_templates"
BASE_CONFIGS: Path = MEOWRCH_DIR / "base_configs" 
MEOWRCH_ASSETS: Path = MEOWRCH_DIR / "utils" / "assets"

MEOWRCH_CONFIG: Path = Path.home() / ".cache" / "meowrch" / "config.yaml"
LOG_FILE: Path = Path.home() / ".cache" / "meowrch" / "logs.log"
WALLPAPER_SYMLINC: Path = Path.home() / ".cache" / "meowrch" / "current_wallpaper"

ROFI_SELECTING_THEME: Path = Path.home() / ".config" / "rofi" / "selecting.rasi"

WALLPAPERS_CACHE_DIR: Path = HOME / ".cache" / "meowrch" / "wallpaper_thumbnails"
THEMES_CACHE_DIR: Path = HOME / ".cache" / "meowrch" / "themes_thumbnails"

OOMOX_COLORS: Path = lambda theme_name: MEOWRCH_THEMES / theme_name / "oomox-colors"  # noqa: E731

THEME_GEN_SCRIPT: Path = Path("/opt/oomox/plugins/base16/cli.py")
if not THEME_GEN_SCRIPT.exists():
    # Attempt to find it in NixOS or other standard locations
    potential_paths = [
        Path("/run/current-system/sw/share/oomox/plugins/base16/cli.py"),
        Path("/usr/share/oomox/plugins/base16/cli.py"),
        Path("/usr/local/share/oomox/plugins/base16/cli.py")
    ]
    for p in potential_paths:
        if p.exists():
            THEME_GEN_SCRIPT = p
            break

SESSION_TYPE: Optional[str] = (lambda s: s if s != "$XDG_SESSION_TYPE" else None)(expandvars("$XDG_SESSION_TYPE"))

GTK2_CFG: Path = HOME / ".gtkrc-2.0"
GTK3_CFG: Path = HOME / ".config" / "gtk-3.0" / "settings.ini"
GTK4_CFG: Path = HOME / ".config" / "gtk-4.0" / "settings.ini"

# Dynamic theme files for apps (NixOS writable locations)
HYPR_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "hypr" / "theme.conf"
KITTY_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "kitty" / "theme.conf"
WAYBAR_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "waybar" / "theme.css"
ROFI_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "rofi" / "theme.rasi"
BTOP_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "btop" / "meowrch.theme"
STARSHIP_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "starship" / "starship.toml"
ZED_THEME_CFG: Path = HOME / ".cache" / "meowrch" / "zed" / "settings.json"