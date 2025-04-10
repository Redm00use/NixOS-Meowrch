# /etc/nixos/home.nix
# Упрощенная версия без настроек GTK/Qt
# ---> ИСПРАВЛЕННЫЙ ЗАГОЛОВОК: Добавлен 'inputs'
{ config, pkgs, lib, inputs, ... }:

{
  # --- Основные настройки Home Manager ---
  home.username = "redm00us";
  home.homeDirectory = "/home/redm00us";
  home.stateVersion = "24.11";

  # --- Пакеты Пользователя ---
  home.packages = with pkgs; [
   # -- Терминал и Оболочка --
    kitty                # Терминал
    fish                 # Оболочка
    starship             # Промпт для оболочки
    fastfetch            # Информация о системе

    # -- Файловые менеджеры -- (лучше перенести в home.nix)
    nemo                 # Файловый менеджер
    nautilus             # Файловый менеджер (GNOME)

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

    # -- Разработка --
    git                  # Система контроля версий
    gcc                  # Компилятор C/C++ (GNU)
    #clang                # Компилятор C/C++/Objective-C (LLVM)
    nodejs               # Среда выполнения JavaScript
    ripgrep              # Утилита поиска текста
    vscode               # Редактор кода
    python311            # Python 3.11
    python311Packages.pip     # pip для Python 3.11
    python311Packages.numpy   # NumPy для Python 3.11
    python311Packages.pandas  # Pandas для Python 3.11
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
    #mesa-demos           # Демонстрации Mesa
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

    # --- Добавлен Yandex Music из flake input ---
    inputs.yandex-music.packages.${pkgs.system}.default
  ];

  # --- Настройки Fish Shell (Оставляем) ---
  programs.fish = {
    enable = true;
    shellAliases = {
      b = "sudo nixos-rebuild switch --flake .#nixos";
      c = "code --user-data-dir=\"$HOME/.vscode-root\" /etc/nixos/configuration.nix";
      u = "echo 'Для обновления используйте: nix flake update && sudo nixos-rebuild switch --flake .#nixos'";
      f = "fastfetch";
      dell = "sudo nix-collect-garbage -d";
    };
    functions = {
      wget = ''
        command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
      '';
    };
    interactiveShellInit = ''
      set fish_greeting ""
      if not contains -- "$HOME/.local/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.local/bin"
      end
      fastfetch
    '';
  };

  # --- Интеграция Starship ---
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # --- Интеграция Pyenv ---
  programs.pyenv = {
    enable = true;
    enableFishIntegration = true;
  };

  # --- Переменные окружения ---
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
  };

  # --- Настройки Git ---
  programs.git = {
    enable = true;
    userName = "Redm00us";
    userEmail = "krokismau@icloud.com"; 
  };

  # --- Управление Dotfiles ---
  # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;

}
