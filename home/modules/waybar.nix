{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        height = 34;
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        reload_style_on_change = true;

        # Modules Layout
        modules-left = [
          "custom/l_end"
          "tray"
          "custom/r_end"
          "custom/l_end"
          "hyprland/workspaces"
          "custom/r_end"
          "custom/l_end"
          "wlr/taskbar"
          "custom/r_end"
          "custom/padd"
        ];

        modules-center = [
          "group/system-info"
        ];

        modules-right = [
          "group/system-levels"
          "custom/l_end"
          "idle_inhibitor"
          "clock"
          "custom/r_end"
          "custom/l_end"
          "hyprland/language"
          "custom/r_end"
          "group/control-panel"
          "custom/padd"
        ];

        # Groups
        "group/system-info" = {
          orientation = "horizontal";
          modules = [
            "custom/cpu"
            "custom/ram"
            "custom/gpu"
          ];
        };

        "group/system-levels" = {
          orientation = "horizontal";
          modules = [
            "custom/brightness"
            "custom/battery"
            "custom/volume"
            "custom/microphone"
          ];
        };

        "group/control-panel" = {
          orientation = "horizontal";
          modules = [
            "custom/system-update"
            "custom/do-not-disturb"
            "custom/vpn"
            "custom/bluetooth"
            "custom/networkmanager"
            "custom/power"
          ];
        };

        # Left Modules
        tray = {
          icon-size = 18;
          rotate = 0;
          spacing = 5;
        };

        "hyprland/workspaces" = {
          rotate = 0;
          all-outputs = true;
          active-only = false;
          on-click = "activate";
          disable-scroll = false;
          on-scroll-up = "hyprctl dispatch workspace -1";
          on-scroll-down = "hyprctl dispatch workspace +1";
          persistent-workspaces = {};
        };

        "wlr/taskbar" = {
          format = "{icon}";
          rotate = 0;
          icon-size = 18;
          icon-theme = "Tela-circle-dracula";
          spacing = 0;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          app_ids-mapping = {
            firefoxdeveloperedition = "firefox-developer-edition";
          };
        };

        # Middle Modules
        "custom/cpu" = {
          exec = "python ~/bin/system-info.py --cpu --normal-color \"#f5c2e7\" --critical-color \"#f38ba8\" | cat";
          on-click = "python ~/bin/system-info.py --cpu --click";
          return-type = "json";
          format = "{}  ";
          rotate = 0;
          interval = 2;
          tooltip = true;
        };

        "custom/ram" = {
          exec = "python ~/bin/system-info.py --ram --normal-color \"#fab387\" --critical-color \"#f38ba8\" | cat";
          return-type = "json";
          format = "{}  ";
          rotate = 0;
          interval = 2;
          tooltip = true;
        };

        "custom/gpu" = {
          exec = "python ~/bin/system-info.py --gpu --normal-color \"#f5e0dc\" --critical-color \"#f38ba8\" | cat";
          on-click = "python ~/bin/system-info.py --gpu --click";
          return-type = "json";
          format = "{}";
          rotate = 0;
          interval = 2;
          tooltip = true;
        };

        # Right Modules
        clock = {
          format = "{:%H:%M %p}";
          rotate = 0;
          format-alt = "{:%R | 󰃭 %d·%m·%y}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          rotate = 0;
          format-icons = {
            activated = "󰥔 ";
            deactivated = " ";
          };
        };

        "custom/battery" = {
          exec = "sh ~/bin/battery.sh --status --discharged-color \"#f38ba8\" --charged-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{}  ";
          interval = 3;
          rotate = 0;
          on-click = "sh ~/bin/battery.sh --notify";
          tooltip = false;
        };

        "custom/brightness" = {
          exec = "sh ~/bin/brightness.sh --status --color \"#61afef\" | cat";
          return-type = "raw";
          format = "{}  ";
          interval = 1;
          rotate = 0;
          on-scroll-up = "sh ~/bin/brightness.sh --up";
          on-scroll-down = "sh ~/bin/brightness.sh --down";
          on-click-left = "sh ~/bin/brightness.sh --max";
          on-click-right = "sh ~/bin/brightness.sh --min";
          tooltip = false;
        };

        "custom/volume" = {
          exec = "sh ~/bin/volume.sh --device output --status --disabled-color \"#f38ba8\" --enabled-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{}  ";
          interval = 1;
          rotate = 0;
          on-click = "sh ~/bin/volume.sh --device output --action toggle";
          on-scroll-up = "sh ~/bin/volume.sh --device output --action increase";
          on-scroll-down = "sh ~/bin/volume.sh --device output --action decrease";
          scroll-step = 5;
          tooltip = false;
        };

        "custom/microphone" = {
          exec = "sh ~/bin/volume.sh --device input --status --disabled-color \"#f38ba8\" --enabled-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{}";
          interval = 1;
          rotate = 0;
          on-click = "sh ~/bin/volume.sh --device input --action toggle";
          on-scroll-up = "sh ~/bin/volume.sh --device input --action increase";
          on-scroll-down = "sh ~/bin/volume.sh --device input --action decrease";
          scroll-step = 5;
          tooltip = false;
        };

        "hyprland/language" = {
          format = "{short} {variant}";
          rotate = 0;
          min-length = 2;
          tooltip = false;
        };

        "custom/system-update" = {
          exec = "sh ~/bin/system-update.sh --status --unupdated-color \"#fab387\" --updated-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{} ";
          rotate = 0;
          on-click = "CHECKUPDATES_DB=\"/tmp/checkup-db-\${UID}-$$\" sh ~/bin/system-update.sh";
          interval = 86400;
          tooltip = false;
        };

        "custom/do-not-disturb" = {
          exec = "sh ~/bin/do-not-disturb.sh --status --disabled-color \"#f38ba8\" --enabled-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{} ";
          interval = 1;
          rotate = 0;
          on-click = "sh ~/bin/do-not-disturb.sh";
          tooltip = false;
        };

        "custom/vpn" = {
          exec = "sh ~/bin/rofi-menus/vpn-manager.sh --status --disabled-color \"#f38ba8\" --enabled-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{} ";
          interval = 3;
          rotate = 0;
          on-click = "sh ~/bin/rofi-menus/vpn-manager.sh";
          tooltip = false;
        };

        "custom/bluetooth" = {
          format = "<span color=\"#89b4fa\">󰂯  </span>";
          interval = 3;
          rotate = 0;
          on-click = "blueman-manager";
          tooltip = false;
        };

        "custom/networkmanager" = {
          exec = "sh ~/bin/rofi-menus/network-manager.sh --status --disabled-color \"#f38ba8\" --enabled-color \"#a6e3a1\" | cat";
          return-type = "raw";
          format = "{}  ";
          interval = 3;
          rotate = 0;
          on-click = "sh ~/bin/rofi-menus/network-manager.sh";
          tooltip = false;
        };

        "custom/power" = {
          on-click = "sh ~/bin/rofi-menus/powermenu.sh";
          format = "<span color=\"#f38ba8\"> </span>";
          rotate = 0;
          tooltip = false;
        };

        # Other Modules
        "custom/l_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/r_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/padd" = {
          format = "  ";
          interval = "once";
          tooltip = false;
        };

        "custom/padd_bg" = {
          format = "  ";
          interval = "once";
          tooltip = false;
        };
      };
    };

    style = builtins.readFile (pkgs.writeText "waybar-style.css" ''
      /* Waybar Meowrch Theme - Catppuccin Mocha */
    '');
  };

  # Create waybar style file
  home.file.".config/waybar/style.css".text = ''
    /*
    ┏┓ ┏┓ ┏┓ ┏┓ ┏┓ • ┏┓ ┏┓ ┏┓ ┏┓
    ┣┫ ┣┫ ┣┫ ┣┫ ┣┫ • ┣┫ ┣┫ ┣┫ ┣┫  - Meowrch
    ┗┛ ┗┛ ┗┛ ┗┛ ┗┛ • ┗┛ ┗┛ ┗┛ ┗┛
    */

    @define-color highlight-color rgba(181, 206, 168, 1);
    @define-color background-color rgba(24, 24, 37, 0.8);
    @define-color primary-color rgba(205, 214, 244, 1);
    @define-color secondary-color rgba(88, 91, 112, 1);
    @define-color accent-color rgba(137, 180, 250, 1);

    * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", Helvetica, Arial, sans-serif;
        font-weight: bold;
        font-size: 13px;
        min-height: 0;
    }

    window#waybar {
        background-color: transparent;
        color: @primary-color;
        transition-property: background-color;
        transition-duration: 0.5s;
    }

    tooltip {
        background: rgba(24, 24, 37, 0.9);
        border: 1px solid rgba(180, 190, 254, 0.3);
        border-radius: 10px;
        color: @primary-color;
    }

    tooltip label {
        color: @primary-color;
    }

    /* Left modules */
    #custom-l_end {
        color: @background-color;
        background: transparent;
        font-size: 20px;
    }

    #custom-r_end {
        color: @background-color;
        background: transparent;
        font-size: 20px;
    }

    #custom-padd {
        background: transparent;
    }

    #tray,
    #workspaces,
    #taskbar {
        background-color: @background-color;
        margin: 5px 0;
        padding: 0 10px;
        border-radius: 10px;
    }

    #tray {
        padding: 0 10px;
    }

    #tray menu {
        background-color: rgba(24, 24, 37, 0.9);
        border: 1px solid rgba(180, 190, 254, 0.3);
        border-radius: 10px;
    }

    #workspaces {
        padding: 0 5px;
    }

    #workspaces button {
        background-color: transparent;
        color: @secondary-color;
        padding: 5px 10px;
        margin: 0 2px;
        border-radius: 10px;
        transition: all 0.3s ease;
    }

    #workspaces button.active {
        background-color: @accent-color;
        color: rgba(24, 24, 37, 1);
    }

    #workspaces button:hover {
        background-color: rgba(180, 190, 254, 0.2);
        color: @primary-color;
    }

    #taskbar button {
        background-color: transparent;
        color: @secondary-color;
        padding: 5px;
        margin: 0 2px;
        border-radius: 8px;
        transition: all 0.3s ease;
    }

    #taskbar button.active {
        background-color: @accent-color;
        color: rgba(24, 24, 37, 1);
    }

    #taskbar button:hover {
        background-color: rgba(180, 190, 254, 0.2);
        color: @primary-color;
    }

    /* Center modules */
    .modules-center {
        background-color: @background-color;
        border-radius: 10px;
        margin: 5px 0;
        padding: 0 15px;
    }

    #custom-cpu,
    #custom-ram,
    #custom-gpu {
        padding: 0 10px;
        color: @primary-color;
    }

    /* Right modules */
    #custom-brightness,
    #custom-battery,
    #custom-volume,
    #custom-microphone {
        background-color: @background-color;
        margin: 5px 2px;
        padding: 0 10px;
        border-radius: 10px;
        color: @primary-color;
    }

    #idle_inhibitor,
    #clock,
    #language {
        background-color: @background-color;
        margin: 5px 0;
        padding: 0 15px;
        border-radius: 10px;
        color: @primary-color;
    }

    #custom-system-update,
    #custom-do-not-disturb,
    #custom-vpn,
    #custom-bluetooth,
    #custom-networkmanager,
    #custom-power {
        background-color: @background-color;
        margin: 5px 2px;
        padding: 0 8px;
        border-radius: 10px;
        color: @primary-color;
    }

    /* Hover effects */
    #tray:hover,
    #workspaces:hover,
    #taskbar:hover,
    .modules-center:hover,
    #idle_inhibitor:hover,
    #clock:hover,
    #language:hover,
    #custom-brightness:hover,
    #custom-battery:hover,
    #custom-volume:hover,
    #custom-microphone:hover,
    #custom-system-update:hover,
    #custom-do-not-disturb:hover,
    #custom-vpn:hover,
    #custom-bluetooth:hover,
    #custom-networkmanager:hover,
    #custom-power:hover {
        background-color: rgba(24, 24, 37, 0.95);
        transition: all 0.3s ease;
    }

    /* Special states */
    #custom-power {
        color: #f38ba8;
    }

    #custom-power:hover {
        color: #ffffff;
        background-color: #f38ba8;
    }

    #idle_inhibitor.activated {
        color: #f9e2af;
    }

    /* Animation */
    * {
        transition: all 0.2s ease;
    }
  '';
}
