{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk4
, wrapGAppsHook4
}:

rustPlatform.buildRustPackage rec {
  pname = "hotkeyhub";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "HotkeyHub";
    rev = "v0.3";
    sha256 = "sha256-V7TKJyJcQM8oaO8aDcfYxt/o3zBWa8m1Xt0hU1OJ77A=";
  };
  cargoHash = "sha256-qatwDu4F1Xwemsp8CtLLIz+cHYN4IZRJ5MRwN43QJy4=";

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
