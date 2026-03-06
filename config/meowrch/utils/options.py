import re
import shutil
import logging
import traceback
import subprocess
from typing import List
from pathlib import Path
from dataclasses import dataclass, field

from .schemes import BaseOption
from .other import overcopy, generate_theme
from vars import MEOWRCH_THEMES, OOMOX_TEMPLATES, OOMOX_COLORS, BASE_CONFIGS, HOME, SESSION_TYPE


@dataclass
class CopyOption(BaseOption):
	name: str
	path_to: str
	is_dir: bool = field(default=False)

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists():
			if self.is_dir and cfg_path.is_dir() or not self.is_dir and cfg_path.is_file():
				overcopy(cfg_path, self.path_to)
				return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)


@dataclass
class CopyOrGenOption(BaseOption):
	name: str
	path_to: str
	template_name: str

	def _run(self, theme_name: str) -> None:
		oomox_colors_path = OOMOX_COLORS(theme_name)
		template_path = OOMOX_TEMPLATES / self.template_name
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)
			return

		if template_path.exists():
			if oomox_colors_path.exists():
				generated_theme = generate_theme(
					template_name=self.template_name,
					oomox_colors=oomox_colors_path,
				)

				if generated_theme is not None:
					if self.path_to.exists():
						try: os.chmod(self.path_to, 0o644)
						except: pass
					with open(self.path_to, "w") as file:
						file.write(generated_theme)	
					return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"!" \
			f"There is no \"{self.name}\" file in the theme folder. No generation option."
		)


@dataclass
class TmuxCfgOption(BaseOption):
	name: str
	path_to: str
	base_config_name: str

	def _run(self, theme_name: str) -> None:
		tmux: Path = self.path_to
		custom_prefs: Path = MEOWRCH_THEMES / theme_name / self.name
		tmux_base: Path = BASE_CONFIGS / self.base_config_name

		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if tmux_base.exists():
			with open(tmux, "w") as f:
				with open(tmux_base, "r") as b:
					f.write(b.read())
				f.write("\n\n")
				with open(custom_prefs, "r") as c:
					f.write(c.read())
		else:
			overcopy(custom_prefs, tmux)

		try:
			if subprocess.run(["pgrep", "tmux"], stdout=subprocess.PIPE).stdout.decode().strip():
				subprocess.run(["tmux", "source", str(tmux)], check=True)
		except Exception:
			logging.warning("Failed to update the theme for tmux in an open session.")


@dataclass
class DunstOption(BaseOption):
	name: str
	path_to: str
	apply_theme: bool

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)

			if self.apply_theme:
				subprocess.Popen(
					['killall', '-HUP', 'dunst'],
					stdout=subprocess.PIPE,
					stderr=subprocess.PIPE,
					text=True
				)

			return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)


@dataclass
class CavaOption(BaseOption):
	name: str
	path_to: str
	apply_theme: bool

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)

			if self.apply_theme:
				subprocess.Popen(
					['pkill', '-USR1', 'cava'],
					stdout=subprocess.PIPE,
					stderr=subprocess.PIPE,
					text=True
				)

			return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)


@dataclass
class FishOption(BaseOption):
	name: str
	path_to: str
	apply_theme: bool

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)

			if self.apply_theme:
				subprocess.Popen(
					['fish', '-c', 'echo "y" | fish_config theme save meowrch'],
					stdout=subprocess.PIPE,
					stderr=subprocess.PIPE,
					text=True
				)

			return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)


@dataclass
class KittyOption(BaseOption):
	name: str
	path_to: str
	template_name: str
	apply_theme: bool

	def apply_kitty_theme(self) -> None:
		if self.apply_theme:
			try:
				result = subprocess.run(['pgrep', 'kitty'], capture_output=True, text=True, check=True)
				pids = result.stdout.strip().split('\n')
				for pid in pids:
					try:
						subprocess.run(['kill', '-SIGUSR1', pid])
					except Exception:
						logging.warning(f"Failed to reload kitty with pid {pid}")
			except Exception:
				logging.warning("Failed to reload kitty.")

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		oomox_colors_path = OOMOX_COLORS(theme_name)
		template_path = OOMOX_TEMPLATES / self.template_name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)
			self.apply_kitty_theme()
			return

		if template_path.exists():
			if oomox_colors_path.exists():
				generated_theme = generate_theme(
					template_name=self.template_name,
					oomox_colors=oomox_colors_path,
				)

				if generated_theme is not None:
					if self.path_to.exists():
						try: os.chmod(self.path_to, 0o644)
						except: pass
					with open(self.path_to, "w") as file:
						file.write(generated_theme)	

					self.apply_kitty_theme()
					return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)

