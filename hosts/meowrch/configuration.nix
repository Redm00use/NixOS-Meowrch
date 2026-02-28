# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    СИСТЕМНАЯ КОНФИГУРАЦИЯ MEOWRCH                        ║
# ║                         Оптимизировано для NixOS                         ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{ config, pkgs, inputs, lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ────────────── Импорты модулей ──────────────
  imports =
    let
      hardwareConfigPath =
        lib.findFirst (path: lib.pathExists path) null [
          ./hardware-configuration.nix
          /etc/nixos/hardware-configuration.nix
        ];
    in
    ([
      ../../modules/nixos/system/audio.nix
      ../../modules/nixos/system/bluetooth.nix
      ../../modules/nixos/system/graphics.nix
      ../../modules/nixos/system/graphics-amd.nix # GPU_MODULE_LINE
      ../../modules/nixos/system/networking.nix
      ../../modules/nixos/system/security.nix
      ../../modules/nixos/system/services.nix
      ../../modules/nixos/system/fonts.nix
      ../../modules/nixos/desktop/sddm.nix
      ../../modules/nixos/desktop/theming.nix
      ../../modules/nixos/packages/packages.nix
      ../../modules/nixos/packages/flatpak.nix
    ]
    ++ lib.optional (hardwareConfigPath != null) hardwareConfigPath
    ++ lib.optional (hardwareConfigPath == null) {
      fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
      boot.loader.grub.devices = [ "/dev/nodevice" ];
    }
    );

  # ────────────── Ядро системы ──────────────
  system.stateVersion = "25.11";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      substituters = [ "https://cache.nixos.org/" "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ────────────── Загрузка и Ядро ──────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    kernelParams = [ "quiet" "splash" ];
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  # ────────────── Пользователи ──────────────
  users = {
    defaultUserShell = pkgs.fish;
    users.meowrch = {
      isNormalUser = true;
      description = "Meowrch User";
      group = "meowrch";
      initialPassword = "1";
      extraGroups = [
        "wheel" "networkmanager" "audio" "video" "storage"
        "optical" "scanner" "power" "input" "uucp" "bluetooth"
        "render" "libvirtd"
      ];
      shell = pkgs.fish;
    };
    groups.meowrch = {};
  };

  # ────────────── Окружение ──────────────
  environment = {
    sessionVariables = {
      EDITOR = "zed";
      VISUAL = "zed";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    shellAliases = {
      cls = "clear";
      ll = "ls -la";
      g = "git";
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      u = "cd ~/NixOS-Meowrch && git pull && ./scripts/update-pkg-hashes.sh && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
      update-pkgs = "cd ~/NixOS-Meowrch && ./scripts/update-pkg-hashes.sh && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
      clean = "sudo nix-collect-garbage -d";
    };
  };

  # ────────────── Программы ──────────────
  programs = {
    fish.enable = true;
    dconf.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    gamemode.enable = true;
  };

  # ────────────── Локализация ──────────────
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ────────────── Оптимизация ──────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # ────────────── Системные сервисы ──────────────
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
