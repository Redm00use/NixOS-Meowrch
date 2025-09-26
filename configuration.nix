{ config, pkgs, inputs, lib, ... }:

{
  ############################################
  # Imports (hardware file imported if exists)
  ############################################
  imports =
    ([
      # System / hardware related modules
      ./modules/system/audio.nix
      ./modules/system/bluetooth.nix
      ./modules/system/graphics.nix
      ./modules/system/networking.nix
      ./modules/system/security.nix
      ./modules/system/services.nix
      ./modules/system/fonts.nix

      # Desktop / theming
      ./modules/desktop/sddm.nix
      ./modules/desktop/theming.nix

      # Packages
      ./modules/packages/packages.nix
      ./modules/packages/flatpak.nix
    ]
    ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    );

  ############################################
  # Core system
  ############################################
  system.stateVersion = "25.05";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
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

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  ############################################
  # Boot / Kernel
  ############################################
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    kernelParams = [
      "quiet"
      "splash"
      "mitigations=off"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth = {
      enable = true;
      theme = "spinner";
    };
  };

  # Firmware (единственная декларация)
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Users
  ############################################
  users = {
    defaultUserShell = pkgs.fish;
    users.meowrch = {
      isNormalUser = true;
      description = "Meowrch User";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "storage"
        "optical"
        "scanner"
        "power"
        "input"
        "uucp"
        "bluetooth"
        "render"
        "docker"
        "libvirtd"
      ];
      shell = pkgs.fish;
    };
  };

  ############################################
  # Environment
  ############################################
  environment = {
    systemPackages = with pkgs; [
      # Core tools
      wget curl git vim nano tree file which
      htop btop fastfetch unzip unrar p7zip
      # Dev
      gcc clang cmake gnumake
      python3 python3Packages.pip nodejs
      # Hardware / sys
      usbutils pciutils lshw dmidecode
      parted gparted
      # Media / file
      kdePackages.ark ranger nemo
      # Network / ssh
      networkmanager openssh
      # Multimedia
      ffmpeg imagemagick
      # Graphics utils
      glxinfo vulkan-tools mesa-demos
      # Misc
      polkit_gnome earlyoom
      radeontop
    ];

    sessionVariables = {
      # XDG
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";

      # Apps
      EDITOR = "micro";
      VISUAL = "micro";
      BROWSER = "firefox";
      TERMINAL = "kitty";

      # Wayland / Qt
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "1";

      # AMD GPU
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
      AMD_VULKAN_ICD = "RADV";

      # Java
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dsun.java2d.opengl=true";
    };

    shellAliases = {
      cls = "clear";
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      n = "nvim";
      m = "micro";
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
    };
  };

  ############################################
  # Programs
  ############################################
  programs = {
    fish.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode.enable = true;
  };

  ############################################
  # Services (basic)
  ############################################
  services = {
    xserver.enable = false;
    earlyoom.enable = true;
  };

  ############################################
  # Security
  ############################################
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo = {
      enable = true;
      extraRules = [{
        commands = [
          { command = "${pkgs.systemd}/bin/systemctl suspend";  options = [ "NOPASSWD" ]; }
          { command = "${pkgs.systemd}/bin/reboot";            options = [ "NOPASSWD" ]; }
          { command = "${pkgs.systemd}/bin/poweroff";          options = [ "NOPASSWD" ]; }
        ];
        groups = [ "wheel" ];
      }];
    };
  };

  ############################################
  # Locale / Time
  ############################################
  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  ############################################
  # Virtualization / Memory
  ############################################
  virtualisation = {
    docker.enable = true;
    waydroid.enable = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  ############################################
  # User services
  ############################################
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
