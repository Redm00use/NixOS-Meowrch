# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                             Сделал: Redm00us                             ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{ config, pkgs, lib, inputs, ... }:

{
  # --- Основные настройки Home Manager ---
  home.username = "redm00us";
  home.homeDirectory = "/home/redm00us";
  home.stateVersion = "24.11";

  # --- Применяем overlay spicetify-nix внутри Home Manager ---
  nixpkgs.overlays = [
    inputs.spicetify-nix.overlays.default
    inputs.catppuccin-nix.overlays.default
  ];

  # --- Пакеты Пользователя ---
  home.packages = with pkgs; [
    inputs.yandex-music.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  # --- Настройки Fish Shell ---
  programs.fish = {
    enable = true;
    shellAliases = {
      b = "sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /etc/nixos#nixos --impure";
      c = "code --user-data-dir=\"$HOME/.vscode-root\" /etc/nixos/configuration.nix";
      u = "cd /etc/nixos/ & nix flake update && sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake /etc/nixos#nixos --impure";
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

  # --- Настройка Spicetify ---
  programs.spicetify = {
    enable = true;
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
    colorScheme = "mocha";
    enabledExtensions = [];
  };

  # --- Управление Dotfiles ---
  # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
}
