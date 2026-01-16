{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "meowrch-settings";
  version = "unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch-settings";
    rev = "main";
    sha256 = "4452f8296420fb27f16878e871425d4f4ee06bc9cdcb74f1f835971fe930ad6d"; # TODO: Update this hash
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    # Install udev rules
    mkdir -p $out/lib/udev/rules.d
    find . -name "*.rules" -exec cp {} $out/lib/udev/rules.d/ \;

    # Install sysctl configs (Note: NixOS prefers boot.kernel.sysctl, 
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
