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
, brightnessctl
, adwaita-icon-theme
, hicolor-icon-theme
}:

python3Packages.buildPythonApplication rec {
  pname = "mewline";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "v2.0.0";
    hash = "sha256-GJ9AUCO/RXIBIvYjJ2TypaU+twJQ8hSBlli5lgK756Y=";
  };

  patches = [
    ./patches/media-player.patch
  ];

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    wrapGAppsHook3
    pkg-config
  ];

  # Ensure icons, dart-sass and brightnessctl are available in PATH/XDG at runtime
  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${lib.makeBinPath [ dart-sass brightnessctl ]}"
    "--prefix" "XDG_DATA_DIRS" ":" "${adwaita-icon-theme}/share"
    "--prefix" "XDG_DATA_DIRS" ":" "${hicolor-icon-theme}/share"
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
    systemd-python
    pytesseract
    emoji
    xlib
    adwaita-icon-theme
    hicolor-icon-theme
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
    adwaita-icon-theme
    hicolor-icon-theme
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
    substituteInPlace src/mewline/constants.py \
      --replace 'THEME_STYLE = STYLES_FOLDER / "theme.scss"' 'THEME_STYLE = APP_CACHE_DIRECTORY / "theme.scss"'
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
