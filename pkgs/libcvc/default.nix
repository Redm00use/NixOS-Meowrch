{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, glib
, gobject-introspection
, libpulseaudio
}:

stdenv.mkDerivation rec {
  pname = "libcvc";
  version = "6.6.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-desktop";
    rev = version;
    hash = "sha256-AcUJ9anKuvUAJKaQVHbkYShmrlSHG35gV/NIkPgJojk=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gobject-introspection
  ];

  buildInputs = [
    glib
    libpulseaudio
  ];

  # Patch root meson.build to only build libcvc — skip all other heavy dependencies
  postPatch = ''
    cat > meson.build << 'MESON_EOF'
project('cinnamon-desktop', 'c', version : '6.6.2', meson_version : '>=0.56.0')

pkgconfig = import('pkgconfig')
gnome     = import('gnome')
cc        = meson.get_compiler('c')

# Minimal config — only what libcvc needs
use_alsa = false
rootInclude = include_directories('.')

conf = configuration_data()
conf.set('HAVE_INTROSPECTION', true)
conf.set('HAVE_ALSA', false)
conf.set_quoted('PACKAGE_VERSION', '6.6.2')
conf.set_quoted('GETTEXT_PACKAGE', 'cinnamon-desktop')
conf.set_quoted('GNOMELOCALEDIR', '/usr/share/locale')

configure_file(output: 'config.h', configuration: conf)

# Build only libcvc
subdir('libcvc')
MESON_EOF
  '';

  meta = with lib; {
    description = "Cvc audio volume control library (from cinnamon-desktop) providing Cvc-1.0 GObject typelib";
    homepage = "https://github.com/linuxmint/cinnamon-desktop";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
