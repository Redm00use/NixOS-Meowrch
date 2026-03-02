{ config, pkgs, lib, ... }:

let
  meowrch-sddm-theme = pkgs.stdenvNoCC.mkDerivation {
    name = "meowrch-sddm-theme";
    src = ./../../../assets/sddm;

    dontWrapQtApps = true;

    propagatedBuildInputs = with pkgs.kdePackages; [
      qtsvg
      qtmultimedia
      qt5compat
      qtdeclarative
    ];

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

  # Install the theme package (propagatedBuildInputs will pull in Qt deps)
  environment.systemPackages = [
    meowrch-sddm-theme
    pkgs.bibata-cursors
  ];

  # Create required directories
  systemd.tmpfiles.rules = let
    normalUser = lib.findFirst (u: config.users.users.${u}.isNormalUser) "root" (builtins.attrNames config.users.users);
    homeDir = config.users.users.${normalUser}.home;
  in [
    "d /var/lib/AccountsService/icons 0755 root root - -"
    "d ${homeDir}/.cache/meowrch 0755 ${normalUser} users - -"
  ];

  # Activation script to apply user theme overrides and avatar
  system.activationScripts.sddmTheme.text = let
    # Находим первого обычного пользователя (UID >= 1000), чтобы не хардкодить имя
    # В идеале это должен быть основной пользователь системы
    normalUser = lib.findFirst (u: config.users.users.${u}.isNormalUser) "root" (builtins.attrNames config.users.users);
    homeDir = config.users.users.${normalUser}.home;
  in ''
    # If the user has a generated theme.conf (from the meowrch theme manager),
    # apply it by copying to a writable location
    THEME_SRC="${meowrch-sddm-theme}/share/sddm/themes/meowrch"
    USER_CONF="${homeDir}/.cache/meowrch/sddm-theme.conf"

    if [ -f "$USER_CONF" ]; then
      echo "Applying user SDDM theme.conf override for user ${normalUser}..."
      # Create writable copy of theme for user overrides
      THEME_DST="/var/lib/sddm-theme/meowrch"
      mkdir -p "$THEME_DST"
      rm -rf "$THEME_DST"/*
      cp -rf "$THEME_SRC"/. "$THEME_DST"/
      chmod -R u+w "$THEME_DST"
      cp -f "$USER_CONF" "$THEME_DST/theme.conf"
      chmod -R a+rX "$THEME_DST"
    fi

    # Copy default user avatar if it exists
    if [ -f "${./../../../assets/misc/.face.icon}" ]; then
      mkdir -p /var/lib/AccountsService/icons
      cp -f "${./../../../assets/misc/.face.icon}" /var/lib/AccountsService/icons/${normalUser}
      chmod 644 /var/lib/AccountsService/icons/${normalUser}
    fi
  '';
}
