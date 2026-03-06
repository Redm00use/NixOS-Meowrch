#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import logging
import getpass
import re
import termios
import tty
from pathlib import Path

# --- Configuration & Aesthetics ---
COLORS = {
    "red": "\033[0;31m", "green": "\033[0;32m", "blue": "\033[0;34m",
    "cyan": "\033[0;36m", "yellow": "\033[1;33m", "purple": "\033[0;35m",
    "bold": "\033[1m", "nc": "\033[0m", "rev": "\033[7m", "dim": "\033[2m"
}

BANNER = f"""{COLORS['purple']}
                          ▄▀▄     ▄▀▄           ▄▄▄▄▄
                         ▄█░░▀▀▀▀▀░░█▄         █░▄▄░░█
                     ▄▄  █░░░░░░░░░░░█  ▄▄    █░█  █▄█
                    █▄▄█ █░░▀░░┬░░▀░░█ █▄▄█  █░█
███╗░░░███╗███████╗░█████╗░░██╗░░░░░░░██╗██████╗░░█████╗░██╗░░██╗
████╗░████║██╔════╝██╔══██╗░██║░░██╗░░██║██╔══██╗██╔══██╗██║░░██║
██╔████╔██║█████╗░░██║░░██║░╚██╗████╗██╔╝██████╔╝██║░░╚═╝███████║
██║╚██╔╝██║██╔══╝░░██║░░██║░░████╔═████║░██╔══██╗██║░░██╗██╔══██║
██║░╚═╝░██║███████╗╚█████╔╝░░╚██╔╝░╚██╔╝░██║░░██║╚█████╔╝██║░░██║
╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝
                                 By Redm00use
{COLORS['nc']}"""

PROTECTED_FILES = [
    "hosts/meowrch/user-local.nix", "hosts/meowrch/user-packages.nix",
    "hosts/meowrch/user-features.nix", "hosts/meowrch/hardware-configuration.nix",
    "config/hypr/monitors.conf", "config/hypr/userprefs.conf"
]

# --- Logging ---
class MeowLogger:
    def __init__(self, log_file="install.log"):
        self.log_file = log_file
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[logging.FileHandler(self.log_file, mode='w'), logging.StreamHandler(sys.stdout)]
        )
        self.logger = logging.getLogger("Meowrch")
    def info(self, msg): self.logger.info(f"{COLORS['blue']}[INFO]{COLORS['nc']} {msg}")
    def success(self, msg): self.logger.info(f"{COLORS['green']}[SUCCESS]{COLORS['nc']} {msg}")
    def warn(self, msg): self.logger.warning(f"{COLORS['yellow']}[WARN]{COLORS['nc']} {msg}")
    def error(self, msg): self.logger.error(f"{COLORS['red']}[ERROR]{COLORS['nc']} {msg}")

log = MeowLogger()

# --- Terminal UI Helpers ---
def get_key():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == '\x1b':
            ch += sys.stdin.read(2)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

def interactive_menu(title, options, multi=False, detected_idx=None):
    index = detected_idx if detected_idx is not None else 0
    selected = [False] * len(options)
    
    while True:
        os.system('clear')
        print(BANNER)
        print(f"{COLORS['yellow']}==> {title}{COLORS['nc']}")
        print(f"{COLORS['dim']}(Arrows: Navigate, {'Space: Toggle, ' if multi else ''}Enter: Confirm){COLORS['nc']}\n")
        
        for i, opt in enumerate(options):
            prefix = f"{COLORS['cyan']}➔{COLORS['nc']}" if i == index else " "
            if multi:
                check = f"[{COLORS['green']}x{COLORS['nc']}]" if selected[i] else "[ ]"
                label = f"{opt['label']}"
                if i == index: label = f"{COLORS['rev']} {label} {COLORS['nc']}"
                print(f" {prefix} {check} {label}")
            else:
                label = opt
                if i == detected_idx: label += f" {COLORS['green']}(Detected){COLORS['nc']}"
                if i == index: label = f"{COLORS['rev']} {label} {COLORS['nc']}"
                print(f" {prefix} {label}")

        key = get_key()
        if key == '\x1b[A': index = (index - 1) % len(options)
        elif key == '\x1b[B': index = (index + 1) % len(options)
        elif key == ' ' and multi: selected[index] = not selected[index]
        elif key == '\r':
            if multi: return [options[i]['id'] for i, s in enumerate(selected) if s]
            return index

