{ pkgs, ... }:

let
  # Pawlette wrapper that mimics the original behavior but adapted for NixOS
  # Instead of git switching, it updates a theme file and rebuilds
  pawlette = pkgs.writeShellScriptBin "pawlette" ''
    set -e
    
    THEME_FILE="/etc/nixos/modules/desktop/theme-current.nix" # Adjust path as needed
    FLAKE_DIR="/etc/nixos"
    
    function show_help() {
      echo "Pawlette for NixOS (Wrapper)"
      echo "Usage:"
      echo "  pawlette select <theme>   Select a theme via meowrch.py"
      echo "  pawlette set-theme <th.>  Alias for select"
      echo "  pawlette list             List available themes"
      echo "  pawlette get-themes-info  Get JSON themes info"
    }

    if [ "$1" == "list" ]; then
      echo "Available themes:"
      for theme in ~/.config/meowrch/themes/*; do
        if [ -d "$theme" ]; then
          echo "  $(basename "$theme")"
        fi
      done
      exit 0
    fi

    if [ "$1" == "get-themes-info" ]; then
      THEMES_DIR="$HOME/.config/meowrch/themes"
      echo "{"
      first=true
      if [ -d "$THEMES_DIR" ]; then
        for theme in "$THEMES_DIR"/*; do
          if [ -d "$theme" ]; then
            name=$(basename "$theme")
            logo="$theme/preview.png"
            if [ "$first" = true ]; then
              first=false
            else
              echo ","
            fi
            echo -n "  \"$name\": { \"logo\": \"$logo\" }"
          fi
        done
      fi
      echo ""
      echo "}"
      exit 0
    fi

    if [ "$1" == "select" ] || [ "$1" == "set-theme" ]; then
      THEME="$2"
      if [ -z "$THEME" ]; then
        echo "Error: No theme specified"
        exit 1
      fi
      
      echo "Switching to theme: $THEME"
      $HOME/.config/meowrch/venv/bin/python3 $HOME/.config/meowrch/meowrch.py --action set-theme --name "$THEME" 2>/dev/null || \
      /run/current-system/sw/bin/python3 $HOME/.config/meowrch/meowrch.py --action set-theme --name "$THEME"
      
      exit 0
    fi


    show_help
  '';
in
pawlette
