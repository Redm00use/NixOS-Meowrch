{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, gtk4
, libadwaita
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "hotkeyhub";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "HotkeyHub"; # Case sensitive? Search suggests "HotkeyHub"
    rev = "main";
    sha256 = "3d2040341275c3960ae0c00385afcb5b6c6e8496e5dc5378e7964272085eebe5"; # TODO: Update this hash
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp hotkeyhub $out/bin/ # Assumes binary name
    # Or if it uses make/meson, adjust accordingly
    runHook postInstall
  '';

  meta = with lib; {
    description = "Interactive cheatsheet for keybindings";
    homepage = "https://github.com/meowrch/HotkeyHub";
    license = licenses.mit;
    mainProgram = "hotkeyhub";
  };
}
