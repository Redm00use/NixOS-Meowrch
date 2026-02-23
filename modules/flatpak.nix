{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.flatpak;
in {
  options.programs.flatpak = {
    enable = mkEnableOption "Flatpak - кроссдистрибутивная система управления пакетами";
    
    enableFlathub = mkOption {
      type = types.bool;
      default = true;
      description = "Добавить репозиторий Flathub";
    };
    
    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = "Включить автоматическое обновление Flatpak приложений";
    };
  };

  config = mkIf cfg.enable {
    # Включаем базовые сервисы для Flatpak
    services.flatpak.enable = true;
    
    # Интеграция с рабочим столом для XDG портала
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    
    # Добавляем Flathub репозиторий, если включена соответствующая опция
    system.activationScripts.flathub = mkIf cfg.enableFlathub (stringAfter [ "users" ] ''
      echo "Настройка Flathub репозитория..."
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '');
    
    # Автоматическое обновление, если включено
    systemd.services.flatpak-update = mkIf cfg.autoUpdate {
      description = "Автоматическое обновление Flatpak приложений";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.flatpak}/bin/flatpak update -y";
      };
    };
    
    systemd.timers.flatpak-update = mkIf cfg.autoUpdate {
      description = "Планировщик автоматического обновления Flatpak приложений";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    
    # Устанавливаем сам Flatpak
    environment.systemPackages = with pkgs; [
      flatpak     # Сама система Flatpak
      xdg-utils   # Утилиты для интеграции с рабочим столом
    ];
    
    # Настройки безопасности для корректной работы Flatpak
    security.polkit.enable = true;
  };
}