@dataclass
class ZedOption(BaseOption):
	name: str
	path_to: str
	template_name: str

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		oomox_colors_path = OOMOX_COLORS(theme_name)
		template_path = OOMOX_TEMPLATES / self.template_name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if self.path_to.exists():
			try: os.chmod(self.path_to, 0o644)
			except: pass

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)
			return

		if template_path.exists() and oomox_colors_path.exists():
			generated_theme = generate_theme(
				template_name=self.template_name,
				oomox_colors=oomox_colors_path,
			)

			if generated_theme is not None:
				# For Zed, we might want to update only the theme field in settings.json
				# but for simplicity in this port, we overwrite a dynamic settings file
				with open(self.path_to, "w") as file:
					file.write(generated_theme)
				return

		logging.error(f"Theme \"{theme_name}\" has not been applied to Zed!")

@dataclass
class MewlineOption(BaseOption):
	name: str
	path_to: str

	def _run(self, theme_name: str) -> None:
		cfg_dir = MEOWRCH_THEMES / theme_name / "mewline"
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_dir.exists() and cfg_dir.is_dir():
			# Copy config.json.jsonpaw
			json_src = cfg_dir / "config.json.jsonpaw"
			json_dst = self.path_to / "config.json"
			if json_src.exists():
				overcopy(json_src, json_dst)

			# Copy themes directory
			themes_src = cfg_dir / "themes"
			themes_dst = self.path_to / "themes"
			if themes_src.exists():
				overcopy(themes_src, themes_dst)

			# Reload mewline using fabric-cli
			try:
				subprocess.run(["fabric-cli", "invoke-action", "mewline", "dynamic-island-open", "date_notification"], check=False)
			except Exception:
				logging.warning("Failed to notify mewline about theme change")
			return

		logging.error(f"Theme \"{theme_name}\" has no mewline config")

@dataclass
class WaybarCfgOption(BaseOption):
	name: str
	path_to: str
	reload: bool

	def _run(self, theme_name: str) -> None:
		cfg_path = MEOWRCH_THEMES / theme_name / self.name
		
		if not self.path_to.parent.exists():
			self.path_to.parent.mkdir(parents=True, exist_ok=True)

		if cfg_path.exists() and cfg_path.is_file():
			overcopy(cfg_path, self.path_to)

			if self.reload:
				try:
					wb_pids = subprocess.run(["pgrep", "waybar"], capture_output=True, text=True).stdout.strip()
					if wb_pids:
						subprocess.run(["pkill", "-SIGUSR2", "waybar"], check=False)
				except Exception:
					logging.warning("Failed to reload waybar")

			return

		logging.error(
			f"Theme \"{theme_name}\" has not been applied to \"{self._id}\"! " \
			f"There is no file \"{self.name}\" in the theme folder"
		)

