{ lib, stdenv, fetchFromGitHub }:

let
  # Original Meowrch Wallpapers from the main Arch repo
  meowrch-src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch";
    rev = "main"; # We pull from main to get the latest wallpapers
    sha256 = "sha256-2CqwzWT9ijdVMIfog/aoUGf59b7blS2CtDPQzvbxLrM="; # Placeholder, will be updated by script
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
    mkdir -p $out/share/pawlette
    mkdir -p $out/share/wallpapers/meowrch
    
    # Copy themes
    cp -r ${mocha-theme} $out/share/pawlette/catppuccin-mocha
    
    # Copy ORIGINAL wallpapers from Meowrch repo
    # In the original repo they are in home/.local/share/wallpapers
    if [ -d "${meowrch-src}/home/.local/share/wallpapers" ]; then
      cp -r ${meowrch-src}/home/.local/share/wallpapers/* $out/share/wallpapers/meowrch/
    fi
    
    # Link wallpapers for pawlette themes
    mkdir -p $out/share/pawlette/catppuccin-mocha/wallpapers
    ln -sf $out/share/wallpapers/meowrch/* $out/share/pawlette/catppuccin-mocha/wallpapers/
    
    chmod -R u+w $out/share/pawlette
    runHook postInstall
  '';

  meta = with lib; {
    description = "Official Meowrch (Arch) wallpapers and themes for NixOS";
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
  };
}
