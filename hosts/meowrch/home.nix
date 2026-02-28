# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    ПОЛЬЗОВАТЕЛЬСКАЯ КОНФИГУРАЦИЯ                         ║
# ║                         Home-Manager (Meowrch)                           ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{ config, pkgs, lib, inputs, firefox-addons, pkgs-unstable, ... }:

{
  # ────────────── Импорты модулей ──────────────
  imports = [
    ../../modules/home/rofi.nix
    ../../modules/home/gtk.nix
    ../../modules/home/fish.nix
    ../../modules/home/starship.nix
  ];

  # ────────────── Базовые настройки ──────────────
  home.username = lib.mkForce "meowrch";
  home.homeDirectory = lib.mkForce "/home/meowrch";
  home.stateVersion = "25.11";

  # ────────────── Пользовательские пакеты ──────────────
  home.packages = with pkgs; [
    # Системные инструменты
    meowrch-scripts
    meowrch-themes
    mewline
    fabric-cli
    pawlette
    meowrch-tools
    
    # Приложения
    pkgs-unstable.gemini-cli
    telegram-desktop
    firefox
    zed-editor
  ];

  # ────────────── Сервисы ──────────────
  systemd.user.services.mewline = {
    Unit = {
      Description = "Mewline Dynamic Island Status Bar";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.mewline}/bin/mewline";
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ────────────── Переменные окружения ──────────────
  home.sessionVariables = {
    EDITOR = "zed";
    TERMINAL = "kitty";
    XDG_BIN_HOME = "$HOME/.config/meowrch/bin";
  };

  # ────────────── Тематизация (Catppuccin) ──────────────
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # ────────────── Конфигурация файлов (Symlinks) ──────────────
  home.file = {
    ".config/hypr" = { source = ../../config/hypr; recursive = true; force = true; };
    ".config/kitty" = { source = ../../config/kitty; recursive = true; force = true; };
    ".config/fastfetch" = { source = ../../config/fastfetch; recursive = true; force = true; };
    ".config/btop" = { source = ../../config/btop; recursive = true; force = true; };
    ".config/meowrch" = { source = ../../config/meowrch; recursive = true; force = true; };
    ".config/meowrch/bin" = { source = ../../scripts; recursive = true; force = true; };
    ".config/meowrch/wallpapers" = {
      source = "${pkgs.meowrch-themes}/share/pawlette/catppuccin-mocha/wallpapers";
      recursive = true;
      force = true;
    };
  };

  # ────────────── Дополнительные настройки ──────────────
  programs.home-manager.enable = true;
  programs.pyenv.enable = true;

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
