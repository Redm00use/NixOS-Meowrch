{ lib
, python3Packages
, fetchFromGitHub
, gobject-introspection
, pkg-config
, gtk3
, gtk4
, gtk-layer-shell
, libadwaita
, cairo
, wrapGAppsHook3
, libcvc
}:

python3Packages.buildPythonPackage rec {
  pname = "fabric";
  version = "0.0.2-unstable-2026-02-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "fd2aabbd7e1859aa7c11c626a6c36a937aca736a";
    hash = "sha256-YVlwsUz4SLj8qYAb21ernT3lDB/piU1V6hTW/UjikWA=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    gobject-introspection
    pkg-config
    wrapGAppsHook3
  ];

  postPatch = ''
    # Убираем жесткую привязку к версии pygobject, из-за которой падает сборка
    sed -i -E 's/PyGObject==[0-9.]+/PyGObject/g' pyproject.toml || true
    sed -i -E 's/pygobject==[0-9.]+/pygobject/g' pyproject.toml || true

    # Fix pygobject 3.54+ compatibility in wayland.py
    # Only change the TYPE argument inside @Property(...) declarations, NOT get_enum_member() calls
    python3 -c "
import re

with open('fabric/widgets/wayland.py', 'r') as f:
    content = f.read()

# Replace @Property(GtkLayerShell.Layer, ...) -> @Property(object, ...)
# Match only @Property( followed by the enum type
content = re.sub(
    r'@Property\(\s*GtkLayerShell\.Layer,',
    '@Property(object,',
    content
)
content = re.sub(
    r'@Property\(\s*GtkLayerShell\.KeyboardMode,',
    '@Property(object,',
    content
)
content = re.sub(
    r'@Property\(\s*WaylandWindowExclusivity,',
    '@Property(object,',
    content
)
content = re.sub(
    r'@Property\(\s*tuple\[GtkLayerShell\.Edge, \.\.\.\]',
    '@Property(object',
    content
)

# Remove any default_value= lines that reference GLib enums
content = re.sub(r'\s*default_value=GtkLayerShell\.Layer\.[A-Z_]+,?\n', '\n', content)
content = re.sub(r'\s*default_value=GtkLayerShell\.KeyboardMode\.[A-Z_]+,?\n', '\n', content)

with open('fabric/widgets/wayland.py', 'w') as f:
    f.write(content)

print('wayland.py patched successfully')
"
  '';

  propagatedBuildInputs = with python3Packages; [
    click
    loguru
    pycairo
    pygobject3
    psutil
  ];

  buildInputs = [
    gtk3
    gtk4
    gtk-layer-shell
    libadwaita
    cairo
    # Provides Cvc-1.0 typelib needed by fabric.audio
    libcvc
  ];

  pythonImportsCheck = [ "fabric" ];
  doCheck = false;

  meta = with lib; {
    description = "Next-gen framework for building desktop widgets using Python";
    homepage = "https://github.com/Fabric-Development/fabric";
    license = licenses.agpl3Only;
  };
}
