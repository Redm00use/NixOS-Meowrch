{ config, pkgs, inputs, ... }:

{
  # Install the granular configurations
  xdg.configFile."hypr/default".source = ./hypr-configs;

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    # We use extraConfig to source the files we installed,
    # mimicking the upstream hyprland.conf structure.
    extraConfig = ''
      # Refers to the files installed by xdg.configFile."hypr/default"
      source = ~/.config/hypr/default/autostart.conf
      source = ~/.config/hypr/default/monitors.conf
      source = ~/.config/hypr/default/input.conf
      source = ~/.config/hypr/default/keybindings.conf
      source = ~/.config/hypr/default/windowrules.conf
      source = ~/.config/hypr/default/appearance.conf
      source = ~/.config/hypr/default/general.conf
      
      # User overrides (optional)
      source = ~/.config/hypr/userprefs.conf
      
      # GPU specific (optional, from original config)
      exec-once = sh -lc 'if [ -n "''${GPU_SETUP:-}" ] && [ -r "$HOME/.config/hypr/default/gpu/$GPU_SETUP.conf" ]; then hyprctl keyword source "$HOME/.config/hypr/default/gpu/$GPU_SETUP.conf"; else hyprctl keyword source "$HOME/.config/hypr/default/gpu/gpu-detect.conf"; fi'
    '';

    # Enable systemd integration (critical for UWSM and others)
    systemd.enable = true;
  };
  
  # Ensure the directory for GPU configs exists if referenced
  # We might need to copy that too if it was in the source "default" dir.
  
  # Dependencies for the new scripts (uwsm, etc) are handled in packages.nix / meowrch-scripts.nix
}

