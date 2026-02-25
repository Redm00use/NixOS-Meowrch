{ lib
, stdenv
, fetchFromGitHub
, bash
, hdparm
}:

stdenv.mkDerivation rec {
  pname = "meowrch-settings";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch-settings";
    rev = "v3.1.3";
    hash = "sha256-E7yfqOCTrEMgFgG8G0460hjwEuJaaD0qoUzXS/nT7Cw=";
  };

  nativeBuildInputs = [ bash hdparm ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    # Install udev rules
    mkdir -p $out/lib/udev/rules.d
    find . -name "*.rules" -exec cp {} $out/lib/udev/rules.d/ \;

    # Patch absolute paths in udev rules
    for rule in $out/lib/udev/rules.d/*.rules; do
      substituteInPlace "$rule" \
        --replace "/usr/bin/bash" "${bash}/bin/bash" \
        --replace "/bin/sh" "${bash}/bin/sh" \
        --replace "/usr/bin/hdparm" "${hdparm}/bin/hdparm" \
        || true
    done

    # Install sysctl configs
    # but placing them in lib/sysctl.d might work if systemd loads them)
    mkdir -p $out/lib/sysctl.d
    find . -name "*.conf" -exec cp {} $out/lib/sysctl.d/ \;
    
    # Copy other assets if any
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "System optimizations for Meowrch";
    homepage = "https://github.com/meowrch/meowrch-settings";
    license = licenses.mit;
  };
}
