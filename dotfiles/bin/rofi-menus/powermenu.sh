#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX

BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
DESKTOP="${XDG_CURRENT_DESKTOP:-}"

choice=$(printf "  Lock\n󰍃  Logout\n󰒲  Suspend\n  Reboot\n  Shutdown" | rofi -dmenu)

do_logout() {
    if [[ "$DESKTOP" == *"Hyprland"* ]] || [[ "$DESKTOP" == *"hyprland"* ]]; then
        hyprctl dispatch exit
    elif [[ "$DESKTOP" == "bspwm" ]]; then
        bspc quit
    elif command -v loginctl &>/dev/null; then
        loginctl terminate-user "$USER"
    else
        pkill -KILL -u "$USER"
    fi
}

case "$choice" in
    "  Lock")
        sh "${BIN}/screen-lock.sh"
        ;;
    "󰍃  Logout")
        do_logout
        ;;
    "󰒲  Suspend")
        sh "${BIN}/screen-lock.sh" --suspend
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
esac
