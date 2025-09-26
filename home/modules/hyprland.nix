{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    settings = {
      # Monitor configuration
      monitor = [
        "eDP-1,1920x1080@60,0x0,1"
        ",preferred,auto,auto"
      ];

      # Startup applications
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd --all"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "dunst"
        "hypridle"
        "swww init"
        "udiskie --no-automount --smart-tray"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "python ~/.config/meowrch/meowrch.py --action set-current-theme && python ~/.config/meowrch/meowrch.py --action set-wallpaper && waybar"
      ];

      # Environment variables
      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "GDK_SCALE,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "_JAVA_OPTIONS,-Dsun.java2d.opengl=true"
      ];

      # Input configuration
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0;
        force_no_accel = true;
      };

      # General configuration
      general = {
        gaps_in = 3;
        gaps_out = 8;
        border_size = 3;
        "col.active_border" = "rgb(b4befe) rgb(f5c2e7) 45deg";
        "col.inactive_border" = "rgba(00000000)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Decoration
      decoration = {
        rounding = 10;
        dim_special = 0.3;

        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = false;
          special = true;
        };
      };

      # Animations
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

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      # Misc
      misc = {
        vrr = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # XWayland
      xwayland = {
        force_zero_scaling = true;
      };

      # Variables
      "$mainMod" = "SUPER";
      "$subMod" = "SUPER_SHIFT";
      "$term" = "kitty";
      "$file" = "nemo";
      "$browser" = "firefox";

      # Key bindings
      bind = [
        # System binds
        "$mainMod, Return, exec, $term"
        "$mainMod, E, exec, $file"
        "CTRL_SHIFT, Escape, exec, $term -e btop"
        "$mainMod, W, exec, python ~/.config/meowrch/meowrch.py --action select-wallpaper"
        "$mainMod, T, exec, python ~/.config/meowrch/meowrch.py --action select-theme"
        ", Print, exec, flameshot gui"
        "$mainMod, P, exec, pavucontrol"
        "$mainMod, V, exec, sh ~/bin/rofi-menus/clipboard-manager.sh"
        "$mainMod, D, exec, rofi -show drun"
        "$mainMod, code:60, exec, sh ~/bin/rofi-menus/rofimoji.sh"
        "$mainMod, X, exec, sh ~/bin/rofi-menus/powermenu.sh"
        "$mainMod, L, exec, sh ~/bin/screen-lock.sh"
        "$mainMod, C, exec, sh ~/bin/color-picker.sh"
        "$mainMod, B, exec, sh ~/bin/toggle-bar.sh"

        # User apps
        "$subMod, C, exec, zed"
        "$subMod, F, exec, firefox"
        "$subMod, T, exec, telegram-desktop"

        # Session actions
        "$mainMod, Delete, exit"
        "CTRL_SHIFT, R, exec, hyprctl reload"

        # Window actions
        "$mainMod, Q, killactive"
        "$mainMod, Space, togglefloating"
        "ALT, Return, fullscreen"

        # Move/Change window focus
        "$mainMod, Right, movefocus, r"
        "$mainMod, Left, movefocus, l"
        "$mainMod, Up, movefocus, u"
        "$mainMod, Down, movefocus, d"
        "ALT, Tab, movefocus, d"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod CTRL, Right, workspace, r+1"
        "$mainMod CTRL, Left, workspace, r-1"
        "$mainMod CTRL, Down, workspace, empty"
        "$mainMod, S, togglespecialworkspace"

        # Move focused window to a workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Move focused window around the current workspace
        "$mainMod SHIFT CTRL, Right, movewindow, r"
        "$mainMod SHIFT CTRL, Left, movewindow, l"
        "$mainMod SHIFT CTRL, Up, movewindow, u"
        "$mainMod SHIFT CTRL, Down, movewindow, d"

        # Silent workspaces
        "$mainMod ALT, S, movetoworkspacesilent, special"
      ];

      # Repeat binds
      binde = [
        # Resize windows
        "$mainMod SHIFT, Right, resizeactive, 30 0"
        "$mainMod SHIFT, Left, resizeactive, -30 0"
        "$mainMod SHIFT, Up, resizeactive, 0 -30"
        "$mainMod SHIFT, Down, resizeactive, 0 30"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:273, resizewindow"
        "$mainMod, mouse:272, movewindow"
      ];

      # Volume and brightness controls
      bindel = [
        ", XF86AudioRaiseVolume, exec, sh ~/bin/volume.sh --device output --action increase"
        ", XF86AudioLowerVolume, exec, sh ~/bin/volume.sh --device output --action decrease"
        ", XF86MonBrightnessUp, exec, sh ~/bin/brightness.sh --up"
        ", XF86MonBrightnessDown, exec, sh ~/bin/brightness.sh --down"
      ];

      bindl = [
        ", XF86AudioMute, exec, sh ~/bin/volume.sh --device output --action toggle"
        ", XF86AudioMicMute, exec, sh ~/bin/volume.sh --device input --action toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
      ];

      # Scroll workspaces
      bind = [
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # Window rules
      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(blueman-manager)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(chrony)$"
        "float, ^(galculator)$"
        "float, ^(gnome-calculator)$"
      ];

      windowrulev2 = [
        "opacity 0.90 0.90,class:^(Firefox)$"
        "opacity 0.95 0.95,class:^(kitty)$"
        "opacity 0.90 0.90,class:^(thunar)$"
        "opacity 0.90 0.90,class:^(nemo)$"
        "opacity 0.90 0.90,class:^(zed)$"
        "float,class:^(zenity)$"
        "float,class:^(polkit-gnome-authentication-agent-1)$"
      ];

      # Layer rules
      layerrule = [
        "blur,waybar"
        "blur,rofi"
        "blur,notifications"
      ];
    };
  };
}
