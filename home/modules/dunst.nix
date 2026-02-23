{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    package = pkgs.dunst;
    
    settings = {
      global = {
        # Display
        monitor = 0;
        follow = "mouse";
        
        # Geometry
        width = 350;
        height = 300;
        origin = "top-right";
        offset = "10x10";
        scale = 0;
        notification_limit = 5;
        
        # Progress bar
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        
        # Appearance
        transparency = 10;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 0;
        frame_width = 2;
        frame_color = "#89b4fa";
        separator_color = "frame";
        
        # Sorting
        sort = true;
        
        # Text
        font = "JetBrainsMono Nerd Font 11";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        
        # Icons
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 32;
        icon_path = "/run/current-system/sw/share/icons/Papirus-Dark/32x32/status:/run/current-system/sw/share/icons/Papirus-Dark/32x32/devices:/run/current-system/sw/share/icons/Papirus-Dark/32x32/apps";
        
        # History
        sticky_history = true;
        history_length = 20;
        
        # Misc/Advanced
        dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p dunst";
        browser = "${pkgs.firefox}/bin/firefox";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 10;
        ignore_dbusclose = false;
        
        # Wayland
        force_xwayland = false;
        
        # Legacy
        force_xinerama = false;
        
        # Mouse
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      
      experimental = {
        per_monitor_dpi = false;
      };
      
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
        frame_color = "#45475a";
        highlight = "#89b4fa";
      };
      
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
        frame_color = "#89b4fa";
        highlight = "#89b4fa";
      };
      
      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        highlight = "#f38ba8";
        timeout = 0;
      };
      
      # Custom notification rules
      volume = {
        appname = "Volume";
        urgency = "low";
        timeout = 3;
        frame_color = "#fab387";
        highlight = "#fab387";
        format = "<b>%s</b>\\n%b";
      };
      
      brightness = {
        appname = "Brightness";
        urgency = "low";
        timeout = 3;
        frame_color = "#f9e2af";
        highlight = "#f9e2af";
        format = "<b>%s</b>\\n%b";
      };
      
      battery = {
        appname = "Battery";
        urgency = "normal";
        timeout = 10;
        frame_color = "#a6e3a1";
        highlight = "#a6e3a1";
        format = "<b>%s</b>\\n%b";
      };
      
      battery_critical = {
        appname = "Battery";
        urgency = "critical";
        body = "*Critical*";
        frame_color = "#f38ba8";
        highlight = "#f38ba8";
        format = "<b>🔋 CRITICAL BATTERY</b>\\n%b";
        timeout = 0;
      };
      
      network = {
        appname = "NetworkManager";
        urgency = "low";
        timeout = 5;
        frame_color = "#94e2d5";
        highlight = "#94e2d5";
      };
      
      bluetooth = {
        appname = "Bluetooth";
        urgency = "low";
        timeout = 5;
        frame_color = "#89b4fa";
        highlight = "#89b4fa";
      };
      
      screenshot = {
        appname = "flameshot";
        urgency = "low";
        timeout = 3;
        frame_color = "#f5c2e7";
        highlight = "#f5c2e7";
      };
      
      spotify = {
        appname = "Spotify";
        urgency = "low";
        timeout = 5;
        frame_color = "#a6e3a1";
        highlight = "#a6e3a1";
        format = "<b>🎵 %s</b>\\n%b";
      };
      
      discord = {
        appname = "discord";
        urgency = "low";
        timeout = 5;
        frame_color = "#89b4fa";
        highlight = "#89b4fa";
      };
      
      telegram = {
        appname = "org.telegram.desktop";
        urgency = "normal";
        timeout = 10;
        frame_color = "#89b4fa";
        highlight = "#89b4fa";
      };
      
      firefox = {
        appname = "Firefox";
        urgency = "low";
        timeout = 5;
        frame_color = "#fab387";
        highlight = "#fab387";
      };
    };
  };

  # Custom notification scripts
  home.file."bin/notify-volume.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Volume notification script
      
      get_volume() {
          pamixer --get-volume
      }
      
      is_mute() {
          pamixer --get-mute
      }
      
      send_notification() {
          volume=$(get_volume)
          mute=$(is_mute)
          
          if [[ $mute == "true" ]]; then
              icon="🔇"
              text="Muted"
          elif [[ $volume -eq 0 ]]; then
              icon="🔈"
              text="$volume%"
          elif [[ $volume -lt 30 ]]; then
              icon="🔉"
              text="$volume%"
          else
              icon="🔊"
              text="$volume%"
          fi
          
          dunstify -a "Volume" -u low -r 9991 -h int:value:$volume "$icon Volume" "$text"
      }
      
      case $1 in
          up)
              pamixer -i 5
              send_notification
              ;;
          down)
              pamixer -d 5
              send_notification
              ;;
          toggle)
              pamixer -t
              send_notification
              ;;
          *)
              send_notification
              ;;
      esac
    '';
  };

  home.file."bin/notify-brightness.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Brightness notification script
      
      get_brightness() {
          brightnessctl get
      }
      
      get_max_brightness() {
          brightnessctl max
      }
      
      send_notification() {
          brightness=$(get_brightness)
          max_brightness=$(get_max_brightness)
          percentage=$((brightness * 100 / max_brightness))
          
          if [[ $percentage -lt 10 ]]; then
              icon="🔅"
          elif [[ $percentage -lt 30 ]]; then
              icon="🔆"
          else
              icon="☀️"
          fi
          
          dunstify -a "Brightness" -u low -r 9992 -h int:value:$percentage "$icon Brightness" "$percentage%"
      }
      
      case $1 in
          up)
              brightnessctl set +5%
              send_notification
              ;;
          down)
              brightnessctl set 5%-
              send_notification
              ;;
          *)
              send_notification
              ;;
      esac
    '';
  };

  home.file."bin/notify-battery.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Battery notification script
      
      get_battery_info() {
          upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|to\ empty|percentage"
      }
      
      get_battery_percentage() {
          upower -i $(upower -e | grep 'BAT') | grep percentage | awk '{print $2}' | sed 's/%//'
      }
      
      get_battery_status() {
          upower -i $(upower -e | grep 'BAT') | grep state | awk '{print $2}'
      }
      
      send_notification() {
          percentage=$(get_battery_percentage)
          status=$(get_battery_status)
          
          if [[ $status == "charging" ]]; then
              icon="🔌"
              text="Charging - $percentage%"
          elif [[ $percentage -gt 80 ]]; then
              icon="🔋"
              text="$percentage%"
          elif [[ $percentage -gt 60 ]]; then
              icon="🔋"
              text="$percentage%"
          elif [[ $percentage -gt 40 ]]; then
              icon="🔋"
              text="$percentage%"
          elif [[ $percentage -gt 20 ]]; then
              icon="🪫"
              text="$percentage%"
          else
              icon="🔴"
              text="Critical - $percentage%"
              dunstify -a "Battery" -u critical -r 9993 "$icon Battery" "$text"
              return
          fi
          
          dunstify -a "Battery" -u normal -r 9993 "$icon Battery" "$text"
      }
      
      send_notification
    '';
  };

  home.file."bin/notify-network.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Network notification script
      
      send_wifi_notification() {
          ssid=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2)
          signal=$(nmcli -t -f active,signal dev wifi | egrep '^yes' | cut -d: -f2)
          
          if [[ -n "$ssid" ]]; then
              if [[ $signal -gt 70 ]]; then
                  icon="📶"
              elif [[ $signal -gt 50 ]]; then
                  icon="📶"
              else
                  icon="📶"
              fi
              
              dunstify -a "NetworkManager" -u low -r 9994 "$icon WiFi Connected" "Connected to $ssid ($signal%)"
          else
              dunstify -a "NetworkManager" -u normal -r 9994 "📵 WiFi Disconnected" "No wireless connection"
          fi
      }
      
      case $1 in
          wifi)
              send_wifi_notification
              ;;
          *)
              send_wifi_notification
              ;;
      esac
    '';
  };

  home.file."bin/notify-bluetooth.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Bluetooth notification script
      
      send_bluetooth_notification() {
          if bluetoothctl show | grep -q "Powered: yes"; then
              connected_devices=$(bluetoothctl devices Connected | wc -l)
              
              if [[ $connected_devices -gt 0 ]]; then
                  device_names=$(bluetoothctl devices Connected | cut -d' ' -f3- | tr '\n' ', ' | sed 's/, $//')
                  dunstify -a "Bluetooth" -u low -r 9995 "󰂱 Bluetooth Connected" "Connected to: $device_names"
              else
                  dunstify -a "Bluetooth" -u low -r 9995 "󰂯 Bluetooth On" "No devices connected"
              fi
          else
              dunstify -a "Bluetooth" -u low -r 9995 "󰂲 Bluetooth Off" "Bluetooth is disabled"
          fi
      }
      
      send_bluetooth_notification
    '';
  };

  # Auto-start dunst with graphical session
  systemd.user.services.dunst = {
    Unit = {
      Description = "Dunst notification daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    
    Service = {
      ExecStart = "${pkgs.dunst}/bin/dunst";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}