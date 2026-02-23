{ config, pkgs, lib, ... }:
#
# Graphics / GPU module (AMD-focused)
#
# Responsibilities:
#  - Enable unified graphics stack (OpenGL + Vulkan + 32‑bit for gaming)
#  - Provide useful tooling (debug, profiling, benchmarking)
#  - Basic kernel / initrd requirements (amdgpu in initrd)
#  - Scanner support (sane) – kept here as a “hardware” concern
#
# Exclusions (handled elsewhere):
#  - Firmware enabling (done globally in configuration.nix)
#  - Global GPU env variables (LIBVA_DRIVER_NAME, VDPAU_DRIVER, etc.)
#  - Gamemode / Steam (declared in root config)
#
# Safe to import on non‑AMD hosts (amdgpu module load will simply no‑op if unsupported).
{
  ############################################
  # Modern graphics stack with 32‑bit support
  ############################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      amdvlk                  # AMD Vulkan ICD (RADV also available via mesa)
      libva
      libva-utils
      libdrm
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
      amdvlk
    ];
  };

  ############################################
  # Scanner support (hardware capability)
  ############################################
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplip
      sane-airscan
    ];
  };

  ############################################
  # Early kernel module load for amdgpu
  ############################################
  boot.initrd.kernelModules = [ "amdgpu" ];

  # X11 video driver only if X is enabled elsewhere
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

  ############################################
  # Userland tooling / diagnostics
  ############################################
  environment.systemPackages = with pkgs; [
    # Capability / info
    glxinfo
    vulkan-tools
    mesa-demos
    gpu-viewer
    glmark2

    # Performance / overlays
    mangohud
    goverlay
    radeontop
    amdgpu_top

    # Wayland utilities
    wlr-randr
    wayland-utils

    # Debugging & tracing
    renderdoc
    apitrace

    # Development libs (some consumers expect these explicitly)
    libGL
    libGLU
    wayland
    wayland-protocols

    # Hyprland / wl roots related helper libs (some compositions depend on them)
    seatd
    libinput
    libxkbcommon
    xorg.libxcb
    pipewire
    libgbm
  ];

  ############################################
  # Kernel tuning / parameters (non‑duplicated)
  ############################################
  boot.kernelParams = [
    # AMD feature mask (enables full power features; adjust if unstable)
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    "amdgpu.deep_color=1"
    "amdgpu.dc=1"
  ];

  # Generic DRM helpers (usually auto‑loaded, but explicit for determinism)
  boot.kernelModules = [
    "drm"
    "drm_kms_helper"
  ];

  ############################################
  # Runtime filesystem expectations (some legacy apps)
  ############################################
  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root 10d"
    "d /tmp/.ICE-unix 1777 root root 10d"
  ];

  ############################################
  # Increase virtual memory map count (large games / proton)
  ############################################
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
}
