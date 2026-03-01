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


lock_x11() {
    local fg=c0caf5
    local wrong=db4b4b
    local date=7aa2f7
    local verify=7aa2f7
    local lock_image="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers/.current.wall"

    i3lock -n --force-clock -i "$lock_image" -e \
        --indicator --radius=20 --ring-width=40 \
        --inside-color="$fg" --ring-color="$fg" \
        --insidever-color="$verify" --ringver-color="$verify" \
        --insidewrong-color="$wrong" --ringwrong-color="$wrong" \
        --line-uses-inside --keyhl-color="$verify" \
        --separator-color="$verify" --bshl-color="$verify" \
        --time-str="%H:%M" --time-size=140 \
        --date-str="%a, %d %b" --date-size=45 \
        --verif-text="Verifying Password..." \
        --wrong-text="Wrong Password!" \
        --noinput-text="" \
        --greeter-text="Type the password to Unlock" \
        --ind-pos="650:760" \
        --time-font="Fira Code:style=Bold" \
        --date-font="Fira Code" \
        --verif-font="Fira Code" \
        --greeter-font="Fira Code" \
        --wrong-font="Fira Code" \
        --verif-size=23 --greeter-size=23 --wrong-size=23 \
        --time-pos="650:540" \
        --date-pos="650:600" \
        --greeter-pos="650:930" \
        --wrong-pos="650:970" \
        --verif-pos="650:805" \
        --date-color="$date" \
        --time-color="$date" \
        --greeter-color="$fg" \
        --wrong-color="$wrong" \
        --verif-color="$verify" \
        --pointer=default \
        --refresh-rate=0 \
        --pass-media-keys \
        --pass-volume-keys
}


lock_wayland() {
    local fg=c0caf5
    local wrong=db4b4b
    local date=7aa2f7
    local verify=7aa2f7
    local lock_image="$HOME/.config/meowrch/current_wallpaper"

    swaylock \
        --screenshots \
        --clock \
        --indicator \
        --indicator-radius 100 \
        --indicator-thickness 7 \
        --effect-blur 7x5 \
        --effect-vignette 0.5:0.5 \
        --ring-color "$fg" \
        --key-hl-color "$verify" \
        --text-color "$fg" \
        --line-color 00000000 \
        --inside-color 00000088 \
        --separator-color 00000000 \
        --ring-ver-color "$verify" \
        --inside-ver-color 00000088 \
        --ring-wrong-color "$wrong" \
        --inside-wrong-color 00000088 \
        --font "Fira Code"
}


case "$SESSION_TYPE" in
    "wayland")
        if [[ "$1" == "--suspend" ]]; then
            systemctl suspend
        else
            lock_wayland
        fi
        ;;
    "x11")
        if [[ "$1" == "--suspend" ]]; then
            systemctl suspend
        fi
        lock_x11
        ;;
    *)
        echo "The session type is not defined or is not Wayland/X11."
esac
