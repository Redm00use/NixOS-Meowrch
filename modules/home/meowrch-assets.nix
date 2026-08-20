# ~/.local/share/meowrch/assets -- UI logos used by the rofi menus and mewline.
#
# Upstream meowrch ships these as plain files in the user's home:
#   home/.local/share/meowrch/assets/*.png
# and references them by absolute path from shell scripts and from
# mewline's config.json. Nothing generates them at runtime, so if they are
# absent the consumers degrade silently:
#
#   theme-selector.sh   rofi renders the entries with no icon at all, which
#                       makes the theme picker and the Dynamic Theme toggle
#                       look empty and unclickable-ish but still work.
#   mewline             the compact music widget shows a blank cover.
#
# The fork had none of them: assets/ at the repo root only contains
# misc/.face.icon, sddm/ and themes/. They are now installed by
# packages/meowrch-themes.nix into $out/share/meowrch/assets (taken from the
# upstream checkout it already fetches) and linked into place here.
#
# Why individual files instead of one directory symlink:
# linking a whole directory into the Nix store makes that directory read-only,
# so anything that later wants to write a sibling file inside it fails with
# EROFS. Per-file links keep the parent directory a real, writable directory.
# Same pattern as waybar.nix / swaync.nix / polybar.nix / picom.nix.
#
# NOTE: not imported anywhere yet -- see docs/UPSTREAM-PARITY.md.

{ config, pkgs, lib, ... }:

let
  assetsDir = "${pkgs.meowrch-themes}/share/meowrch/assets";

  # Exactly the six files upstream ships. Keep this list in sync with
  # home/.local/share/meowrch/assets/ upstream.
  assetNames = [
    "random.png"
    "default-theme-logo.png"
    "dynamic-theme-on-logo.png"
    "dynamic-theme-off-logo.png"
    "default-album-logo.png"
    "meowrch-logo.png"
  ];
in
{
  # xdg.dataFile (not home.file) so the paths follow xdg.dataHome, matching the
  # scripts' ${XDG_DATA_HOME:-$HOME/.local/share} lookup.
  xdg.dataFile = lib.listToAttrs (map (name: {
    name = "meowrch/assets/${name}";
    value.source = "${assetsDir}/${name}";
  }) assetNames);

  # Writable runtime directories that upstream simply assumes exist.
  #
  #   ~/.local/state/meowrch/dynamic_theme
  #       written by theme-selector.sh when toggling Dynamic Theme.
  #   ~/.cache/meowrch/current_bar_<wm>
  #       written by toggle-bar.sh (STATE_DIR) on every bar start/stop/next.
  #
  # Neither path is created by us elsewhere, and a store-linked parent would
  # make them unwritable, so create them as real directories on activation.
  home.activation.meowrchRuntimeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg "${config.home.homeDirectory}/.local/state/meowrch"}
    run mkdir -p ${lib.escapeShellArg "${config.xdg.cacheHome}/meowrch"}
  '';
}
