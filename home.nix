# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                             Сделал: Redm00us                             ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{ config, pkgs, lib, inputs, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Основные настройки Home Manager                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.username = "meowrch";
  home.homeDirectory = "/home/meowrch";
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
    inputs.yandex-music.packages.${pkgs.stdenv.hostPlatform.system}.default

    # --- Zen Browser ---
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # --- Python dependency for meowrch.py (yaml) ---
    (python311.withPackages (ps: with ps; [ pyyaml ]))
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Fish Shell                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.fish = {
    enable = true;

    # --- Алиасы ---
    shellAliases = {
      # Быстрая пересборка системы
      b = "sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /home/meowrch/NixOS-Meowrch#meowrch --impure";
      # Открыть конфиг NixOS в VSCode от root
      c = "code --user-data-dir=\"$HOME/.vscode-root\" /home/meowrch/NixOS-Meowrch/configuration.nix";
      # Обновить флейк и пересобрать систему
      u = "cd /home/meowrch/NixOS-Meowrch/ && nix flake update && sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /home/meowrch/NixOS-Meowrch#meowrch --impure";
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


  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                Spicetify                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.spicetify = {
    enable = true;
    # Тема Catppuccin для Spicetify
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.catppuccin;
    colorScheme = "mocha";
    enabledExtensions = [];
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Dotfiles                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  # Пример: подключение конфига Hyprland
  # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
}
