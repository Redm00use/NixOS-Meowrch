{ config, pkgs, lib, ... }:

{
  # SDDM Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # SDDM theme configuration
    theme = "meowrch";

    # General settings
    settings = {
      General = {
        DisplayServer = "wayland";
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
        ThemeDir = "/run/current-system/sw/share/sddm/themes";
      };

      Users = {
        HideShells = "/sbin/nologin";
        MaximumUid = 60000;
        MinimumUid = 1000;
        RememberLastUser = true;
        RememberLastSession = true;
      };

      Wayland = {
        EnableHiDPI = true;
        SessionDir = "/run/current-system/sw/share/wayland-sessions";
      };

      X11 = {
        EnableHiDPI = true;
        ServerArguments = "-nolisten tcp";
        SessionDir = "/run/current-system/sw/share/xsessions";
      };
    };
  };

  # Create SDDM theme directory
  system.activationScripts.sddmTheme = let
    sddm-theme = pkgs.writeTextDir "share/sddm/themes/meowrch/theme.conf" ''
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
    '';
  in ''
    # Create SDDM theme directory
    mkdir -p /run/current-system/sw/share/sddm/themes/meowrch
    cp -f ${sddm-theme}/share/sddm/themes/meowrch/theme.conf /run/current-system/sw/share/sddm/themes/meowrch/

    # Copy other theme files from dotfiles if they exist
    if [ -d "${./../../dotfiles/sddm_theme}" ]; then
      cp -rf ${./../../dotfiles/sddm_theme}/* /run/current-system/sw/share/sddm/themes/meowrch/
    fi
  '';

  # Install required Qt packages for SDDM
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtbase
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
