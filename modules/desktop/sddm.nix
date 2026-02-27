{ config, pkgs, lib, ... }:

let
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
      
      # Only generate theme.conf if it doesn't exist in src
      if [ ! -f "$out/share/sddm/themes/meowrch/theme.conf" ]; then
        cat > $out/share/sddm/themes/meowrch/theme.conf <<EOF
[General]
background=#1e1e2e
type=color
color=#1e1e2e
fontSize=10
autoFocusPassword=true
EOF
      fi
    '';
  };
in {
  # SDDM Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

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
        ThemeDir = "${meowrch-sddm-theme}/share/sddm/themes";
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
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtwayland
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
  services.displayManager.defaultSession = "hyprland-uwsm";
}
