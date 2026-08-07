# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  bspwm + sxhkd (user-level) — паритет с оригинальным meowrch 4.1.1         ║
# ║                                                                            ║
# ║  Источник (meowrch/meowrch @ 4.1.1):                                       ║
# ║    home/.config/bspwm/bspwmrc                                              ║
# ║    home/.config/bspwm/sxhkdrc     ← хоткеи перенесены 1:1                  ║
# ║    home/.config/polybar/launch.sh                                          ║
# ║                                                                            ║
# ║  Хоткеи намеренно совпадают с Hyprland-сессией (modules/home/hyprland.nix) ║
# ║  — так же, как в оригинале.                                                ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: let
  bin = "$XDG_BIN_HOME";
  term = "kitty";
in {
  xsession.windowManager.bspwm = {
    enable = true;

    # 10 рабочих столов, как в Hyprland-сессии
    monitors.focused = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];

    settings = {
      # Соответствует default/appearance.lua Hyprland-сессии
      border_width = 3;
      window_gap = 8;
      split_ratio = 0.5;

      normal_border_color = "#45475a";
      focused_border_color = "#b4befe";
      presel_feedback_color = "#697dfd";

      borderless_monocle = true;
      gapless_monocle = true;
      focus_follows_pointer = true;
      pointer_modifier = "mod4";
    };

    rules = {
      "Vlc".state = "floating";
      ".blueman-manager".state = "floating";
      "Qt5ct".state = "floating";
      "Qt6ct".state = "floating";
      "org.kde.ark".state = "floating";
      "Yad".state = "floating";
      "com.saivert.pwvucontrol".state = "floating";
      "Gnome-calculator".state = "floating";
      "org.gnome.Loupe".state = "floating";
      "org.gnome.FileRoller".state = "floating";
      "com.meowrch.HotkeyHub".state = "floating";
      "Qalculate-gtk".state = "floating";
      "com.gabm.satty".state = "floating";
    };

    startupPrograms = [
      "wmname LG3D"
      "xsetroot -cursor_name left_ptr"
      "xsettingsd"
      "picom"
      "dunst"
      "udiskie --no-automount --smart-tray"
      "sh ${bin}/toggle-bar.sh --start --wm bspwm"
      "sh ${bin}/set-wallpaper.sh --current"
    ];
  };

  # ══ SXHKD: хоткеи 1:1 из home/.config/bspwm/sxhkdrc ═════════════════════
  services.sxhkd = {
    enable = true;

    keybindings = {
      # ── Пользовательские приложения ──
      "super + shift + c" = "code";
      "super + shift + f" = "firefox";
      "super + shift + t" = "Telegram";
      "super + shift + o" = "obsidian";
      "super + shift + p" = "pwvucontrol";
      "super + shift + y" = "${term} -e yazi";

      # ── Mewline (dynamic island) ──
      "super + alt + p" = "fabric-cli invoke-action mewline dynamic-island-open power-menu";
      "super + alt + d" = "fabric-cli invoke-action mewline dynamic-island-open date-notification";
      "super + alt + b" = "fabric-cli invoke-action mewline dynamic-island-open bluetooth";
      "super + alt + a" = "fabric-cli invoke-action mewline dynamic-island-open app-launcher";
      "super + alt + w" = "fabric-cli invoke-action mewline dynamic-island-open wallpapers";
      "super + alt + less" = "fabric-cli invoke-action mewline dynamic-island-open emoji";
      "super + alt + v" = "fabric-cli invoke-action mewline dynamic-island-open clipboard";
      "super + alt + n" = "fabric-cli invoke-action mewline dynamic-island-open network";
      "super + alt + t" = "fabric-cli invoke-action mewline dynamic-island-open pawlette-themes";
      "super + alt + Tab" = "fabric-cli invoke-action mewline dynamic-island-open workspaces";

      # ── Системные бинды ──
      "super + Return" = term;
      "super + e" = "nemo";
      "super + w" = "sh ${bin}/rofi-menus/wallpaper-selector.sh";
      "super + t" = "sh ${bin}/rofi-menus/theme-selector.sh";
      "super + v" = "sh ${bin}/rofi-menus/clipboard-manager.sh";
      "super + a" = "rofi -show drun";
      "super + x" = "sh ${bin}/rofi-menus/powermenu.sh";
      "super + l" = "sh ${bin}/screen-lock.sh";
      "super + c" = "sh ${bin}/color-picker.sh";
      "super + b" = "sh ${bin}/toggle-bar.sh --toggle --wm bspwm";
      "super + shift + b" = "sh ${bin}/toggle-bar.sh --next --wm bspwm";
      "super + period" = "sh ${bin}/rofi-menus/rofimoji.sh";
      "ctrl + shift + Escape" = "${term} -e btop";
      "Print" = "sh ${bin}/screenshot.sh";
      "super + Print" = "sh ${bin}/screenshot.sh --full";
      "alt + shift" = "xkb-switch -n";
      "super + slash" = "hotkeyhub --sxhkd $HOME/.config/bspwm/sxhkdrc";

      # Закрепить окно (sticky + locked)
      "super + p" = ''
        bash -c 'win_id=$(bspc query -N -n focused); \
          is_sticky=$(bspc query -N -n "$win_id.sticky"); \
          is_locked=$(bspc query -N -n "$win_id.locked"); \
          if [ -n "$is_sticky" ] && [ -n "$is_locked" ]; then \
            bspc node "$win_id" -g locked=off; \
            bspc node "$win_id" -g sticky=off; \
          else \
            if [ -z "$(bspc query -N -n "$win_id.floating")" ]; then \
              bspc node "$win_id" -t floating; \
            fi; \
            bspc node "$win_id" -g sticky=on -g locked=on; \
            bspc node "$win_id" -f; \
          fi'
      '';

      # ── Мультимедиа ──
      "XF86AudioRaiseVolume" = "sh ${bin}/volume.sh --device output --action increase";
      "XF86AudioLowerVolume" = "sh ${bin}/volume.sh --device output --action decrease";
      "XF86AudioMute" = "sh ${bin}/volume.sh --device output --action toggle";
      "XF86AudioMicMute" = "sh ${bin}/volume.sh --device input --action toggle";
      "XF86AudioPlay" = "playerctl play-pause";
      "XF86AudioPause" = "playerctl play-pause";
      "XF86AudioNext" = "playerctl next";
      "XF86AudioPrev" = "playerctl previous";
      "XF86AudioStop" = "playerctl stop";
      "XF86MonBrightnessUp" = "sh ${bin}/brightness.sh --up";
      "XF86MonBrightnessDown" = "sh ${bin}/brightness.sh --down";

      # ── Сессия ──
      "super + Delete" = "bspc quit";
      "ctrl + shift + r" = "bspc wm -r; notify-send sxhkd 'Reloaded config' -t 1500";
      "super + Escape" = "pkill -x sxhkd 2>/dev/null && sxhkd -c ~/.config/bspwm/sxhkdrc_disabled &";

      # ── Действия с окном ──
      "super + {q,k}" = ''
        bash -c 'win_id=$(bspc query -N -n focused); \
          [ -z "$win_id" ] && exit 0; \
          if [ -n "$(bspc query -N -n "$win_id.locked")" ] || [ -n "$(bspc query -N -n "$win_id.sticky")" ]; then \
            bspc node "$win_id" -g locked=off; \
            bspc node "$win_id" -g sticky=off; \
            sleep 0.05; \
          fi; \
          if [ "{q,k}" = "q" ]; then \
            bspc node "$win_id" -c; \
          else \
            bspc node "$win_id" -k; \
          fi'
      '';
      "super + space" = ''bspc node -t "~"{floating,tiled}'';
      "alt + Return" = "bspc node -t ~fullscreen";

      # ── Фокус ──
      "super + Right" = "bspc node -f east";
      "super + Left" = "bspc node -f west";
      "super + Up" = "bspc node -f north";
      "super + Down" = "bspc node -f south";
      "alt + Tab" = "bspc node -f last";

      # ── Рабочие столы ──
      "super + {1-9,0}" = "bspc desktop -f {1-9,10}";
      "super + shift + {1-9,0}" = "bspc node -d {'^1','^2','^3','^4','^5','^6','^7','^8','^9','^10'}";
      "super + ctrl + Right" = "bspc desktop -f next";
      "super + ctrl + Left" = "bspc desktop -f prev";
      "super + button4" = "bspc desktop -f next.local";
      "super + button5" = "bspc desktop -f prev.local";
      "super + ctrl + Down" = "bspc desktop $(bspc query -D -d '.!occupied' | head -n 1) --focus";

      # ── Изменение размера ──
      "super + shift + Right" = "bspc node -z right 30 0";
      "super + shift + Left" = "bspc node -z left -30 0";
      "super + shift + Up" = "bspc node -z top 0 -30";
      "super + shift + Down" = "bspc node -z bottom 0 30";

      # ── Перемещение окна ──
      "super + shift + ctrl + Left" = "bspc node -s west";
      "super + shift + ctrl + Right" = "bspc node -s east";
      "super + shift + ctrl + Up" = "bspc node -s north";
      "super + shift + ctrl + Down" = "bspc node -s south";
    };
  };

  # TODO(парити): перенести home/.config/polybar/config.ini.pawlette (9.5 КБ)
  #               и home/.config/bspwm/picom.conf в Nix.
  #               До этого polybar поднимается скриптом toggle-bar.sh,
  #               как в upstream (polybar/launch.sh).
}
