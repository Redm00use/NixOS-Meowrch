{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, vala
, gobject-introspection
, glib
, gtk3
, libdbusmenu-gtk3
}:

stdenv.mkDerivation rec {
  pname = "libgray";
  version = "0.1-unstable";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "gray";
    rev = "main";
    hash = "sha256-s9v9fkp+XrKqY81Z7ezxMikwcL4HHS3KvEwrrudJutw=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vala
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    libdbusmenu-gtk3
  ];

  outputs = [ "out" "dev" ];

  meta = with lib; {
    description = "System trays for everyone — provides Gray-1.0 GObject typelib for system tray support";
    homepage = "https://github.com/Fabric-Development/gray";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
