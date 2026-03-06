import os
import shutil
import subprocess
from pathlib import Path
from os.path import expandvars
from typing import List, Optional

from vars import OOMOX_TEMPLATES, THEME_GEN_SCRIPT


def parse_wallpapers(paths: List[str]):
		"""
		Accepts a list of strings with paths to the wallpaper and returns a list of all found files.
		Supports:
		- Tilde for the home directory
		- Masks of the form *.png, *.jpg, etc.
		"""
		all_wallpapers = []

		for path_str in paths:
			path = Path(expandvars(path_str.strip())).expanduser()

			if path.is_absolute() and path.parts[0] == "~":
				path = Path.home().joinpath(*path.parts[1:])
	
			if "*" in path.name:
				all_wallpapers.extend(list(path.parent.glob(path.name)))
			elif path.exists():
				all_wallpapers.append(path)
		
		return all_wallpapers
		
def notify(title: str, message: str, critical=False) -> None:
	subprocess.run(['notify-send', title, message, '-u', 'critical' if critical else 'normal'])

def overcopy(src: Path, dst: Path) -> None:
	if dst.exists() or dst.is_symlink():
		if dst.is_dir() and not dst.is_symlink():
			shutil.rmtree(dst)
		else:
			dst.unlink(missing_ok=True)

	if src.is_dir():
		shutil.copytree(src, dst)
		# Make everything writable in the new directory
		for root, dirs, files in os.walk(dst):
			for d in dirs: os.chmod(os.path.join(root, d), 0o755)
			for f in files: os.chmod(os.path.join(root, f), 0o644)
	else:
		dst.parent.mkdir(parents=True, exist_ok=True)
		shutil.copy2(src, dst)
		os.chmod(dst, 0o644)

def generate_theme(template_name: str, oomox_colors: Path) -> Optional[str]:
	template_path = OOMOX_TEMPLATES / template_name
	if not template_path.exists():
		return None

	if THEME_GEN_SCRIPT.exists():
		try:
			theme = subprocess.run(
				["python3", str(THEME_GEN_SCRIPT), str(template_path), str(oomox_colors)], 
				stdout=subprocess.PIPE,
				check=True
			).stdout.decode().strip()
			return theme
		except subprocess.CalledProcessError:
			pass

	# Fallback: simple replacement of {{themix_VARIABLE-hex}}
	try:
		with open(template_path, "r") as f:
			content = f.read()
		
		colors = {}
		with open(oomox_colors, "r") as f:
			for line in f:
				if "=" in line:
					k, v = line.strip().split("=", 1)
					colors[k] = v
		
		import re
		def replace_match(match):
			var_name = match.group(1)
			return colors.get(var_name, match.group(0))

		return re.sub(r"{{themix_(.*?)-hex}}", replace_match, content)
	except Exception:
		return None