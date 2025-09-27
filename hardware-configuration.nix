{ config, lib, pkgs, modulesPath, ... }:

# =============================================================================
#  Placeholder hardware-configuration.nix
#  This file MUST be edited to match your actual hardware before building.
#  Generated as a template. Replace all REPLACE-WITH-* UUID markers.
# =============================================================================

{
  imports = [
    # Pull in defaults for hardware bits not auto-detected here.
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ---------------------------------------------------------------------------
  #  Initrd: Add only modules needed to find / (root) + early disk drivers.
  #  Trim this list after confirming with: lsmod | awk '{print $1}'.
  # ---------------------------------------------------------------------------
  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];

  # ---------------------------------------------------------------------------
  #  CPU virtualization module:
  #    * For AMD CPUs: kvm-amd
  #    * For Intel CPUs: replace with kvm-intel
  # ---------------------------------------------------------------------------
  boot.kernelModules = [ "kvm-amd" ]; # TODO: change to "kvm-intel" if Intel
  boot.extraModulePackages = [ ];

  # ---------------------------------------------------------------------------
  #  Root filesystem
  #    Replace UUIDs with values from: lsblk -f   or   blkid
  #    If using btrfs with subvolumes, adapt options and add subvolume lines.
  # ---------------------------------------------------------------------------
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ROOT-UUID"; # TODO
    fsType = "ext4"; # TODO: ext4 | btrfs | xfs | zfs (if zfs, enable module)
    # For btrfs example:
    # options = [ "subvol=@" "compress=zstd" "ssd" "noatime" ];
  };

  # ---------------------------------------------------------------------------
  #  EFI system partition (ESP)
  # ---------------------------------------------------------------------------
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-EFI-UUID"; # TODO
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # ---------------------------------------------------------------------------
  #  Optional separate /home
  # ---------------------------------------------------------------------------
  # fileSystems."/home" = {
  #   device = "/dev/disk/by-uuid/REPLACE-WITH-HOME-UUID";
  #   fsType = "ext4";
  # };

  # ---------------------------------------------------------------------------
  #  Swap: Uncomment if you use a swap partition or swapfile.
  # ---------------------------------------------------------------------------
  swapDevices = [
    # { device = "/dev/disk/by-uuid/REPLACE-WITH-SWAP-UUID"; }
  ];

  # For a swapfile (example):
  # swapDevices = [
  #   { device = "/swapfile"; size = 8192; }  # size in MB
  # ];

  # ---------------------------------------------------------------------------
  #  Filesystem performance / mount options suggestions (uncomment & adapt)
  # ---------------------------------------------------------------------------
  # fileSystems."/".options = [ "noatime" "discard=async" ];

  # ---------------------------------------------------------------------------
  #  GPU Notes:
  #    AMD path handled in main configuration (graphics module).
  #    For NVIDIA (coming soon) you would add:
  #      services.xserver.videoDrivers = [ "nvidia" ];
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  #  Host platform - keep consistent with flake system
  # ---------------------------------------------------------------------------
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ---------------------------------------------------------------------------
  #  Optional: Firmware loading (already enabled globally; keep minimal here)
  # ---------------------------------------------------------------------------
  # hardware.enableRedistributableFirmware = lib.mkDefault true;

  # ---------------------------------------------------------------------------
  #  NIC naming / predictable network interface examples:
  # ---------------------------------------------------------------------------
  # networking.usePredictableInterfaceNames = true;
  # networking.interfaces.enp3s0.useDHCP = true;
  # networking.interfaces.wlp2s0.useDHCP = true;

  # ---------------------------------------------------------------------------
  #  ZFS / LVM / RAID placeholders (add only if used)
  # ---------------------------------------------------------------------------
  # boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.devNodes = "/dev/disk/by-id";
  # services.zfs.autoScrub.enable = true;

  # ---------------------------------------------------------------------------
  #  Validation helper:
  #    After filling UUIDs run:
  #      nix eval .#nixosConfigurations.meowrch.config.system.build.toplevel.drvPath
  # ---------------------------------------------------------------------------
}
