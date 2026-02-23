{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk4
, wrapGAppsHook4
}:

rustPlatform.buildRustPackage rec {
  pname = "hotkeyhub";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "HotkeyHub";
    rev = "main";
    sha256 = "1c7gi59m68fxbsswjssn63gyipy6v33hs6pgd0lcyh2w48kwmd2p"; # Updated by install.sh
  };

  cargoHash = lib.fakeHash;  # Will need to be updated after first build attempt

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
  ];

  meta = with lib; {
    description = "Interactive cheatsheet for keybindings";
    homepage = "https://github.com/meowrch/HotkeyHub";
    license = licenses.gpl3Only;
    mainProgram = "hotkeyhub";
  };
}
