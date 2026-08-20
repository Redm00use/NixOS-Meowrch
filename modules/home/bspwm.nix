# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  bspwm + sxhkd (user-level) — паритет с оригинальным meowrch 4.1.1         ║
# ║                                                                            ║
# ║  Источник (meowrch/meowrch @ 4.1.1):                                       ║
# ║    home/.config/bspwm/bspwmrc                                              ║
# ║    home/.config/bspwm/sxhkdrc              ← хоткеи перенесены 1:1         ║
# ║    home/.config/bspwm/default/initial.sh                                   ║
# ║    home/.config/bspwm/default/monitors.sh                                  ║
# ║    home/.config/bspwm/default/appearance.sh                                ║
# ║    home/.config/bspwm/default/windowrules.sh                               ║
# ║    home/.config/bspwm/default/autostart.sh                                 ║
# ║    home/.config/bspwm/default/clipboard.sh                                 ║
# ║                                                                            ║
# ║  Оригинал разбит на bspwmrc + 6 подключаемых .sh. Здесь всё это собрано    ║
# ║  в один HM-модуль: xsession.windowManager.bspwm сам генерирует bspwmrc,    ║
# ║  поэтому подключать default/*.sh нечем — их содержимое перенесено в        ║
# ║  settings / rules / extraConfig / startupPrograms.                         ║
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

  # Абсолютные пути: bspwmrc выполняется на старте сессии, PATH там ещё
  # не обязательно наполнен.
  jq = "${pkgs.jq}/bin/jq";
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  xdpyinfo = "${pkgs.xorg.xdpyinfo}/bin/xdpyinfo";

  picomLaunch = "${config.xdg.configHome}/bspwm/picom-launch.sh";
