# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                          ОПЦИОНАЛЬНЫЕ ФУНКЦИИ                            ║
# ╟────────────────────────────────────────────────────────────────────────────╢
# ║ Этот файл управляется установщиком Meowrch.                              ║
# ║ Вы можете менять значения вручную (true/false).                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{ config, pkgs, lib, ... }:

let
  cfg = config.meowrch.features;
in {
  options.meowrch.features = {
    steam = lib.mkOption { type = lib.types.bool; default = false; };
    gamemode = lib.mkOption { type = lib.types.bool; default = false; };
    mangohud = lib.mkOption { type = lib.types.bool; default = false; };
    flatpak = lib.mkOption { type = lib.types.bool; default = false; };
    docker = lib.mkOption { type = lib.types.bool; default = false; };
    telegram = lib.mkOption { type = lib.types.bool; default = false; };
    discord = lib.mkOption { type = lib.types.bool; default = false; };
    obsidian = lib.mkOption { type = lib.types.bool; default = false; };
    wine = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = {
    # Gaming
    programs.steam.enable = cfg.steam;
    programs.gamemode.enable = cfg.gamemode;
    
    # Packages
    environment.systemPackages = with pkgs; [
      (lib.mkIf cfg.mangohud mangohud)
      (lib.mkIf cfg.telegram telegram-desktop)
      (lib.mkIf cfg.discord discord)
      (lib.mkIf cfg.obsidian obsidian)
      (lib.mkIf cfg.wine wine-wow64)
    ];

    # Services
    services.flatpak.enable = cfg.flatpak;
    virtualisation.docker.enable = cfg.docker;
  };
}
