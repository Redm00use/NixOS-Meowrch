{ config, pkgs, lib, ... }:

let
  meowrch-sddm-theme = pkgs.stdenv.mkDerivation {
    name = "meowrch-sddm-theme";
    src = ./../../../assets/sddm;
    
    installPhase = ''
      mkdir -p $out/share/sddm/themes/meowrch
      cp -r ./* $out/share/sddm/themes/meowrch/
      
      # Use a symlink for theme.conf so it can be updated dynamically
      ln -sf /home/meowrch/.cache/meowrch/sddm-theme.conf $out/share/sddm/themes/meowrch/theme.conf
      chmod -R +w $out/share/sddm/themes/meowrch/
    '';
  };
in {
  # SDDM Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    
    # Use Qt6-based SDDM package for better compatibility with Qt6 themes
    package = pkgs.kdePackages.sddm;

    # SDDM theme configuration
    theme = "meowrch";

    extraPackages = with pkgs.kdePackages; [
      qt5compat
      qtmultimedia
      qtsvg
      qtwayland
      qtdeclarative
    ];

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

  # Install required Qt6 packages for SDDM and the theme itself
  environment.systemPackages = with pkgs; [
    kdePackages.qt5compat
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qtwayland
    kdePackages.qtdeclarative
    meowrch-sddm-theme
    bibata-cursors
  ];

  # Create user avatars directory and cache directory for theme
  systemd.tmpfiles.rules = [
    "d /var/lib/AccountsService/icons 0755 root root - -"
    "d /home/meowrch/.cache/meowrch 0755 meowrch users - -"
  ];

  # Copy default avatar if it exists
  system.activationScripts.userAvatar.text = ''
    if [ -f "${./../../../assets/misc/.face.icon}" ]; then
      mkdir -p /var/lib/AccountsService/icons
      cp -f ${./../../../assets/misc/.face.icon} /var/lib/AccountsService/icons/meowrch
      chmod 644 /var/lib/AccountsService/icons/meowrch
    fi
  '';

  # SDDM default session
  services.displayManager.defaultSession = "hyprland-uwsm";
}
