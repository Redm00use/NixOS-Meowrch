{ config, pkgs, lib, ... }:
#
# Intel GPU module
#
# Imports: graphics.nix (base) should be imported alongside this module.
#
# Provides:
#  - Intel i915 kernel module
#  - Intel VA-API (hardware video decode)
#  - Intel-specific monitoring (intel-gpu-tools)
#
{
  ############################################
  # Early kernel module load for Intel GPU
  ############################################
  boot.initrd.kernelModules = [ "i915" ];

  # X11 video driver (if X is enabled)
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "modesetting" ];

  ############################################
  # Intel kernel tuning
  ############################################
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.fastboot=1"
  ];

  ############################################
  # Intel VA-API (hardware video acceleration)
  ############################################
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver    # iHD driver (Broadwell+, recommended)
    intel-vaapi-driver    # i965 driver (older GPUs fallback)
    libva-vdpau-driver    # VDPAU backend for VA-API
    libvdpau-va-gl        # VDPAU via VA-API
    vpl-gpu-rt            # Intel oneVPL GPU runtime
  ];

  ############################################
  # Environment variables for Intel VA-API
  ############################################
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";  # Use intel-media-driver (Broadwell+)
    # For older GPUs, change to "i965"
  };

  ############################################
  # Intel-specific monitoring tools
  ############################################
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];
}
