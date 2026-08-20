# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  Паритет пакетов с оригинальным meowrch 4.1.1                              ║
# ║                                                                            ║
# ║  Источник истины: meowrch/meowrch @ 4.1.1 → Builder/packages.py            ║
# ║  Секции ниже 1:1 повторяют группы upstream. Arch/AUR-пакеты заменены        ║
# ║  эквивалентами из nixpkgs.                                                 ║
# ║                                                                            ║
# ║  Пакеты без прямого аналога в nixpkgs помечены TODO и закомментированы,     ║
# ║  чтобы не ломать сборку. Их нужно упаковать в pkgs/.                       ║
# ║                                                                            ║
# ║  Пакеты, не нужные на NixOS (base-devel, sudo, mkinitcpio, update-grub),   ║
# ║  сознательно опущены — их роль выполняет сама система.                      ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Опциональные группы upstream (CUSTOM в packages.py).
  # Читаем защищённо: если опция не объявлена — считаем выключенной.
  features = config.meowrch.features or {};
  has = name: features.${name} or false;
in {
  # ══════════════════════════════════════════════════════════════════════════
  #  BASE ▸ common
  # ══════════════════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs;
    [
      # ── Система ──
      git
      libnotify
      playerctl
      upower
      brightnessctl
      udiskie
      gobject-introspection
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      gvfs
      jmtpfs # gvfs-mtp
      android-udev-rules # android-udev
      xvfb-run # xorg-server-xvfb

      # ── Аудио (pipewire включается в modules/nixos/system/audio.nix) ──
      wireplumber
      pamixer
      sof-firmware
      # TODO: python-pyalsa — проверить наличие python3Packages.pyalsa

      # ── CLI ──
      jq
      fastfetch
      lsd
      bat
      micro
      btop
      yazi
      starship
      openssh
      sshfs
      wget
      neovim
      tmux
      ffmpeg
      cliphist
      tree
      bash-completion
      fish
      zsh
      zsh-syntax-highlighting
      zsh-autosuggestions
      zsh-history-substring-search
      matugen

      # ── GUI ──
      firefox
      kitty
      blueman
      file-roller
      nemo-with-extensions
      nemo-fileroller
      ffmpegthumbnailer
      imagemagick
      vlc
      loupe
      redshift
      zenity
      polkit_gnome
      gnome-disk-utility
      rofimoji
      satty
      qalculate-gtk
      adw-gtk3 # adw-gtk-theme
      kdePackages.breeze # breeze / breeze5
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtmultimedia
      libsForQt5.qt5.qtquickcontrols2
      gst_all_1.gst-plugins-good
      # TODO: nemo-compare (добавлен в upstream 4.1.1) — упаковать через nemo-python

      # ── Ранее AUR (BASE.aur.common) ──
      vscode # visual-studio-code-bin
      pwvucontrol # в 4.1.1 заменил pavucontrol
      bibata-cursors # bibata-cursor-theme-bin
      tela-circle-icon-theme # tela-circle-icon-theme-dracula
      firefox-gnome-theme
      cava
      # TODO: pokemon-colorscripts — проверить наличие в nixpkgs

      # ── Собственные пакеты форка (pkgs/) ──
      meowrch-settings
      meowrch-tools
      hotkeyhub # hotkeyhub-bin
      pawlette

      # ══════════════════════════════════════════════════════════════════════
      #  BASE ▸ hyprland
      # ══════════════════════════════════════════════════════════════════════
      waybar
      hyprlock
      hypridle
      hyprpicker
      hyprprop
      wl-clipboard
      wl-clip-persist
      wlr-randr
      uwsm
      newt # libnewt
      swaynotificationcenter # swaync
      grim
      slurp
      grimblast # grimblast-git
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
      libsForQt5.qt5.qtwayland
      qt6.qtwayland
      mewline
      # TODO(критично): awww / awww-daemon — в upstream 4.x заменил swww.
      #                 В nixpkgs отсутствует, нужен пакет в pkgs/.
    ]
    # ══════════════════════════════════════════════════════════════════════
    #  CUSTOM ▸ опциональные группы
    # ══════════════════════════════════════════════════════════════════════
    ++ lib.optionals (has "useful") [
      timeshift
    ]
    ++ lib.optionals (has "development") [
      postgresql
      pgadmin4
      redis
    ]
    ++ lib.optionals (has "social_media") [
      telegram-desktop
      discord
      vesktop
      # TODO: tg-config (AUR) — конфиг темы Telegram, перенести из misc/
    ]
    ++ lib.optionals (has "games") [
      mangohud
      # steam и gamemode включаются через programs.steam / programs.gamemode
      # TODO: portproton (AUR)
    ]
    ++ lib.optionals (has "entertainment") [
      spotify
      # TODO: yandex-music (AUR) — прямого аналога в nixpkgs нет
    ]
    ++ lib.optionals (has "office") [
      libreoffice-fresh
      onlyoffice-bin
      evince
    ];

  # ══════════════════════════════════════════════════════════════════════════
  #  BASE ▸ fonts
  # ══════════════════════════════════════════════════════════════════════════
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra
    jetbrains-mono # ttf-jetbrains-mono
    fira-code # ttf-fira-code
    nerd-fonts.hack # ttf-hack-nerd
    nerd-fonts.iosevka # ttf-iosevka-nerd
    nerd-fonts.jetbrains-mono # ttf-jetbrains-mono-nerd
    nerd-fonts.meslo-lg # ttf-meslo-nerd-font-powerlevel10k
  ];

  # ══════════════════════════════════════════════════════════════════════════
  #  Сервисы, соответствующие пакетам upstream
  # ══════════════════════════════════════════════════════════════════════════
  # power-profiles-daemon из BASE.pacman.common
  services.power-profiles-daemon.enable = lib.mkDefault true;

  # plymouth из BASE.pacman.common (тема — misc/plymouth_theme, см. TODO в docs)
  boot.plymouth.enable = lib.mkDefault true;
}
