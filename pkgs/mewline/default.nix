{ lib
, python3Packages
, fetchFromGitHub
, gtk4
, gtk-layer-shell
, libadwaita
, gobject-introspection
, wrapGAppsHook4
, pkg-config
, dart-sass
, tesseract
, gnome-bluetooth
, upower
, networkmanager
}:

python3Packages.buildPythonApplication rec {
  pname = "mewline";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "main";
    sha256 = "12gg108bbkl72pjiiic4x7imj9klsbysn5k895cfw161yav22bfl"; # Updated by install.sh
  };

  pyproject = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    pkg-config
    python3Packages.setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    loguru
    dbus-python
    pillow
    psutil
    pydantic
    setproctitle
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
  ];

  # fabric dependency is from git and complex — skip dependency checking at build time 
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "fabric" "emoji" "pytesseract" "pkgconfig" "systemd" ];

  # Don't run tests (require display)
  doCheck = false;

  meta = with lib; {
    description = "Dynamic Island for Linux status bar";
    homepage = "https://github.com/meowrch/mewline";
    license = licenses.mit;
    mainProgram = "mewline";
  };
}
