#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# Created by DIMFLIX
# Github: https://github.com/DIMFLIX

SESSION_TYPE="$XDG_SESSION_TYPE"
COLOR="#ffffff"
LANG_MODE=false
CAPS_MODE=false
PLAIN_MODE=false
CAPS_ICON="󰪛"

get_lang() {
    if [ "$SESSION_TYPE" == "wayland" ]; then
        hyprctl devices -j | jq -r '.keyboards[] | select(.main == true).active_keymap | 
        {
            "English (US)": "EN",
            "Russian": "RU",
            "French": "FR",
            "German": "DE",
            "Spanish": "ES",
            "Italian": "IT",
            "Portuguese": "PT",
            "Dutch": "NL",
            "Swedish": "SV",
            "Norwegian": "NO",
            "Danish": "DA",
            "Finnish": "FI",
            "Polish": "PL",
            "Czech": "CS",
            "Hungarian": "HU",
            "Greek": "EL",
            "Turkish": "TR",
            "Hebrew": "HE",
            "Arabic": "AR",
            "Thai": "TH",
            "Chinese (Simplified)": "ZH-CN",
            "Chinese (Traditional)": "ZH-TW",
            "Japanese": "JA",
            "Korean": "KO"
        }[.]'
    elif [ "$SESSION_TYPE" == "x11" ]; then
        xkb-switch -p
    fi
}

get_caps() {
    if [ "$SESSION_TYPE" == "wayland" ]; then
        hyprctl devices -j | jq -r '.keyboards[] | select(.main == true).capsLock'
    elif [ "$SESSION_TYPE" == "x11" ]; then
        xset q | awk '/Caps Lock/ {print $4}'
    fi
}

format_output() {
    local content="$1"
    local color="$2"
    
    if $PLAIN_MODE; then
        echo -n "$content"
    else
        if [[ "$SESSION_TYPE" == "wayland" ]]; then
            echo -n "<span color=\"$color\">$content</span>"
        elif [[ "$SESSION_TYPE" == "x11" ]]; then
            echo -n "%{F$color}$content%{F-}"
        fi
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)
            LANG_MODE=true
            shift
            ;;
        --caps)
            CAPS_MODE=true
            shift
            ;;
        --color)
            COLOR="$2"
            shift 2
            ;;
        --plain)
            PLAIN_MODE=true
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            echo "Usage: $0 [--lang] [--caps] [--color COLOR] [--plain]"
            exit 1
            ;;
    esac
done

if $LANG_MODE || $CAPS_MODE; then
    output=""
    if $LANG_MODE; then
        lang=$(get_lang)
        output+=$(format_output "$lang" "$COLOR")
    fi
    
    if $CAPS_MODE; then
        caps=$(get_caps)
        if [[ "$caps" == "true" || "$caps" == "on" ]]; then
            output+=" "
            output+=$(format_output "$CAPS_ICON" "$COLOR")
        fi
    fi
    
    echo -n "$output"
else
    lang=$(get_lang)
    caps=$(get_caps)
    
    if [[ "$caps" == "true" || "$caps" == "on" ]]; then
     	output=$(format_output "$lang | $CAPS_ICON" "$COLOR")
    else 
   		output=$(format_output "$lang" "$COLOR")
   	fi
    
    echo "$output"
fi
