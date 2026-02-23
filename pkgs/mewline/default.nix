{ lib
, python3Packages
, fetchFromGitHub
, pkg-config
, gtk4
, gtk-layer-shell
, libadwaita
, gobject-introspection
, wrapGAppsHook4
, dart-sass
, tesseract
, gnome-bluetooth
, upower
, networkmanager
, playerctl
, fabric
}:

python3Packages.buildPythonApplication rec {
  pname = "mewline";
  version = "unstable-2025-01-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "main";
    sha256 = "12gg108bbkl72pjiiic4x7imj9klsbysn5k895cfw161yav22bfl"; # Updated by install.sh
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    wrapGAppsHook4
    pkg-config
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
  ];

  buildInputs = [
    gtk4
    gtk-layer-shell
    libadwaita
    dart-sass
    tesseract
    gnome-bluetooth
    upower
    networkmanager
    playerctl
  ];

  # Remove deps not available in nixpkgs
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "emoji" "pytesseract" "pkgconfig" "systemd" ];

  doCheck = false;

  meta = with lib; {
    description = "Dynamic Island for Linux status bar";
    homepage = "https://github.com/meowrch/mewline";
    license = licenses.mit;
    mainProgram = "mewline";
  };
}
