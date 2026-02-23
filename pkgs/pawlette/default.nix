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
      echo "  pawlette select <theme>   Select a theme and rebuild"
      echo "  pawlette list             List available themes"
    }

    if [ "$1" == "list" ]; then
      echo "Available themes:"
      echo "  catppuccin-mocha"
      echo "  catppuccin-latte"
      # Add more dynamic listing if possible
      exit 0
    fi

    if [ "$1" == "select" ]; then
      THEME="$2"
      if [ -z "$THEME" ]; then
        echo "Error: No theme specified"
        exit 1
      fi
      
      echo "Switching to theme: $THEME"
      # Here we would ideally sed the theme file
      # For now, this is a placeholder for the logic
      echo "Updating configuration..."
      # sed -i "s/theme = .*/theme = \"$THEME\";/" $THEME_FILE
      
      echo "Rebuilding system..."
      sudo nixos-rebuild switch --flake .#meowrch
      exit 0
    fi

    show_help
  '';
in
pawlette
