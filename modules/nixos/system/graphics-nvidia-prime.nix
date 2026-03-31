{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./graphics-nvidia.nix ];

  hardware.nvidia.prime = {
    sync.enable = lib.mkDefault true;
    intelBusId = lib.mkDefault "PCI:0:2:0";
    nvidiaBusId = lib.mkDefault "PCI:1:0:0";
  };

  warnings = [
    "NVIDIA PRIME profile enabled. Verify and adjust bus IDs in modules/nixos/system/graphics-nvidia-prime.nix for your laptop before applying the configuration."
  ];
}
