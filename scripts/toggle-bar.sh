#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX

SESSION_TYPE=$XDG_SESSION_TYPE
FLAG_FILE="$HOME/.config/hypr/current_bar"
ACTION="toggle"

# Parsing arguments
case "$1" in
    "--start") ACTION="start" ;;
    "--stop")  ACTION="stop"  ;;
    "")
        # No arguments - save toggle
        ;;
    *)
        echo "Unknown Argument: $1"
        echo "Utilization: $0 [--start|--stop]"
        exit 1
        ;;
esac

# Launch bar with UWSM support
launch_bar() {
    local bar_name="$1"
    # Use service type for auto-restart capability when UWSM is active
    # nohup is needed here because we want the bar to survive toggle-bar.sh exit
    if [[ "$bar_name" == "mewline" ]]; then
        nohup "${XDG_BIN_HOME:-$HOME/.local/bin}/uwsm-launcher.sh" -t service -s s "$bar_name" >/dev/null 2>&1 &
    else
        nohup "${XDG_BIN_HOME:-$HOME/.local/bin}/uwsm-launcher.sh" -t service -s s "$bar_name" >/dev/null 2>&1 &
    fi
    disown
}

handle_wayland() {
    [ ! -f "$FLAG_FILE" ] && echo "mewline" > "$FLAG_FILE"
    current_bar=$(cat "$FLAG_FILE")

    case "$ACTION" in
        "start")
            if ! pgrep -x "$current_bar" >/dev/null; then
                launch_bar "$current_bar"
            fi
            ;;

        "stop")
            pgrep -x "$current_bar" >/dev/null && pkill -x "$current_bar"
            ;;

        "toggle")
            if pgrep -x "$current_bar" >/dev/null; then
                pkill -x "$current_bar"
            else
                launch_bar "$current_bar"
            fi
            ;;
    esac
}

handle_x11() {
    case "$ACTION" in
        "start")
            if ! pgrep -x polybar >/dev/null; then
                "$HOME/.config/polybar/launch.sh"
                bspc config -m focused top_padding 31
            fi
            ;;

        "stop")
            if pgrep -x polybar >/dev/null; then
                killall polybar
                bspc config -m focused top_padding 0
            fi
            ;;

        "toggle")
            if pgrep -x polybar >/dev/null; then
                killall polybar
                bspc config -m focused top_padding 0
            else 
                "$HOME/.config/polybar/launch.sh"
                bspc config -m focused top_padding 31
            fi
            ;;
    esac
}

case "$SESSION_TYPE" in
    "wayland") handle_wayland ;;
    "x11")     handle_x11     ;;
    *)
        echo "The session type is not defined or is not Wayland/X11."
        exit 1
        ;;
esac

exit 0
