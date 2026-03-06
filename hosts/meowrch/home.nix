# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                         Оптимизирован для NixOS 25.11                    ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  inputs,
  firefox-addons,
  pkgs-unstable,
  meowrchUser,
  meowrchHostname,
  ...
}: {
  imports = [
    ../../modules/home/rofi.nix
    ../../modules/home/gtk.nix
    ../../modules/home/fish.nix
    ../../modules/home/starship.nix
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Основные настройки Home Manager                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.username = lib.mkForce meowrchUser;
  home.homeDirectory = lib.mkForce "/home/${meowrchUser}";
  home.stateVersion = "25.11";

  # Cursor theme (critical for Wayland — without this, cursor stays default)
  # bibata-cursors ships a built-in hyprcursor theme (no separate package needed)
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;       # writes ~/.icons/default/index.theme + gtk settings
    x11.enable = true;       # writes ~/.Xresources cursor entry
    hyprcursor.enable = true; # sets HYPRCURSOR_THEME / HYPRCURSOR_SIZE for Hyprland
    hyprcursor.size = 24;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           Пользовательские пакеты                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.packages = with pkgs; [
    # --- Кастомные скрипты и темы ---
    meowrch-scripts
    meowrch-themes
    mewline
    fabric-cli
    pawlette
    meowrch-tools

    # --- Дополнительные пакеты пользователя ---
    pkgs-unstable.gemini-cli
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Systemd Services                           ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  systemd.user.services.mewline = {
    Unit = {
      Description = "Mewline Dynamic Island Status Bar";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.mewline}/bin/mewline";
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                  Pyenv                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.pyenv = {
    enable = true;
    enableFishIntegration = true;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                        Переменные окружения                              ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";

    # XDG directories (critical for scripts)
    XDG_BIN_HOME = "$HOME/.config/meowrch/bin";

    # Default applications
    EDITOR = "zed";
    VISUAL = "zed";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Development
    NIXPKGS_ALLOW_UNFREE = "1";
    # OPENROUTER_API_KEY задаётся локально в ~/.config/fish/conf.d/99-local-secrets.fish
  };

  # (Git configuration block intentionally removed; git package can still be installed via system packages)

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                Spicetify                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.spicetify = {
    enable = true;
    # Тема Catppuccin для Spicetify
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.extensions; [
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

    # Disable problematic integrations
    starship.enable = false;
    delta.enable = false; # workaround: programs.git.delta.enable renamed in HM 25.11
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
        force = true;
        packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
        ];
      };

      settings = {
        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;

        # Fix for Google login persistence
        "network.cookie.cookieBehavior" = 0; # Accept all cookies
        "privacy.trackingprotection.enabled" = false;
        "privacy.trackingprotection.socialtracking.enabled" = false;
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Zed Editor                                  ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Zed config file
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # Theme
    theme = "One Dark Pro";
    theme_mode = "dark";

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
        formatter = {
          external = {
            command = "alejandra";
            arguments = ["-"];
          };
        };
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

    # Assistant / AI Agent — OpenRouter (DeepSeek R1 0528 по умолчанию)
    assistant = {
      enabled = true;
      version = "2";
      default_model = {
        provider = "openrouter";
        model = "deepseek/deepseek-r1-0528";
      };
      system_prompt = "Всегда отвечай на русском языке. Код и технические термины можно оставлять на английском, но все объяснения, комментарии и ответы пиши на русском.";
    };

    # Дополнительные провайдеры AI
    # API ключ читается из env: OPENROUTER_API_KEY (задан локально, не в git)
    language_models = {
      openrouter = {
        available_models = [
          {
            provider = "openrouter";
            name = "anthropic/claude-3.7-sonnet";
            display_name = "Claude 3.7 Sonnet";
            max_tokens = 200000;
          }
          {
            provider = "openrouter";
            name = "anthropic/claude-3.5-sonnet";
            display_name = "Claude 3.5 Sonnet";
            max_tokens = 200000;
          }
          {
            provider = "openrouter";
            name = "google/gemini-2.0-flash";
            display_name = "Gemini 2.0 Flash";
            max_tokens = 1000000;
          }
          {
            provider = "openrouter";
            name = "openai/gpt-4o";
            display_name = "GPT-4o";
            max_tokens = 128000;
          }
          {
            provider = "openrouter";
            name = "deepseek/deepseek-r1-0528";
            display_name = "DeepSeek R1 0528";
            max_tokens = 64000;
          }
          {
            provider = "openrouter";
            name = "deepseek/deepseek-r1";
            display_name = "DeepSeek R1";
            max_tokens = 64000;
          }
        ];
      };
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
        "ctrl-shift-d" = "editor::DuplicateLineDown";
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

  # Создание необходимых директорий и файлов-заглушек
  home.file.".local/bin/.keep".text = "";
  home.file.".config/.keep".text = "";
  home.file.".cache/meowrch/hypr/theme.conf".text = "# Initial theme placeholder\n";
  home.file.".cache/meowrch/kitty/theme.conf".text = "# Initial theme placeholder\n";
  home.file.".cache/meowrch/waybar/theme.css".text = "/* Initial theme placeholder */\n";

  # Подключение конфигураций из репозитория
  home.file.".config/hypr" = {
    source = ../../config/hypr;
    recursive = true;
    force = true;
  };
  home.file.".config/kitty" = {
    source = ../../config/kitty;
    recursive = true;
    force = true;
  };
  home.file.".config/fastfetch" = {
    source = ../../config/fastfetch;
    recursive = true;
    force = true;
  };
  home.file.".config/btop" = {
    source = ../../config/btop;
    recursive = true;
    force = true;
  };
  home.file.".config/meowrch" = {
    source = ../../config/meowrch;
    recursive = true;
    force = true;
  };
  home.file.".config/meowrch/bin" = {
    source = ../../scripts;
    recursive = true;
    force = true;
  };

  # Qt5ct/Qt6ct конфигурация — Catppuccin Mocha тема для Qt приложений (Ark и др.)
  home.file.".config/qt5ct" = {
    source = ../../config/qt5ct;
    recursive = true;
    force = true;
  };
  home.file.".config/qt6ct" = {
    source = ../../config/qt6ct;
    recursive = true;
    force = true;
  };
  home.file.".config/meowrch/wallpapers" = {
    source = "${pkgs.meowrch-themes}/share/wallpapers/meowrch";
    recursive = true;
    force = true;
  };
  home.file.".local/share/wallpapers" = {
    source = "${pkgs.meowrch-themes}/share/wallpapers/meowrch";
    recursive = true;
    force = true;
  };

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
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -x $HOME/.config/meowrch/bin/change-wallpaper.sh ]; then $HOME/.config/meowrch/bin/change-wallpaper.sh; fi'";
      };

      Install = {
        WantedBy = ["default.target"];
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
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
        "application/pdf" = ["firefox.desktop"];
        "image/jpeg" = ["feh.desktop"];
        "image/png" = ["feh.desktop"];
        "image/gif" = ["feh.desktop"];
        "video/mp4" = ["mpv.desktop"];
        "video/x-matroska" = ["mpv.desktop"];
        "audio/mpeg" = ["mpv.desktop"];
        "audio/flac" = ["mpv.desktop"];
      };
    };
  };
}
