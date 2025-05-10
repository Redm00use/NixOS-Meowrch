{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  zed-editor-pkg,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                             ТЕРМИНАЛ И ОБОЛОЧКА                         ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    kitty # GPU-терминал (быстрый, кастомизируемый)
    fish # Современная оболочка командной строки
    starship # Кроссплатформенный быстрый prompt для shell
    fastfetch # Быстрый вывод информации о системе

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                           ФАЙЛОВЫЕ МЕНЕДЖЕРЫ                            ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    nemo # Файловый менеджер Cinnamon (графический)
    zenity # Диалоговые окна GTK+ через shell (скрипты)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                       WAYLAND / HYPRLAND УТИЛИТЫ                        ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    wayland # Библиотеки Wayland (основа протокола)
    xwayland # X11 сервер для Wayland (совместимость)
    wl-clipboard # Копирование/вставка для Wayland (clipboard)
    cliphist # История буфера обмена для Wayland
    grim # Скриншоты для Wayland (grab image)
    slurp # Выделение области экрана для grim
    swww # Динамические обои для Wayland
    rofi-wayland # Лаунчер приложений для Wayland (меню)
    waybar # Панель статуса для Wayland
    swaylock-effects # Локскрин с эффектами для Wayland
    dunst # Демон уведомлений (notification daemon)
    pamixer # Управление громкостью через PulseAudio
    playerctl # Управление медиаплеерами через MPRIS
    kdePackages.polkit-kde-agent-1 # Агент polkit для KDE (авторизация)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                              ВЕБ И СЕТЬ                                  ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    firefox # Веб-браузер Firefox
    cloudflare-warp # VPN от Cloudflare (WireGuard)
    wget # Загрузка файлов по HTTP/FTP
    curl # HTTP-клиент для командной строки
    modemmanager # Управление мобильными модемами (3G/4G)
    networkmanagerapplet # Апплет NetworkManager для панели
    usb-modeswitch # Переключение режимов USB-модемов
    dig # DNS lookup утилита (анализ DNS)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                              РАЗРАБОТКА                                  ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    # --- Редакторы и инструменты Nix ---
    zed-editor-pkg # Редактор Zed (современный, быстрый)
    alejandra # Форматер nix кода
    nixd # Язык-сервер для Nix (LSP)
    # --- Системы контроля версий ---
    git # Система контроля версий Git
    # --- Компиляторы и инструменты сборки ---
    gcc # Компилятор GCC (C/C++)
    clang # Компилятор Clang/LLVM (C/C++)
    nodejs # JavaScript runtime (Node.js)
    ripgrep # Быстрый поиск по файлам (rg)
    # --- Python 3.11 и пакеты ---
    python311 # Python 3.11 интерпретатор
    python311Packages.pip # pip для Python 3.11 (менеджер пакетов)
    python311Packages.numpy # Математическая библиотека NumPy
    python311Packages.pandas # Анализ данных Pandas
    python311Packages.psutil # Информация о процессах/системе
    python311Packages.meson # Система сборки Meson (Python)
    python311Packages.pillow # Работа с изображениями (Pillow)
    python311Packages.pyyaml # Работа с YAML файлами
    python311Packages.setuptools # setuptools для Python (build system)
    python311Packages.uv # Быстрый менеджер пакетов Python (uv)
    python311Packages.pkgconfig # pkg-config для Python (build deps)
    pyenv # Менеджер версий Python

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                                ОБЩЕНИЕ                                   ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    viber # Мессенджер Viber (VoIP, чат)
    discord # Discord клиент (чат, голос)
    pkgs-unstable.materialgram # Клиент Telegram Materialgram (unstable, Qt)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                              МУЛЬТИМЕДИА                                 ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    spotify # Клиент Spotify (музыка)
    mpv # Видеоплеер MPV (универсальный)
    obs-studio # OBS Studio для записи/стриминга
    feh # Просмотр изображений (легковесный)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                          ИГРЫ И ГРАФИКА                                  ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    # --- Оптимизация и overlay ---
    gamemode # Оптимизация производительности игр
    mangohud # Overlay с FPS и статистикой
    # --- Платформы и совместимость ---
    steam # Клиент Steam (игры)
    wine # Запуск Windows-приложений
    winetricks # Скрипты для настройки Wine
    # --- Графические библиотеки и драйверы ---
    mesa # OpenGL реализация (Mesa)
    mesa.drivers # Драйверы Mesa (GPU)
    libGL # OpenGL библиотеки
    libva # Аппаратное ускорение видео VA-API
    libvdpau # Аппаратное ускорение видео VDPAU
    vulkan-loader # Загрузчик Vulkan (runtime)
    vulkan-tools # Инструменты Vulkan (отладка)
    vulkan-validation-layers # Слои валидации Vulkan (debug)
    amdvlk # Vulkan-драйвер AMD (GPU)
    dxvk # DirectX 9/10/11 → Vulkan (DXVK)
    mesa-demos # Демо-программы для Mesa (тесты)
    virtualgl # Виртуализация OpenGL (удалённо)
    virtualglLib # Библиотеки VirtualGL

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                           ВИРТУАЛИЗАЦИЯ                                  ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    qemu_full # Полная сборка QEMU (виртуализация)
    gnome-boxes # Виртуальные машины GNOME Boxes (GUI)
    libvirt # Менеджер виртуализации libvirt (hypervisor)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        СИСТЕМНЫЕ УТИЛИТЫ                                 ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    gnome-disk-utility # Управление дисками GNOME (разметка, монтирование)
    gnome-system-monitor # Монитор системы GNOME (процессы, ресурсы)
    gnome-calculator # Калькулятор GNOME
    qbittorrent # Торрент-клиент qBittorrent
    remmina # Удалённый рабочий стол Remmina (RDP, VNC)
    upower # Управление питанием (battery, AC)
    blueman # Менеджер Bluetooth Blueman (GUI)
    bluez # Стек Bluetooth BlueZ (ядро)
    bluez-tools # Инструменты BlueZ (CLI)
    glibc # GNU C Library (базовые библиотеки)
    xdg-utils # XDG-утилиты (открытие файлов, mime)

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                           ТЕМЫ И ИКОНКИ                                  ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    catppuccin-gtk # GTK-тема Catppuccin (оформление)
    gnome-themes-extra # Дополнительные темы GNOME
    gsettings-desktop-schemas # Схемы настроек рабочего стола
    catppuccin-qt5ct # Catppuccin тема для qt5ct (Qt приложения)
  ];
}
