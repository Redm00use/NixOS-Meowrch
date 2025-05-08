{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.portproton;
  
  # Скрипт для оптимизации системы для игр
  portproton-optimize = pkgs.writeShellScriptBin "portproton-optimize" ''
    #!/usr/bin/env bash
    
    # Переменные для вывода
    BOLD="\e[1m"
    RESET="\e[0m"
    RED="\e[31m"
    GREEN="\e[32m"
    BLUE="\e[34m"
    YELLOW="\e[33m"
    
    # Функция для вывода сообщений
    show_message() {
      echo -e "\e[1;34m==>\e[0m \e[1m$1\e[0m"
    }
    
    # Проверка наличия прав root
    if [ "$EUID" -ne 0 ]; then
      echo -e "$RED$BOLD Ошибка: Запустите скрипт с правами root (sudo)!$RESET"
      exit 1
    fi
    
    # Приветствие
    echo -e "$BLUE$BOLD╔════════════════════════════════════════════════════════════════════════════╗$RESET"
    echo -e "$BLUE$BOLD║                          ОПТИМИЗАЦИЯ PORTPROTON                         ║$RESET"
    echo -e "$BLUE$BOLD╚════════════════════════════════════════════════════════════════════════════╝$RESET"
    
    # Оптимизации системы для игр
    show_message "Применение оптимизаций для игр..."
    
    # 1. Оптимизация CPU governor
    show_message "Настройка CPU governor на performance..."
    
    # Проверка и установка cpupower если не установлен
    if ! command -v cpupower &> /dev/null; then
      echo "Установка cpupower..."
      nix-env -iA nixos.linuxPackages.cpupower
    fi
    
    # Установка performance governor
    cpupower frequency-set -g performance
    
    # 2. Оптимизация параметров ядра
    show_message "Оптимизация параметров ядра..."
    sysctl -w vm.swappiness=10
    sysctl -w vm.vfs_cache_pressure=50
    sysctl -w vm.max_map_count=1048576
    sysctl -w fs.file-max=100000
    
    # 3. Настройка I/O scheduler для дисков
    show_message "Оптимизация планировщика I/O..."
    for drive in /sys/block/sd*; do
      if [ -e "$drive/queue/scheduler" ]; then
        echo "mq-deadline" > "$drive/queue/scheduler" 2>/dev/null || true
      fi
    done
    
    # 4. Отключение ненужных служб при игровой сессии
    show_message "Временное отключение ненужных сервисов..."
    systemctl stop bluetooth.service || true
    systemctl stop cups.service || true
    systemctl stop avahi-daemon.service || true
    
    # 5. Очистка кеша памяти
    show_message "Очистка кеша памяти..."
    sync; echo 3 > /proc/sys/vm/drop_caches
    
    # 6. Установка приоритета процессов
    show_message "Настройка приоритетов процессов..."
    for pid in $(pgrep steam); do
      renice -n -5 -p $pid 2>/dev/null || true
    done
    
    for pid in $(pgrep portproton); do
      renice -n -5 -p $pid 2>/dev/null || true
    done
    
    # 7. Настройка irqbalance
    show_message "Оптимизация распределения прерываний..."
    systemctl restart irqbalance.service 2>/dev/null || true
    
    # 8. Включение Gamemode
    show_message "Активация GameMode..."
    systemctl --user start gamemoded.service 2>/dev/null || true
    
    echo -e "$GREEN$BOLD Система оптимизирована для запуска игр через Port Proton!$RESET"
    echo -e "$YELLOW$BOLD Примечание: Оптимизации временные и будут сброшены после перезагрузки$RESET"
    echo -e "$YELLOW$BOLD Для постоянных настроек добавьте параметры в конфигурацию NixOS$RESET"
  '';
  
  # Конфигурационный файл vkBasalt для Port Proton
  vkbasalt-conf = pkgs.writeTextFile {
    name = "vkbasalt.conf";
    text = ''
      # Конфигурация vkBasalt для Port Proton
      
      # Включение/отключение эффектов
      effects = cas
      
      # Настройка CAS (Contrast Adaptive Sharpening)
      cas_sharpness = 0.4
      
      # Клавиша для включения/выключения
      toggleKey = Home

      # Другие эффекты
      # effects = cas:fxaa:smaa

      # Настройки FXAA
      # fxaa_quality = 3

      # Настройки SMAA
      # smaa_edge_detection = luma
      # smaa_threshold = 0.05
      # smaa_max_search_steps = 32
      # smaa_max_search_steps_diag = 16
      # smaa_corner_rounding = 25
    '';
  };
  
  # Конфигурационный файл MangoHud для Port Proton
  mangohud-conf = pkgs.writeTextFile {
    name = "MangoHud.conf";
    text = ''
      ### MangoHud configuration для Port Proton ###

      # Основные настройки
      fps_limit=0
      vsync=0
      gl_vsync=0
      
      # Отображаемая информация
      fps
      frametime
      gpu_stats
      gpu_temp
      gpu_power
      cpu_stats
      cpu_temp
      ram
      vram
      wine
      
      # Позиция и размер
      position=top-left
      font_size=24
      background_alpha=0.5
      
      # Цветовая схема (Catppuccin Mocha)
      text_color=cdd6f4
      background_color=1e1e2e
      gpu_color=f5c2e7
      cpu_color=89b4fa
      vram_color=f38ba8
      ram_color=a6e3a1
      engine_color=cba6f7
      io_color=89dceb
      frametime_color=fab387
      
      # Горячая клавиша переключения
      toggle_hud=F12
    '';
  };
  
  # Создаем скрипт для установки конфигураций
  portproton-config-install = pkgs.writeShellScriptBin "portproton-config-install" ''
    #!/usr/bin/env bash
    
    # Создаем директории
    mkdir -p "$HOME/.config/vkBasalt"
    mkdir -p "$HOME/.config/MangoHud"
    
    # Копируем конфигурации
    cp ${vkbasalt-conf} "$HOME/.config/vkBasalt/vkBasalt.conf"
    cp ${mangohud-conf} "$HOME/.config/MangoHud/MangoHud.conf"
    
    # Создаем конфигурацию portproton
    mkdir -p "$HOME/.var/app/portproton/data_from_portwine/data/prefixes/default/drive_c/users/steamuser/My Documents/My Games/PortProton"
    
    cat > "$HOME/.var/app/portproton/data_from_portwine/data/prefixes/default/drive_c/users/steamuser/My Documents/My Games/PortProton/portproton.conf" << EOF
    # Оптимизированная конфигурация PortProton
    
    # Используем DXVK для DirectX
    DXVK="1"
    
    # Используем VKD3D для DirectX12
    VKD3D="1"
    
    # DLSS/FSR для улучшения FPS
    DLSS="1"
    FSR="1"
    
    # MangoHud и GameMode
    MANGOHUD="1"
    GAMEMODE="1"
    MANGOHUD_CONFIG="fps,frametime,gpu_stats,cpu_stats,ram,vram,wine,gpu_temp,cpu_temp"
    
    # Оптимизации для Wine
    WINE_FULLSCREEN_FSR="1"
    WINE_LARGE_ADDRESS_AWARE="1"
    
    # Многопоточность
    WINE_MT="1"
    
    # Настройки синхронизации
    ESYNC="1"
    FSYNC="1"
    
    # Аудио настройки
    PULSE_LATENCY="60"
    
    # Vulkan синхронизация
    WINE_VULKAN_NEGATIVE_MIP_BIAS="0"
    VK_PRESENT_MAILBOX="1"
    VK_USE_PRESENT_IMAGE_LAYOUT_TRANSFER_SRC="1"
    EOF
    
    echo "Конфигурации успешно установлены!"
  '';
in {
  options.programs.portproton.optimizations = {
    enable = mkEnableOption "Оптимизации производительности для Port Proton";
    
    managedConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Установить оптимизированную конфигурацию для vkBasalt и MangoHud";
    };
    
    systemTweaks = mkOption {
      type = types.bool;
      default = true;
      description = "Применить системные оптимизации для повышения производительности";
    };
  };
  
  config = mkIf (cfg.enable && cfg.optimizations.enable) {
    # Устанавливаем скрипты и настройки
    environment.systemPackages = [
      portproton-optimize
      portproton-config-install
    ];
    
    # Системные настройки для повышения производительности
    boot.kernelParams = mkIf cfg.optimizations.systemTweaks [
      "intel_pstate=active"
      "mitigations=off"
      "nowatchdog"
      "threadirqs"
      "acpi_osi=Linux"
    ];
    
    # Настройки ядра
    boot.kernel.sysctl = mkIf cfg.optimizations.systemTweaks {
      "vm.swappiness" = 10;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
      "kernel.sched_autogroup_enabled" = 0;
      "kernel.sched_wakeup_granularity_ns" = 15000000;
      "kernel.sched_min_granularity_ns" = 10000000;
      "kernel.sched_migration_cost_ns" = 500000;
    };
    
    # Устанавливаем gamemode и mangohud
    programs.gamemode.enable = true;
    programs.gamescope.enable = mkDefault true;
    
    # Настраиваем файрвол для онлайн-игр
    networking.firewall.allowedTCPPortRanges = [
      { from = 27015; to = 27030; } # Steam, Source Engine Games
      { from = 3478; to = 3480; }   # Steam (voice chat)
      { from = 7777; to = 27900; }  # Common game ports
    ];
    
    networking.firewall.allowedUDPPortRanges = [
      { from = 27000; to = 27031; } # Steam, Source Engine Games
      { from = 4380; to = 4380; }   # Steam
      { from = 3478; to = 3479; }   # Steam (voice chat)
    ];
    
    # Автоматически устанавливаем конфигурации
    system.userActivationScripts = mkIf cfg.optimizations.managedConfig {
      installPortProtonConfigs = {
        text = ''
          if [ -d "$HOME/.var/app/portproton" ]; then
            ${portproton-config-install}/bin/portproton-config-install
          fi
        '';
      };
    };
  };
}