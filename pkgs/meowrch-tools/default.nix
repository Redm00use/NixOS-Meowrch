{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, curl
, jq
, python3
, gamemode
}:

stdenv.mkDerivation rec {
  pname = "meowrch-tools";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch-tools";
    rev = "v3.1.1";
    hash = "sha256-KQUY/fN2v6h6Qm1B2WMOwx+jlhDz200aOjtByByqJjg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # The repo structure is usr/bin/, not bin/
    cp -r usr $out

    # Make all scripts executable
    find $out/bin -type f -exec chmod +x {} \;

    # Wrap scripts to ensure dependencies are available
    for script in $out/bin/*; do
      if [ -f "$script" ] && head -1 "$script" | grep -q "bash\|sh"; then
        wrapProgram "$script" \
          --prefix PATH : ${lib.makeBinPath [ bash coreutils curl jq python3 gamemode ]}
      fi
    done

    # Wrap scripts in subdirectories
    for dir in $out/bin/core $out/bin/wrappers $out/bin/gaming; do
      if [ -d "$dir" ]; then
        for script in "$dir"/*; do
          if [ -f "$script" ]; then
            chmod +x "$script"
            wrapProgram "$script" \
              --prefix PATH : ${lib.makeBinPath [ bash coreutils curl jq python3 gamemode ]}
          fi
        done
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Meowrch gaming and utility tools";
    homepage = "https://github.com/meowrch/meowrch-tools";
    license = licenses.mit;
  };
}
