{ lib
, python3Packages
, fetchFromGitHub
, gobject-introspection
, pkg-config
, gtk4
, gtk-layer-shell
, libadwaita
}:

python3Packages.buildPythonPackage rec {
  pname = "fabric";
  version = "0.0.2-unstable";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "main";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # Updated by install.sh
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    pkg-config
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    loguru
    pycairo
    pygobject3
    psutil
  ];

  buildInputs = [
    gtk4
    gtk-layer-shell
    libadwaita
  ];

  pythonImportsCheck = [ "fabric" ];
  doCheck = false;

  meta = with lib; {
    description = "Next-gen framework for building desktop widgets using Python";
    homepage = "https://github.com/Fabric-Development/fabric";
    license = licenses.agpl3Only;
  };
}
