{ lib, stdenv, python3, bash, coreutils, findutils, gawk, gnugrep, gnused,
  procps, systemd, brightnessctl, pamixer, playerctl, hyprland, swww, rofi,
  wl-clipboard, cliphist, networkmanager, bluez, upower, dunst,
  util-linux, jq, imagemagick, curl, zenity, libnotify, bc, hyprpicker,
  hyprlock, wlr-randr, makeWrapper }:

let
  # Python with all needed packages for system-info.py
  pythonWithPkgs = python3.withPackages (ps: with ps; [
    psutil
    # GPUtil is not in nixpkgs as 'gputil', use graceful fallback in script
    # pyamdgpuinfo — AMD GPU info; also optional
    pyyaml
  ]);
in

stdenv.mkDerivation rec {
  pname = "meowrch-scripts";
  version = "1.0.0";

  src = ../scripts;

  nativeBuildInputs = [ makeWrapper ];

  # All runtime dependencies available at script execution time
  runtimeDeps = [
    pythonWithPkgs
    bash
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    procps
    systemd
    brightnessctl
    pamixer
    playerctl
    swww
    rofi
    wl-clipboard
    cliphist
    networkmanager
    bluez
    upower
    dunst
    util-linux          # flock, lsblk
    jq                  # JSON parsing (wallpaper-selector, kb-layout, etc.)
    imagemagick         # magick / convert — wallpaper thumbnails
    curl                # playerinfo.sh art download
    zenity              # VPN config file picker (GTK dialog)
    libnotify           # notify-send
    bc                  # arithmetic in uwsm-launcher.sh
    hyprpicker          # color-picker.sh
    hyprlock            # screen-lock.sh
    wlr-randr           # set-wallpaper.sh refresh rate detection
  ] ++ lib.optional (hyprland != null) hyprland;

  # Don't build, just copy scripts
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Copy all scripts (preserving directory structure)
    cp -r * $out/bin/

    # Make all scripts executable
    find $out/bin -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;

    # Also make scripts without extension executable (like pfetch)
    find $out/bin -maxdepth 1 -type f ! -name "*.*" -exec chmod +x {} \;

    # Patch interpreter shebangs
    patchShebangs $out/bin

    runHook postInstall
  '';

  postInstall = ''
    runtimePath="${lib.makeBinPath runtimeDeps}"

    # Wrap all top-level .sh scripts
    for script in $out/bin/*.sh; do
      [ -f "$script" ] || continue
      name=$(basename "$script")
      wrapProgram "$script" --prefix PATH : "$runtimePath"
    done

    # Wrap Python scripts
    for script in $out/bin/*.py; do
      [ -f "$script" ] || continue
      wrapProgram "$script" --prefix PATH : "$runtimePath"
    done

    # Wrap rofi-menus
    if [ -d "$out/bin/rofi-menus" ]; then
      for script in "$out/bin/rofi-menus"/*.sh; do
        [ -f "$script" ] || continue
        wrapProgram "$script" --prefix PATH : "$runtimePath"
      done
    fi

    # Compatibility symlinks (scripts accessible without .sh extension)
    mkdir -p $out/share/meowrch-scripts
    for script in $out/bin/*.sh; do
      [ -f "$script" ] || continue
      base=$(basename "$script" .sh)
      ln -sf "$script" "$out/share/meowrch-scripts/$base"
    done
    ln -sf $out/bin/rofi-menus $out/share/meowrch-scripts/rofi-menus
  '';

  meta = with lib; {
    description = "Meowrch system scripts and utilities";
    longDescription = ''
      A collection of shell and Python scripts for the Meowrch desktop environment.
      Includes utilities for volume control, brightness adjustment, screenshot capture,
      color picking, system monitoring, and Rofi-based menus.
      Portable between Arch Linux and NixOS.
    '';
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
