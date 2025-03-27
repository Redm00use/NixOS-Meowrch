{ config, pkgs, ... }:

let
  # Импорт нестабильного канала
  unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) {
    config = { allowUnfree = true; };
  };
in
{
  imports = [
    ./hardware-configuration.nix 
  ];


  # Сервис для Warp VPN
  systemd.services.warp-svc = {
  enable = true;
  description = "Cloudflare WARP Service";
  wantedBy = [ "multi-user.target" ];
  after = [ "network.target" "dbus.service" ];
  serviceConfig = {
    ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
    Restart = "on-failure";
    RestartSec = "5s";
    Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";  # Для пользовательского сервиса
  };
};

  # Включение Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

#телеграм принудительно использует nemo 
  environment.etc."xdg/applications/io.github.kukuruzka165.materialgram.desktop".text = ''
    [Desktop Entry]
    Name=Materialgram
    Exec=env XDG_CURRENT_DESKTOP=Hyprland io.github.kukuruzka165.materialgram -- %u
    Icon=io.github.kukuruzka165.materialgram
    Terminal=false
    Type=Application
    Categories=Network;InstantMessaging;
  '';

#Настройка для видеокарты и Steam
hardware.graphics.enable = true;
services.xserver.videoDrivers = [ "amdgpu" ];

programs.steam.enable = true;
programs.steam.package = pkgs.steam.override {
  extraPkgs = pkgs: with pkgs; [ libdrm wayland ];
};

  # Настройка шрифтов
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      noto-fonts
      noto-fonts-cjk-sans  # Заменено на noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
      hack-font
      iosevka
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # Настройка libinput
  services.libinput.enable = true;

  # Установка Docker
  environment.systemPackages = with pkgs; [
    cloudflare-warp
    git
    hyprland
    wayland
    xwayland
    kitty
    fish
    nemo
    vscode
    rofi
    dunst
    python311
    python311Packages.pip
    python311Packages.numpy
    python311Packages.pandas
    waybar
    swww
    cliphist
    grim
    slurp
    kdePackages.polkit-kde-agent-1
    wl-clipboard
    xdg-utils
    upower
    pamixer
    (python3.withPackages (ps: [ ps.psutil ]))
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    bibata-cursors
    tela-circle-icon-theme
    gnome-themes-extra
    adwaita-icon-theme
    gsettings-desktop-schemas
    glib
    dconf-editor
    blueman
    bluez
    bluez-tools
    papirus-icon-theme
    wget
    glibc
    python3Packages.psutil
    catppuccin-gtk
    fastfetch
    papirus-icon-theme
    python3
    starship
    pyenv
    discord
    wine
    winetricks
    vulkan-tools
    dxvk
    vulkan-loader
    libGL
    libva
    libvdpau
    libpulseaudio
    dpkg
    playerctl
    ark
    swaylock
    steam
    mesa-demos
    virtualgl
    virtualglLib
    mesa
    mesa.drivers
    vulkan-loader
    vulkan-validation-layers
    amdvlk 
    gparted
    kdenlive
    yandex-music
    gnome-calculator
    feh
    gnome-disk-utility
    gnome-system-monitor
    mpv
    obs-studio
    qbittorrent
    remmina
    catppuccin-gtk
    catppuccin-cursors
    vscode-extensions.catppuccin.catppuccin-vsc-icons
    vscode-extensions.catppuccin.catppuccin-vsc
    catppuccin-papirus-folders
    catppuccin-qt5ct
    catppuccin-kde
    catppuccin
    gnome-tweaks
    gvfs
    nautilus
 ];

  # Включаем Docker
  virtualisation.docker = {
    enable = true;
  };

  # (Опционально) Устанавливаем, чтобы Docker запускался автоматически при старте системы
  systemd.services.docker = {
    wantedBy = [ "multi-user.target" ];
  };

  # Настройка displayManager (SDDM)
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

  # Настройка xdg-desktop-portal
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

  # Переменные окружения для Wayland
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # Включение необходимых сервисов
  services = {
    dbus.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  # Включение polkit для авторизации
  security.polkit.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = unstable.linuxPackages_6_12;  # Используем ядро из нестабильного канала

  # Сетевая конфигурация
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Часовой пояс
  time.timeZone = "Europe/Kyiv";

  # Локализация
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "uk_UA.UTF-8";
    LC_IDENTIFICATION = "uk_UA.UTF-8";
    LC_MEASUREMENT = "uk_UA.UTF-8";
    LC_MONETARY = "uk_UA.UTF-8";
    LC_NAME = "uk_UA.UTF-8";
    LC_NUMERIC = "uk_UA.UTF-8";
    LC_PAPER = "uk_UA.UTF-8";
    LC_TELEPHONE = "uk_UA.UTF-8";
    LC_TIME = "uk_UA.UTF-8";
  };

  # Раскладка клавиатуры
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Пользовательская конфигурация
  users.users.redm00us = {
    isNormalUser = true;
    description = "Redm00us";
    extraGroups = [ "networkmanager" "wheel" "lp" "bluetooth" "docker" ];  # Объединенные группы
    packages = with pkgs; [];
  };

  # Разрешение несвободных пакетов
  nixpkgs.config.allowUnfree = true;

  # Включение Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # Версия системы
  system.stateVersion = "24.11";
}
