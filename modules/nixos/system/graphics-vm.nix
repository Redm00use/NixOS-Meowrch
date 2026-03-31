{ config, pkgs, lib, ... }:
{
  services.xserver.videoDrivers = [ "modesetting" "qxl" "vmware" ];

  boot.initrd.kernelModules = [
    "virtio_gpu"
    "virtio_pci"
    "virtio_balloon"
  ];

  services.spice-vdagentd.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    spice-vdagent
    virtiofsd
  ];

  environment.sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = lib.mkDefault "0";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  warnings = [
    "Virtual machine graphics profile enabled. Best results are typically with virtio-gpu + SPICE/QXL or VMware graphics."
  ];
}
