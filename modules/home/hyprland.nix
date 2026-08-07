# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  Hyprland — перенос конфигурации оригинального meowrch 4.1.1               ║
# ║                                                                            ║
# ║  Источник (meowrch/meowrch @ 4.1.1):                                       ║
# ║    home/.config/hypr/hyprland.lua                                          ║
# ║    home/.config/hypr/default/{general,input,appearance,keybindings,        ║
# ║                               windowrules,autostart}.lua                   ║
# ║    home/.config/hypr/userprefs.lua                                         ║
# ║                                                                            ║
# ║  В upstream 4.x конфиг Hyprland стал декларативным на Lua (hl.* API).      ║
# ║  Здесь он переписан на нативные опции Home Manager. Семантика — 1:1.       ║
# ║                                                                            ║
# ║  ⚠️  Модуль управляет ~/.config/hypr. Перед подключением уберите блок       ║
# ║      home.file.".config/hypr" из hosts/meowrch/home.nix, иначе             ║
# ║      Home Manager сообщит о конфликте файлов.                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Каталог скриптов meowrch. В upstream это $XDG_BIN_HOME.
  bin = "$XDG_BIN_HOME";
  term = "kitty";

  # ── Рабочие столы 1..10 (в upstream генерируются циклом for i = 1, 10) ──
  # Клавиша для 10-го стола — "0", как в оригинале (key = i % 10).
  workspaceBinds = builtins.concatLists (builtins.genList (i: let
    n = i + 1;
    key =
      if n == 10
      then "0"
      else builtins.toString n;
    ws = builtins.toString n;
  in [
    "SUPER, ${key}, workspace, ${ws}"
    "SUPER SHIFT, ${key}, movetoworkspace, ${ws}"
  ]) 10);
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Сессией управляет uwsm (как в upstream 4.x), поэтому systemd-интеграцию
    # Home Manager отключаем, чтобы не было двойного запуска.
    systemd.enable = false;

    settings = {
      # ══ ENVIRONMENT ═══════════════════════════════════════════════════════
      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"

        # Курсор. HYPRCURSOR_SIZE добавлен в upstream 4.1.0.
        # Размер 20 — как в default/appearance.lua (hyprctl setcursor ... 20).
        "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        "HYPRCURSOR_SIZE,20"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,20"
      ];

      # ══ AUTOSTART (default/autostart.lua) ═════════════════════════════════
      exec-once = [
        "${bin}/resetxdgportal.sh"

        # Окружение uwsm и D-Bus
        "${bin}/uwsm-launcher.sh -t service -s s dbus-update-activation-environment --systemd --all"
        "${bin}/uwsm-launcher.sh -t service -s s systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

        # Polkit и демоны (уведомления, буфер обмена, диски)
        "${bin}/uwsm-launcher.sh -t service -s s ${bin}/polkitkdeauth.sh"
        "${bin}/uwsm-launcher.sh -t service -s s swaync"
        "${bin}/uwsm-launcher.sh -t service -s s hypridle"
        "${bin}/uwsm-launcher.sh -t service -s s awww-daemon"
        "${bin}/uwsm-launcher.sh -t service -s s udiskie --no-automount --smart-tray"

        # Менеджеры буфера обмена (cliphist)
        "${bin}/uwsm-launcher.sh -t service -s s wl-clip-persist --clipboard regular"
        "${bin}/uwsm-launcher.sh -t service -s s wl-paste --type text --watch cliphist store"
        "${bin}/uwsm-launcher.sh -t service -s s wl-paste --type image --watch cliphist store"

        # Статус-бар, системный сервис meowrch и обои
        "${bin}/uwsm-launcher.sh --system-mode sh ${bin}/toggle-bar.sh --start"
        "systemctl --user start meowrch-hyprland-uwsm.service"
        "sh ${bin}/set-wallpaper.sh --current"
      ];

      # ══ GENERAL (default/appearance.lua + default/general.lua) ════════════
      general = {
        gaps_in = 3;
        gaps_out = 8;
        border_size = 3;
        "col.active_border" = "rgba(b4befeff) rgba(697dfdff) 45deg";
        "col.inactive_border" = "rgba(45475aff)";
        "col.nogroup_border" = "rgba(181825ff)";
        resize_on_border = true;
        layout = "dwindle";
      };

      # ══ DECORATION (default/appearance.lua + userprefs.lua) ═══════════════
      decoration = {
        rounding = 10;
        dim_special = 0.3;

        blur = {
          enabled = true;
          special = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = false;
        };

        # userprefs.lua: decoration.screen_shader
        screen_shader = "~/.config/hypr/shaders/rounded_corners.glsl";
      };

      # ══ ANIMATIONS (default/appearance.lua) ═══════════════════════════════
      animations = {
        enabled = true;

        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];

        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      # ══ LAYOUTS (default/general.lua) ═════════════════════════════════════
      dwindle.preserve_split = true;
      master.new_status = "master";

      # ══ MISC (default/general.lua) ════════════════════════════════════════
      misc = {
        vrr = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        anr_missed_pings = 5;
        allow_session_lock_restore = true;
      };

      xwayland.force_zero_scaling = true;

      # ══ INPUT (default/input.lua) ═════════════════════════════════════════
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        numlock_by_default = true;
        follow_mouse = 1;
        sensitivity = 0;
        force_no_accel = 1;
        accel_profile = "flat";
        touchpad.natural_scroll = false;
      };

      # Жест на 3 пальца по горизонтали → переключение рабочих столов
      gesture = ["3, horizontal, workspace"];

      # ══ KEYBINDINGS (default/keybindings.lua + userprefs.lua) ═════════════
      bind =
        [
          # ── Системные бинды ──
          "SUPER, Return, exec, ${term}"
          "SUPER, E, exec, nemo"
          "CTRL SHIFT, Escape, exec, ${term} -e btop"
          "SUPER, W, exec, sh ${bin}/rofi-menus/wallpaper-selector.sh"
          "SUPER, T, exec, sh ${bin}/rofi-menus/theme-selector.sh"
          ", Print, exec, sh ${bin}/screenshot.sh"
          "SUPER, Print, exec, sh ${bin}/screenshot.sh --full"
          "SUPER, V, exec, sh ${bin}/rofi-menus/clipboard-manager.sh"
          "SUPER, A, exec, rofi -show drun"
          "SUPER, code:60, exec, sh ${bin}/rofi-menus/rofimoji.sh"
          "SUPER, X, exec, sh ${bin}/rofi-menus/powermenu.sh"
          "SUPER, L, exec, sh ${bin}/screen-lock.sh"
          "SUPER, C, exec, sh ${bin}/color-picker.sh"
          "SUPER, B, exec, sh ${bin}/toggle-bar.sh --toggle --wm hyprland"
          "SUPER, N, exec, swaync-client -t"
          "SUPER SHIFT, B, exec, sh ${bin}/toggle-bar.sh --next --wm hyprland"
          "SUPER, SLASH, exec, hotkeyhub --hyprland $HOME/.config/hypr/hyprland.conf"

          # Закрепить окно: если оно не плавающее — сделать плавающим, затем pin
          "SUPER, P, exec, bash -c 'if [ \"$(hyprctl -j activewindow | jq -r .floating)\" = false ]; then hyprctl dispatch togglefloating; fi; hyprctl dispatch pin'"

          # Отключить/включить все хоткеи
          "SUPER, ESCAPE, submap, passthru"

          # ── Сессия ──
          "SUPER, Delete, exit"
          "CTRL SHIFT, R, exec, hyprctl reload"

          # ── Действия с окном ──
          "SUPER, Q, killactive"
          "SUPER, K, forcekillactive"
          "SUPER, Space, togglefloating"
          "ALT, Return, fullscreen"

          # ── Фокус ──
          "SUPER, right, movefocus, r"
          "SUPER, left, movefocus, l"
          "SUPER, up, movefocus, u"
          "SUPER, down, movefocus, d"
          "ALT, Tab, movefocus, d"

          # ── Переключение рабочих столов ──
          "SUPER CTRL, right, workspace, r+1"
          "SUPER CTRL, left, workspace, r-1"
          "SUPER CTRL, down, workspace, empty"
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"

          # ── Перемещение окна по текущему столу ──
          "SUPER SHIFT CTRL, right, movewindow, r"
          "SUPER SHIFT CTRL, left, movewindow, l"
          "SUPER SHIFT CTRL, up, movewindow, u"
          "SUPER SHIFT CTRL, down, movewindow, d"

          # ── Спец. рабочий стол ──
          "SUPER, S, togglespecialworkspace"
          "SUPER ALT, S, exec, bash -c 'if hyprctl activewindow | grep -q special:special; then hyprctl dispatch movetoworkspace $(hyprctl activeworkspace | awk \"{print \\$3}\"); else hyprctl dispatch movetoworkspacesilent special; fi'"

          # ── Пользовательские приложения (userprefs.lua) ──
          "SUPER SHIFT, C, exec, code"
          "SUPER SHIFT, F, exec, firefox"
          "SUPER SHIFT, T, exec, Telegram"
          "SUPER SHIFT, O, exec, obsidian"
          "SUPER SHIFT, P, exec, pwvucontrol"
          "SUPER SHIFT, Y, exec, ${term} -e yazi"
        ]
        ++ workspaceBinds;

      # Изменение размера окна (repeating = true)
      binde = [
        "SUPER SHIFT, right, resizeactive, 30 0"
        "SUPER SHIFT, left, resizeactive, -30 0"
        "SUPER SHIFT, up, resizeactive, 0 -30"
        "SUPER SHIFT, down, resizeactive, 0 30"
      ];

      # Мультимедиа: locked = true (работает на локскрине)
      bindl = [
        ", XF86AudioMute, exec, sh ${bin}/volume.sh --device output --action toggle"
        ", XF86AudioMicMute, exec, sh ${bin}/volume.sh --device input --action toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
      ];

      # Громкость и яркость: repeating = true + locked = true
      bindel = [
        ", XF86AudioRaiseVolume, exec, sh ${bin}/volume.sh --device output --action increase"
        ", XF86AudioLowerVolume, exec, sh ${bin}/volume.sh --device output --action decrease"
        ", XF86MonBrightnessUp, exec, sh ${bin}/brightness.sh --up"
        ", XF86MonBrightnessDown, exec, sh ${bin}/brightness.sh --down"
      ];

      # Индикатор CapsLock в waybar (release = true)
      bindr = [", Caps_Lock, exec, pkill -RTMIN+8 waybar"];

      # Мышь
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # ══ WINDOW RULES (default/windowrules.lua) ════════════════════════════
      windowrulev2 = [
        # Прозрачность и размытие
        "noblur, class:^()$, title:^()$"
        "opacity 0.90 0.90, class:^(.*)$, title:^(.*)$"
        "opacity 1 1, class:^(firefox)$"

        # Picture-in-Picture
        # Примечание: в upstream класс символов [-\s]; здесь эквивалент [ -]
        "float, title:^([Pp]icture[ -]?[Ii]n[ -]?[Pp]icture)(.*)$"
        "keepaspectratio, title:^([Pp]icture[ -]?[Ii]n[ -]?[Pp]icture)(.*)$"
        "move 74% 74%, title:^([Pp]icture[ -]?[Ii]n[ -]?[Pp]icture)(.*)$"
        "size 25% 25%, title:^([Pp]icture[ -]?[Ii]n[ -]?[Pp]icture)(.*)$"
        "pin, title:^([Pp]icture[ -]?[Ii]n[ -]?[Pp]icture)(.*)$"

        # idleinhibit
        "idleinhibit fullscreen, class:^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$"
        "idleinhibit fullscreen, class:^(.*[Ss]potify.*)$"
        "idleinhibit fullscreen, class:^(yandex-music)$"
        "idleinhibit fullscreen, class:^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$"

        # Плавающие окна
        "float, class:^(vlc)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(firefox)$, title:^(Picture-in-Picture)$"
        "float, class:^(firefox)$, title:^(Library)$"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float, class:^(qt5ct)$"
        "float, class:^(qt6ct)$"
        "float, class:^(org.kde.ark)$"
        "float, class:^(yad)$"

        # pwvucontrol (в 4.1.1 заменил pavucontrol)
        "float, class:^(com.saivert.pwvucontrol)$"
        "size 48% 42%, class:^(com.saivert.pwvucontrol)$"

        "float, class:^(gnome-calculator)$"
        "center, class:^(gnome-calculator)$"
        "size 19% 47%, class:^(gnome-calculator)$"

        "float, class:^(org.gnome.Loupe)$"
        "center, class:^(org.gnome.Loupe)$"
        "size 63% 74%, class:^(org.gnome.Loupe)$"

        "float, class:^(org.gnome.FileRoller)$"
        "center, class:^(org.gnome.FileRoller)$"
        "size 63% 74%, class:^(org.gnome.FileRoller)$"

        "float, class:^(com.meowrch.HotkeyHub)$"
        "center, class:^(com.meowrch.HotkeyHub)$"
        "size 63% 74%, class:^(com.meowrch.HotkeyHub)$"

        "float, class:^(qalculate-gtk)$"
        "center, class:^(qalculate-gtk)$"
        "size 45% 55%, class:^(qalculate-gtk)$"

        # satty — редактор скриншотов (плавающее окно, добавлено в 4.1.x)
        "float, class:^(com.gabm.satty)$"
        "center, class:^(com.gabm.satty)$"
        "size 63% 74%, class:^(com.gabm.satty)$"

        # Модальные окна
        "float, title:^(Open)$"
        "float, title:^(Authentication Required)$"
        "float, title:^(Add Folder to Workspace)$"
        "float, initialTitle:^(Open File)$"
        "float, title:^(Choose Files)$"
        "float, title:^(Save As)$"
        "float, title:^(Confirm to replace files)$"
        "float, title:^(File Operation Progress)$"
        "float, title:^(File Upload)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, class:^(.*dialog.*)$"
        "float, title:^(.*dialog.*)$"

        # Порталы
        "float, class:^(org.freedesktop.impl.portal.desktop.hyprland)$"
        "center, class:^(org.freedesktop.impl.portal.desktop.hyprland)$"
        "float, class:^(org.freedesktop.impl.portal.desktop.gtk)$"
        "center, class:^(org.freedesktop.impl.portal.desktop.gtk)$"
        "float, class:^([Xx]dg-desktop-portal-gtk)$"
        "center, class:^([Xx]dg-desktop-portal-gtk)$"
      ];

      # ══ LAYER RULES (default/windowrules.lua) ═════════════════════════════
      layerrule = [
        "blur, rofi"
        "ignorealpha 0, rofi"
        "blur, notifications"
        "ignorealpha 0, notifications"
        "blur, swaync-notification-window"
        "ignorealpha 0, swaync-notification-window"
        "blur, swaync-control-center"
        "ignorealpha 0, swaync-control-center"
        "blur, waybar"
        "ignorealpha 0, waybar"
        "noanim, selection"
      ];
    };

    # ══ SUBMAP: passthru (SUPER+ESCAPE отключает все хоткеи) ════════════════
    extraConfig = ''
      submap = passthru
      bind = SUPER, ESCAPE, submap, reset
      submap = reset
    '';
  };
}
