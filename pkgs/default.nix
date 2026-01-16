{ pkgs, ... }:

{
  mewline = pkgs.callPackage ./mewline {};
  pawlette = pkgs.callPackage ./pawlette {};
  hotkeyhub = pkgs.callPackage ./hotkeyhub {};
  meowrch-settings = pkgs.callPackage ./meowrch-settings {};
  meowrch-tools = pkgs.callPackage ./meowrch-tools {};
}
