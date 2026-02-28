{ config, pkgs, ... }:

{
  home.packages = [ pkgs.dunst pkgs.libnotify ];

  # We don't use services.dunst.settings because it creates a read-only dunstrc.
  # Instead, we let the theme manager overwrite ~/.config/dunst/dunstrc.
  # We only ensure the directory exists.
  home.file.".config/dunst/.keep".text = "";

  # Custom notification scripts (preserved from original)
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
}