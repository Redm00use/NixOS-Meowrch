# /etc/nixos/configuration.nix
{ config, pkgs, pkgs-unstable, lib, inputs, ... }:

{
  # --- Импорты ---
  imports = [
    # Включаем конфигурацию оборудования, сгенерированную NixOS
    ./hardware-configuration.nix
    ./modules/group.nix
  ];

  # --- Версия конфигурации NixOS ---
  # Позволяет NixOS управлять изменениями и обновлениями.
  system.stateVersion = "24.11"; # Управления версией вашего первого развертывания NixOS

  # --- Общие настройки системы ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Загрузчик ---
  boot.loader.systemd-boot.enable = true; # Используем systemd-boot
  boot.loader.efi.canTouchEfiVariables = true; # Разрешаем изменять EFI переменные
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest; # Используем самое свежее ядро из unstable

  # --- Сервис для Warp VPN ---
  services.cloudflare-warp.enable = true; # Включаем Cloudflare WARP

  # --- Локализация и время ---
  time.timeZone = "Europe/Kyiv"; # Установка часового пояса
  i18n.defaultLocale = "ru_UA.UTF-8"; # Основная локаль системы
  i18n.extraLocaleSettings = { # Дополнительные настройки локали
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
    # Добавляем пользователя в необходимые группы
    extraGroups = [ "networkmanager" "wheel" "lp" "bluetooth" "libvirtd" "users" "audio" "video" "cloudflare-warp" ];
    # 'users' добавлена для прав на /media/*
    packages = with pkgs; [
      # Сюда можно добавить пакеты, специфичные для пользователя, если нужно
    ];
  };

  # --- Графическая подсистема и оконный менеджер (Hyprland) ---
  programs.hyprland = {
    enable = true; # Включаем Hyprland
    xwayland.enable = true; # Включаем XWayland для совместимости с X11 приложениями
  };
  # Настройка драйверов для видеокарты AMD
  hardware.graphics.enable = true;
  # services.xserver.videoDrivers = [ "amdgpu" ]; # Закомментировано, т.к. может не требоваться для Wayland/Hyprland с Mesa

  # Настройка SDDM как Display Manager
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true; # Включаем Wayland сессию для SDDM
    };
    defaultSession = "hyprland"; # Сессия по умолчанию
    autoLogin = { # Автоматический вход для пользователя redm00us
      enable = true;
      user = "redm00us";
    };
  };

  # Настройка XDG Desktop Portal для работы приложений в Wayland
  xdg.portal = {
    enable = true;
    config = {
      # Указываем Hyprland и GTK как порталы по умолчанию
      common.default = [ "hyprland" "gtk" ];
      # Настройки для специфичных порталов
      "org.freedesktop.impl.portal.Settings" = { default = [ "hyprland" ]; };
      "org.freedesktop.impl.portal.FileChooser" = { default = [ "gtk" ]; };
      "org.freedesktop.impl.portal.Screenshot" = { default = [ "hyprland" ]; };
    };
    # Устанавливаем необходимые реализации порталов
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
  # Переменные окружения для сессии Wayland
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # --- Шрифты ---
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # Nerd Fonts с JetBrains Mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
      hack-font
      iosevka
      font-awesome # Иконочные шрифты
    ];
    fontconfig = { # Настройки Fontconfig
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ]; # Моноширинный шрифт по умолчанию
        sansSerif = [ "Noto Sans" ]; # Sans-serif шрифт по умолчанию
        serif = [ "Noto Serif" ]; # Serif шрифт по умолчанию
      };
    };
  };

  # --- Звук (PipeWire) ---
  services.pipewire = {
    enable = true; # Включаем PipeWire
    alsa.enable = true; # Включаем поддержку ALSA
    pulse.enable = true; # Включаем поддержку PulseAudio (для совместимости)
    wireplumber.enable = true; # Включаем WirePlumber (менеджер сессий)
  };

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true; # Включаем Bluetooth
    powerOnBoot = true; # Включать Bluetooth при загрузке
    settings = { # Дополнительные настройки Bluez
    };
  };


  # --- Сеть ---
  networking.hostName = "nixos"; # Имя хоста
  networking.networkmanager.enable = true; # Используем NetworkManager для управления сетью
  hardware.enableRedistributableFirmware = true;

  # --- Файловые системы и монтирование ---
  # Монтирование дисков в /media
  fileSystems."/media/Home-1" = {
    device = "/dev/disk/by-uuid/f4dcae61-4c7e-4935-8cf9-b34c6788f50d";
    fsType = "ext4";
    options = [ "rw" "noatime" ]; # Опции монтирования: чтение/запись, без обновления времени доступа
  };
  fileSystems."/media/Home-2" = {
    device = "/dev/disk/by-uuid/57b95720-abcb-43f3-bd2a-91596d8c65f4";
    fsType = "ext4";
    options = [ "rw" "noatime" ];
  };
  # Установка прав на точки монтирования через tmpfiles.d
  # Пользователь redm00us и группа users будут иметь права 0770
  environment.etc."tmpfiles.d/home-disks.conf".text = ''
   d /media/Home-1 0770 redm00us users -
   d /media/Home-2 0770 redm00us users -
  '';

  # --- Виртуализация ---
  virtualisation.libvirtd.enable = true; # Включаем демон libvirtd для управления ВМ

  # --- Настройки ввода ---
  services.libinput.enable = true; # Включаем libinput для управления устройствами ввода
  services.xserver.xkb = { # Настройки раскладки клавиатуры (влияет и на Wayland через libinput)
    layout = "us"; # Основная раскладка
    variant = ""; # Вариант раскладки
  };

  # --- Игры ---
  programs.gamemode.enable = true; # Включаем Feral GameMode
  programs.steam = {
    enable = true; # Включаем Steam
    # Добавляем необходимые зависимости для Steam и Proton/Wayland (используем стабильные pkgs)
    package = pkgs.steam.override {
      extraPkgs = p: with p; [ libdrm wayland mangohud gamemode ];
    };
    remotePlay.openFirewall = true; # Открыть порты для Remote Play
    dedicatedServer.openFirewall = true; # Открыть порты для выделенных серверов
  };

  # --- Основные сервисы ---
  services.dbus.enable = true; # Включаем D-Bus
  services.udisks2.enable = true; # Сервис для работы с дисками (монтирование и т.д.)
  services.upower.enable = true; # Сервис управления питанием
  security.polkit.enable = true; # Включаем Polkit для управления привилегиями
  services.usbmuxd.enable = true; # Демон для работы с устройствами Apple через USB

  # --- Вспомогательные программы и утилиты ---
  programs.command-not-found.enable = true; # Помощник для неизвестных команд
  programs.nix-ld.enable = true; # Динамический линковщик для бинарников не из Nix store
  programs.fish.enable = true; # Используем Fish как оболочку по умолчанию (нужно настроить для пользователя)

  # --- Системные пакеты ---
  # ---> ВАЖНО: Все пакеты здесь, КРОМЕ materialgram, будут браться из pkgs (стабильной ветки 24.11)
  environment.systemPackages = with pkgs; [
       # -- Терминал и Оболочка --
    kitty                # Терминал
    fish                 # Оболочка
    starship             # Промпт для оболочки
    fastfetch            # Информация о системе

    # -- Файловые менеджеры -- (лучше перенести в home.nix)
    nemo                 # Файловый менеджер
    zenity               # GTK диалоговые окна (для Nemo)

    # -- Утилиты Wayland/Hyprland --
    wayland              # Протокол Wayland
    xwayland             # Слой совместимости X11 для Wayland
    wl-clipboard         # Работа с буфером обмена в Wayland
    cliphist             # История буфера обмена для Wayland
    grim                 # Скриншоты в Wayland
    slurp                # Выделение области экрана в Wayland
    swww                 # Управление обоями для Wayland (альтернатива feh/nitrogen)
    rofi-wayland         # Запускатель приложений / меню (Wayland-совместимые форки существуют)
    waybar               # Панель статуса для Wayland
    swaylock-effects     # Экран блокировки с эффектами
    dunst                # Сервер уведомлений
    pamixer              # Управление громкостью PulseAudio/PipeWire
    playerctl            # Управление медиаплеерами из командной строки
    kdePackages.polkit-kde-agent-1 # Агент Polkit для KDE/Qt приложений

    # -- Веб и Сеть --
    firefox              # Веб-браузер
    cloudflare-warp      # Клиент Cloudflare WARP
    wget                 # Утилита для скачивания файлов
    curl                 # Утилита для работы с URL
    modemmanager         # Управление мобильными устройствами (модемами)
    networkmanagerapplet # Апплет для управления сетями (GTK)
    usb-modeswitch       # Переключение режимов USB устройств (например, модемов)
    dig                  # Утилита для DNS-запросов

    # -- Разработка --
    git                  # Система контроля версий
    gcc                  # Компилятор C/C++ (GNU)
    clang                # Компилятор C/C++/Objective-C (LLVM)
    nodejs               # Среда выполнения JavaScript
    ripgrep              # Утилита поиска текста
    vscode               # Редактор кода
    python311            # Python 3.11
    python311Packages.pip     # pip для Python 3.11
    python311Packages.numpy   # NumPy для Python 3.11
    python311Packages.pandas  # Pandas для Python 3.11{
    python311Packages.psutil  # Psutil для Python 3.11
    python311Packages.meson   # Meson для Python 3.11
    python311Packages.pillow  # Pillow для Python 3.11
    python311Packages.pyyaml  # PyYAML для Python 3.11
    python311Packages.setuptools # setuptools для Python 3.11
    python311Packages.uv      # uv для Python 3.11
    python311Packages.pkgconfig # pkg-config для Python 3.11
    pyenv                # Управление версиями Python

    # -- Общение --
    viber                # Мессенджер Viber 
    discord              # Мессенджер Discord 

    # -- Мультимедиа --
    spotify              # Музыкальный стриминг
    mpv                  # Медиаплеер
    obs-studio           # Запись экрана и стриминг
    feh                  # Просмотрщик изображений (легковесный, для X11/Wayland с xwayland)

    # -- Игры и графика --
    gamemode             # Оптимизация для игр
    mangohud             # Оверлей для мониторинга в играх
    steam                # Игровая платформа Steam
    wine                 # Слой совместимости для Windows приложений
    winetricks           # Утилита для настройки Wine

    # Зависимости для Wine/Proton/Vulkan
    mesa                 # 3D графика (OpenGL/Vulkan)
    mesa.drivers         # Драйверы Mesa
    libGL                # Библиотека OpenGL
    libva                # VA-API (аппаратное ускорение видео)
    libvdpau             # VDPAU (аппаратное ускорение видео)
    vulkan-loader        # Загрузчик Vulkan
    vulkan-tools         # Утилиты Vulkan
    vulkan-validation-layers # Слои валидации Vulkan
    amdvlk               # Альтернативный драйвер AMD Vulkan
    dxvk                 # Трансляция DirectX 9/10/11 в Vulkan
    # Дополнительные утилиты для графики
    mesa-demos           # Демонстрации Mesa
    virtualgl            # Перенаправление OpenGL рендеринга
    virtualglLib         # Библиотеки VirtualGL

    # -- Виртуализация --
    qemu_full            # Эмулятор QEMU (полный пакет)
    gnome-boxes          # Простой интерфейс для виртуальных машин (использует QEMU/libvirt)
    libvirt              # Библиотека и демон для управления виртуализацией

    # -- Системные утилиты --
    gnome-disk-utility   # Утилита для работы с дисками
    gnome-system-monitor # Системный монитор
    gnome-calculator     # Калькулятор
    ark                  # Архиватор
    qbittorrent          # Торрент-клиент 
    remmina              # Клиент удаленного доступа
    upower               # Управление питанием
    blueman              # Менеджер Bluetooth (GTK)
    bluez                # Стек Bluetooth
    bluez-tools          # Утилиты Bluetooth
    glibc                # Стандартная библиотека C
    xdg-utils            # Утилиты для интеграции с рабочим столом (открытие файлов и т.д.)

    # -- Темы и иконки -- (Лучше управлять через home.nix)
    catppuccin-gtk       # Тема Catppuccin для GTK
    gnome-themes-extra   # Дополнительные темы GNOME
    gsettings-desktop-schemas # Схемы для настроек GTK/GNOME
    # Темы Qt
    catppuccin-qt5ct     # Тема Catppuccin для Qt5/qt5ct
    # Темы KDE
    catppuccin-kde       # Тема Catppuccin для KDE Plasma
    # Иконки
    papirus-icon-theme   # Тема иконок Papirus
    tela-circle-icon-theme # Тема иконок Tela Circle
    adwaita-icon-theme   # Стандартная тема иконок Adwaita
    font-awesome         # Иконочный шрифт
    # Курсоры
    bibata-cursors       # Тема курсоров Bibata
    catppuccin-cursors   # Тема курсоров Catppuccin
    # Настройки GNOME/GTK
    gnome-tweaks         # Утилита тонкой настройки GNOME
    dconf-editor         # Редактор DConf (для низкоуровневых настроек GTK/GNOME)
    # Прочее
    glib                 # Базовая библиотека для GTK/GNOME
    gvfs                 # Виртуальная файловая система GNOME
    vscode-extensions.catppuccin.catppuccin-vsc-icons
    vscode-extensions.catppuccin.catppuccin-vsc
    # Общий пакет темы
    catppuccin           # Если это действительно пакет с ресурсами

    pkgs-unstable.materialgram # Используем пакет из нестабильной ветки
  ];
}
