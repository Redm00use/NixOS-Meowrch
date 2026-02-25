{ lib, stdenv, fetchFromGitHub }:

let
  mocha-src = fetchFromGitHub {
    owner = "meowrch";
    repo = "pawlette-catppuccin-mocha-theme";
    rev = "v1.7.4";
    sha256 = "0isjkhi3ghgpgg02hd612m5gz2g51kl038nl2v803pl7jdlja0dg";
  };
  
  latte-src = fetchFromGitHub {
    owner = "meowrch";
    repo = "pawlette-catppuccin-latte-theme";
    rev = "v1.7.4";
    sha256 = "17c8sz2jr1a04gh9cvznwbgm7y6rz55snp6lnscsmgbc5hm337xw";
  };
in
stdenv.mkDerivation rec {
  pname = "meowrch-themes";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "Meowrch";
    repo = "meowrch-themes";
    rev = "6a720a4fb5c44f6b6a3be48c828526392ab1e8b1";
    hash = "sha256-KAXoEP18KbFQLuXh1QYOKrsEdOe6zlNJpQCjrpp5mi8=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/pawlette/themes
    
    # Copy themes from their sources
    cp -r ${mocha-src} $out/share/pawlette/themes/catppuccin-mocha
    cp -r ${latte-src} $out/share/pawlette/themes/catppuccin-latte
    
    # Ensure they are readable
    chmod -R u+w $out/share/pawlette/themes
    runHook postInstall
  '';

  meta = with lib; {
    description = "Official themes for Pawlette and Meowrch";
    homepage = "https://github.com/Meowrch/meowrch-themes";
    license = licenses.mit;
    maintainers = [ ];
  };
}