in {
  xsession.windowManager.bspwm = {
    enable = true;

    # default/monitors.sh: 10 рабочих столов, как в Hyprland-сессии
    monitors.focused = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];

    # ══ default/appearance.sh ═════════════════════════════════════════════
    settings = {
      border_width = 3;
      borderless_monocle = true;

      # ВНИМАНИЕ: window_gap здесь 10, а не 8.
      # В Hyprland-сессии gaps_out = 8 (default/appearance.lua), но у bspwm
      # оригинал ставит именно `bspc config window_gap 10`. Раньше здесь
      # стояло 8 — скопировано по ошибке из Hyprland-конфига.
      window_gap = 10;

      # Тоже расхождение, исправлено: в appearance.sh явно false.
      gapless_monocle = false;

      split_ratio = 0.5;

      normal_border_color = "#45475a";
      # Перетирается ниже в extraConfig, если есть палитра pawlette.
      focused_border_color = "#b4befe";
      presel_feedback_color = "#697dfd";

      focus_follows_pointer = true;

      # Без pointer_action* модификатор сам по себе ничего не делает —
      # floating-окна нельзя было ни двигать, ни ресайзить мышью.
      pointer_modifier = "mod4";
      pointer_action1 = "move";
      pointer_action2 = "resize_side";
      pointer_action3 = "resize_corner";
    };

    # ══ default/windowrules.sh (часть без размеров) ════════════════════════
    rules = {
      # Фикс отображения Java-приложений
      "*:sun-awt-X11-XWindowPeer".manage = false;

      "feh".state = "floating";
      "Vlc" = {
        state = "floating";
        center = true;
      };
      ".blueman-manager" = {
        state = "floating";
        center = true;
      };
      "Blueman-manager" = {
        state = "floating";
        center = true;
      };
      "Qt5ct" = {
        state = "floating";
        center = true;
      };
      "Qt6ct" = {
        state = "floating";
        center = true;
      };
      "ark" = {
        state = "floating";
        center = true;
      };
      "org.kde.ark" = {
        state = "floating";
        center = true;
      };
      "Xarchiver" = {
        state = "floating";
        center = true;
      };
      "Yad" = {
        state = "floating";
        center = true;
      };
    };

    # ══ Остаток default/*.sh ══════════════════════════════════════════════
    extraConfig = ''
      # ── default/appearance.sh: цвет рамки из активной палитры pawlette ──
      # Без этого рамка оставалась лавандовой при любой выбранной теме.
      PALETTE="$HOME/.local/state/pawlette/active_palette.json"
      if [ -f "$PALETTE" ]; then
        COLOR_PRIMARY=$(${jq} -r '.color_primary' "$PALETTE" 2>/dev/null)
        if [ -n "$COLOR_PRIMARY" ] && [ "$COLOR_PRIMARY" != "null" ]; then
          bspc config focused_border_color "$COLOR_PRIMARY"
        fi
      fi

      # ── default/monitors.sh: выставить лучший режим монитора ──
      monitor=$(${xrandr} --query | grep " connected" | awk '{ print $1 }' | head -n 1)
      resolution=$(${xrandr} --query | grep -A1 "^$monitor" | grep -Eo '[0-9]+x[0-9]+' | sort -V | tail -n 1)
      refresh_rate=$(${xrandr} --query | grep -A1 "^$monitor" | grep -Eo '[0-9]+\.[0-9]+' | sort -V | tail -n 1)

      if [ -n "$monitor" ] && [ -n "$resolution" ] && [ -n "$refresh_rate" ]; then
        ${xrandr} --output "$monitor" --mode "$resolution" --rate "$refresh_rate"
      fi

      # ── default/windowrules.sh: правила с размерами ──
      # Размеры в оригинале — проценты от экрана, считаются в рантайме.
      # Через HM-опцию rules так нельзя (там только статическая строка),
      # поэтому функция rect() перенесена сюда как есть.
      SW=$(${xdpyinfo} | awk '/dimensions:/ {print $2}' | cut -d'x' -f1)
      SH=$(${xdpyinfo} | awk '/dimensions:/ {print $2}' | cut -d'x' -f2)

      rect() {
        w_pct=$1
        h_pct=$2

        w=$((SW * w_pct / 100))
        h=$((SH * h_pct / 100))
        x=$(((SW - w) / 2))
        y=$(((SH - h) / 2))

        echo "''${w}x''${h}+''${x}+''${y}"
      }

      if [ -n "$SW" ] && [ -n "$SH" ]; then
        bspc rule -a 'org.gnome.FileRoller' state=floating rectangle=$(rect 63 74) center=true
        bspc rule -a 'Gnome-calculator'     state=floating rectangle=$(rect 19 47) center=true
        bspc rule -a 'loupe'                state=floating rectangle=$(rect 63 74) center=true
        bspc rule -a 'hotkeyhub'            state=floating rectangle=$(rect 63 74) center=true
        bspc rule -a 'qalculate-gtk'        state=floating rectangle=$(rect 45 55) center=true
        bspc rule -a 'satty'                state=floating rectangle=$(rect 63 74) center=true
        bspc rule -a 'pwvucontrol'          state=floating rectangle=$(rect 48 42) center=true
      fi

      # ── default/autostart.sh: Xresources ──
      if [ -f "$HOME/.config/X11/Xresources" ]; then
        ${pkgs.xorg.xrdb}/bin/xrdb merge "$HOME/.config/X11/Xresources"
      fi

      # ── default/clipboard.sh ──
      # Без этого цикла cliphist пуст, и SUPER+V (clipboard-manager.sh)
      # показывал бы пустой список. В оригинале скрипт молча выходит,
      # если чего-то нет — здесь все три бинарника гарантированы Nix'ом.
      (
        while ${pkgs.clipnotify}/bin/clipnotify; do
          ${pkgs.xclip}/bin/xclip -o -selection c | ${pkgs.cliphist}/bin/cliphist store
        done
      ) &
    '';

    # ══ default/initial.sh + default/autostart.sh ═════════════════════════
    # sxhkd не в списке: его поднимает services.sxhkd ниже.
    startupPrograms = [
      # initial.sh: фикс отображения Java-приложений
      "wmname LG3D"

      # appearance.sh
      "xsetroot -cursor_name left_ptr"

      # autostart.sh
      "xsettingsd"
      "dunst"

      # Раньше здесь было просто "picom" — без --config, то есть со
      # СТАНДАРТНЫМ конфигом picom: ни закруглений, ни блюра, ни анимаций.
      # Теперь запускается скрипт из modules/home/picom.nix, который
      # подбирает флаги backend'а под видеокарту, как в оригинале.
      "sh ${picomLaunch}"

      # Диалог аутентификации для GUI-приложений (был потерян)
      "sh ${bin}/polkitkdeauth.sh"

      "udiskie --no-automount --smart-tray"
      "sh ${bin}/toggle-bar.sh --start --wm bspwm"
      "sh ${bin}/set-wallpaper.sh --current"
    ];
  };

  # ══ Зависимости, которые дёргают bspwmrc и default/*.sh ═════════════════
  home.packages = with pkgs; [
    wmname # initial.sh
    xsettingsd # autostart.sh
    xorg.xsetroot # appearance.sh
    xorg.xrandr # monitors.sh, polybar/launch.sh
    xorg.xdpyinfo # windowrules.sh (rect)
    xorg.xrdb # autostart.sh
    jq # appearance.sh (палитра pawlette)
    clipnotify # clipboard.sh
    xclip # clipboard.sh, screenshot.sh на X11
    cliphist # clipboard.sh
    feh # set-wallpaper.sh на X11 (wallpapers.x11_method)
    maim # screenshot.sh на X11
    xkb-switch # sxhkd: alt+shift переключение раскладки
    udiskie # autostart.sh
  ];

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

  # ══ sxhkdrc_disabled ════════════════════════════════════════════════════
  # SUPER+ESCAPE переключает sxhkd на этот файл — режим, где работает только
  # обратное переключение. Аналог submap passthru в Hyprland-сессии.
  # services.sxhkd генерирует только основной sxhkdrc, поэтому второй файл
  # кладём вручную.
  xdg.configFile."bspwm/sxhkdrc_disabled".text = ''

    super + Escape
        pkill -x sxhkd 2>/dev/null && sxhkd -c ~/.config/bspwm/sxhkdrc &
  '';
}
