{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, gamemode
}:

stdenv.mkDerivation rec {
  pname = "meowrch-tools";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch-tools";
    rev = "main";
    sha256 = "012720fac153f68ceeface798948bbdef4337e079b804eb8cb42d059356e4ef4"; # TODO: Update this hash
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    
    # Install scripts/binaries
    cp -r bin/* $out/bin/
    chmod +x $out/bin/*
    
    # Wrap game-run to ensure gamemode is available
    wrapProgram $out/bin/meowrch-game-run \
      --prefix PATH : ${lib.makeBinPath [ gamemode ]}
      
    runHook postInstall
  '';

  meta = with lib; {
    description = "Meowrch gaming and utility tools";
    homepage = "https://github.com/meowrch/meowrch-tools";
    license = licenses.mit;
  };
}
