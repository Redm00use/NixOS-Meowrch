{ config, pkgs, lib, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           ГЛОБАЛЬНАЯ ТЕМАТИЗАЦИЯ                         ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Boot loader theming (systemd-boot конфигурируется в configuration.nix)
  # GRUB отключен для избежания конфликтов

  # ────────────── Plymouth (загрузочный экран) ──────────────
  # Plymouth disabled due to package compatibility issues in NixOS 25.05
  # boot.plymouth = {
  #   enable = true;
  #   theme = "spinner";
  # };

  # ────────────── Системные пакеты для тем ──────────────
  environment.systemPackages = with pkgs; [
    # GTK темы
    adwaita-qt
    qgnomeplatform-qt6

    # Темы иконок
    papirus-icon-theme

    # Курсоры
    bibata-cursors

    # Catppuccin темы
    catppuccin-gtk
    catppuccin-qt5ct

    # Дополнительные темы
    gnome-themes-extra
    gsettings-desktop-schemas
  ];

  # ────────────── Конфигурационные файлы ──────────────
  environment.etc = {
    # GTK2 system-wide
    "gtk-2.0/gtkrc".text = ''
      gtk-theme-name = "Catppuccin-Mocha-Standard-Blue-Dark"
      gtk-icon-theme-name = "Papirus-Dark"
      gtk-cursor-theme-name = "Bibata-Modern-Classic"
      gtk-cursor-theme-size = 24
      gtk-font-name = "Noto Sans 11"
    '';

    # GTK3 system-wide
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-font-name=Noto Sans 11
      gtk-application-prefer-dark-theme=1
    '';

    # Тема иконок по умолчанию
    "icons/default/index.theme".text = ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=Bibata-Modern-Classic
    '';
  };

  # ────────────── Шрифты ──────────────
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Основные шрифты
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra

      # Программистские шрифты
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.ubuntu-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.meslo-lg
      jetbrains-mono
      fira-code
      fira-code-symbols
      source-code-pro
      ubuntu_font_family
      dejavu_fonts

      # UI шрифты
      inter
      roboto
      open-sans
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      subpixel.lcdfilter = "default";

      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Hack Nerd Font" "FiraCode Nerd Font" ];
        sansSerif = [ "Noto Sans" "Inter" "Roboto" ];
        serif = [ "Noto Serif" "DejaVu Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- Использовать JetBrainsMono для моноширинных шрифтов -->
          <alias>
            <family>monospace</family>
            <prefer>
              <family>JetBrainsMono Nerd Font</family>
              <family>Hack Nerd Font</family>
              <family>FiraCode Nerd Font</family>
            </prefer>
          </alias>

          <!-- Улучшенный рендеринг шрифтов -->
          <match target="font">
            <edit name="lcdfilter" mode="assign">
              <const>lcddefault</const>
            </edit>
          </match>

          <match target="font">
            <edit name="rgba" mode="assign">
              <const>rgb</const>
            </edit>
          </match>

          <!-- Отключить автохинтинг для некоторых шрифтов -->
          <match target="font">
            <test name="family" compare="contains">
              <string>JetBrainsMono</string>
            </test>
            <edit name="autohint" mode="assign">
              <bool>false</bool>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };

  # ────────────── Переменные окружения ──────────────
  environment.variables = {
    # GTK темы
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";

    # Курсоры
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";

    # Qt темы (use mkForce to override system defaults)
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
    QT_STYLE_OVERRIDE = lib.mkForce "Adwaita-Dark";

    # Catppuccin
    CATPPUCCIN_FLAVOR = "mocha";
  };

  # ────────────── Сессионные переменные ──────────────
  environment.sessionVariables = {
    # GTK настройки
    GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";

    # Qt настройки
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Курсоры (use mkDefault to avoid conflict with system)
    XCURSOR_PATH = lib.mkDefault "/usr/share/icons:$XDG_DATA_HOME/icons";
  };

  # ────────────── XDG настройки ──────────────
  # XDG portal configuration moved to hyprland.nix to avoid conflicts

  # ────────────── Программы с темами ──────────────
  programs = {
    # Dconf для GTK настроек
    dconf.enable = true;
  };

  # Qt platform theme configuration (updated for NixOS 25.05)
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  # ────────────── Systemd сервисы ──────────────
  systemd.user.services = {
    # Применение GTK настроек
    apply-gtk-theme = {
      description = "Apply GTK theme settings";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      script = ''
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha-Standard-Blue-Dark"
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-size 24
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface font-name "Noto Sans 11"
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 11"
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