@dataclass
class GTKOption(BaseOption):
	gtk4_template_name: str
	gtk2_cfg: Path
	gtk3_cfg: Path
	gtk4_cfg: Path

	def generate_gtk_2_3(self, path_to_theme: Path, oomox_colors_path: str, theme_name: str) -> bool:
		try:
			subprocess.check_output(["which", "oomox-cli"])
		except subprocess.CalledProcessError:
			return False
		try:
			subprocess.run(["oomox-cli", oomox_colors_path, "-o", theme_name, "-m", "all", "-d", "true"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
		except:
			return False
		return True

	def generate_gtk_4(self, path_to_theme: Path, gtk4_template: Path, oomox_colors_path: Path) -> bool:
		generated_gtk4 = generate_theme(template_name=self.gtk4_template_name, oomox_colors=oomox_colors_path)
		if generated_gtk4 is not None:
			gtk4_path: Path = path_to_theme / "gtk-4.0"
			gtk4_path.mkdir(parents=True, exist_ok=True)
			with open(str(gtk4_path / "gtk.css"), "w") as file: file.write(generated_gtk4)
			with open(str(gtk4_path / "gtk-dark.css"), "w") as file: file.write(generated_gtk4)
			return True
		return False

	def _is_light_theme(self, original_theme_name: str) -> bool:
		try:
			oomox_colors_path = OOMOX_COLORS(original_theme_name)
			if oomox_colors_path.exists():
				with open(oomox_colors_path, "r") as f:
					for line in f:
						if line.startswith("BG="):
							bg_hex = line.strip().split("=", 1)[1].strip().lstrip("#")
							r, g, b = int(bg_hex[0:2], 16), int(bg_hex[2:4], 16), int(bg_hex[4:6], 16)
							return (0.2126 * r + 0.7152 * g + 0.0722 * b) > 128
		except: pass
		return "latte" in original_theme_name.lower()

	def apply_gtk_themes(self, gtk_configs: List[Path], theme_name: str, original_theme_name: str = ""):
		for gtk_cfg in gtk_configs:
			if not gtk_cfg.parent.exists(): continue
			if not gtk_cfg.exists(): gtk_cfg.touch()
			try:
				with open(gtk_cfg, "r") as file: content = file.read()
				# Special handling for catppuccin theme names in gtkrc/settings.ini
				real_theme_name = theme_name
				is_light = self._is_light_theme(original_theme_name)
				prefer_dark = "0" if is_light else "1"

				if original_theme_name == "catppuccin-mocha":
					real_theme_name = "pawlette-catppuccin-mocha"
				elif original_theme_name == "catppuccin-latte":
					real_theme_name = "pawlette-catppuccin-latte"

				# Update theme name and dark theme preference
				new_content = content
				if f"gtk-theme-name={real_theme_name}" not in content:
					new_content = re.sub(r"gtk-theme-name=.*", f"gtk-theme-name={real_theme_name}", new_content) if "gtk-theme-name=" in new_content else new_content + f"gtk-theme-name={real_theme_name}\n"
				
				if f"gtk-application-prefer-dark-theme={prefer_dark}" not in new_content:
					new_content = re.sub(r"gtk-application-prefer-dark-theme=.*", f"gtk-application-prefer-dark-theme={prefer_dark}", new_content) if "gtk-application-prefer-dark-theme=" in new_content else new_content + f"gtk-application-prefer-dark-theme={prefer_dark}\n"

				if new_content != content:
					if gtk_cfg.is_symlink(): gtk_cfg.unlink()
					with open(gtk_cfg, "w") as file: file.write(new_content)
			except: pass

		is_light = self._is_light_theme(original_theme_name)
		color_scheme = "prefer-light" if is_light else "prefer-dark"
		icon_theme = "Papirus" if is_light else "Papirus-Dark"
		
		# Map meowrch theme names to actual GTK theme names for gsettings
		gsettings_theme = theme_name
		if original_theme_name == "catppuccin-mocha":
			gsettings_theme = "pawlette-catppuccin-mocha"
		elif original_theme_name == "catppuccin-latte":
			gsettings_theme = "pawlette-catppuccin-latte"

		if SESSION_TYPE == "wayland":
			try:
				subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", gsettings_theme], check=False)
				subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", color_scheme], check=False)
				subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", icon_theme], check=False)
				subprocess.run(["hyprctl", "keyword", "decoration:shadow:enabled", "false"], check=False)
				subprocess.run(["hyprctl", "keyword", "general:border_size", "0"], check=False)
			except: pass

	def _run(self, theme_name: str) -> None:
		original_theme_name = theme_name
		meowrch_theme_name = f"meowrch-{theme_name}"
		path_to_theme = HOME / ".themes" / meowrch_theme_name
		oomox_colors_path = OOMOX_COLORS(theme_name)
		try:
			subprocess.check_output(["which", "oomox-cli"], stderr=subprocess.DEVNULL)
			oomox_available = True
		except: oomox_available = False
		if not oomox_available:
			self.apply_gtk_themes([self.gtk2_cfg, self.gtk3_cfg, self.gtk4_cfg], f"pawlette-{theme_name}", original_theme_name)
			return
		if not path_to_theme.exists(): self.generate_gtk_2_3(path_to_theme, str(oomox_colors_path), meowrch_theme_name)
		if not (path_to_theme / "gtk-4.0").exists(): self.generate_gtk_4(path_to_theme, self.gtk4_template_name, oomox_colors_path)
		self.apply_gtk_themes([self.gtk2_cfg, self.gtk3_cfg, self.gtk4_cfg], meowrch_theme_name, original_theme_name)
