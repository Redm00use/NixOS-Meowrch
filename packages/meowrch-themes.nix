{ lib, stdenv, fetchFromGitHub }:

let
  # Original Meowrch Wallpapers from the main Arch repo
  meowrch-src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch";
    rev = "main";
    sha256 = "sha256-2CqwzWT9ijdVMIfog/aoUGf59b7blS2CtDPQzvbxLrM="; 
  };

  mocha-theme = fetchFromGitHub {
    owner = "meowrch";
    repo = "pawlette-catppuccin-mocha-theme";
    rev = "v1.7.4";
    sha256 = "0isjkhi3ghgpgg02hd612m5gz2g51kl038nl2v803pl7jdlja0dg";
  };
in
stdenv.mkDerivation rec {
  pname = "meowrch-themes";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "Meowrch";
    repo = "meowrch-themes";
    rev = "main";
    hash = "sha256-KAXoEP18KbFQLuXh1QYOKrsEdOe6zlNJpQCjrpp5mi8=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    
    # 1. Create directory structure in $out
    mkdir -p $out/share/pawlette/catppuccin-mocha
    mkdir -p $out/share/wallpapers/meowrch
    
    # 2. Copy the theme contents to our writable output directory
    cp -r ${mocha-theme}/* $out/share/pawlette/catppuccin-mocha/
    
    # 3. Copy ORIGINAL wallpapers from Meowrch repo
    if [ -d "${meowrch-src}/home/.local/share/wallpapers" ]; then
      cp -r ${meowrch-src}/home/.local/share/wallpapers/* $out/share/wallpapers/meowrch/
    fi
    
    # 4. Create and populate the wallpapers directory within the theme
    mkdir -p $out/share/pawlette/catppuccin-mocha/wallpapers
    
    # Use find to safely link all wallpapers to the theme folder
    find $out/share/wallpapers/meowrch -type f -exec ln -sf {} $out/share/pawlette/catppuccin-mocha/wallpapers/ \;
    
    # 5. Fix permissions to ensure everything is readable
    chmod -R u+w $out/share/pawlette
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Official Meowrch (Arch) wallpapers and themes for NixOS";
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
  };
}
