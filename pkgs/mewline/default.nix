{ lib
, python3Packages
, fetchFromGitHub
, pkg-config
, gtk3
, gtk4
, gtk-layer-shell
, libadwaita
, gobject-introspection
, wrapGAppsHook3
, dart-sass
, tesseract
, gnome-bluetooth
, upower
, networkmanager
, playerctl
, fabric
, libcvc
, libgray
, libdbusmenuGtk3
}:

python3Packages.buildPythonApplication rec {
  pname = "mewline";
  version = "0.1.0-unstable-2026-02-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "afb3ffb4cf52e72b30c132601a29a63b1ea4081d";
    hash = "sha256-N6DFD2aGjkfjWTOr1e3yUjj6fgTdsVhiM/tbfnej5Zw=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    wrapGAppsHook3
    pkg-config
  ];

  # Ensure dart-sass is available in PATH at runtime
  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${dart-sass}/bin"
  ];

  propagatedBuildInputs = with python3Packages; [
    fabric
    loguru
    dbus-python
    pillow
    psutil
    pydantic
    setproctitle
    pygobject3
    pycairo
    click
    systemd-python
    pytesseract
    emoji
  ];

  buildInputs = [
    gtk3
    gtk4
    gtk-layer-shell
    libadwaita
    dart-sass
    tesseract
    gnome-bluetooth
    upower
    networkmanager
    playerctl
    libcvc
    libgray
    libdbusmenuGtk3
  ];

  # Remove deps not available in nixpkgs
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "pkgconfig" "systemd" ];

  # Include .scss style files which setuptools skips by default
  postPatch = ''
    # Tell setuptools to include non-Python files
    cat >> pyproject.toml << 'EOF'

[tool.setuptools.package-data]
mewline = ["styles/**/*.scss", "styles/**/*.css"]
EOF

    # Redirect writable style paths from read-only Nix store to XDG cache
    # THEME_STYLE must be writable — mewline writes the active theme here
    # MAIN_STYLE must also be readable from a location where sass can @import siblings
    substituteInPlace src/mewline/constants.py \
      --replace-fail 'THEME_STYLE = STYLES_FOLDER / "theme.scss"' \
        'THEME_STYLE = APP_CACHE_DIRECTORY / "theme.scss"'

    # Fix upstream bug: screen_brightness getter crashes with AttributeError
    # when no backlight device is found (screen_backlight_path is never set).
    substituteInPlace src/mewline/services/brightness.py \
      --replace-fail \
        'brightness_path = self.screen_backlight_path / "brightness"' \
        'brightness_path = getattr(self, "screen_backlight_path", None)
        if brightness_path is None:
            return -1
        brightness_path = brightness_path / "brightness"'
  '';

  postInstall = ''
    # Copy styles directory to the installed package
    site=$out/lib/python*/site-packages/mewline
    cp -r src/mewline/styles $site/ 2>/dev/null || true
  '';

  doCheck = false;

  meta = with lib; {
    description = "Dynamic Island for Linux status bar";
    homepage = "https://github.com/meowrch/mewline";
    license = licenses.mit;
    mainProgram = "mewline";
  };
}
