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
    "bold": "\033[1m", "nc": "\033[0m"
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

# --- Logging Setup ---
class MeowLogger:
    def __init__(self, log_file="install.log"):
        self.log_file = log_file
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[logging.FileHandler(self.log_file, mode='w'), logging.StreamHandler(sys.stdout)]
        )
        self.logger = logging.getLogger("MeowrchInstaller")
    def info(self, msg): self.logger.info(f"{COLORS['blue']}[INFO]{COLORS['nc']} {msg}")
    def warn(self, msg): self.logger.warning(f"{COLORS['yellow']}[WARN]{COLORS['nc']} {msg}")
    def error(self, msg): self.logger.error(f"{COLORS['red']}[ERROR]{COLORS['nc']} {msg}")
    def success(self, msg): self.logger.info(f"{COLORS['green']}[SUCCESS]{COLORS['nc']} {msg}")

log = MeowLogger()

# --- Interactive Picker ---
class MeowPicker:
    def __init__(self, options, title=""):
        self.options = options
        self.title = title
        self.index = 0
    def _get_key(self):
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
            if ch == '\x1b': ch += sys.stdin.read(2)
        finally: termios.tcsetattr(fd, termios.TCSADRAIN, old)
        return ch
    def pick(self):
        while True:
            os.system('clear')
            print(BANNER)
            print(f"{COLORS['yellow']}==> {self.title} (Space to toggle, Enter to confirm){COLORS['nc']}\n")
            for i, opt in enumerate(self.options):
                prefix = f"{COLORS['cyan']}➔{COLORS['nc']}" if i == self.index else " "
                check = f"[{COLORS['green']}x{COLORS['nc']}]" if opt['selected'] else "[ ]"
                label = f"{COLORS['bold']}{opt['label']}{COLORS['nc']}" if i == self.index else opt['label']
                print(f" {prefix} {check} {label}")
            key = self._get_key()
            if key == '\x1b[A': self.index = (self.index - 1) % len(self.options)
            elif key == '\x1b[B': self.index = (self.index + 1) % len(self.options)
            elif key == ' ': self.options[self.index]['selected'] = not self.options[self.index]['selected']
            elif key == '\r': return {opt['id']: opt['selected'] for opt in self.options}

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
        print(f"{COLORS['cyan']}Meowrch Installer v4.5.0 (Ultimate Edition){COLORS['nc']}\n")
        
        # Disk Check
        usage = shutil.disk_usage("/")
        if (usage.free // (1024**3)) < 10:
            log.warn("Low disk space! Running cleanup...")
            subprocess.run(["sudo", "nix-collect-garbage", "-d"])
        
        # Dependencies
        for cmd in ["nix-env", "git", "sudo", "nix-prefetch-url", "nix-hash"]:
            if shutil.which(cmd) is None:
                log.error(f"Missing dependency: {cmd}"); sys.exit(1)
        log.info("System checks passed.")

    def update_source_hashes(self):
        log.info("Refreshing source hashes...")
        packages = [
            ("packages/meowrch-themes.nix", "meowrch-themes", "https://github.com/Meowrch/meowrch-themes", "main"),
            ("packages/meowrch-scripts.nix", "meowrch-scripts", "https://github.com/Meowrch/meowrch", "main"),
            ("pkgs/meowrch-settings/default.nix", "meowrch-settings", "https://github.com/Meowrch/meowrch-settings", "main"),
            ("pkgs/mewline/default.nix", "mewline", "https://github.com/meowrch/mewline", "v2.0.0"),
            ("pkgs/pawlette/default.nix", "pawlette", "https://github.com/Meowrch/pawlette", "main"),
        ]
        for path, name, url, branch in packages:
            fpath = os.path.join(self.source_dir, path)
            if not os.path.exists(fpath): continue
            try:
                tar = f"{url}/archive/{branch}.tar.gz"
                raw = subprocess.check_output(["nix-prefetch-url", "--unpack", tar], text=True, stderr=subprocess.DEVNULL).strip()
                sri = "sha256-" + subprocess.check_output(["nix-hash", "--to-base64", "--type", "sha256", raw], text=True, stderr=subprocess.DEVNULL).strip()
                with open(fpath, "r") as f: content = f.read()
                new = re.sub(r'(hash|sha256)\s*=\s*"sha256-[^"]+";', f'\\1 = "{sri}";', content, count=1)
                if new != content:
                    with open(fpath, "w") as f: f.write(new)
                    log.success(f"Updated {name} hash.")
            except: pass

    def survey(self):
        print(f"\n{COLORS['yellow']}==> General Configuration{COLORS['nc']}")
        modes = ["Update current system", "New installation (/mnt)"]
        self.conf["mode"] = self.ask_choice("Select mode:", modes)
        self.target_dir = "/mnt/etc/nixos/meowrch" if self.conf["mode"] == 1 else os.path.join(os.path.expanduser("~"), "NixOS-Meowrch")
        
        self.conf["hostname"] = self.ask("Hostname", self.conf["hostname"])
        self.conf["username"] = self.ask("Username", self.conf["username"])
        
        # GPU detection
        try:
            lspci = subprocess.check_output("lspci", text=True)
            if "NVIDIA" in lspci: self.conf["gpu"] = 2
            elif "AMD" in lspci or "ATI" in lspci: self.conf["gpu"] = 0
            else: self.conf["gpu"] = 1
        except: pass
        gpus = ["AMD (Mesa)", "Intel (Mesa)", "Nvidia (Proprietary)"]
        self.conf["gpu"] = self.ask_choice("Confirm GPU:", gpus)
        
        if self.conf["mode"] == 0:
            self.conf["full_update"] = self.ask("Update flakes (deep update)?", "n").lower() == 'y'

        # Features Picker
        picker = MeowPicker([
            {"id": "steam", "label": "Steam (Gaming)", "selected": False},
            {"id": "gamemode", "label": "Feral GameMode", "selected": False},
            {"id": "mangohud", "label": "MangoHud (FPS)", "selected": False},
            {"id": "telegram", "label": "Telegram Desktop", "selected": True},
            {"id": "discord", "label": "Discord", "selected": True},
            {"id": "flatpak", "label": "Flatpak Support", "selected": True},
            {"id": "docker", "label": "Docker Engine", "selected": False},
            {"id": "wine", "label": "Wine (Windows Apps)", "selected": False},
        ], title="Select Optional Features")
        self.conf["features"] = picker.pick()

    def ask(self, prompt, default=""):
        val = input(f"{COLORS['green']}? {COLORS['nc']}{prompt} [{COLORS['cyan']}{default}{COLORS['nc']}]: ").strip()
        return val if val else default

    def ask_choice(self, prompt, options):
        print(f"{COLORS['green']}? {COLORS['nc']}{prompt}")
        for i, opt in enumerate(options): print(f"  [{COLORS['cyan']}{i+1}{COLORS['nc']}] {opt}")
        while True:
            choice = input(f"{COLORS['green']}> {COLORS['nc']}").strip()
            if choice.isdigit() and 0 < int(choice) <= len(options): return int(choice)-1

    def prepare_files(self):
        log.info("Syncing and protecting files...")
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
                    dst_file = os.path.join(dest_root, f)
                    if rel_file in PROTECTED_FILES and os.path.exists(dst_file):
                        log.info(f"Preserving: {rel_file}"); continue
                    shutil.copy2(os.path.join(root, f), dst_file)
        
        os.chdir(target_abs)
        # user-local.nix
        if not os.path.exists("hosts/meowrch/user-local.nix"):
            with open("hosts/meowrch/user-local.nix", "w") as f:
                f.write(f'{{\n  meowrch.user = "{self.conf["username"]}";\n  meowrch.hostname = "{self.conf["hostname"]}";\n}}\n')
        
        # user-features.nix
        feats = self.conf["features"]
        content = "{\n  meowrch.features = {\n"
        for k, v in feats.items(): content += f"    {k} = {'true' if v else 'false'};\n"
        content += "  };\n}\n"
        with open("hosts/meowrch/user-features.nix", "w") as f: f.write(content)

        # Patch GPU and Nvidia License
        conf_nix = "hosts/meowrch/configuration.nix"
        gpu_map = {0: "graphics-amd.nix", 1: "graphics-intel.nix", 2: "graphics-nvidia.nix"}
        gpu_file = gpu_map[self.conf["gpu"]]
        with open(conf_nix, "r") as f: lines = f.readlines()
        lines = [l for l in lines if "nvidia.acceptLicense = true" not in l]
        with open(conf_nix, "w") as f:
            for line in lines:
                if "GPU_MODULE_LINE" in line:
                    f.write(f"      ../../modules/nixos/system/{gpu_file} # GPU_MODULE_LINE\n")
                elif self.conf["gpu"] == 2 and "allowUnfreePredicate" in line:
                    f.write(line); f.write("    nvidia.acceptLicense = true;\n")
                else: f.write(line)
        if self.conf["gpu"] == 2:
            flake_nix = "flake.nix"
            with open(flake_nix, "r") as f: f_lines = f.readlines()
            f_lines = [l for l in f_lines if "config.nvidia.acceptLicense = true" not in l]
            inserted = False
            with open(flake_nix, "w") as f:
                for line in f_lines:
                    f.write(line)
                    if "config.allowUnfree = true;" in line and not inserted:
                        f.write("      config.nvidia.acceptLicense = true;\n"); inserted = True

    def generate_hardware_config(self):
        hw_path = "hosts/meowrch/hardware-configuration.nix"
        if os.path.exists(hw_path) and self.conf["mode"] == 0: return
        log.info("Generating hardware config...")
        cmd = "sudo nixos-generate-config --show-hardware-config"
        if self.conf["mode"] == 1: cmd += " --root /mnt"
        try:
            res = subprocess.run(cmd, shell=True, text=True, capture_output=True)
            with open(hw_path, "w") as f: f.write(res.stdout)
        except: pass

    def install(self):
        if self.conf["full_update"]: run_command("nix flake update")
        if not os.path.exists(".git"): run_command("git init -q")
        run_command("git add -A --force")
        env = os.environ.copy(); env["NIXPKGS_ALLOW_UNFREE"] = "1"
        try:
            cmd = ["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"] if self.conf["mode"] == 1 else ["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"]
            subprocess.run(cmd, env=env, check=True)
            log.success("Complete! Reboot now.")
        except: log.error("Failed."); sys.exit(1)

if __name__ == "__main__":
    inst = MeowInstaller()
    try:
        inst.startup()
        inst.update_source_hashes()
        inst.survey()
        inst.prepare_files()
        inst.generate_hardware_config()
        inst.install()
    except KeyboardInterrupt: sys.exit(0)
