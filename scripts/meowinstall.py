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

# --- UI Helpers ---
def get_key():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == '\x1b': ch += sys.stdin.read(2)
    finally: termios.tcsetattr(fd, termios.TCSADRAIN, old)
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
                label = opt['label']
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

# --- Installer ---
class MeowInstaller:
    def __init__(self):
        self.source_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
        self.conf = {"mode": 0, "hostname": "meowrch", "username": getpass.getuser(), "gpu": 0, "features": []}
        self.detected_gpu = 0

    def startup(self):
        os.system('clear')
        print(BANNER)
        log.info("Meowrch Ultimate Installer v4.6.0 starting...")
        try:
            lspci = subprocess.check_output("lspci", text=True)
            if "NVIDIA" in lspci: self.detected_gpu = 2
            elif "AMD" in lspci or "ATI" in lspci: self.detected_gpu = 0
            else: self.detected_gpu = 1
        except: pass

    def update_hashes(self):
        log.info("Auto-calculating latest source hashes...")
        pkgs = [
            ("packages/meowrch-themes.nix", "https://github.com/Meowrch/meowrch-themes/archive/main.tar.gz"),
            ("packages/meowrch-scripts.nix", "https://github.com/Meowrch/meowrch/archive/main.tar.gz"),
            ("pkgs/meowrch-settings/default.nix", "https://github.com/Meowrch/meowrch-settings/archive/main.tar.gz"),
            ("pkgs/pawlette/default.nix", "https://github.com/Meowrch/pawlette/archive/main.tar.gz")
        ]
        for path, url in pkgs:
            fpath = os.path.join(self.source_dir, path)
            if not os.path.exists(fpath): continue
            try:
                # Fetch new hash
                raw_hash = subprocess.check_output(["nix-prefetch-url", "--unpack", url], text=True, stderr=subprocess.DEVNULL).strip()
                sri_hash = "sha256-" + subprocess.check_output(["nix-hash", "--to-base64", "--type", "sha256", raw_hash], text=True, stderr=subprocess.DEVNULL).strip()
                
                with open(fpath, "r") as f: content = f.read()
                # Powerful regex to catch hash = "..." or sha256 = "..."
                new_content = re.sub(r'(hash|sha256)\s*=\s*"sha256-[^"]+";', f'\\1 = "{sri_hash}";', content)
                
                if new_content != content:
                    with open(fpath, "w") as f: f.write(new_content)
                    log.success(f"Fixed hash in {path}")
                    # CRITICAL: Stage the fixed file for Git so Nix Flakes see it!
                    subprocess.run(["git", "add", fpath], cwd=self.source_dir, stderr=subprocess.DEVNULL)
            except Exception as e:
                log.warn(f"Skip hash fix for {path}: {e}")

    def survey(self):
        self.conf["mode"] = interactive_menu("Installation Mode", ["Update current system", "Clean Install (Manual partitioning /mnt)"])
        print(f"\n{COLORS['yellow']}==> Identity{COLORS['nc']}")
        self.conf["hostname"] = input(f" ? Hostname [{self.conf['hostname']}]: ") or self.conf['hostname']
        self.conf["username"] = input(f" ? Username [{self.conf['username']}]: ") or self.conf['username']
        self.conf["gpu"] = interactive_menu("GPU Driver", ["AMD", "Intel", "NVIDIA"], detected_idx=self.detected_gpu)
        
        feature_list = [
            {"id": "steam", "label": "Steam", "selected": False},
            {"id": "gamemode", "label": "GameMode", "selected": False},
            {"id": "telegram", "label": "Telegram", "selected": True},
            {"id": "discord", "label": "Discord", "selected": True},
            {"id": "zed", "label": "Zed Editor", "selected": True},
            {"id": "flatpak", "label": "Flatpak", "selected": True},
            {"id": "wine", "label": "Wine", "selected": False},
        ]
        self.conf["features"] = interactive_menu("Select Applications", feature_list, multi=True)

    def prepare(self):
        self.update_hashes() # AUTO-FIX HASHES BEFORE INSTALL
        target = "/mnt/etc/nixos/meowrch" if self.conf["mode"] == 1 else os.path.expanduser("~/NixOS-Meowrch")
        source_abs = os.path.abspath(self.source_dir)
        target_abs = os.path.abspath(target)

        if source_abs != target_abs:
            log.info(f"Syncing to {target}...")
            os.makedirs(target_abs, exist_ok=True)
            for root, dirs, files in os.walk(self.source_dir):
                if ".git" in dirs: dirs.remove(".git")
                rel = os.path.relpath(root, self.source_dir)
                dest = os.path.join(target_abs, rel)
                os.makedirs(dest, exist_ok=True)
                for f in files:
                    if f.endswith(".log") or f == "result": continue
                    if os.path.join(rel, f) in PROTECTED_FILES and os.path.exists(os.path.join(dest, f)): continue
                    shutil.copy2(os.path.join(root, f), os.path.join(dest, f))
        
        os.chdir(target_abs)
        with open("hosts/meowrch/user-features.nix", "w") as f:
            f.write("{ ... }: {\n  meowrch.features = {\n")
            for feat in self.conf["features"]: f.write(f"    {feat} = true;\n")
            f.write("  };\n}\n")
        with open("hosts/meowrch/user-local.nix", "w") as f:
            f.write(f'{{ meowrch.user = "{self.conf["username"]}"; meowrch.hostname = "{self.conf["hostname"]}"; }}\n')

    def install(self):
        log.info("Starting build...")
        if not os.path.exists(".git"): subprocess.run(["git", "init", "-q"])
        subprocess.run(["git", "add", "-A"]) # Stage everything
        env = os.environ.copy(); env["NIXPKGS_ALLOW_UNFREE"] = "1"
        cmd = ["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"]
        if self.conf["mode"] == 1: cmd = ["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"]
        
        process = subprocess.Popen(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        with open("install.log", "a") as f:
            for line in process.stdout:
                sys.stdout.write(line); f.write(line)
        process.wait()
        if process.returncode == 0: log.success("Finished! Please reboot.")
        else: log.error("Failed. See install.log")

if __name__ == "__main__":
    inst = MeowInstaller()
    try: inst.startup(); inst.survey(); inst.prepare(); inst.install()
    except KeyboardInterrupt: print("\nAborted.")
