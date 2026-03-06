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
        if e.output: log.error(f"Output: {e.output}")
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
                if 0 <= idx < len(options):
                    return idx
            print(f"{COLORS['red']}Invalid selection. Try again.{COLORS['nc']}")
        except EOFError:
            return 0

# --- Installer Class ---
class MeowInstaller:
    def __init__(self):
        real_script_path = os.path.realpath(__file__)
        self.script_dir = os.path.dirname(real_script_path)
        
        if os.path.basename(self.script_dir) == "scripts":
            self.source_dir = os.path.dirname(self.script_dir)
        else:
            self.source_dir = self.script_dir
            
        self.target_dir = ""
        self.conf = {
            "mode": 0,
            "hostname": "meowrch-machine",
            "username": getpass.getuser(),
            "gpu": 0
        }

    def startup(self):
        os.system('clear')
        print(BANNER)
        print(f"{COLORS['cyan']}Welcome to Meowrch NixOS Python Installer v4.1.0 (Auto-Hash Edition){COLORS['nc']}\n")
        
        if not os.path.exists("/etc/NIXOS"):
            log.warn("This doesn't look like NixOS. Proceed with caution.")
        
        for cmd in ["nix-env", "git", "sudo", "nix-prefetch-url", "nix-hash"]:
            if shutil.which(cmd) is None:
                log.error(f"Required command '{cmd}' not found. Please install it first.")
                sys.exit(1)
        
        log.info("System checks passed.")

    def update_source_hashes(self):
        log.info("Refreshing source hashes to prevent 'hash mismatch' errors...")
        
        packages_to_update = [
            # (File, Package Name, Repo URL, Branch/Tag)
            ("packages/meowrch-themes.nix", "meowrch-themes", "https://github.com/Meowrch/meowrch-themes", "main"),
            ("packages/meowrch-scripts.nix", "meowrch-scripts", "https://github.com/Meowrch/meowrch", "main"),
            ("pkgs/meowrch-settings/default.nix", "meowrch-settings", "https://github.com/Meowrch/meowrch-settings", "main"),
            ("pkgs/mewline/default.nix", "mewline", "https://github.com/meowrch/mewline", "v2.0.0"),
            ("pkgs/pawlette/default.nix", "pawlette", "https://github.com/Meowrch/pawlette", "main"),
        ]

        for rel_path, pkg_name, repo_url, branch in packages_to_update:
            file_path = os.path.join(self.source_dir, rel_path)
            if not os.path.exists(file_path):
                continue

            tar_url = f"{repo_url}/archive/{branch}.tar.gz"
            log.info(f"Fetching latest hash for {pkg_name}...")
            
            try:
                # Fetch raw hash
                raw_hash = subprocess.check_output(
                    ["nix-prefetch-url", "--unpack", tar_url],
                    text=True, stderr=subprocess.DEVNULL
                ).strip()
                
                # Convert to SRI format (sha256-...)
                sri_hash = "sha256-" + subprocess.check_output(
                    ["nix-hash", "--to-base64", "--type", "sha256", raw_hash],
                    text=True, stderr=subprocess.DEVNULL
                ).strip()

                # Update the file
                with open(file_path, "r") as f:
                    content = f.read()
                
                # Find 'hash = "..." ' or 'sha256 = "..." '
                # We prioritize the first one found in the stdenv.mkDerivation block
                new_content = re.sub(r'(hash|sha256)\s*=\s*"sha256-[^"]+";', f'\\1 = "{sri_hash}";', content, count=1)
                
                if new_content != content:
                    with open(file_path, "w") as f:
                        f.write(new_content)
                    log.success(f"Updated hash for {pkg_name} in {rel_path}")
                else:
                    log.info(f"Hash for {pkg_name} is already up to date or file format mismatch.")

            except Exception as e:
                log.warn(f"Could not update hash for {pkg_name}: {str(e)}")

    def survey(self):
        print(f"\n{COLORS['yellow']}==> Configuration Survey{COLORS['nc']}")
        
        modes = ["Apply to current system (Update)", "Install to new disk (Bootstrap /mnt)"]
        self.conf["mode"] = ask_choice("Choose installation mode:", modes)

        if self.conf["mode"] == 1:
            if not os.path.exists("/mnt/etc"):
                log.error("/mnt is not mounted or empty. Please mount your partitions first if you are bootstraping.")
                sys.exit(1)
            self.target_dir = "/mnt/etc/nixos/meowrch"
        else:
            if os.path.exists("/mnt/etc"):
                log.warn("Detected mounted /mnt. If you manually partitioned, you should choose 'Bootstrap /mnt' instead of 'Update'.")
            self.target_dir = os.path.join(os.path.expanduser("~"), "NixOS-Meowrch")

        self.conf["hostname"] = ask("Enter Hostname", self.conf["hostname"])
        self.conf["username"] = ask("Enter Username", self.conf["username"])
        
        gpus = ["AMD (Recommended)", "Intel", "Nvidia (Proprietary)"]
        self.conf["gpu"] = ask_choice("Select GPU Driver:", gpus)

        print(f"\n{COLORS['yellow']}==> Summary{COLORS['nc']}")
        print(f"  Mode:     {modes[self.conf['mode']]}")
        print(f"  Target:   {self.target_dir}")
        print(f"  Hostname: {self.conf['hostname']}")
        print(f"  User:     {self.conf['username']}")
        print(f"  GPU:      {gpus[self.conf['gpu']]}")
        
        if ask("Proceed with installation?", "y").lower() != 'y':
            log.info("Installation aborted by user.")
            sys.exit(0)

    def prepare_files(self):
        log.info("Preparing files...")
        target_abs = os.path.abspath(self.target_dir)
        
        if os.path.abspath(self.source_dir) == target_abs:
            log.info("Already in target directory. Skipping copy.")
        else:
            if os.path.exists(target_abs):
                log.info(f"Cleaning existing directory {target_abs}...")
                if target_abs == "/" or target_abs == os.path.expanduser("~"):
                    log.error("Safety trigger: Target is root or home. Aborting.")
                    sys.exit(1)
                shutil.rmtree(target_abs)
            
            os.makedirs(os.path.dirname(target_abs), exist_ok=True)
            log.info(f"Copying files from {self.source_dir} to {target_abs}...")
            shutil.copytree(
                self.source_dir, 
                target_abs, 
                symlinks=True, 
                ignore=shutil.ignore_patterns('.git', 'install.log', '__pycache__')
            )

        os.chdir(target_abs)
        
        # Write user-local.nix
        user_local_path = "hosts/meowrch/user-local.nix"
        content = f"""# This file is auto-generated by Meowrch Installer.
{{
  meowrch.user = "{self.conf['username']}";
  meowrch.hostname = "{self.conf['hostname']}";
}}
"""
        with open(user_local_path, "w") as f:
            f.write(content)
        log.info(f"Generated {user_local_path}")

        # GPU Patching
        conf_nix = "hosts/meowrch/configuration.nix"
        flake_nix = "flake.nix"
        gpu_map = {0: "graphics-amd.nix", 1: "graphics-intel.nix", 2: "graphics-nvidia.nix"}
        gpu_file = gpu_map[self.conf["gpu"]]
        
        # Patch configuration.nix
        with open(conf_nix, "r") as f: lines = f.readlines()
        lines = [l for l in lines if "nvidia.acceptLicense = true" not in l]
        with open(conf_nix, "w") as f:
            for line in lines:
                if "GPU_MODULE_LINE" in line:
                    f.write(f"      ../../modules/nixos/system/{gpu_file} # GPU_MODULE_LINE\n")
                elif self.conf["gpu"] == 2 and "allowUnfreePredicate" in line:
                    f.write(line)
                    f.write("    nvidia.acceptLicense = true;\n")
                else: f.write(line)
        
        # Patch flake.nix for Nvidia
        if self.conf["gpu"] == 2:
            with open(flake_nix, "r") as f: f_lines = f.readlines()
            f_lines = [l for l in f_lines if "config.nvidia.acceptLicense = true" not in l]
            inserted = False
            with open(flake_nix, "w") as f:
                for line in f_lines:
                    f.write(line)
                    if "config.allowUnfree = true;" in line and not inserted:
                        f.write("      config.nvidia.acceptLicense = true;\n")
                        inserted = True
        
        log.info(f"Patched configuration for {gpu_file}")

        if os.path.exists("scripts"):
            for root, dirs, files in os.walk("scripts"):
                for f in files: os.chmod(os.path.join(root, f), 0o755)

    def generate_hardware_config(self):
        log.info("Generating hardware configuration (requires sudo)... ")
        hw_path = "hosts/meowrch/hardware-configuration.nix"
        cmd = "sudo nixos-generate-config --show-hardware-config"
        if self.conf["mode"] == 1: cmd += " --root /mnt"
        
        try:
            result = subprocess.run(cmd, shell=True, text=True, capture_output=True, check=False)
            if result.returncode != 0 and not result.stdout.strip():
                log.error(f"nixos-generate-config failed: {result.stderr}")
                sys.exit(1)
            if "Failed to retrieve subvolume info" in result.stderr:
                log.warn("Btrfs subvolume warning detected, but proceeding.")
            with open(hw_path, "w") as f: f.write(result.stdout)
            log.success(f"Hardware configuration saved to {hw_path}")
        except Exception as e:
            log.error(f"Failed to generate hardware config: {str(e)}")
            sys.exit(1)

    def install(self):
        log.info("Starting installation phase...")
        if not os.path.exists(".git"): run_command("git init -q")
        run_command("git add -A --force")
        env = os.environ.copy()
        env["NIXPKGS_ALLOW_UNFREE"] = "1"
        
        try:
            if self.conf["mode"] == 1:
                subprocess.run(["sudo", "nixos-install", "--flake", ".#meowrch", "--root", "/mnt", "--impure"], env=env, check=True)
            else:
                subprocess.run(["sudo", "nixos-rebuild", "boot", "--flake", ".#meowrch", "--impure"], env=env, check=True)
            log.success("Action complete! Please reboot.")
        except subprocess.CalledProcessError:
            log.error("The installation command failed.")
            sys.exit(1)

def main():
    installer = MeowInstaller()
    try:
        installer.startup()
        installer.update_source_hashes() # New step: Auto-hash update
        installer.survey()
        installer.prepare_files()
        installer.generate_hardware_config()
        installer.install()
    except KeyboardInterrupt:
        print(f"\n{COLORS['red']}Installation cancelled.{COLORS['nc']}")
        sys.exit(0)
    except Exception as e:
        log.error(f"Unexpected error: {str(e)}")
        import traceback
        log.error(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    main()
