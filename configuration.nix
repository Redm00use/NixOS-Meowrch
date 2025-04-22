# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл NixOS                          ║
# ║                         Сделал: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{ config, pkgs, pkgs-unstable, lib, inputs, zed-editor-pkg, ... }:

{
  # --- Импорты ---
  imports = [
    ./hardware-configuration.nix
    ./modules/group.nix
  ];

  # --- Версия конфигурации NixOS ---
  system.stateVersion = "24.11";

  # --- Общие настройки системы и flakes ---
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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # Патченный шрифт JetBrainsMono с Nerd Fonts
      noto-fonts                 # Основные шрифты Noto
      noto-fonts-cjk-sans        # Noto для CJK
      noto-fonts-emoji           # Emoji-шрифты Noto
      noto-fonts-extra           # Дополнительные Noto
      fira-code                  # Fira Code
      fira-code-symbols          # Символы для Fira Code
      hack-font                  # Hack
      iosevka                    # Iosevka
      font-awesome               # Font Awesome
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
      extraPkgs = p: with p; [
        libdrm    # DRM-библиотека для графики
        wayland   # Wayland-библиотеки
        mangohud  # Overlay для FPS и мониторинга
        gamemode  # Оптимизация производительности игр
      ];
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
    kitty                       # Терминал
    fish                        # Оболочка Fish
    starship                    # Промпт Starship
    fastfetch                   # Информация о системе

    # -- Файловые менеджеры --
    nemo                        # Файловый менеджер Nemo
    zenity                      # Диалоговые окна GTK

    # -- Утилиты Wayland/Hyprland --
    wayland                     # Библиотеки Wayland
    xwayland                    # XWayland для совместимости X11
    wl-clipboard                # Клипборд для Wayland
    cliphist                    # История буфера обмена
    grim                        # Скриншоты
    slurp                       # Выделение области экрана
    swww                        # Обои для Wayland
    rofi-wayland                # Лаунчер Rofi для Wayland
    waybar                      # Панель Waybar
    swaylock-effects            # Локскрин с эффектами
    dunst                       # Уведомления
    pamixer                     # Управление громкостью
    playerctl                   # Управление медиаплеерами
    kdePackages.polkit-kde-agent-1   # Агент polkit для KDE

    # -- Веб и Сеть --
    firefox                     # Браузер Firefox
    cloudflare-warp             # VPN Warp
    wget                        # Загрузка файлов
    curl                        # HTTP-клиент
    modemmanager                # Модемы
    networkmanagerapplet        # Апплет NetworkManager
    usb-modeswitch              # Переключение режимов USB-модемов
    dig                         # DNS-утилита

    # -- Разработка --
    git                         # Git
    gcc                         # Компилятор GCC
    clang                       # Компилятор Clang
    nodejs                      # Node.js
    ripgrep                     # Поиск по файлам
    vscode                      # Visual Studio Code
    python311                    # Python 3.11
    python311Packages.pip        # pip для Python 3.11
    python311Packages.numpy      # NumPy
    python311Packages.pandas     # Pandas
    python311Packages.psutil     # psutil
    python311Packages.meson      # Meson
    python311Packages.pillow     # Pillow
    python311Packages.pyyaml     # PyYAML
    python311Packages.setuptools # setuptools
    python311Packages.uv         # uv
    python311Packages.pkgconfig  # pkgconfig
    pyenv                       # Менеджер версий Python

    # -- Общение --
    viber                       # Viber
    discord                     # Discord

    # -- Мультимедиа --
    spotify                     # Spotify
    mpv                         # Видеоплеер MPV
    obs-studio                  # OBS Studio
    feh                         # Просмотр изображений

    # -- Игры и графика --
    gamemode                    # Оптимизация игр
    mangohud                    # Overlay для игр
    steam                       # Steam
    wine                        # Wine
    winetricks                  # Winetricks
    mesa                        # Mesa (OpenGL)
    mesa.drivers                # Драйверы Mesa
    libGL                       # OpenGL
    libva                       # Аппаратное ускорение видео VA-API
    libvdpau                    # Аппаратное ускорение видео VDPAU
    vulkan-loader               # Vulkan loader
    vulkan-tools                # Инструменты Vulkan
    vulkan-validation-layers    # Валидация Vulkan
    amdvlk                      # Vulkan-драйвер AMD
    dxvk                        # DXVK (DirectX → Vulkan)
    mesa-demos                  # Демо-программы Mesa
    virtualgl                   # VirtualGL
    virtualglLib                # Библиотеки VirtualGL

    # -- Виртуализация --
    qemu_full                   # QEMU (полная сборка)
    gnome-boxes                 # GNOME Boxes
    libvirt                     # Libvirt

    # -- Системные утилиты --
    gnome-disk-utility          # Диски GNOME
    gnome-system-monitor        # Монитор системы
    gnome-calculator            # Калькулятор
    ark                         # Архиватор
    qbittorrent                 # Торрент-клиент
    remmina                     # Удалённый рабочий стол
    upower                      # Управление питанием
    blueman                     # Менеджер Bluetooth
    bluez                       # Стек Bluetooth
    bluez-tools                 # Инструменты Bluez
    glibc                       # GNU C Library
    xdg-utils                   # XDG-утилиты

    # -- Темы и иконки --
    catppuccin-gtk              # GTK-тема Catppuccin
    gnome-themes-extra          # Дополнительные темы GNOME
    gsettings-desktop-schemas   # Схемы настроек
    catppuccin-qt5ct            # Catppuccin для qt
  ];
}
