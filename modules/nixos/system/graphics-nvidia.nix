{
  config,
  pkgs,
  lib,
  ...
}:
#
# Nvidia GPU module
#
# Imports: graphics.nix (base) should be imported alongside this module.
#
# Provides:
#  - Nvidia proprietary driver (production branch)
#  - Modesetting, power management, open kernel module option
#  - Wayland/GBM environment variables for Nvidia
#  - nvidia-settings, nvtop monitoring tools
#
# IMPORTANT: Forces stable kernel to avoid Nvidia driver build failures
# with bleeding-edge kernels (e.g. 6.19.x breaks nvidia 580.x).
#
{
  ############################################
  # Force stable kernel for Nvidia compatibility
  # linuxPackages_latest often breaks nvidia driver builds
  ############################################
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  ############################################
  # Nvidia driver
  ############################################
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Use the stable production driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Modesetting is required for Wayland compositors (Hyprland)
    modesetting.enable = true;

    # Use the open-source kernel module (for Turing+ GPUs, i.e. RTX 20xx and newer)
    # Set to false if you have an older GPU (GTX 10xx or earlier)
    open = lib.mkDefault false;

    # Nvidia power management (helps with suspend/resume)
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Enable the nvidia-settings GUI
    nvidiaSettings = true;
  };

  ############################################
  # Nvidia kernel params
  ############################################
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  ############################################
  # Environment variables for Nvidia + Wayland
  ############################################
  environment.sessionVariables = {
    # Force GBM backend for Nvidia Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Disable hardware cursors (fixes flickering on some setups)
    WLR_NO_HARDWARE_CURSORS = "1";

    # VA-API driver for Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  ############################################
  # Nvidia-specific monitoring tools
  ############################################
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    nvidia-vaapi-driver
  ];

  ############################################
  # Nvidia VA-API support (hardware video decode)
  ############################################
  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
  ];

  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    nvidia-vaapi-driver
  ];
}
