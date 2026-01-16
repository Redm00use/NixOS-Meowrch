# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                         Оптимизирован для NixOS 25.05                    ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{ config, pkgs, lib, inputs, firefox-addons, meowrch-scripts, meowrch-themes, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Основные настройки Home Manager                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.username = lib.mkForce "meowrch";
  home.homeDirectory = lib.mkForce "/home/meowrch";
  home.stateVersion = "25.05";

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Overlays                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  # nixpkgs.overlays = [
  #   # Overlay для Spicetify (временно отключен)
  #   # inputs.spicetify-nix.overlays.default
  # ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           Пользовательские пакеты                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.packages = with pkgs; [
    # --- Музыкальный плеер Яндекс.Музыка ---
    # inputs.yandex-music.packages.${pkgs.system}.default  # Temporarily disabled for syntax check

    # --- Zen Browser ---
    inputs.zen-browser.packages.${pkgs.system}.default

    # --- Кастомные скрипты и темы ---
    # meowrch-scripts  # Temporarily disabled due to build issues
    # meowrch-themes   # Temporarily disabled due to build issues

    # --- Дополнительные пакеты пользователя ---
    # Добавьте здесь свои пакеты
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Fish Shell                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.fish = {
    enable = true;

    # --- Универсальные алиасы для NixOS ---
    shellAliases = {
      # === УПРАВЛЕНИЕ NIXOS ===
      # Быстрая пересборка системы
      rebuild = "sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure";
      b = "rebuild";  # короткий алиас

      # Проверка конфигурации без применения
      check = "sudo nixos-rebuild dry-build --flake .#meowrch";
      test = "sudo nixos-rebuild test --flake .#meowrch";

      # Обновление системы
      update = "cd /home/meowrch/NixOS-25.05 && nix flake update && rebuild";
      u = "update";  # короткий алиас

      # Валидация конфигурации
      validate = "cd /home/meowrch/NixOS-25.05 && ./validate-config.sh";

      # === УПРАВЛЕНИЕ NIX ===
      # Очистка мусора
      cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      clean = "cleanup";
      dell = "cleanup";  # оставляем старый алиас для совместимости

      # Оптимизация store
      optimize = "sudo nix-store --optimise";

      # Показать поколения
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      gens = "generations";

      # Откат к предыдущему поколению
      rollback = "sudo nixos-rebuild switch --rollback";

      # === HOME MANAGER ===
      # Применить конфигурацию Home Manager
      home = "home-manager switch --flake .#meowrch";
      hm = "home";

      # Поколения Home Manager
      home-gens = "home-manager generations";

      # === РЕДАКТИРОВАНИЕ КОНФИГУРАЦИИ ===
      # Открыть конфиг в редакторе
      config = "cd /home/meowrch/NixOS-25.05 && zed .";
      c = "config";

      # Быстрое редактирование основных файлов
      edit-config = "zed /home/meowrch/NixOS-25.05/configuration.nix";
      edit-home = "zed /home/meowrch/NixOS-25.05/home/home.nix";
      edit-flake = "zed /home/meowrch/NixOS-25.05/flake.nix";

      # === ИНФОРМАЦИЯ О СИСТЕМЕ ===
      # Системная информация
      sysinfo = "fastfetch";
      f = "sysinfo";

      # Версии и статус
      nixos-version = "nixos-version";
      nix-version = "nix --version";

      # Размер Nix store
      store-size = "du -sh /nix/store";

      # === ПОИСК И ПАКЕТЫ ===
      # Поиск пакетов
      search = "nix search nixpkgs";
      find-pkg = "search";

      # Информация о пакете
      pkg-info = "nix show-derivation";

      # Установка пакета временно
      try = "nix shell nixpkgs#";

      # === FLAKE КОМАНДЫ ===
      # Проверка flake
      flake-check = "nix flake check";
      flake-show = "nix flake show";
      flake-update = "nix flake update";

      # === СИСТЕМНЫЕ КОМАНДЫ ===
      # Журналы
      logs = "journalctl -xe";
      logs-boot = "journalctl -b";
      logs-hypr = "journalctl --user -u hyprland";

      # Сервисы
      services = "systemctl list-units --type=service";
      user-services = "systemctl --user list-units --type=service";

      # === ФАЙЛОВАЯ СИСТЕМА ===
      ll = "ls -la --color=auto";
      la = "ls -la --color=auto";
      l = "ls -l --color=auto";
      ls = "ls --color=auto";

      # Навигация
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Утилиты
      cls = "clear";
      grep = "grep --color=auto";

      # === GIT СОКРАЩЕНИЯ ===
      g = "git";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gco = "git checkout";
      gb = "git branch";
      gd = "git diff";
      gl = "git log --oneline";

      # === БЫСТРЫЕ КОМАНДЫ ===
      # Перезагрузка и выключение
      reboot = "sudo systemctl reboot";
      shutdown = "sudo systemctl poweroff";

      # Сеть
      ip = "ip --color=auto";
      ping = "ping -c 4";

      # Процессы
      ps = "ps aux";
      top = "btop";

      # Диски
      df = "df -h";
      du = "du -sh";

      # === СПЕЦИАЛЬНЫЕ MEOWRCH КОМАНДЫ ===
      # Смена темы
      theme = "python ~/.config/meowrch/meowrch.py --action select-theme";
      wallpaper = "python ~/.config/meowrch/meowrch.py --action select-wallpaper";

      # Быстрый доступ к конфигурации
      cd-config = "cd /home/meowrch/NixOS-25.05";
      cd-home = "cd /home/meowrch/NixOS-25.05/home";
      cd-modules = "cd /home/meowrch/NixOS-25.05/modules";
    };

    # --- Пользовательские функции ---
    functions = {
      # wget с поддержкой XDG_DATA_HOME
      wget = ''
        command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
      '';

      # Функция для быстрого поиска файлов
      ff = ''
        find . -type f -name "*$argv*" 2>/dev/null
      '';

      # Функция для создания и перехода в директорию
      mkcd = ''
        mkdir -p $argv[1] && cd $argv[1]
      '';

      # === РАСШИРЕННЫЕ NIXOS ФУНКЦИИ ===

      # Умный rebuild с валидацией
      smart-rebuild = ''
        echo "🔍 Проверка конфигурации..."
        if ./validate-config.sh
          echo "✅ Конфигурация валидна. Начинаем сборку..."
          sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure
        else
          echo "❌ Найдены ошибки в конфигурации. Сборка отменена."
        end
      '';

      # Backup конфигурации перед изменениями
      backup-config = ''
        set backup_dir "/home/meowrch/config-backups"
        set timestamp (date '+%Y%m%d_%H%M%S')
        set backup_name "nixos-config-$timestamp"

        mkdir -p $backup_dir
        cp -r /home/meowrch/NixOS-25.05 "$backup_dir/$backup_name"
        echo "📦 Конфигурация сохранена в: $backup_dir/$backup_name"
      '';

      # Показать размер разных компонентов системы
      system-size = ''
        echo "📊 Размеры компонентов системы:"
        echo "┌─────────────────┬──────────────┐"
        echo "│ Компонент       │ Размер       │"
        echo "├─────────────────┼──────────────┤"
        printf "│ Nix Store       │ %12s │\n" (du -sh /nix/store 2>/dev/null | cut -f1)
        printf "│ Boot            │ %12s │\n" (du -sh /boot 2>/dev/null | cut -f1)
        printf "│ Home            │ %12s │\n" (du -sh /home 2>/dev/null | cut -f1)
        printf "│ Var             │ %12s │\n" (du -sh /var 2>/dev/null | cut -f1)
        echo "└─────────────────┴──────────────┘"
      '';

      # Анализ поколений системы
      generation-size = ''
        echo "📈 Анализ поколений системы:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | while read gen
          set gen_num (echo $gen | awk '{print $1}')
          if test -n "$gen_num" -a "$gen_num" != "Generation"
            set gen_path "/nix/var/nix/profiles/system-$gen_num-link"
            if test -L $gen_path
              set size (du -sh $gen_path 2>/dev/null | cut -f1)
              printf "Поколение %s: %s\n" $gen_num $size
            end
          end
        end
      '';

      # Поиск пакета с описанием
      pkg-search = ''
        if test (count $argv) -eq 0
          echo "Использование: pkg-search <название_пакета>"
          return 1
        end

        echo "🔍 Поиск пакета: $argv[1]"
        nix search nixpkgs $argv[1] | head -20
      '';

      # Быстрая установка пакета во временное окружение
      quick-install = ''
        if test (count $argv) -eq 0
          echo "Использование: quick-install <пакет1> [пакет2] ..."
          return 1
        end

        echo "⚡ Временная установка: $argv"
        nix shell nixpkgs#$argv[1]
      '';

      # Проверка статуса сервисов
      service-status = ''
        echo "🔧 Статус основных сервисов:"
        echo "┌─────────────────────┬──────────────┐"
        echo "│ Сервис              │ Статус       │"
        echo "├─────────────────────┼──────────────┤"

        set services "pipewire" "bluetooth" "networkmanager" "sddm"
        for service in $services
          set status (systemctl is-active $service 2>/dev/null)
          if test "$status" = "active"
            set status_icon "✅"
          else
            set status_icon "❌"
          end
          printf "│ %-19s │ %s %-10s │\n" $service $status_icon $status
        end
        echo "└─────────────────────┴──────────────┘"
      '';

      # Логи последней сборки
      build-logs = ''
        echo "📋 Последние логи сборки NixOS:"
        journalctl -u nixos-rebuild --since "1 hour ago" --no-pager | tail -50
      '';

      # Сравнение конфигураций между поколениями
      diff-generations = ''
        if test (count $argv) -lt 2
          echo "Использование: diff-generations <поколение1> <поколение2>"
          echo "Пример: diff-generations 1 2"
          return 1
        end

        set gen1 $argv[1]
        set gen2 $argv[2]
        echo "🔄 Сравнение поколений $gen1 и $gen2:"
        sudo nix store diff-closures /nix/var/nix/profiles/system-$gen1-link /nix/var/nix/profiles/system-$gen2-link
      '';

      # Мониторинг сборки в реальном времени
      watch-build = ''
        echo "👁️ Мониторинг сборки NixOS в реальном времени..."
        echo "Нажмите Ctrl+C для остановки"
        journalctl -u nixos-rebuild -f
      '';

      # Быстрая диагностика системы
      system-health = ''
        echo "🏥 Диагностика состояния системы:"
        echo ""
        echo "💾 Память:"
        free -h | head -2
        echo ""
        echo "💿 Диски:"
        df -h | grep -E '^(/dev/|Filesystem)'
        echo ""
        echo "🔥 Температура:"
        sensors 2>/dev/null | grep -E '(Core|temp)' | head -5 || echo "  sensors не установлен"
        echo ""
        echo "⚡ Загрузка системы:"
        uptime
        echo ""
        echo "🔧 Последние ошибки:"
        journalctl -p err --since "1 hour ago" --no-pager | tail -5
      '';
    };

    # --- Инициализация интерактивной оболочки ---
    interactiveShellInit = ''
      set fish_greeting ""

      # Добавить ~/.local/bin в PATH, если его нет
      if not contains -- "$HOME/.local/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.local/bin"
      end

      # Добавить директорию скриптов в PATH
      if not contains -- "$HOME/.config/meowrch/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.config/meowrch/bin"
      end

      # Красивый вывод информации о системе при запуске
      fastfetch
    '';
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Starship Prompt                             ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = "$all$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        style = "bold purple";
      };

      nix_shell = {
        format = "via [$symbol$state]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                        Переменные окружения                              ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";

    # Default applications
    EDITOR = "zed";
    VISUAL = "zed";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Development
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # (Git configuration block intentionally removed; git package can still be installed via system packages)

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                Spicetify                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.spicetify = {
    enable = true;
    # Тема Catppuccin для Spicetify
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.system}.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Catppuccin Theme                            ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    # Disable problematic starship theming
    starship.enable = false;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Firefox                                     ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      extensions = {
        packages = with firefox-addons.packages.${pkgs.system}; [
          ublock-origin
          bitwarden
          privacy-badger
          decentraleyes
          clearurls
        ];
      };

      settings = {
        # Privacy and security
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                  Kitty                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.kitty = {
    enable = true;

    settings = {
      # Font configuration
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;

      # Window layout
      remember_window_size = false;
      initial_window_width = 1200;
      initial_window_height = 800;

      # Colors will be set by Catppuccin

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Wayland settings
      wayland_titlebar_color = "system";
      linux_display_server = "wayland";

      # Scrollback
      scrollback_lines = 10000;

      # URLs
      url_style = "curly";
      open_url_with = "default";

      # Bell
      enable_audio_bell = false;
      visual_bell_duration = 0.0;

      # Window settings
      confirm_os_window_close = 0;
      background_opacity = 0.95;
    };

    keybindings = {
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_window";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+r" = "start_resizing_window";
      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+shift+minus" = "decrease_font_size";
      "ctrl+shift+backspace" = "restore_font_size";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Zed Editor                                  ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Zed config file
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # Theme
    theme = "Catppuccin Mocha";

    # UI Settings
    ui_font_size = 14;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    ui_font_family = "JetBrainsMono Nerd Font";

    # Editor settings
    tab_size = 2;
    soft_wrap = "editor_width";
    show_whitespaces = "all";
    relative_line_numbers = true;
    cursor_blink = true;

    # Git integration
    git.git_gutter = "tracked_files";
    git.inline_blame.enabled = true;

    # Language settings
    languages = {
      Nix = {
        language_servers = ["nil"];
        formatter = "alejandra";
      };
    };

    # Terminal
    terminal = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 14;
    };

    # Auto save
    autosave = "on_focus_change";
    format_on_save = "on";

    # File tree
    project_panel = {
      dock = "left";
      default_width = 240;
    };

    # Vim mode (optional)
    vim_mode = false;

    # Assistant (disable if not needed)
    assistant = {
      enabled = false;
    };
  };

  # Zed keymap file
  home.file.".config/zed/keymap.json".text = builtins.toJSON [
    {
      context = "Editor";
      bindings = {
        "ctrl-/" = "editor::ToggleComments";
        "ctrl-d" = "editor::SelectNext";
        "ctrl-shift-k" = "editor::DeleteLine";
        "ctrl-shift-d" = "editor::DuplicateLine";
        "ctrl-p" = "file_finder::Toggle";
        "ctrl-shift-p" = "command_palette::Toggle";
        "ctrl-shift-f" = "search::ToggleReplace";
        "ctrl-`" = "terminal_panel::ToggleFocus";
      };
    }
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Dotfiles                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Создание необходимых директорий
  home.file.".local/bin/.keep".text = "";
  home.file.".config/meowrch/.keep".text = "";

  # Автоматический запуск Home Manager
  programs.home-manager.enable = true;

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                            Systemd Services                              ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  systemd.user.services = {
    # Автоматическое обновление wallpaper (если есть скрипты)
    wallpaper-changer = {
      Unit = {
        Description = "Random wallpaper changer";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -x $HOME/.config/meowrch/bin/change-wallpaper.sh ]; then $HOME/.config/meowrch/bin/change-wallpaper.sh; fi'";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                 XDG                                      ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "image/jpeg" = [ "feh.desktop" ];
        "image/png" = [ "feh.desktop" ];
        "image/gif" = [ "feh.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "audio/mpeg" = [ "mpv.desktop" ];
        "audio/flac" = [ "mpv.desktop" ];
      };
    };
  };
}
