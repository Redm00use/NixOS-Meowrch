{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.portproton;
  
  # Зависимости, необходимые для работы Port Proton
  dependencies = with pkgs; [
    # Базовые библиотеки
    zlib
    glibc
    ncurses
    libglvnd
    libpulseaudio
    libudev0-shim
    freetype
    fontconfig
    glib
    gtk3
    gnome.zenity
    
    # Vulkan и графические библиотеки
    vulkan-loader
    vulkan-tools
    mesa
    mesa-demos
    
    # Аудио поддержка
    pipewire
    alsa-lib
    alsa-plugins
    
    # Графические библиотеки
    libGL
    libva
    
    # Улучшения
    gamemode
    mangohud
    vkBasalt
    
    # Утилиты
    wget
    curl
    git
    cabextract
    unzip
    p7zip
    jq
    pciutils
    python311
    python311Packages.vdf
    python311Packages.pillow
    
    # Wine зависимости
    wine
    winetricks
  ];
  
  # Скрипт для автоматизированной загрузки и установки Port Proton
  portproton-installer = pkgs.writeShellScriptBin "portproton-installer" ''
    #!/usr/bin/env bash
    
    # Переменные
    USER_HOME=$HOME
    INSTALL_DIR="$USER_HOME/.var/app/portproton"
    PP_REPO="https://github.com/Castro-Fidel/PortWINE"
    CONFIG_DIR="$USER_HOME/.config/portwine"
    
    # Создаем необходимые директории
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # Функция для вывода сообщений
    show_message() {
      echo -e "\e[1;34m==>\e[0m \e[1m$1\e[0m"
    }
    
    # Проверка установлен ли уже Port Proton
    if [ -f "$INSTALL_DIR/data_from_portwine/scripts/portwine_manager" ]; then
      show_message "Port Proton уже установлен. Обновляем..."
      cd "$INSTALL_DIR"
      git pull
      exit 0
    fi
    
    # Загрузка и установка Port Proton
    show_message "Загрузка Port Proton из репозитория..."
    git clone --depth=1 "$PP_REPO" "$INSTALL_DIR"
    
    if [ ! -d "$INSTALL_DIR/data_from_portwine" ]; then
      show_message "Ошибка при загрузке Port Proton!"
      exit 1
    fi
    
    # Создание конфигурации
    show_message "Настройка Port Proton..."
    
    # Создаем ссылку для запуска
    mkdir -p "$USER_HOME/.local/bin"
    
    cat > "$USER_HOME/.local/bin/portproton" << 'EOF'
    #!/usr/bin/env bash
    
    export PORTPROTON_DIR="$HOME/.var/app/portproton"
    
    if [ ! -d "$PORTPROTON_DIR" ]; then
      echo "Port Proton не установлен! Запустите portproton-installer"
      exit 1
    fi
    
    cd "$PORTPROTON_DIR/data_from_portwine"
    bash "./scripts/portwine_manager" "$@"
    EOF
    
    chmod +x "$USER_HOME/.local/bin/portproton"
    
    # Создаем .desktop файл
    mkdir -p "$USER_HOME/.local/share/applications"
    
    cat > "$USER_HOME/.local/share/applications/portproton.desktop" << EOF
    [Desktop Entry]
    Name=Port Proton
    Comment=Wine-based compatibility layer for Windows applications on Linux
    Exec=$USER_HOME/.local/bin/portproton
    Icon=$INSTALL_DIR/data_from_portwine/img/gui/portproton.svg
    Terminal=false
    Type=Application
    Categories=Game;Utility;
    EOF
    
    show_message "Port Proton успешно установлен!"
    show_message "Запустите 'portproton' для начала работы."
  '';
  
  # Скрипт для запуска и обновления Port Proton
  portproton-run = pkgs.writeShellScriptBin "portproton" ''
    #!/usr/bin/env bash
    
    PORTPROTON_DIR="$HOME/.var/app/portproton"
    
    if [ ! -d "$PORTPROTON_DIR" ]; then
      echo "Port Proton не установлен! Запускаем установщик..."
      portproton-installer
    fi
    
    cd "$PORTPROTON_DIR/data_from_portwine"
    bash "./scripts/portwine_manager" "$@"
  '';
  
  # Обертка для удаления, если пользователь хочет начать заново
  portproton-remove = pkgs.writeShellScriptBin "portproton-remove" ''
    #!/usr/bin/env bash
    
    echo -e "\e[1;33mВнимание! Это действие удалит все данные Port Proton!\e[0m"
    read -p "Вы уверены, что хотите продолжить? (y/N) " confirmation
    
    if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
      echo "Удаление Port Proton..."
      rm -rf "$HOME/.var/app/portproton"
      rm -rf "$HOME/.config/portwine"
      rm -f "$HOME/.local/bin/portproton"
      rm -f "$HOME/.local/share/applications/portproton.desktop"
      echo "Port Proton успешно удален!"
    else
      echo "Операция отменена."
    fi
  '';
  
in {
  options.programs.portproton = {
    enable = mkEnableOption "Port Proton - улучшенная версия Proton для запуска Windows игр";
    
    systemWide = mkOption {
      type = types.bool;
      default = false;
      description = "Установить Port Proton для всех пользователей (требует root)";
    };
    
    autoInstall = mkOption {
      type = types.bool;
      default = true;
      description = "Автоматически установить Port Proton при первом запуске";
    };
  };
  
  config = mkIf cfg.enable {
    # Устанавливаем все зависимости
    environment.systemPackages = dependencies ++ [
      portproton-installer
      portproton-run
      portproton-remove
    ];
    
    # Необходимые опции для работы
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    
    # Поддержка 32-bit библиотек
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Vulkan поддержка
    hardware.pulseaudio.enable = lib.mkForce false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Оптимизации ядра для игр
    boot.kernel.sysctl = {
      "vm.max_map_count" = 1048576;
      "fs.file-max" = 100000;
    };
    
    # Разрешаем доступ к магазинам игр
    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };
    
    # Автоматическая установка для пользователя
    system.userActivationScripts = mkIf cfg.autoInstall {
      installPortProton = {
        text = ''
          if [ ! -d "$HOME/.var/app/portproton" ]; then
            ${portproton-installer}/bin/portproton-installer
          fi
        '';
      };
    };
  };
}