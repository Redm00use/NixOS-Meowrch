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
        packages = with firefox-addons; [
          ublock-origin
          bitwarden
        ];
      };

      settings = {
        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # Theming and UI
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0; # Use system theme
        "browser.theme.toolbar-theme" = 0; # Use system theme
        "extensions.activeThemeID" = "default-theme@mozilla.org";

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

  # Dynamic Zed config (writable via theme script)
  home.file.".config/zed/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/${meowrchUser}/.cache/meowrch/zed/settings.json";
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
  home.file.".cache/meowrch/zed/settings.json".text = builtins.toJSON {
    theme = "One Dark Pro";
    theme_mode = "dark";
    ui_font_size = 14;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    ui_font_family = "JetBrainsMono Nerd Font";
    tab_size = 2;
    soft_wrap = "editor_width";
    git.git_gutter = "tracked_files";
    assistant = {
      enabled = true;
      version = "2";
      default_model = {
        provider = "openrouter";
        model = "deepseek/deepseek-r1-0528";
      };
    };
  };

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
