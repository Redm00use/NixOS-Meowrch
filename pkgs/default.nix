{ pkgs, ... }:

let
  libcvc  = pkgs.callPackage ./libcvc {};
  libgray = pkgs.callPackage ./libgray {};
  fabric  = pkgs.callPackage ./fabric { inherit libcvc; };
  fabric-cli = pkgs.callPackage ./fabric-cli {};
in
rec {
  inherit fabric fabric-cli libcvc libgray;
  meowrch-themes   = pkgs.callPackage ../packages/meowrch-themes.nix {};
  mewline          = pkgs.callPackage ./mewline { 
    inherit fabric libcvc libgray; 
    libdbusmenuGtk3 = pkgs.libdbusmenu-gtk3;
    brightnessctl = pkgs.brightnessctl;
  };
  pawlette         = pkgs.callPackage ./pawlette { inherit meowrch-themes; inherit (pkgs) glib makeWrapper; };
  meowrch-scripts  = pkgs.callPackage ../packages/meowrch-scripts.nix { hyprland = pkgs.hyprland; };
  hotkeyhub        = pkgs.callPackage ./hotkeyhub {};
  meowrch-settings = pkgs.callPackage ./meowrch-settings { inherit (pkgs) bash hdparm; };
  meowrch-tools    = pkgs.callPackage ./meowrch-tools {};
}
