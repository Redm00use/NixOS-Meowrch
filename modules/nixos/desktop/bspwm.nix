# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  X11-сессия (bspwm) — паритет с оригинальным meowrch 4.1.1                 ║
# ║                                                                            ║
# ║  Оригинальный meowrch предлагает на выбор ДВЕ сессии: Hyprland (Wayland)   ║
# ║  и bspwm (X11). До этого коммита форк поддерживал только Hyprland.         ║
# ║                                                                            ║
# ║  Источник (meowrch/meowrch @ 4.1.1):                                       ║
# ║    Builder/packages.py → BASE.pacman.bspwm_packages / BASE.aur.bspwm       ║
# ║    home/.config/bspwm/bspwmrc                                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver = {
    enable = true;

    # bspwm как оконный менеджер. Home Manager отдельно поднимает sxhkd,
    # см. modules/home/bspwm.nix
    windowManager.bspwm.enable = true;

    # Раскладка идентична Hyprland-сессии (default/input.lua)
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  # Пакеты X11-сессии из BASE.pacman.bspwm_packages
  environment.systemPackages = with pkgs; [
    bspwm
    sxhkd
    picom
    polybar
    dunst
    feh
    maim
    wmname
    xclip
    clipnotify
    xsettingsd
    betterlockscreen # BASE.aur.bspwm_packages
    xkb-switch # BASE.aur.bspwm_packages
    xorg.xinit
    xorg.xrandr
    xorg.xsetroot
  ];

  # picom запускается из bspwmrc (как в upstream), поэтому системный
  # сервис compton/picom не включаем, чтобы не было двойного запуска.
  services.picom.enable = false;
}
