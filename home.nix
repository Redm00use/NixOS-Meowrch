# /etc/nixos/home.nix
# Упрощенная версия без настроек GTK/Qt
# ---> ИСПРАВЛЕННЫЙ ЗАГОЛОВОК: Добавлен 'inputs'
{ config, pkgs, lib, inputs, ... }:

{
  # --- Основные настройки Home Manager ---
  home.username = "redm00us";
  home.homeDirectory = "/home/redm00us";
  home.stateVersion = "24.11";

  # --- Пакеты Пользователя ---
  home.packages = with pkgs; [
    # --- Добавлен Yandex Music из flake input ---
    inputs.yandex-music.packages.${pkgs.system}.default
  ];

  # --- Настройки Fish Shell (Оставляем) ---
  programs.fish = {
    enable = true;
    shellAliases = {
      b = "sudo nixos-rebuild switch --flake .#nixos";
      c = "code --user-data-dir=\"$HOME/.vscode-root\" /etc/nixos/configuration.nix";
      u = "echo 'Для обновления используйте: nix flake update && sudo nixos-rebuild switch --flake .#nixos'";
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

  # --- Управление Dotfiles ---
  # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;

}
