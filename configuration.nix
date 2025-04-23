# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл NixOS                          ║
# ║                         Сделал: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  zed-editor-pkg,
  ...
}: {
  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                            ИМПОРТЫ                                   ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  imports = [
    ./hardware-configuration.nix # Аппаратная конфигурация
    ./modules/group.nix # Группы пользователей
    ./modules/packages.nix # Пользовательские пакеты
  ];

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                  ОСНОВНЫЕ НАСТРОЙКИ СИСТЕМЫ И FLAKES                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  system.stateVersion = "24.11"; # Версия конфигурации NixOS

  nixpkgs.config.allowUnfree = true; # Разрешить не свободные пакеты
  nix.settings.experimental-features = ["nix-command" "flakes"]; # Включить flakes и новую CLI

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                            ЗАГРУЗЧИК                                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  boot.loader.systemd-boot.enable = true; # Systemd-boot как загрузчик
  boot.loader.efi.canTouchEfiVariables = true; # Разрешить запись EFI переменных
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest; # Самое свежее ядро из unstable

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                        VPN и СЕТЕВЫЕ СЕРВИСЫ                         ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  services.cloudflare-warp.enable = true; # Warp VPN от Cloudflare

  networking.hostName = "nixos"; # Имя хоста
  networking.networkmanager.enable = true; # NetworkManager для управления сетью
  hardware.enableRedistributableFirmware = true; # Прошивки для оборудования

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                      ЛОКАЛИЗАЦИЯ И ВРЕМЯ                             ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  time.timeZone = "Europe/Kyiv"; # Часовой пояс
  i18n.defaultLocale = "ru_UA.UTF-8"; # Основная локаль
  i18n.extraLocaleSettings = {
    # Дополнительные локали
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

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                        ПОЛЬЗОВАТЕЛИ                                  ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  users.users.redm00us = {
    isNormalUser = true; # Обычный пользователь
    description = "Redm00us"; # Описание пользователя
    extraGroups = [
      # Группы для доступа к функциям
      "networkmanager" # Управление сетью
      "wheel" # Админ-доступ (sudo)
      "lp" # Принтеры
      "bluetooth" # Bluetooth
      "libvirtd" # Виртуализация
      "users" # Общая группа пользователей
      "audio" # Аудио
      "video" # Видео
      "cloudflare-warp" # Warp VPN
    ];
    packages = with pkgs; []; # Индивидуальные пакеты пользователя
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║        ГРАФИЧЕСКАЯ ПОДСИСТЕМА И ОКОННЫЙ МЕНЕДЖЕР (HYPRLAND)          ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  programs.hyprland = {
    enable = true; # Включить Hyprland (Wayland WM)
    xwayland.enable = true; # Поддержка XWayland
  };
  hardware.graphics.enable = true; # Включить графику

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                DISPLAY MANAGER (SDDM) и АВТОВХОД                     ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  services.displayManager = {
    sddm = {
      enable = true; # Включить SDDM
      wayland.enable = true; # SDDM с поддержкой Wayland
    };
    defaultSession = "hyprland"; # Сессия по умолчанию
    autoLogin = {
      enable = true; # Автоматический вход
      user = "redm00us"; # Пользователь для автологина
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                  XDG DESKTOP PORTAL (ИНТЕГРАЦИЯ)                     ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  xdg.portal = {
    enable = true; # Включить XDG Portal
    config = {
      common.default = ["hyprland" "gtk"]; # Порталы по умолчанию
      "org.freedesktop.impl.portal.Settings" = {default = ["hyprland"];};
      "org.freedesktop.impl.portal.FileChooser" = {default = ["gtk"];};
      "org.freedesktop.impl.portal.Screenshot" = {default = ["hyprland"];};
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland # Портал для Hyprland
      xdg-desktop-portal-gtk # Портал для GTK-приложений
    ];
  };
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland"; # Текущий рабочий стол
    XDG_SESSION_TYPE = "wayland"; # Тип сессии
    XDG_SESSION_DESKTOP = "Hyprland"; # Рабочий стол сессии
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                              ШРИФТЫ                                  ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["JetBrainsMono"];}) # JetBrainsMono с патчем Nerd Fonts
      noto-fonts # Основные шрифты Noto
      noto-fonts-cjk-sans # Noto для CJK (китайский, японский, корейский)
      noto-fonts-emoji # Emoji-шрифты Noto
      noto-fonts-extra # Дополнительные Noto
      fira-code # Fira Code (программирование)
      fira-code-symbols # Символы для Fira Code
      hack-font # Hack (моноширинный)
      iosevka # Iosevka (моноширинный)
      font-awesome # Font Awesome (иконки)
    ];
    fontconfig = {
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font Mono"]; # Моноширинный по умолчанию
        sansSerif = ["Noto Sans"]; # Без засечек по умолчанию
        serif = ["Noto Serif"]; # С засечками по умолчанию
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                         ЗВУК (PIPEWIRE)                              ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  services.pipewire = {
    enable = true; # Включить PipeWire
    alsa.enable = true; # Поддержка ALSA
    pulse.enable = true; # Поддержка PulseAudio
    wireplumber.enable = true; # WirePlumber как session manager
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                            BLUETOOTH                                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  hardware.bluetooth = {
    enable = true; # Включить Bluetooth
    powerOnBoot = true; # Включать Bluetooth при загрузке
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                ФАЙЛОВЫЕ СИСТЕМЫ И МОНТИРОВАНИЕ                       ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  fileSystems."/media/Home-1" = {
    device = "/dev/disk/by-uuid/f4dcae61-4c7e-4935-8cf9-b34c6788f50d"; # UUID диска Home-1
    fsType = "ext4"; # Файловая система
    options = ["rw" "noatime"]; # Опции монтирования
  };
  fileSystems."/media/Home-2" = {
    device = "/dev/disk/by-uuid/57b95720-abcb-43f3-bd2a-91596d8c65f4"; # UUID диска Home-2
    fsType = "ext4";
    options = ["rw" "noatime"];
  };
  environment.etc."tmpfiles.d/home-disks.conf".text = ''
    d /media/Home-1 0770 redm00us users -
    d /media/Home-2 0770 redm00us users -
  ''; # Создание директорий с нужными правами для монтирования

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                        ВИРТУАЛИЗАЦИЯ                                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  virtualisation.libvirtd.enable = true; # Включить libvirtd (виртуальные машины)

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                        НАСТРОЙКИ ВВОДА                               ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  services.libinput.enable = true; # Поддержка тачпадов и мышей
  services.xserver.xkb = {
    layout = "us"; # Раскладка клавиатуры
    variant = ""; # Вариант раскладки
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                               ИГРЫ                                   ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  programs.gamemode.enable = true; # GameMode для оптимизации игр
  programs.steam = {
    enable = true; # Включить Steam
    package = pkgs.steam.override {
      extraPkgs = p:
        with p; [
          libdrm # DRM-библиотека для графики
          wayland # Wayland-библиотеки
          mangohud # Overlay для FPS и мониторинга
          gamemode # Оптимизация производительности игр
        ];
    };
    remotePlay.openFirewall = true; # Открыть порты для Remote Play
    dedicatedServer.openFirewall = true; # Открыть порты для серверов
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                        ОСНОВНЫЕ СЕРВИСЫ                              ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  services.dbus.enable = true; # D-Bus для IPC
  services.udisks2.enable = true; # UDisks2 для работы с дисками
  services.upower.enable = true; # Upower для управления питанием
  security.polkit.enable = true; # Polkit для управления правами
  services.usbmuxd.enable = true; # USBMUXD для устройств Apple

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                ВСПОМОГАТЕЛЬНЫЕ ПРОГРАММЫ И УТИЛИТЫ                   ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  programs.command-not-found.enable = true; # Подсказки по командам
  programs.nix-ld.enable = true; # Запуск бинарников с внешними зависимостями
  programs.fish.enable = true; # Fish shell
}
