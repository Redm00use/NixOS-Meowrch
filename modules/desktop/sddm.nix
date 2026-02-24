{ config, pkgs, lib, ... }:

{
  # SDDM Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    # Disable experimental wayland backend for SDDM, as it often causes 
    # input freezes and requires specific Qt6 Wayland compositor setups.
    # Hyprland will still run in Wayland natively!
    wayland.enable = false;

  };

  # SDDM Requires an active display server (X11 since we disabled SDDM Wayland backend)
  services.xserver.enable = true;

  # SDDM Display Manager Configuration (continued)
  services.displayManager.sddm = {
    # SDDM theme configuration
    theme = "meowrch";

    # General settings
    settings = {
      General = {
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
        InputMethod = "";
        Numlock = "on";
      };

      Theme = {
        CursorTheme = "Bibata-Modern-Classic";
        CursorSize = 24;
        EnableAvatars = true;
        FacesDir = "/var/lib/AccountsService/icons/";
        # Let NixOS handle ThemeDir automatically!
      };

      Users = {
        HideShells = "/sbin/nologin";
        MaximumUid = 60000;
        MinimumUid = 1000;
        RememberLastUser = true;
        RememberLastSession = true;
      };
    };
  };

  # Install required Qt packages for SDDM and the theme itself
  environment.systemPackages = let
    meowrch-sddm-theme = pkgs.stdenv.mkDerivation {
      name = "meowrch-sddm-theme";
      src = if builtins.pathExists ../../dotfiles/sddm_theme then ../../dotfiles/sddm_theme else null;
      dontUnpack = if builtins.pathExists ../../dotfiles/sddm_theme then false else true;
      
      installPhase = ''
        mkdir -p $out/share/sddm/themes/meowrch
        
        # Copy everything from src if it exists
        if [ -n "$src" ] && [ -d "$src" ]; then
          cp -r $src/* $out/share/sddm/themes/meowrch/
          chmod -R +w $out/share/sddm/themes/meowrch/
        fi
        
        # Generate or overwrite theme.conf
        cat > $out/share/sddm/themes/meowrch/theme.conf <<EOF
[General]
background=#1e1e2e
type=color
color=#1e1e2e
fontSize=10
autoFocusPassword=true

[Design]
backgroundMode=fill

[loginButton]
textColor=#cdd6f4
backgroundColor=#89b4fa
borderColor=#89b4fa

[userList]
userColor=#cdd6f4
userBackgroundColor=#313244
userBorderColor=#89b4fa

[textField]
textColor=#cdd6f4
backgroundColor=#313244
borderColor=#89b4fa
EOF
      '';
    };
  in with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtbase
    meowrch-sddm-theme
  ];

  # Create user avatars directory
  systemd.tmpfiles.rules = [
    "d /var/lib/AccountsService/icons 0755 root root - -"
  ];

  # Copy default avatar if it exists (temporarily disabled)
  # system.activationScripts.userAvatar = ''
  #   if [ -f "${./../../misc/.face.icon}" ]; then
  #     mkdir -p /var/lib/AccountsService/icons
  #     cp -f ${./../../misc/.face.icon} /var/lib/AccountsService/icons/meowrch
  #   fi
  # '';

  # SDDM default session
  services.displayManager.defaultSession = "hyprland";
}
