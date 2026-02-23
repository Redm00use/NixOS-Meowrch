{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

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
      scroll-method = 0;
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

    theme = "meowrch";
  };

  # Create custom Rofi theme
  home.file.".config/rofi/themes/meowrch.rasi".text = ''
    /*
     * Meowrch Rofi Theme
     * Based on Catppuccin Mocha
     */

    * {
        bg-col:  #1e1e2e;
        bg-col-light: #313244;
        border-col: #45475a;
        selected-col: #89b4fa;
        blue: #89b4fa;
        fg-col: #cdd6f4;
        fg-col2: #f38ba8;
        grey: #6c7086;
        width: 600;
        font: "JetBrainsMono Nerd Font 12";
    }

    element-text, element-icon , mode-switcher {
        background-color: inherit;
        text-color:       inherit;
    }

    window {
        height: 360px;
        border: 3px;
        border-color: @border-col;
        background-color: @bg-col;
        border-radius: 15px;
    }

    mainbox {
        background-color: @bg-col;
        border-radius: 15px;
    }

    inputbar {
        children: [prompt,entry];
        background-color: @bg-col;
        border-radius: 10px;
        padding: 8px;
        margin: 10px 10px 0px 10px;
        border: 2px;
        border-color: @border-col;
    }

    prompt {
        background-color: @selected-col;
        padding: 6px 12px;
        text-color: @bg-col;
        border-radius: 6px;
        margin: 0px 10px 0px 0px;
        font: "JetBrainsMono Nerd Font Bold 12";
    }

    textbox-prompt-colon {
        expand: false;
        str: "";
    }

    entry {
        padding: 6px;
        margin: 0px 0px 0px 0px;
        text-color: @fg-col;
        background-color: @bg-col;
        placeholder: "Search...";
        placeholder-color: @grey;
        vertical-align: 0.5;
    }

    listview {
        border: 0px 0px 0px;
        padding: 6px 0px 0px;
        margin: 10px 10px 0px 10px;
        columns: 1;
        lines: 8;
        background-color: @bg-col;
        spacing: 0px;
        cycle: true;
        dynamic: true;
        layout: vertical;
    }

    element {
        padding: 8px 12px;
        background-color: @bg-col;
        text-color: @fg-col;
        border-radius: 8px;
        margin: 0px 0px 2px 0px;
    }

    element-icon {
        size: 24px;
        margin: 0px 10px 0px 0px;
    }

    element.selected {
        background-color: @selected-col;
        text-color: @bg-col;
    }

    element.selected.active {
        background-color: @selected-col;
        text-color: @bg-col;
    }

    mode-switcher {
        spacing: 0;
        margin: 10px;
        background-color: @bg-col-light;
        border-radius: 10px;
        padding: 5px;
    }

    button {
        padding: 8px 12px;
        background-color: @bg-col-light;
        text-color: @grey;
        vertical-align: 0.5;
        horizontal-align: 0.5;
        border-radius: 6px;
        margin: 2px;
    }

    button.selected {
        background-color: @selected-col;
        text-color: @bg-col;
        font: "JetBrainsMono Nerd Font Bold 12";
    }

    message {
        background-color: @bg-col-light;
        margin: 10px;
        padding: 10px;
        border-radius: 10px;
        border: 2px;
        border-color: @border-col;
    }

    textbox {
        padding: 6px;
        margin: 0px 0px 0px 0px;
        text-color: @fg-col2;
        background-color: @bg-col-light;
    }

    error-message {
        padding: 10px;
        border: 2px solid;
        border-radius: 10px;
        border-color: @fg-col2;
        background-color: @bg-col;
    }
  '';

  # Create custom Rofi scripts directory
  home.file."bin/rofi-menus" = {
    source = ../../dotfiles/bin/rofi-menus;
    recursive = true;
    executable = true;
  };

  # Individual Rofi menu scripts
  home.file."bin/rofi-powermenu.sh".text = ''
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

  home.file."bin/rofi-emoji.sh".text = ''
    #!/usr/bin/env bash
    # Rofi emoji picker for Meowrch

    theme="$HOME/.config/rofi/themes/meowrch.rasi"

    if command -v rofimoji &> /dev/null; then
        rofimoji --rofi-args="-theme $theme"
    else
        rofi -modi emoji -show emoji -theme "$theme"
    fi
  '';

  home.file."bin/rofi-clipboard.sh".text = ''
    #!/usr/bin/env bash
    # Rofi clipboard manager for Meowrch

    theme="$HOME/.config/rofi/themes/meowrch.rasi"

    if command -v cliphist &> /dev/null; then
        cliphist list | rofi -dmenu -p "Clipboard" -theme "$theme" | cliphist decode | wl-copy
    else
        echo "cliphist not found" | rofi -dmenu -p "Error" -theme "$theme"
    fi
  '';

  home.file."bin/rofi-wifi.sh".text = ''
    #!/usr/bin/env bash
    # Rofi WiFi manager for Meowrch

    theme="$HOME/.config/rofi/themes/meowrch.rasi"

    # Get list of available WiFi networks
    wifi_list=$(nmcli dev wifi list | sed 1d | awk '{print $1}' | sort -u)

    # Show rofi menu
    chosen_network=$(echo "$wifi_list" | rofi -dmenu -p "WiFi Networks" -theme "$theme")

    if [[ -n "$chosen_network" ]]; then
        # Ask for password
        password=$(rofi -dmenu -p "Password for $chosen_network" -password -theme "$theme")

        if [[ -n "$password" ]]; then
            nmcli dev wifi connect "$chosen_network" password "$password"
            notify-send "WiFi" "Connecting to $chosen_network"
        fi
    fi
  '';

  home.file."bin/rofi-bluetooth.sh".text = ''
    #!/usr/bin/env bash
    # Rofi Bluetooth manager for Meowrch

    theme="$HOME/.config/rofi/themes/meowrch.rasi"

    # Bluetooth options
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

  # Make scripts executable
  home.activation.makeRofiScriptsExecutable = config.lib.dag.entryAfter ["writeBoundary"] ''
    chmod +x $HOME/bin/rofi-*.sh
  '';
}
