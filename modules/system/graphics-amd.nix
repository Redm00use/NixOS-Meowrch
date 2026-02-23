{ config, pkgs, lib, ... }:
#
# AMD GPU module
#
# Imports: graphics.nix (base) should be imported alongside this module.
#
# Provides:
#  - amdgpu kernel module in initrd
#  - AMD-specific kernel parameters
#  - AMD profiling/monitoring tools (radeontop, amdgpu_top)
#  - X11 videoDriver = "amdgpu"
#
{
  ############################################
  # Early kernel module load for amdgpu
  ############################################
  boot.initrd.kernelModules = [ "amdgpu" ];

  # X11 video driver (if X is enabled)
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

  ############################################
  # AMD kernel tuning
  ############################################
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    "amdgpu.deep_color=1"
    "amdgpu.dc=1"
  ];

  ############################################
  # AMD-specific monitoring tools
  ############################################
  environment.systemPackages = with pkgs; [
    radeontop
    amdgpu_top
  ];
}
