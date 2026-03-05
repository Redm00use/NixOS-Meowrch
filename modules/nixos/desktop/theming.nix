{ config, pkgs, lib, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           ГЛОБАЛЬНАЯ ТЕМАТИЗАЦИЯ                         ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Boot loader theming (systemd-boot конфигурируется в configuration.nix)
  # GRUB отключен для избежания конфликтов

  # ────────────── Plymouth (загрузочный экран) ──────────────
  # Plymouth disabled due to package compatibility issues in NixOS 25.11
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

    # Qt5ct/Qt6ct для настройки тем
    libsForQt5.qt5ct
    kdePackages.qt6ct

    # Дополнительные темы
    gnome-themes-extra
    gsettings-desktop-schemas
  ];

  # ────────────── Шрифты ──────────────
  fonts = {
    # enableDefaultPackages is set in fonts.nix

    packages = with pkgs; [
      # Основные шрифты
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      # noto-fonts-extra merged into noto-fonts

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
      ubuntu-classic
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
  # Cursor vars здесь — системный фолбэк для SDDM и системных сервисов.
  # Для Hyprland/Wayland сессии — используется home.pointerCursor (home.nix)
  # и переменные из hyprland.nix (XCURSOR_THEME/SIZE, HYPRCURSOR_THEME/SIZE).
  environment.variables = {
    # XCursor (X11/XWayland фолбэк, системный уровень)
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";

    # Qt темы — qt6ct управляет стилем через свои конфиги (как в оригинальном Meowrch)
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";

    # Catppuccin
    CATPPUCCIN_FLAVOR = "mocha";
  };

  # ────────────── Сессионные переменные ──────────────
  environment.sessionVariables = {
    # Qt настройки
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # ────────────── XDG настройки ──────────────
  # XDG portal configuration moved to hyprland.nix to avoid conflicts

  # ────────────── Программы с темами ──────────────
  programs = {
    # Dconf для GTK настроек
    dconf.enable = true;
  };

  # Qt platform theme configuration (как в оригинальном Meowrch)
  # Внимание: qt.platformTheme принимает только "qt5ct", но переменная
  # QT_QPA_PLATFORMTHEME выше устанавливает qt6ct для реального рантайма
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
}
