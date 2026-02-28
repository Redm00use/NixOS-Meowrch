{ config, pkgs, lib, ... }:
#
# Graphics / GPU base module (shared across all GPU vendors)
#
# Responsibilities:
#  - Enable unified graphics stack (OpenGL + Vulkan + 32-bit for gaming)
#  - Common tooling, debugging, wayland utilities
#  - Scanner support (sane) — hardware concern
#  - Common kernel tuning (vm.max_map_count, tmpfiles)
#
# GPU-specific settings (drivers, kernel modules, vendor tools)
# are in graphics-amd.nix / graphics-nvidia.nix / graphics-intel.nix
#
{
  ############################################
  # Modern graphics stack with 32-bit support
  ############################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      libva
      libva-utils
      libdrm
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
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
  # Common userland tooling / diagnostics
  ############################################
  environment.systemPackages = with pkgs; [
    # Capability / info (glxinfo is part of mesa-demos)
    vulkan-tools
    mesa-demos
    gpu-viewer
    glmark2

    # Performance / overlays
    mangohud
    goverlay

    # Wayland utilities
    wlr-randr
    wayland-utils

    # Debugging & tracing
    renderdoc
    apitrace

    # Development libs
    libGL
    libGLU
    wayland
    wayland-protocols

    # Hyprland / wlroots helper libs
    seatd
    libinput
    libxkbcommon
    xorg.libxcb
    pipewire
    libgbm
  ];

  ############################################
  # Common runtime filesystem expectations
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

  # Generic DRM helpers
  boot.kernelModules = [
    "drm"
    "drm_kms_helper"
  ];
}
