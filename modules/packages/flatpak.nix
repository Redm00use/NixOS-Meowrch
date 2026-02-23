{ config, pkgs, lib, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                            FLATPAK КОНФИГУРАЦИЯ                         ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Включить поддержку Flatpak
  services.flatpak.enable = true;

  # Настройка XDG Desktop Portal для Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = lib.mkDefault "*";
  };

  # Системные пакеты для поддержки Flatpak
  environment.systemPackages = with pkgs; [
    flatpak
    gnome-software  # Графический менеджер для Flatpak
  ];

  # Настройка групп пользователей для Flatpak
  users.groups.flatpak = {};

  # Автоматическое добавление Flathub репозитория
  system.activationScripts.flatpak-repo = ''
    if [ ! -d "/var/lib/flatpak/repo" ]; then
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
  '';

  # Настройка переменных окружения для Flatpak
  environment.sessionVariables = {
    XDG_DATA_DIRS = lib.mkDefault "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  # Systemd сервисы для Flatpak
  systemd.services.flatpak-system-helper = {
    description = "Flatpak system helper";
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Flatpak.SystemHelper";
      ExecStart = "${pkgs.flatpak}/libexec/flatpak-system-helper";
    };
  };

  # Разрешения для портала файлов
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.Flatpak.app-install" ||
             action.id == "org.freedesktop.Flatpak.runtime-install"||
             action.id == "org.freedesktop.Flatpak.app-uninstall" ||
             action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
             action.id == "org.freedesktop.Flatpak.modify-repo") &&
            subject.active == true && subject.local == true &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
        return polkit.Result.NOT_HANDLED;
    });
  '';
}
