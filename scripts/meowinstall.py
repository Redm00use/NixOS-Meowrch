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

# --- Configuration & Aesthetics ---
COLORS = {
    "red": "\033[0;31m", "green": "\033[0;32m", "blue": "\033[0;34m",
    "cyan": "\033[0;36m", "yellow": "\033[1;33m", "purple": "\033[0;35m",
    "bold": "\033[1m", "nc": "\033[0m", "rev": "\033[7m"
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

# --- Interactive Picker ---
class MeowPicker:
    def __init__(self, options):
        self.options = options # List of {"id": "key", "label": "Name", "selected": False}
        self.index = 0

    def _get_key(self):
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
            if ch == '\x1b':
                ch += sys.stdin.read(2)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

    def pick(self):
        while True:
            os.system('clear')
            print(BANNER)
            print(f"{COLORS['yellow']}==> Select Optional Features (Space to toggle, Enter to confirm){COLORS['nc']}\n")
            
            for i, opt in enumerate(self.options):
                prefix = f"{COLORS['cyan']}➔{COLORS['nc']}" if i == self.index else " "
                check = f"[{COLORS['green']}x{COLORS['nc']}]" if opt['selected'] else "[ ]"
                label = f"{COLORS['bold']}{opt['label']}{COLORS['nc']}" if i == self.index else opt['label']
                print(f" {prefix} {check} {label}")

            key = self._get_key()
            if key == '\x1b[A': # Up
                self.index = (self.index - 1) % len(self.options)
            elif key == '\x1b[B': # Down
                self.index = (self.index + 1) % len(self.options)
            elif key == ' ': # Space
                self.options[self.index]['selected'] = not self.options[self.index]['selected']
            elif key == '\r': # Enter
                return {opt['id']: opt['selected'] for opt in self.options}

# --- Installer ---
class MeowInstaller:
    def __init__(self):
        real_path = os.path.realpath(__file__)
        self.script_dir = os.path.dirname(real_path)
        self.source_dir = os.path.dirname(self.script_dir) if os.path.basename(self.script_dir) == "scripts" else self.script_dir
        self.target_dir = ""
        self.conf = {
            "mode": 0, "hostname": "meowrch-machine", "username": getpass.getuser(),
            "gpu": 0, "full_update": False, "features": {}
        }

    def startup(self):
        os.system('clear')
        print(BANNER)
        print(f"{COLORS['cyan']}Welcome to Meowrch v4.4.0 (Custom Build Edition){COLORS['nc']}\n")
        usage = shutil.disk_usage("/")
        if (usage.free // (1024**3)) < 10:
            print(f"{COLORS['red']}Low disk space!{COLORS['nc']}")
            if input("Cleanup? (y/n): ") == 'y': subprocess.run(["sudo", "nix-collect-garbage", "-d"])

    def survey(self):
        print(f"\n{COLORS['yellow']}==> Configuration{COLORS['nc']}")
        self.conf["mode"] = 0 if input("Update current system? (y/n): ") == 'y' else 1
        self.target_dir = "/mnt/etc/nixos/meowrch" if self.conf["mode"] == 1 else os.path.join(os.path.expanduser("~"), "NixOS-Meowrch")
        self.conf["hostname"] = input(f"Hostname [{self.conf['hostname']}]: ") or self.conf['hostname']
        self.conf["username"] = input(f"Username [{self.conf['username']}]: ") or self.conf['username']
        
        # GPU detection
        try:
            lspci = subprocess.check_output("lspci", text=True)
            if "NVIDIA" in lspci: self.conf["gpu"] = 2
            elif "AMD" in lspci or "ATI" in lspci: self.conf["gpu"] = 0
            else: self.conf["gpu"] = 1
        except: pass
        
        # Features Picker
        picker = MeowPicker([
            {"id": "steam", "label": "Steam (Gaming)", "selected": False},
            {"id": "gamemode", "label": "Feral GameMode", "selected": False},
            {"id": "mangohud", "label": "MangoHud (FPS Counter)", "selected": False},
            {"id": "telegram", "label": "Telegram Desktop", "selected": True},
            {"id": "discord", "label": "Discord", "selected": True},
            {"id": "obsidian", "label": "Obsidian (Notes)", "selected": False},
            {"id": "flatpak", "label": "Flatpak Support", "selected": True},
            {"id": "docker", "label": "Docker Engine", "selected": False},
            {"id": "wine", "label": "Wine (Windows Apps)", "selected": False},
        ])
        self.conf["features"] = picker.pick()

    def prepare_files(self):
        logging.info("Syncing files...")
        target_abs = os.path.abspath(self.target_dir)
        if os.path.abspath(self.source_dir) != target_abs:
            os.makedirs(target_abs, exist_ok=True)
            for root, dirs, files in os.walk(self.source_dir):
                if ".git" in dirs: dirs.remove(".git")
                rel_path = os.path.relpath(root, self.source_dir)
                dest_root = os.path.join(target_abs, rel_path)
                os.makedirs(dest_root, exist_ok=True)
                for f in files:
                    rel_file = os.path.join(rel_path, f) if rel_path != "." else f
                    if rel_file in PROTECTED_FILES and os.path.exists(os.path.join(dest_root, f)): continue
                    shutil.copy2(os.path.join(root, f), os.path.join(dest_root, f))
        
        os.chdir(target_abs)
        # Write user-features.nix
        feats = self.conf["features"]
        content = "{\n  meowrch.features = {\n"
        for k, v in feats.items():
            content += f"    {k} = {'true' if v else 'false'};\n"
        content += "  };\n}\n"
        with open("hosts/meowrch/user-features.nix", "w") as f: f.write(content)

    def install(self):
        print(f"\n{COLORS['green']}Starting installation...{COLORS['nc']}")
        if not os.path.exists(".git"): subprocess.run(["git", "init", "-q"])
        subprocess.run(["git", "add", "-A", "--force"])
        env = os.environ.copy()
        env["NIXPKGS_ALLOW_UNFREE"] = "1"
        cmd = ["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"] if self.conf["mode"] == 1 else ["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"]
        subprocess.run(cmd, env=env, check=True)

if __name__ == "__main__":
    inst = MeowInstaller()
    try:
        inst.startup()
        inst.survey()
        inst.prepare_files()
        inst.install()
    except KeyboardInterrupt: print("\nAborted.")
