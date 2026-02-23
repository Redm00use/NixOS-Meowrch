{ pkgs, ... }:

let
  fabric = pkgs.callPackage ./fabric {};
in
{
  inherit fabric;
  mewline = pkgs.callPackage ./mewline { inherit fabric; };
  pawlette = pkgs.callPackage ./pawlette {};
  hotkeyhub = pkgs.callPackage ./hotkeyhub {};
  meowrch-settings = pkgs.callPackage ./meowrch-settings {};
  meowrch-tools = pkgs.callPackage ./meowrch-tools {};
}
