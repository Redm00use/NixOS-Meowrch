#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import logging
import getpass
import re

# --- Configuration & Aesthetics ---
COLORS = {
    "red": "\033[0;31m",
    "green": "\033[0;32m",
    "blue": "\033[0;34m",
    "cyan": "\033[0;36m",
    "yellow": "\033[1;33m",
    "purple": "\033[0;35m",
    "bold": "\033[1m",
    "nc": "\033[0m"
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
    "hosts/meowrch/user-local.nix",
    "hosts/meowrch/user-packages.nix",
    "hosts/meowrch/hardware-configuration.nix",
    "config/hypr/monitors.conf",
    "config/hypr/userprefs.conf"
]

# --- Logging Setup ---
class MeowLogger:
    def __init__(self, log_file="install.log"):
        self.log_file = log_file
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[
                logging.FileHandler(self.log_file, mode='w'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger("MeowrchInstaller")

    def info(self, msg): self.logger.info(f"{COLORS['blue']}[INFO]{COLORS['nc']} {msg}")
    def warn(self, msg): self.logger.warning(f"{COLORS['yellow']}[WARN]{COLORS['nc']} {msg}")
    def error(self, msg): self.logger.error(f"{COLORS['red']}[ERROR]{COLORS['nc']} {msg}")
    def success(self, msg): self.logger.info(f"{COLORS['green']}[SUCCESS]{COLORS['nc']} {msg}")

log = MeowLogger()

# --- Utilities ---
def run_command(cmd, shell=True, check=True, capture_output=False, env=None):
    try:
        result = subprocess.run(
            cmd, shell=shell, check=check, 
            text=True, capture_output=capture_output, env=env
        )
        return result
    except subprocess.CalledProcessError as e:
        log.error(f"Command failed: {cmd}\nExit code: {e.returncode}")
        if check: sys.exit(1)
        return e

def ask(prompt, default=""):
    try:
        val = input(f"{COLORS['green']}? {COLORS['nc']}{prompt} [{COLORS['cyan']}{default}{COLORS['nc']}]: ").strip()
        return val if val else default
    except EOFError:
        return default

def ask_choice(prompt, options):
    print(f"{COLORS['green']}? {COLORS['nc']}{prompt}")
    for i, opt in enumerate(options):
        print(f"  [{COLORS['cyan']}{i+1}{COLORS['nc']}] {opt}")
    while True:
        try:
            choice = input(f"{COLORS['green']}> {COLORS['nc']}").strip()
            if choice.isdigit():
                idx = int(choice) - 1
                if 0 <= idx < len(options): return idx
            print(f"{COLORS['red']}Invalid selection.{COLORS['nc']}")
        except EOFError: return 0

# --- Installer Class ---
class MeowInstaller:
    def __init__(self):
        real_path = os.path.realpath(__file__)
        self.script_dir = os.path.dirname(real_path)
        self.source_dir = os.path.dirname(self.script_dir) if os.path.basename(self.script_dir) == "scripts" else self.script_dir
        self.target_dir = ""
        self.conf = {
            "mode": 0, "hostname": "meowrch-machine", "username": getpass.getuser(),
            "gpu": 0, "full_update": False
        }

    def startup(self):
        os.system('clear')
        print(BANNER)
        print(f"{COLORS['cyan']}Meowrch NixOS Installer v4.3.0 (Resource Guard Edition){COLORS['nc']}\n")
        
        # Check Disk Space
        usage = shutil.disk_usage("/")
        free_gb = usage.free // (1024**3)
        log.info(f"Free space: {free_gb} GB")
        if free_gb < 10:
            log.warn("Low disk space! Nix builds might fail.")
            if ask("Run garbage collection to free space?", "y").lower() == 'y':
                log.info("Cleaning up old generations...")
                subprocess.run(["sudo", "nix-collect-garbage", "-d"])

    def detect_gpu(self):
        try:
            lspci = subprocess.check_output("lspci", text=True)
            if "NVIDIA" in lspci: self.conf["gpu"] = 2
            elif "AMD" in lspci or "ATI" in lspci: self.conf["gpu"] = 0
            elif "Intel" in lspci: self.conf["gpu"] = 1
        except: pass

    def survey(self):
        print(f"\n{COLORS['yellow']}==> Survey{COLORS['nc']}")
        modes = ["Update current system", "New installation (/mnt)"]
        self.conf["mode"] = ask_choice("Mode:", modes)
        self.target_dir = "/mnt/etc/nixos/meowrch" if self.conf["mode"] == 1 else os.path.join(os.path.expanduser("~"), "NixOS-Meowrch")
        
        self.conf["hostname"] = ask("Hostname", self.conf["hostname"])
        self.conf["username"] = ask("Username", self.conf["username"])
        
        self.detect_gpu()
        gpus = ["AMD", "Intel", "Nvidia"]
        self.conf["gpu"] = ask_choice("Confirm GPU:", gpus)
        
        if self.conf["mode"] == 0:
            self.conf["full_update"] = ask("Perform full update (nix flake update)?", "n").lower() == 'y'

        print(f"\n{COLORS['bold']}SUMMARY{COLORS['nc']}")
        print(f"  Target:   {self.target_dir}")
        print(f"  GPU:      {gpus[self.conf['gpu']]}")
        print(f"  Update:   {'Deep (update flakes)' if self.conf['full_update'] else 'Standard'}")
        
        if ask("Proceed?", "y").lower() != 'y': sys.exit(0)

    def prepare_files(self):
        log.info("Syncing files...")
        target_abs = os.path.abspath(self.target_dir)
        if os.path.abspath(self.source_dir) != target_abs:
            os.makedirs(target_abs, exist_ok=True)
            for root, dirs, files in os.walk(self.source_dir):
                if ".git" in dirs: dirs.remove(".git")
                if "__pycache__" in dirs: dirs.remove("__pycache__")
                rel_path = os.path.relpath(root, self.source_dir)
                dest_root = os.path.join(target_abs, rel_path)
                os.makedirs(dest_root, exist_ok=True)
                for f in files:
                    rel_file = os.path.join(rel_path, f) if rel_path != "." else f
                    if rel_file in PROTECTED_FILES and os.path.exists(os.path.join(dest_root, f)):
                        continue
                    shutil.copy2(os.path.join(root, f), os.path.join(dest_root, f))
        os.chdir(target_abs)

    def install(self):
        if self.conf["full_update"]:
            log.info("Updating flake inputs (this may take a while)...")
            run_command("nix flake update")
            
        if not os.path.exists(".git"): run_command("git init -q")
        run_command("git add -A --force")
        
        env = os.environ.copy()
        env["NIXPKGS_ALLOW_UNFREE"] = "1"
        try:
            if self.conf["mode"] == 1:
                subprocess.run(["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"], env=env, check=True)
            else:
                subprocess.run(["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"], env=env, check=True)
            log.success("Success! Please reboot.")
        except:
            log.error("Failed.")
            sys.exit(1)

def main():
    installer = MeowInstaller()
    try:
        installer.startup()
        installer.survey()
        installer.prepare_files()
        installer.install()
    except KeyboardInterrupt: sys.exit(0)
    except Exception as e:
        log.error(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__": main()
