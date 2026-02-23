{ lib, stdenv, fetchFromGitHub, python3, bash, coreutils, findutils, gawk, gnugrep, gnused, procps, systemd, brightnessctl, pamixer, playerctl, hyprland, swww, rofi-wayland, flameshot, wl-clipboard, cliphist, networkmanager, bluez, upower, dunst, waybar }:

stdenv.mkDerivation rec {
  pname = "meowrch-scripts";
  version = "1.0.0";

  src = ../dotfiles/bin;

  nativeBuildInputs = [ ];

  buildInputs = [
    python3
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
    hyprland
    swww
    rofi-wayland
    flameshot
    wl-clipboard
    cliphist
    networkmanager
    bluez
    upower
    dunst
    waybar
  ];

  # Don't build, just copy scripts
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Create bin directory
    mkdir -p $out/bin

    # Copy all scripts from source
    cp -r * $out/bin/

    # Make all scripts executable
    find $out/bin -type f -name "*.sh" -exec chmod +x {} \;
    find $out/bin -type f -name "*.py" -exec chmod +x {} \;

    # Patch shebangs
    patchShebangs $out/bin

    # Create wrapper scripts with proper PATH
    for script in $out/bin/*.sh; do
      if [ -f "$script" ]; then
        scriptname=$(basename "$script")
        mv "$script" "$script.unwrapped"
        cat > "$script" << EOF
#!${bash}/bin/bash
export PATH="${lib.makeBinPath buildInputs}:\$PATH"
exec "$script.unwrapped" "\$@"
EOF
        chmod +x "$script"
      fi
    done

    # Handle Python scripts
    for script in $out/bin/*.py; do
      if [ -f "$script" ]; then
        scriptname=$(basename "$script")
        mv "$script" "$script.unwrapped"
        cat > "$script" << 'PYTHON_WRAPPER_EOF'
#!/usr/bin/env python3
import os
import sys

# Add required paths
path_additions = os.pathsep.join([
    os.path.dirname(sys.executable),
])
current_path = os.environ.get('PATH', '')
os.environ['PATH'] = path_additions + os.pathsep + current_path

# Execute the original script
script_path = __file__ + '.unwrapped'
with open(script_path, 'r') as f:
    script_code = f.read()

exec(script_code)
PYTHON_WRAPPER_EOF
        sed -i "1s|.*|#!${python3}/bin/python3|" "$script"
        chmod +x "$script"
      fi
    done

    # Handle rofi-menus directory specially
    if [ -d "$out/bin/rofi-menus" ]; then
      find "$out/bin/rofi-menus" -type f -name "*.sh" -exec chmod +x {} \;
      for script in $out/bin/rofi-menus/*.sh; do
        if [ -f "$script" ]; then
          scriptname=$(basename "$script")
          mv "$script" "$script.unwrapped"
          cat > "$script" << EOF
#!${bash}/bin/bash
export PATH="${lib.makeBinPath buildInputs}:\$PATH"
exec "$script.unwrapped" "\$@"
EOF
          chmod +x "$script"
        fi
      done
    fi

    runHook postInstall
  '';

  # Create individual script packages for easier access
  postInstall = ''
    # Create symlinks for commonly used scripts
    mkdir -p $out/share/meowrch-scripts

    # Volume control
    ln -sf $out/bin/volume.sh $out/share/meowrch-scripts/volume

    # Brightness control
    ln -sf $out/bin/brightness.sh $out/share/meowrch-scripts/brightness

    # Screenshot
    ln -sf $out/bin/screenshot.sh $out/share/meowrch-scripts/screenshot

    # Color picker
    ln -sf $out/bin/color-picker.sh $out/share/meowrch-scripts/color-picker

    # Screen lock
    ln -sf $out/bin/screen-lock.sh $out/share/meowrch-scripts/screen-lock

    # System info
    ln -sf $out/bin/system-info.py $out/share/meowrch-scripts/system-info

    # Rofi menus
    ln -sf $out/bin/rofi-menus $out/share/meowrch-scripts/rofi-menus

    # Create desktop entries for GUI applications
    mkdir -p $out/share/applications

    cat > $out/share/applications/meowrch-theme-selector.desktop << EOF
[Desktop Entry]
Name=Meowrch Theme Selector
Comment=Select and apply Meowrch themes
Exec=$out/bin/theme-selector.sh
Icon=preferences-desktop-theme
Terminal=false
Type=Application
Categories=Settings;DesktopSettings;
EOF

    cat > $out/share/applications/meowrch-wallpaper-selector.desktop << EOF
[Desktop Entry]
Name=Meowrch Wallpaper Selector
Comment=Select and apply wallpapers
Exec=$out/bin/wallpaper-selector.sh
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Settings;DesktopSettings;
EOF
  '';

  meta = with lib; {
    description = "Meowrch system scripts and utilities";
    longDescription = ''
      A collection of shell and Python scripts for the Meowrch desktop environment.
      Includes utilities for volume control, brightness adjustment, screenshot capture,
      color picking, system monitoring, and Rofi-based menus.
    '';
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
