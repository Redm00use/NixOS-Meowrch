#!/bin/bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX

session_type=$XDG_SESSION_TYPE

if [ "$session_type" == "wayland" ]; then
    selected=$(cliphist list | rofi -dmenu)
    if [ -n "$selected" ]; then
        echo "$selected" | cliphist decode | wl-copy
    fi

elif [ "$session_type" == "x11" ]; then
    selected=$(cliphist list | rofi -dmenu)
    if [ -n "$selected" ]; then
        echo "$selected" | cliphist decode | xclip -selection clipboard
    fi
else
    echo "Тип сеанса не определен или не является Wayland/X11."
fi
