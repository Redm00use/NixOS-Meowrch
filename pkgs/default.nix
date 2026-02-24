{ pkgs, ... }:

let
  libcvc  = pkgs.callPackage ./libcvc {};
  libgray = pkgs.callPackage ./libgray {};
  fabric  = pkgs.callPackage ./fabric { inherit libcvc; };
in
{
  inherit fabric libcvc libgray;
  mewline          = pkgs.callPackage ./mewline { inherit fabric libcvc libgray; libdbusmenuGtk3 = pkgs.libdbusmenu-gtk3; };
  pawlette         = pkgs.callPackage ./pawlette {};
  hotkeyhub        = pkgs.callPackage ./hotkeyhub {};
  meowrch-settings = pkgs.callPackage ./meowrch-settings {};
  meowrch-tools    = pkgs.callPackage ./meowrch-tools {};
}
