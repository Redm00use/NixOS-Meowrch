{ lib
, python3Packages
, fetchFromGitHub
, gtk4
, libadwaita
, gobject-introspection
, wrapGAppsHook
}:

python3Packages.buildPythonApplication rec {
  pname = "mewline";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "main";
    sha256 = "2bc10d0aefaef8bbc6d1b1e324f3e2f64e6754455e3f87dde19a78e3426a8851"; # TODO: Update this hash
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    loguru
    # Add other python dependencies here as found
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  meta = with lib; {
    description = "Dynamic Island for Linux status bar";
    homepage = "https://github.com/meowrch/mewline";
    license = licenses.mit; # Assumption
    mainProgram = "mewline";
  };
}
