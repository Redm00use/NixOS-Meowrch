{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.portproton;
  
  # Генерация .desktop файлов для игр
  portproton-desktop-gen = pkgs.writeShellScriptBin "portproton-desktop-gen" ''
    #!/usr/bin/env bash
    
    # Переменные
    PORTPROTON_DIR="$HOME/.var/app/portproton"
    DESKTOP_DIR="$HOME/.local/share/applications"
    GAMES_DIR="$PORTPROTON_DIR/data_from_portwine/data/prefixes"
    
    # Функция для вывода сообщений
    show_message() {
      echo -e "\e[1;34m==>\e[0m \e[1m$1\e[0m"
    }
    
    # Проверка установки Port Proton
    if [ ! -d "$PORTPROTON_DIR" ]; then
      show_message "Port Proton не установлен! Сначала установите Port Proton."
      exit 1
    fi
    
    # Создаем директорию для .desktop файлов
    mkdir -p "$DESKTOP_DIR"
    
    # Функция для генерации .desktop файла
    generate_desktop_file() {
      local name="$1"
      local prefix="$2"
      local exe_path="$3"
      local icon_path="$4"
      
      # Если путь к иконке пустой, используем иконку Port Proton
      if [ -z "$icon_path" ] || [ ! -f "$icon_path" ]; then
        icon_path="$PORTPROTON_DIR/data_from_portwine/img/gui/portproton.svg"
      fi
      
      # Создаем .desktop файл
      cat > "$DESKTOP_DIR/portproton-$prefix-$name.desktop" << EOF
    [Desktop Entry]
    Name=$name (Port Proton)
    Comment=Запуск через Port Proton
    Exec=$HOME/.local/bin/portproton --run "$prefix" "$exe_path"
    Icon=$icon_path
    Terminal=false
    Type=Application
    Categories=Game;
    StartupWMClass=$name
    EOF
      
      show_message "Создан ярлык для $name"
    }
    
    # Сканируем установленные игры
    show_message "Сканирование установленных игр..."
    
    if [ ! -d "$GAMES_DIR" ]; then
      show_message "Директория с префиксами не найдена!"
      exit 1
    fi
    
    # Для каждого префикса ищем .exe файлы
    found_games=0
    
    for prefix_dir in "$GAMES_DIR"/*; do
      if [ ! -d "$prefix_dir" ]; then
        continue
      fi
      
      prefix_name=$(basename "$prefix_dir")
      
      # Проверяем наличие файла конфигурации игры
      portproton_conf="$prefix_dir/drive_c/users/steamuser/My Documents/My Games/PortProton/portproton.conf"
      
      if [ -f "$portproton_conf" ]; then
        # Получаем имя игры из конфигурации
        game_name=$(grep "^LAUNCHER_NAME=" "$portproton_conf" | cut -d'"' -f2)
        exe_path=$(grep "^LAUNCHER_EXE=" "$portproton_conf" | cut -d'"' -f2)
        icon_path=$(grep "^LAUNCHER_ICON=" "$portproton_conf" | cut -d'"' -f2)
        
        if [ -n "$game_name" ] && [ -n "$exe_path" ]; then
          generate_desktop_file "$game_name" "$prefix_name" "$exe_path" "$icon_path"
          found_games=$((found_games + 1))
        fi
      fi
    done
    
    if [ "$found_games" -eq 0 ]; then
      show_message "Не найдено игр с конфигурацией в Port Proton."
      show_message "Сначала запустите игры через Port Proton!"
    else
      show_message "Успешно создано $found_games ярлыков для рабочего стола."
    fi
  '';
  
  # Интеграция с файловым менеджером
  portproton-mime-types = pkgs.writeTextFile {
    name = "portproton-mime.xml";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        <mime-type type="application/x-ms-dos-executable">
          <comment>Windows executable</comment>
          <glob pattern="*.exe"/>
        </mime-type>
        <mime-type type="application/x-wine-extension-msi">
          <comment>Windows Installer package</comment>
          <glob pattern="*.msi"/>
        </mime-type>
      </mime-info>
    '';
  };
  
  # Скрипт для открытия .exe через PortProton
  portproton-mime-handler = pkgs.writeShellScriptBin "portproton-mime-handler" ''
    #!/usr/bin/env bash
    
    # Проверяем наличие аргумента
    if [ -z "$1" ]; then
      echo "Использование: $0 <путь к .exe файлу>"
      exit 1
    fi
    
    EXE_PATH="$1"
    
    # Запускаем выбор префикса через zenity
    PREFIX=$(zenity --list --title="Выберите префикс Port Proton" \
      --column="Префикс" \
      --width=400 --height=300 \
      "default" \
      $(ls -1 "$HOME/.var/app/portproton/data_from_portwine/data/prefixes/" | grep -v "default") \
      "new_prefix")
    
    # Если пользователь отменил выбор
    if [ -z "$PREFIX" ]; then
      exit 0
    fi
    
    # Если выбрано создание нового префикса
    if [ "$PREFIX" = "new_prefix" ]; then
      NEW_PREFIX=$(zenity --entry --title="Новый префикс" --text="Введите имя нового префикса:" \
        --width=400)
      
      if [ -z "$NEW_PREFIX" ]; then
        exit 0
      fi
      
      PREFIX="$NEW_PREFIX"
    fi
    
    # Запускаем через Port Proton
    "$HOME/.local/bin/portproton" --run "$PREFIX" "$EXE_PATH"
  '';
  
  # Установка и настройка обработчика .exe файлов
  portproton-mime-setup = pkgs.writeShellScriptBin "portproton-mime-setup" ''
    #!/usr/bin/env bash
    
    DESKTOP_DIR="$HOME/.local/share/applications"
    MIME_DIR="$HOME/.local/share/mime"
    
    # Создаем директории
    mkdir -p "$DESKTOP_DIR"
    mkdir -p "$MIME_DIR/packages"
    
    # Создаем .desktop файл для обработчика .exe
    cat > "$DESKTOP_DIR/portproton-exe-handler.desktop" << EOF
    [Desktop Entry]
    Name=Port Proton EXE Handler
    Comment=Запуск Windows приложений через Port Proton
    Exec=$HOME/.local/bin/portproton-mime-handler %f
    Icon=$HOME/.var/app/portproton/data_from_portwine/img/gui/portproton.svg
    Terminal=false
    Type=Application
    MimeType=application/x-ms-dos-executable;application/x-wine-extension-msi;
    NoDisplay=true
    EOF
    
    # Копируем файл типов MIME
    cp ${portproton-mime-types} "$MIME_DIR/packages/portproton-mime.xml"
    
    # Обновляем базу данных MIME
    update-mime-database "$MIME_DIR"
    
    # Устанавливаем Port Proton как обработчик по умолчанию для .exe
    xdg-mime default portproton-exe-handler.desktop application/x-ms-dos-executable
    xdg-mime default portproton-exe-handler.desktop application/x-wine-extension-msi
    
    echo "Port Proton установлен как обработчик .exe и .msi файлов"
  '';
  
in {
  options.programs.portproton.desktop = {
    enable = mkEnableOption "Интеграция Port Proton с рабочим столом";
    
    mimeHandler = mkOption {
      type = types.bool;
      default = true;
      description = "Установить Port Proton как обработчик .exe файлов";
    };
    
    autoCreateDesktopFiles = mkOption {
      type = types.bool;
      default = true;
      description = "Автоматически создавать ярлыки на рабочем столе для игр";
    };
  };
  
  config = mkIf (cfg.enable && cfg.desktop.enable) {
    # Устанавливаем необходимые пакеты
    environment.systemPackages = [
      portproton-desktop-gen
      portproton-mime-handler
      portproton-mime-setup
    ];
    
    # Добавляем в автозагрузку создание desktop-файлов
    system.userActivationScripts = mkIf cfg.desktop.autoCreateDesktopFiles {
      portprotonDesktopIntegration = {
        text = ''
          if [ -d "$HOME/.var/app/portproton" ]; then
            ${portproton-desktop-gen}/bin/portproton-desktop-gen
          fi
        '';
      };
    };
    
    # Устанавливаем обработчик MIME если включено
    system.userActivationScripts = mkIf cfg.desktop.mimeHandler {
      portprotonMimeSetup = {
        text = ''
          if [ -d "$HOME/.var/app/portproton" ]; then
            ${portproton-mime-setup}/bin/portproton-mime-setup
          fi
        '';
      };
    };
  };
}