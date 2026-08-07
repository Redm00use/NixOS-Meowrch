#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX

# -display-columns 2 — показывает в rofi только текст записи, но возвращает
# строку целиком вместе с ID, без которого cliphist decode не работает.
# Проверка [ -n "$selected" ] обязательна: без неё отмена по Escape
# отправит пустоту в wl-copy/xclip и очистит буфер обмена.

session_type=$XDG_SESSION_TYPE

if [ "$session_type" == "wayland" ]; then
    selected=$(cliphist list | rofi -dmenu -display-columns 2)
    if [ -n "$selected" ]; then
        echo "$selected" | cliphist decode | wl-copy
    fi

elif [ "$session_type" == "x11" ]; then
    selected=$(cliphist list | rofi -dmenu -display-columns 2)
    if [ -n "$selected" ]; then
        echo "$selected" | cliphist decode | xclip -selection clipboard
    fi
else
    echo "Тип сеанса не определен или не является Wayland/X11."
fi
