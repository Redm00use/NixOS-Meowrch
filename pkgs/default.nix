{ pkgs, ... }:

let
  libcvc  = pkgs.callPackage ./libcvc {};
  libgray = pkgs.callPackage ./libgray {};
  fabric  = pkgs.callPackage ./fabric { inherit libcvc; };
  fabric-cli = pkgs.callPackage ./fabric-cli {};
in
{
  inherit fabric fabric-cli libcvc libgray;
  mewline          = pkgs.callPackage ./mewline { inherit fabric libcvc libgray; libdbusmenuGtk3 = pkgs.libdbusmenu-gtk3; };
  pawlette         = pkgs.callPackage ./pawlette {};
  meowrch-themes   = pkgs.callPackage ../packages/meowrch-themes.nix {};
  meowrch-scripts  = pkgs.callPackage ../packages/meowrch-scripts.nix { hyprland = pkgs.hyprland; };
  hotkeyhub        = pkgs.callPackage ./hotkeyhub {};
  meowrch-settings = pkgs.callPackage ./meowrch-settings { inherit (pkgs) bash hdparm; };
  meowrch-tools    = pkgs.callPackage ./meowrch-tools {};
}
