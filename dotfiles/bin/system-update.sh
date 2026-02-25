#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX
# NixOS adaptation by meowrch

SESSION_TYPE=$XDG_SESSION_TYPE
DEFAULT_UPDATED_COLOR="#a6e3a1"
DEFAULT_UNUPDATED_COLOR="#fab387"
DEFAULT_TERMINAL="kitty"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --status              Show the update status."
    echo "  --updated-color COLOR Set the color for zero updates (default: $DEFAULT_UPDATED_COLOR)."
    echo "  --unupdated-color COLOR Set the color for non-zero updates (default: $DEFAULT_UNUPDATED_COLOR)."
    echo "  --terminal TERMINAL   Specify the terminal to run (default: $DEFAULT_TERMINAL)."
    echo "  --help                Show this message."
    echo ""
    echo "Example:"
    echo "  $0 --status"
    echo "  $0 --terminal kitty"
}

# Detect distro type
is_nixos() {
    [ -f /run/current-system/nixos-version ] || grep -qi "nixos" /etc/os-release 2>/dev/null
}

is_arch() {
    [ -f /etc/arch-release ]
}

# ─── NixOS update check ───────────────────────────────────────────────────────
check_nixos_updates() {
    # Check for flake updates by comparing flake.lock timestamps or use nix-diff
    # Since a real network check is expensive, we output 0 (up to date) by default
    # Real update checking would require: nix flake update --dry-run
    if command -v nix &>/dev/null; then
        # Count derivations that would be built (fast heuristic: just output 0 if we can't check)
        echo 0
    else
        echo 0
    fi
}

trigger_nixos_upgrade() {
    local terminal="${1:-$DEFAULT_TERMINAL}"
    local flake_dir=""

    # Detect common flake locations
    for d in \
        "$HOME/NixOS-Meowrch" \
        "$HOME/.nixos" \
        "/etc/nixos"
    do
        [ -f "$d/flake.nix" ] && flake_dir="$d" && break
    done

    local command
    if [ -n "$flake_dir" ]; then
        command="echo 'Updating NixOS flake at $flake_dir...'; cd \"$flake_dir\" && sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake \"$flake_dir#meowrch\" --impure; echo; echo 'Done. Press any key to close.'; read -n1"
    else
        command="echo 'Rebuilding NixOS...'; sudo nixos-rebuild switch; echo; echo 'Done. Press any key to close.'; read -n1"
    fi

    case $terminal in
        alacritty)  alacritty -e bash -c "$command" ;;
        kitty)      kitty -e bash -c "$command" ;;
        foot)       foot bash -c "$command" ;;
        gnome-terminal) gnome-terminal -- bash -c "$command; exec bash" ;;
        wezterm)    wezterm start -- bash -c "$command" ;;
        xterm)      xterm -e bash -c "$command" ;;
        *)
            echo "Unsupported terminal: $terminal. Please run the command manually."
            exit 1
            ;;
    esac
}

# ─── Arch update check ────────────────────────────────────────────────────────
pkg_installed() {
    pacman -Qq "$1" &>/dev/null
}

get_aurhlpr() {
    if command -v paru &>/dev/null; then echo "paru"
    elif command -v yay &>/dev/null; then echo "yay"
    else echo ""; fi
}

check_aur_updates() {
    local aurhlpr
    aurhlpr=$(get_aurhlpr)
    [ -z "$aurhlpr" ] && echo 0 && return
    echo $("$aurhlpr" -Qua 2>/dev/null | wc -l)
}

check_official_updates() {
    command -v checkupdates &>/dev/null || { echo 0; return; }
    (while pgrep -x checkupdates > /dev/null; do sleep 1; done)
    echo $(checkupdates 2>/dev/null | wc -l)
}

check_flatpak_updates() {
    command -v flatpak &>/dev/null || { echo 0; return; }
    echo $(flatpak remote-ls --updates 2>/dev/null | wc -l)
}

calculate_arch_updates() {
    local ofc aur fpk
    ofc=$(check_official_updates)
    aur=$(check_aur_updates)
    fpk=$(check_flatpak_updates)
    echo $((ofc + aur + fpk))
}

trigger_arch_upgrade() {
    local aurhlpr=$(get_aurhlpr)
    local terminal=${1:-$DEFAULT_TERMINAL}
    local command

    if [ -n "$aurhlpr" ]; then
        command="echo 'Official packages to update: \$(checkupdates 2>/dev/null | wc -l)'; \
                   echo 'AUR packages to update: \$(${aurhlpr} -Qua 2>/dev/null | wc -l)'; \
                   echo 'Flatpak packages to update: \$(flatpak remote-ls --updates 2>/dev/null | wc -l)'; \
                   echo; \
                   sudo ${aurhlpr} -Syu && sudo flatpak update; echo; echo 'Done. Press any key.'; read -n1"
    else
        command="sudo pacman -Syu; echo; echo 'Done. Press any key.'; read -n1"
    fi

    case $terminal in
        alacritty)      alacritty -e bash -c "$command" ;;
        kitty)          kitty -e bash -c "$command" ;;
        foot)           foot bash -c "$command" ;;
        gnome-terminal) gnome-terminal -- bash -c "$command; exec bash" ;;
        wezterm)        wezterm start -- bash -c "$command" ;;
        xterm)          xterm -e bash -c "$command" ;;
        *)
            echo "Unsupported terminal: $terminal. Please run manually."
            exit 1
            ;;
    esac
}

# ─── Unified interface ────────────────────────────────────────────────────────
calculate_updates() {
    if is_nixos; then
        check_nixos_updates
    elif is_arch; then
        calculate_arch_updates
    else
        echo 0
    fi
}

trigger_upgrade() {
    local terminal="${1:-$DEFAULT_TERMINAL}"
    if is_nixos; then
        trigger_nixos_upgrade "$terminal"
    elif is_arch; then
        trigger_arch_upgrade "$terminal"
    else
        notify-send "System Update" "Unsupported distro. Update manually." -u normal
    fi
}

print_status() {
    local updates color
    updates=$(calculate_updates)
    color=${2:-$DEFAULT_UNUPDATED_COLOR}

    if [ "$updates" -eq 0 ]; then
        updates=""
        color=${1:-$DEFAULT_UPDATED_COLOR}
    fi

    if [ "$SESSION_TYPE" == "wayland" ]; then
        echo "<span color=\"$color\">󰮯 $updates </span>"
    elif [ "$SESSION_TYPE" == "x11" ]; then
        echo "%{F$color}󰮯 $updates %{F-}"
    else
        echo "󰮯 $updates"
    fi
}

main() {
    local updated_color="$DEFAULT_UPDATED_COLOR"
    local unupdated_color="$DEFAULT_UNUPDATED_COLOR"
    local terminal="$DEFAULT_TERMINAL"
    local status=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                status=1
                ;;
            --updated-color)
                shift
                updated_color="$1"
                ;;
            --unupdated-color)
                shift
                unupdated_color="$1"
                ;;
            --terminal)
                shift
                terminal="$1"
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown argument: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    if [ "$status" -eq 1 ]; then
        print_status "$updated_color" "$unupdated_color"
    else
        trigger_upgrade "$terminal"
    fi
}

main "$@"
