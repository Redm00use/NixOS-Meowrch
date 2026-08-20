#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┻┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX
#
# NixOS-Meowrch: upstream 4.1.1 logic, with one deviation -- the shebang is
# #!/usr/bin/env bash instead of upstream's #!/bin/bash, because /bin/bash does
# not exist on NixOS (only /bin/sh does).
#
# Note that --suspend deliberately falls through to the locker: suspending
# without locking would let the machine wake up unlocked.

SESSION_TYPE=$XDG_SESSION_TYPE


case "$SESSION_TYPE" in
    "wayland")
        if [[ "$1" == "--suspend" ]]; then
            systemctl suspend
        fi
        hyprlock
        ;;
    "x11")
        if [[ "$1" == "--suspend" ]]; then
            systemctl suspend
        fi
        betterlockscreen -l dim
        ;;
    *)
        echo "The session type is not defined or is not Wayland/X11."
esac
