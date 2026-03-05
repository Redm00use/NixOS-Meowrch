{ config, pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
    ];

    terminal = "${pkgs.kitty}/bin/kitty";

    extraConfig = {
      modi = "drun,run,filebrowser,emoji,calc";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " Files";
      display-emoji = "󰞅 Emoji";
      display-calc = " Calc";
      drun-display-format = "{name}";
      disable-history = false;
      hide-scrollbar = true;
      sidebar-mode = true;
      hover-select = true;
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
      scroll-method = 0;
      window-format = "[{w}] ··· {t}";
      click-to-exit = true;
      max-history-size = 25;
      combi-hide-mode-prefix = true;
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      normalize-match = true;
      threads = 0;
      case-sensitive = false;
      cycle = true;
      eh = 1;
      auto-select = false;
      parse-hosts = true;
      parse-known-hosts = true;
      tokenize = true;
      m = "-5";
      filter = "";
      config = "";
      no-lazy-grab = false;
      no-plugins = false;
      plugin-path = "/run/current-system/sw/lib/rofi";
      window-thumbnail = false;
      dpi = -1;
    };

    theme = lib.mkForce "meowrch";
  };

  # Create custom Rofi theme
  home.file.".config/rofi/themes/meowrch.rasi".text = ''
    /**
     * Meowrch Original Rofi Theme
     * Colors: Catppuccin Mocha
     **/

    * {
        bg-col:  #1e1e2e;
        bg-col-light: #1e1e2e;
        border-col: #b4befe;
        selected-col: #b4befe;
        blue: #89b4fa;
        fg-col: #cdd6f4;
        fg-col2: #f38ba8;
        grey: #6c7086;
        width: 600;
        font: "JetBrainsMono Nerd Font 11";
    }

    element-text, element-icon , mode-switcher {
        background-color: inherit;
        text-color:       inherit;
    }

    window {
        height: 450px;
        width: 700px;
        border: 0px;
        border-color: @border-col;
        background-color: @bg-col;
        border-radius: 12px;
    }

    mainbox {
        background-color: @bg-col;
    }

    inputbar {
        children: [prompt,entry];
        background-color: @bg-col;
        border-radius: 5px;
        padding: 2px;
    }

    prompt {
        background-color: @blue;
        padding: 6px;
        text-color: @bg-col;
        border-radius: 3px;
        margin: 20px 0px 0px 20px;
    }

    textbox-prompt-colon {
        expand: false;
        str: ":";
    }

    entry {
        padding: 6px;
        margin: 20px 0px 0px 10px;
        text-color: @fg-col;
        background-color: @bg-col;
    }

    listview {
        border: 0px 0px 0px;
        padding: 6px 0px 0px;
        margin: 10px 0px 0px 20px;
        columns: 2;
        lines: 5;
        background-color: @bg-col;
    }

    element {
        padding: 5px;
        background-color: @bg-col;
        text-color: @fg-col  ;
    }

    element-icon {
        size: 25px;
    }

    element selected {
        background-color:  @selected-col ;
        text-color: @bg-col  ;
        border-radius: 5px;
    }

    mode-switcher {
        spacing: 0;
      }

    button {
        padding: 10px;
        background-color: @bg-col-light;
        text-color: @grey;
        vertical-align: 0.5; 
        horizontal-align: 0.5;
    }

    button selected {
      background-color: @bg-col;
      text-color: @blue;
    }

    message {
        background-color: @bg-col-light;
        margin: 2px;
        padding: 2px;
        border-radius: 5px;
    }

    textbox {
        padding: 6px;
        margin: 20px 0px 0px 20px;
        text-color: @blue;
        background-color: @bg-col-light;
    }
  '';

  # Create selecting.rasi for wallpaper and theme pickers
  home.file.".config/rofi/selecting.rasi".text = ''
    /*****----- Configuration -----*****/
    configuration {
        show-icons:                 true;
        drun-display-format:        "{name}";
    }

    /*****----- Global Properties -----*****/
    @import "~/.config/rofi/themes/meowrch.rasi"

    /*****----- Main Window -----*****/
    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       1100px;
        x-offset:                    0px;
        y-offset:                    0px;

        enabled:                     true;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               15px;
        border-color:                @selected-col;
        background-color:            @bg-col;
        cursor:                      "default";
    }

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     20px;
        margin:                      0px;
        padding:                     20px;
        border:                      0px solid;
        border-radius:               0px 0px 0px 0px;
        border-color:                @selected-col;
        background-color:            transparent;
        children:                    [ "inputbar", "listview" ];
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @selected-col;
        background-color:            transparent;
        text-color:                  @fg-col;
        children:                    [ "prompt", "entry" ];
    }

    prompt {
        enabled:                     true;
        background-color:            @selected-col;
        text-color:                  @bg-col;
        padding:                     10px;
        border-radius:               10px;
    }

    entry {
        enabled:                     true;
        background-color:            @bg-col-light;
        text-color:                  inherit;
        cursor:                      text;
        placeholder:                 "Search...";
        placeholder-color:           inherit;
        padding:                     10px;
        border-radius:               10px;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     5;
        lines:                       2;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        
        spacing:                     10px;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @selected-col;
        background-color:            transparent;
        text-color:                  @fg-col;
        cursor:                      "default";
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     10px;
        border:                      0px solid;
        border-radius:               15px;
        border-color:                @selected-col;
        background-color:            transparent;
        text-color:                  @fg-col;
        orientation:                 vertical;
        cursor:                      "pointer";
    }
    element normal.normal {
        background-color:            transparent;
        text-color:                  @fg-col;
    }
    element selected.normal {
        background-color:            @selected-col;
        text-color:                  @bg-col;
    }
    element-icon {
        background-color:            transparent;
        text-color:                  inherit;
        size:                        180px;
        cursor:                      inherit;
    }
    element-text {
        background-color:            transparent;
        text-color:                  inherit;
        highlight:                   inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }
  '';

  # Create custom Rofi scripts directory
  home.file."bin/rofi-menus" = {
    source = ../../scripts/rofi-menus;
    recursive = true;
    executable = true;
  };

  # Individual Rofi menu scripts
  home.file."bin/rofi-powermenu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi power menu for Meowrch

      theme="$HOME/.config/rofi/themes/meowrch.rasi"

      # Options
      shutdown="⏻ Shutdown"
      reboot=" Reboot"
      lock=" Lock"
      suspend="⏾ Suspend"
      logout="󰗽 Logout"

      # Variable passed to rofi
      options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

      chosen="$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme "$theme" -width 300 -lines 5)"
      case $chosen in
          $shutdown)
              systemctl poweroff
              ;;
          $reboot)
              systemctl reboot
              ;;
          $lock)
              swaylock
              ;;
          $suspend)
              systemctl suspend
              ;;
          $logout)
              hyprctl dispatch exit
              ;;
      esac
    '';
  };

  home.file."bin/rofi-emoji.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi emoji picker for Meowrch

      theme="$HOME/.config/rofi/themes/meowrch.rasi"

      if command -v rofimoji &> /dev/null; then
          rofimoji --rofi-args="-theme $theme"
      else
          rofi -modi emoji -show emoji -theme "$theme"
      fi
    '';
  };

  home.file."bin/rofi-clipboard.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi clipboard manager for Meowrch

      theme="$HOME/.config/rofi/themes/meowrch.rasi"

      if command -v cliphist &> /dev/null; then
          cliphist list | rofi -dmenu -p "Clipboard" -theme "$theme" | cliphist decode | wl-copy
      else
          echo "cliphist not found" | rofi -dmenu -p "Error" -theme "$theme"
      fi
    '';
  };

  home.file."bin/rofi-wifi.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi WiFi manager for Meowrch

      theme="$HOME/.config/rofi/themes/meowrch.rasi"

      wifi_list=$(nmcli dev wifi list | sed 1d | awk '{print $1}' | sort -u)
      chosen_network=$(echo "$wifi_list" | rofi -dmenu -p "WiFi Networks" -theme "$theme")

      if [[ -n "$chosen_network" ]]; then
          password=$(rofi -dmenu -p "Password for $chosen_network" -password -theme "$theme")
          if [[ -n "$password" ]]; then
              nmcli dev wifi connect "$chosen_network" password "$password"
              notify-send "WiFi" "Connecting to $chosen_network"
          fi
      fi
    '';
  };

  home.file."bin/rofi-bluetooth.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi Bluetooth manager for Meowrch

      theme="$HOME/.config/rofi/themes/meowrch.rasi"

      options="󰂯 Toggle Bluetooth\n Scan for devices\n󰂱 Connected devices\n Pair new device"
      chosen="$(echo -e "$options" | rofi -dmenu -p "Bluetooth" -theme "$theme")"

      case $chosen in
          "󰂯 Toggle Bluetooth")
              if bluetoothctl show | grep -q "Powered: yes"; then
                  bluetoothctl power off
                  notify-send "Bluetooth" "Bluetooth turned off"
              else
                  bluetoothctl power on
                  notify-send "Bluetooth" "Bluetooth turned on"
              fi
              ;;
          " Scan for devices")
              bluetoothctl scan on &
              sleep 5
              bluetoothctl scan off
              devices=$(bluetoothctl devices | cut -d' ' -f3-)
              chosen_device=$(echo "$devices" | rofi -dmenu -p "Available devices" -theme "$theme")
              if [[ -n "$chosen_device" ]]; then
                  mac=$(bluetoothctl devices | grep "$chosen_device" | cut -d' ' -f2)
                  bluetoothctl connect "$mac"
              fi
              ;;
          "󰂱 Connected devices")
              connected=$(bluetoothctl devices Connected | cut -d' ' -f3-)
              if [[ -n "$connected" ]]; then
                  echo "$connected" | rofi -dmenu -p "Connected devices" -theme "$theme"
              else
                  echo "No connected devices" | rofi -dmenu -p "Bluetooth" -theme "$theme"
              fi
              ;;
          " Pair new device")
              bluetoothctl scan on &
              sleep 5
              bluetoothctl scan off
              devices=$(bluetoothctl devices | cut -d' ' -f3-)
              chosen_device=$(echo "$devices" | rofi -dmenu -p "Pair device" -theme "$theme")
              if [[ -n "$chosen_device" ]]; then
                  mac=$(bluetoothctl devices | grep "$chosen_device" | cut -d' ' -f2)
                  bluetoothctl pair "$mac"
                  bluetoothctl trust "$mac"
                  bluetoothctl connect "$mac"
              fi
              ;;
      esac
    '';
  };
}
