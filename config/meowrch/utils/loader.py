import logging
from typing import List
from logging.handlers import RotatingFileHandler
from pathlib import Path

from utils.schemes import BaseOption
from utils.options import (
	CopyOption, CopyOrGenOption, TmuxCfgOption, GTKOption, FishOption, 
	WaybarCfgOption, KittyOption, DunstOption, CavaOption, MewlineOption, ZedOption
)
from vars import (
    HOME, MEOWRCH_DIR, GTK2_CFG, GTK3_CFG, GTK4_CFG, LOG_FILE,
    HYPR_THEME_CFG, KITTY_THEME_CFG, WAYBAR_THEME_CFG, ROFI_THEME_CFG,
    BTOP_THEME_CFG, STARSHIP_THEME_CFG, ZED_THEME_CFG
)


##==> Настройки применения тем для конфигураций
###################################################
theme_options: List[BaseOption] = [
	##==> Копирование конфигов
	###############################################
	CopyOption(_id="tmux_theme", is_dir=True, name="tmux-theme", path_to=HOME / ".cache" / "meowrch" / "tmux" / "theme"),
	CopyOption(_id="starship", name="starship.toml", path_to=STARSHIP_THEME_CFG),
	CopyOption(_id="rofi", name="rofi.rasi", path_to=ROFI_THEME_CFG),
	CopyOption(_id="btop", name="btop.theme", path_to=BTOP_THEME_CFG),
	CopyOption(_id="micro", name="theme.micro", path_to=HOME / ".config" / "micro" / "colorschemes" / "meowrch.micro"),
	CopyOption(_id="hyprland", name="hyprland-custom-prefs.conf", path_to=HYPR_THEME_CFG, xorg_needed=False),


	##==> Копирование / Генерация конфигов
	###############################################
	CopyOrGenOption(
		_id="alacritty",
		name="alacritty.toml",
		path_to=HOME / ".cache" / "meowrch" / "alacritty" / "meowrch.toml",
		template_name="alacritty.mustache"
	),
	ZedOption(
		_id="zed",
		name="zed.json",
		path_to=ZED_THEME_CFG,
		template_name="zed.mustache"
	),
	CopyOrGenOption(
		_id="qt5ct",
		name="qt5ct-colors.conf",
		path_to=HOME / ".cache" / "meowrch" / "qt5ct" / "colors" / "meowrch.conf",
		template_name="qt5ct-colors.mustache"
	),
	CopyOrGenOption(
		_id="qt6ct",
		name="qt6ct-colors.conf",
		path_to=HOME / ".cache" / "meowrch" / "qt6ct" / "colors" / "meowrch.conf",
		template_name="qt6ct-colors.mustache"
	),
	CopyOrGenOption(
		_id="sddm",
		name="sddm-theme.conf",
		path_to=HOME / ".cache" / "meowrch" / "sddm-theme.conf",
		template_name="sddm.mustache"
	),

	##==> Кастомные действия 
	###############################################
	CavaOption(
		_id="cava", 
		name="cava", 
		path_to=HOME / ".cache" / "meowrch" / "cava" / "config",
		apply_theme=True
	),
	FishOption(
		_id="fish", 
		name="fish-theme.theme", 
		path_to=HOME / ".config" / "fish" / "themes" / "meowrch.theme",
		apply_theme=True
	),
	KittyOption(
		_id="kitty",
		name="kitty.conf",
		path_to=KITTY_THEME_CFG,
		template_name="kitty.mustache",
		apply_theme=True
	),
	MewlineOption(
		_id="mewline",
		name="mewline",
		path_to=HOME / ".cache" / "meowrch" / "mewline"
	),
	GTKOption(
		_id="gtk_theme",
		gtk4_template_name="gtk4-oodwaita.mustache",
		gtk2_cfg=GTK2_CFG,
		gtk3_cfg=GTK3_CFG,
		gtk4_cfg=GTK4_CFG
	)
]

for vscode in [".vscode", ".vscode-oss"]:
	if Path(HOME / vscode).exists():
		theme_options.append(
			CopyOrGenOption(
				_id="vscode",
				name="vscode.json",
				path_to=HOME / vscode / "extensions" / "dimflix-official.meowrch-theme-1.0.0" / "themes" / "meowrch-theme.json",
				template_name="vscode.mustache"
			)
		)

##==> Логирование
###############################################
log_file = LOG_FILE
log_file.parent.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(funcName)s: %(lineno)d - %(message)s',
    level=logging.DEBUG,
	handlers=[
		RotatingFileHandler(
			filename=log_file,
			mode='a',
			maxBytes=5 * 1024 * 1024,
			backupCount=1
		), # Настройка логирования с ротацией по размеру
        logging.StreamHandler()
	],
)

with open(log_file, 'a') as f:
    f.write('\n')
