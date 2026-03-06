# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                      ОПРЕДЕЛЕНИЯ ОПЦИОНАЛЬНЫХ ФУНКЦИЙ                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{ config, pkgs, lib, ... }:

let
  cfg = config.meowrch.features;
in {
  options.meowrch.features = {
    # Gaming
    steam = lib.mkOption { type = lib.types.bool; default = false; };
    gamemode = lib.mkOption { type = lib.types.bool; default = false; };
    mangohud = lib.mkOption { type = lib.types.bool; default = false; };
    
    # Social
    telegram = lib.mkOption { type = lib.types.bool; default = false; };
    discord = lib.mkOption { type = lib.types.bool; default = false; };
    obsidian = lib.mkOption { type = lib.types.bool; default = false; };
    
    # Office
    libreoffice = lib.mkOption { type = lib.types.bool; default = false; };
    thunderbird = lib.mkOption { type = lib.types.bool; default = false; };
    
    # Development
    docker = lib.mkOption { type = lib.types.bool; default = false; };
    vscode = lib.mkOption { type = lib.types.bool; default = false; };
    zed = lib.mkOption { type = lib.types.bool; default = false; };
    
    # System
    flatpak = lib.mkOption { type = lib.types.bool; default = false; };
    wine = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = {
    programs.steam.enable = lib.mkForce cfg.steam;
    programs.gamemode.enable = lib.mkForce cfg.gamemode;
    virtualisation.docker.enable = lib.mkForce cfg.docker;
    services.flatpak.enable = lib.mkForce cfg.flatpak;

    environment.systemPackages = with pkgs; [
      (lib.mkIf cfg.mangohud mangohud)
      (lib.mkIf cfg.telegram telegram-desktop)
      (lib.mkIf cfg.discord discord)
      (lib.mkIf cfg.obsidian obsidian)
      (lib.mkIf cfg.libreoffice libreoffice-fresh)
      (lib.mkIf cfg.thunderbird thunderbird)
      (lib.mkIf cfg.vscode vscode)
      (lib.mkIf cfg.zed zed-editor)
      (lib.mkIf cfg.wine wine-wow64)
    ];
  };
}