# --- Main Installer ---
class MeowInstaller:
    def __init__(self):
        self.source_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
        self.conf = {"mode": 0, "hostname": "meowrch", "username": getpass.getuser(), "gpu": 0, "features": []}
        self.detected_gpu = 0

    def startup(self):
        os.system('clear')
        print(BANNER)
        log.info("Starting Meowrch Ultimate Installer...")
        try:
            lspci = subprocess.check_output("lspci", text=True)
            if "NVIDIA" in lspci: self.detected_gpu = 2
            elif "AMD" in lspci or "ATI" in lspci: self.detected_gpu = 0
            else: self.detected_gpu = 1
        except: pass

    def survey(self):
        # 1. Mode
        self.conf["mode"] = interactive_menu("Installation Mode", ["Update current system", "Clean Install (Manual partitioning /mnt)"])
        
        # 2. Identity
        print(f"\n{COLORS['yellow']}==> Identity{COLORS['nc']}")
        self.conf["hostname"] = input(f" ? Enter Hostname [{self.conf['hostname']}]: ") or self.conf['hostname']
        self.conf["username"] = input(f" ? Enter Username [{self.conf['username']}]: ") or self.conf['username']
        
        # 3. GPU
        self.conf["gpu"] = interactive_menu("Select GPU Driver", ["AMD (Mesa)", "Intel (Mesa)", "NVIDIA (Proprietary)"], detected_idx=self.detected_gpu)
        
        # 4. Features (Categorized)
        feature_list = [
            {"id": "header_gaming", "label": f"{COLORS['bold']}--- GAMING ---{COLORS['nc']}", "selected": False, "is_header": True},
            {"id": "steam", "label": "Steam", "selected": False},
            {"id": "gamemode", "label": "GameMode", "selected": False},
            {"id": "mangohud", "label": "MangoHud", "selected": False},
            {"id": "header_social", "label": f"\n{COLORS['bold']}--- SOCIAL ---{COLORS['nc']}", "selected": False, "is_header": True},
            {"id": "telegram", "label": "Telegram", "selected": True},
            {"id": "discord", "label": "Discord", "selected": True},
            {"id": "obsidian", "label": "Obsidian", "selected": False},
            {"id": "header_office", "label": f"\n{COLORS['bold']}--- OFFICE ---{COLORS['nc']}", "selected": False, "is_header": True},
            {"id": "libreoffice", "label": "LibreOffice", "selected": False},
            {"id": "thunderbird", "label": "Thunderbird", "selected": False},
            {"id": "header_dev", "label": f"\n{COLORS['bold']}--- DEVELOPMENT ---{COLORS['nc']}", "selected": False, "is_header": True},
            {"id": "docker", "label": "Docker", "selected": False},
            {"id": "vscode", "label": "VS Code", "selected": False},
            {"id": "zed", "label": "Zed Editor", "selected": True},
            {"id": "header_sys", "label": f"\n{COLORS['bold']}--- SYSTEM ---{COLORS['nc']}", "selected": False, "is_header": True},
            {"id": "flatpak", "label": "Flatpak", "selected": True},
            {"id": "wine", "label": "Wine", "selected": False},
        ]
        
        # Filter out headers from the final selection
        raw_features = interactive_menu("Select Applications", [f for f in feature_list], multi=True)
        self.conf["features"] = [f for f in raw_features if not f.startswith("header_")]

    def prepare(self):
        # Refresh hashes logic (already robust)
        target = "/mnt/etc/nixos/meowrch" if self.conf["mode"] == 1 else os.path.expanduser("~/NixOS-Meowrch")
        target_abs = os.path.abspath(target)
        source_abs = os.path.abspath(self.source_dir)

        # Sync files only if directories are different
        if source_abs != target_abs:
            log.info(f"Syncing files to {target}...")
            os.makedirs(target_abs, exist_ok=True)
            for root, dirs, files in os.walk(self.source_dir):
                if ".git" in dirs: dirs.remove(".git")
                if "__pycache__" in dirs: dirs.remove("__pycache__")
                
                rel = os.path.relpath(root, self.source_dir)
                dest = os.path.join(target_abs, rel)
                os.makedirs(dest, exist_ok=True)
                
                for f in files:
                    # Ignore logs and temp files
                    if f.endswith(".log") or f == "error.txt" or f == "result": continue
                    
                    src_file = os.path.join(root, f)
                    rel_file = os.path.join(rel, f) if rel != "." else f
                    dst_file = os.path.join(dest, f)
                    
                    if rel_file in PROTECTED_FILES and os.path.exists(dst_file):
                        continue
                    shutil.copy2(src_file, dst_file)
        else:
            log.info("Source and target are the same. Skipping file sync.")

        os.chdir(target_abs)
        # Write feature file
        with open("hosts/meowrch/user-features.nix", "w") as f:
            f.write("{ ... }: {\n  meowrch.features = {\n")
            for feat in self.conf["features"]: f.write(f"    {feat} = true;\n")
            f.write("  };\n}\n")
        
        # Write identity
        with open("hosts/meowrch/user-local.nix", "w") as f:
            f.write(f'{{ meowrch.user = "{self.conf["username"]}"; meowrch.hostname = "{self.conf["hostname"]}"; }}\n')

    def install(self):
        log.info("Starting build process...")
        env = os.environ.copy(); env["NIXPKGS_ALLOW_UNFREE"] = "1"
        cmd = ["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"] if self.conf["mode"] == 1 else ["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"]
        
        # Run with live output to log and screen
        process = subprocess.Popen(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        with open("install.log", "a") as f:
            for line in process.stdout:
                sys.stdout.write(line)
                f.write(line)
        process.wait()
        if process.returncode == 0: log.success("Installation finished! Please reboot.")
        else: log.error("Installation failed. Check install.log")

if __name__ == "__main__":
    inst = MeowInstaller()
    try:
        inst.startup()
        inst.survey()
        inst.prepare()
        inst.install()
    except KeyboardInterrupt: print("\nAborted.")
