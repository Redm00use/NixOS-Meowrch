# /etc/nixos/configuration.nix
{ config, pkgs, pkgs-unstable, lib, inputs, zed-editor-pkg, ... }:

{
  # --- Импорты ---
  imports = [
    ./hardware-configuration.nix
    ./modules/group.nix
  ];

  # --- Версия конфигурации NixOS ---
  system.stateVersion = "24.11";

  # --- Общие настройки системы ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Загрузчик ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;

  # --- Сервис для Warp VPN ---
  services.cloudflare-warp.enable = true;

  # --- Локализация и время ---
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "ru_UA.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "uk_UA.UTF-8";
    LC_IDENTIFICATION = "uk_UA.UTF-8";
    LC_MEASUREMENT = "uk_UA.UTF-8";
    LC_MONETARY = "uk_UA.UTF-8";
    LC_NAME = "uk_UA.UTF-8";
    LC_NUMERIC = "uk_UA.UTF-8";
    LC_PAPER = "uk_UA.UTF-8";
    LC_TELEPHONE = "uk_UA.UTF-8";
    LC_TIME = "ru_UA.UTF-8";
  };

  # --- Пользователь ---
  users.users.redm00us = {
    isNormalUser = true;
    description = "Redm00us";
    extraGroups = [ "networkmanager" "wheel" "lp" "bluetooth" "libvirtd" "users" "audio" "video" "cloudflare-warp" ];
    packages = with pkgs; [];
  };

  # --- Графическая подсистема и оконный менеджер (Hyprland) ---
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  hardware.graphics.enable = true;

  # Настройка SDDM как Display Manager
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = "redm00us";
    };
  };

  # Настройка XDG Desktop Portal
  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Settings" = { default = [ "hyprland" ]; };
      "org.freedesktop.impl.portal.FileChooser" = { default = [ "gtk" ]; };
      "org.freedesktop.impl.portal.Screenshot" = { default = [ "hyprland" ]; };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # --- Шрифты ---
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
      hack-font
      iosevka
      font-awesome
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # --- Звук (PipeWire) ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # --- Сеть ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;

  # --- Файловые системы и монтирование ---
  fileSystems."/media/Home-1" = {
    device = "/dev/disk/by-uuid/f4dcae61-4c7e-4935-8cf9-b34c6788f50d";
    fsType = "ext4";
    options = [ "rw" "noatime" ];
  };
  fileSystems."/media/Home-2" = {
    device = "/dev/disk/by-uuid/57b95720-abcb-43f3-bd2a-91596d8c65f4";
    fsType = "ext4";
    options = [ "rw" "noatime" ];
  };
  environment.etc."tmpfiles.d/home-disks.conf".text = ''
    d /media/Home-1 0770 redm00us users -
    d /media/Home-2 0770 redm00us users -
  '';

  # --- Виртуализация ---
  virtualisation.libvirtd.enable = true;

  # --- Настройки ввода ---
  services.libinput.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- Игры ---
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = p: with p; [ libdrm wayland mangohud gamemode ];
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # --- Основные сервисы ---
  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  security.polkit.enable = true;
  services.usbmuxd.enable = true;

  # --- Вспомогательные программы и утилиты ---
  programs.command-not-found.enable = true;
  programs.nix-ld.enable = true;
  programs.fish.enable = true;

  # --- Системные пакеты ---
  environment.systemPackages = with pkgs; [
    # -- Терминал и Оболочка --
    kitty
    fish
    starship
    fastfetch

    # -- Файловые менеджеры --
    nemo
    zenity

    # -- Утилиты Wayland/Hyprland --
    wayland
    xwayland
    wl-clipboard
    cliphist
    grim
    slurp
    swww
    rofi-wayland
    waybar
    swaylock-effects
    dunst
    pamixer
    playerctl
    kdePackages.polkit-kde-agent-1

    # -- Веб и Сеть --
    firefox
    cloudflare-warp
    wget
    curl
    modemmanager
    networkmanagerapplet
    usb-modeswitch
    dig

    # -- Разработка --
    git
    gcc
    clang
    nodejs
    ripgrep
    vscode
    python311
    python311Packages.pip
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.psutil
    python311Packages.meson
    python311Packages.pillow
    python311Packages.pyyaml
    python311Packages.setuptools
    python311Packages.uv
    python311Packages.pkgconfig
    pyenv

    # -- Общение --
    viber
    discord

    # -- Мультимедиа --
    spotify
    mpv
    obs-studio
    feh

    # -- Игры и графика --
    gamemode
    mangohud
    steam
    wine
    winetricks
    mesa
    mesa.drivers
    libGL
    libva
    libvdpau
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    amdvlk
    dxvk
    mesa-demos
    virtualgl
    virtualglLib

    # -- Виртуализация --
    qemu_full
    gnome-boxes
    libvirt

    # -- Системные утилиты --
    gnome-disk-utility
    gnome-system-monitor
    gnome-calculator
    ark
    qbittorrent
    remmina
    upower
    blueman
    bluez
    bluez-tools
    glibc
    xdg-utils

    # -- Темы и иконки --
    catppuccin-gtk
    gnome-themes-extra
    gsettings-desktop-schemas
    catppuccin-qt5ct
    catppuccin-kde
    papirus-icon-theme
    tela-circle-icon-theme
    adwaita-icon-theme
    font-awesome
    bibata-cursors
    catppuccin-cursors
    gnome-tweaks
    dconf-editor
    glib
    gvfs
    vscode-extensions.catppuccin.catppuccin-vsc-icons
    vscode-extensions.catppuccin.catppuccin-vsc
    catppuccin

    pkgs-unstable.materialgram
    gnupg

    # -- Zed Editor --
    zed-editor-pkg # Используем пакет из specialArgs
    nil            # Адон для zed
    nixd           # Адон для zed
  ];
}
