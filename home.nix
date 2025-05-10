# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                             Сделал: Redm00us                             ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Основные настройки Home Manager                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.username = "redm00us";
  home.homeDirectory = "/home/redm00us";
  home.stateVersion = "24.11";

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Overlays                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  nixpkgs.overlays = [
    # Overlay для Spicetify
    inputs.spicetify-nix.overlays.default
    # Overlay для Catppuccin тем
    inputs.catppuccin-nix.overlays.default
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           Пользовательские пакеты                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.packages = with pkgs; [
    # --- Музыкальный плеер Яндекс.Музыка ---
    inputs.yandex-music.packages.${pkgs.system}.default

    # --- Zen Browser ---
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Fish Shell                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.fish = {
    enable = true;

    # --- Алиасы ---
    shellAliases = {
      # Быстрая пересборка системы
      b = "sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /etc/nixos#nixos --impure";
      # Открыть конфиг NixOS в VSCode от root
      c = "code --user-data-dir=\"$HOME/.vscode-root\" /etc/nixos/configuration.nix";
      # Обновить флейк и пересобрать систему
      u = "cd /etc/nixos/ & nix flake update && sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /etc/nixos#nixos --impure";
      # Быстрый вывод информации о системе
      f = "fastfetch";
      # Очистка мусора Nix
      dell = "sudo nix-collect-garbage -d";
    };

    # --- Пользовательские функции ---
    functions = {
      # wget с поддержкой XDG_DATA_HOME
      wget = ''
        command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
      '';
    };

    # --- Инициализация интерактивной оболочки ---
    interactiveShellInit = ''
      set fish_greeting ""
      # Добавить ~/.local/bin в PATH, если его нет
      if not contains -- "$HOME/.local/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.local/bin"
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
    # Включить поддержку Wayland для Firefox
    MOZ_ENABLE_WAYLAND = "1";
    # Использовать Wayland для SDL
    SDL_VIDEODRIVER = "wayland";
    # Использовать Wayland для Qt
    QT_QPA_PLATFORM = "wayland";
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                   Git                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.git = {
    enable = true;
    userName = "Redm00us";
    userEmail = "krokismau@icloud.com";
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                Spicetify                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.spicetify = {
    enable = true;
    # Тема Catppuccin для Spicetify
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
    colorScheme = "mocha";
    enabledExtensions = [];
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Dotfiles                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  # Пример: подключение конфига Hyprland
  # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
}
