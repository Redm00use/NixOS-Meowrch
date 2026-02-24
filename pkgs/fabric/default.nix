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
    hash = "sha256-YVlwsUz4SLj8qYAb21ernT3lDB/piU1V6hTW/UjikWA=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    pkg-config
  ];

  postPatch = ''
    # Убираем жесткую привязку к версии pygobject, из-за которой падает сборка
    sed -i -E 's/PyGObject==[0-9.]+/PyGObject/g' pyproject.toml || true
    sed -i -E 's/pygobject==[0-9.]+/pygobject/g' pyproject.toml || true
  '';

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
