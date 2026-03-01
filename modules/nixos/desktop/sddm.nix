{ config, pkgs, lib, ... }:

let
  meowrch-sddm-theme = pkgs.stdenv.mkDerivation {
    name = "meowrch-sddm-theme";
    src = ./../../../assets/sddm;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/meowrch
      cp -r ./* $out/share/sddm/themes/meowrch/
    '';
  };
in {
  # SDDM Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # Use Qt6-based SDDM package
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
        ThemeDir = "/var/lib/sddm-theme";
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

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /var/lib/AccountsService/icons 0755 root root - -"
    "d /var/lib/sddm-theme 0755 root root - -"
    "d /var/lib/sddm-theme/meowrch 0755 root root - -"
    "d /home/kotlin/.cache/meowrch 0755 kotlin users - -"
  ];

  # Activation script: copy theme to writable location and apply overrides
  system.activationScripts.sddmTheme.text = ''
    THEME_SRC="${meowrch-sddm-theme}/share/sddm/themes/meowrch"
    THEME_DST="/var/lib/sddm-theme/meowrch"

    echo "Deploying SDDM meowrch theme to $THEME_DST..."
    mkdir -p "$THEME_DST"

    # Copy all theme files from the Nix store
    cp -rf "$THEME_SRC"/. "$THEME_DST"/

    # Make the destination writable
    chmod -R u+w "$THEME_DST"

    # If the user has a generated theme.conf (from the meowrch theme manager),
    # apply it on top of the default one so dynamic color updates take effect.
    USER_CONF="/home/kotlin/.cache/meowrch/sddm-theme.conf"
    if [ -f "$USER_CONF" ]; then
      echo "Applying user theme.conf from $USER_CONF"
      cp -f "$USER_CONF" "$THEME_DST/theme.conf"
    fi

    # Ensure SDDM user can read the theme directory
    chmod -R a+rX "$THEME_DST"

    ${lib.optionalString (config ? "users.users.sddm") ''
      chown -R sddm:sddm "$THEME_DST" 2>/dev/null || true
    ''}

    echo "SDDM theme deployed successfully."

    # Copy default user avatar if it exists
    if [ -f "${./../../../assets/misc/.face.icon}" ]; then
      mkdir -p /var/lib/AccountsService/icons
      cp -f "${./../../../assets/misc/.face.icon}" /var/lib/AccountsService/icons/kotlin
      chmod 644 /var/lib/AccountsService/icons/kotlin
    fi
  '';
}
