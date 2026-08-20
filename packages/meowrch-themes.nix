{ lib, stdenv, fetchFromGitHub, gtk3 }:

let
  # Original Meowrch Wallpapers from the main Arch repo
  #
  # ┌─ WARNING (NixOS-Meowrch) ────────────────────────────────────────────────┐
  # │ `rev = "main"` is a MUTABLE ref pinned to a FIXED sha256.                │
  # │                                                                          │
  # │ fetchFromGitHub with rev="main" downloads                                │
  # │   https://github.com/meowrch/meowrch/archive/main.tar.gz                 │
  # │ which always returns whatever main points at *right now*. The moment     │
  # │ upstream pushes a commit, this fixed-output derivation stops matching    │
  # │ its hash and the build dies with a hash mismatch.                        │
  # │                                                                          │
  # │ This can hide for a long time: while the old tarball is still in         │
  # │ /nix/store, Nix never refetches, so it keeps "working" locally and then  │
  # │ fails on a clean machine or after nix-collect-garbage.                   │
  # │                                                                          │
  # │ Upstream is now at 4.1.1 (dab45f99e65ba95ba9719e00768d337278861bb9),     │
  # │ so the hash below is expected to be stale already. To repin properly:    │
  # │                                                                          │
  # │   nix-prefetch-url --unpack \                                            │
  # │     https://github.com/meowrch/meowrch/archive/<commit>.tar.gz           │
  # │                                                                          │
  # │ then replace rev with that full commit SHA and paste in the hash.        │
  # │ The same problem applies to `latte-theme` and to `src` below;            │
  # │ only `mocha-theme` is correctly pinned (rev = "v1.7.4").                 │
  # │                                                                          │
  # │ Left as-is on purpose: changing rev without being able to build and      │
  # │ read back the real hash would only swap one broken hash for another.     │
  # └──────────────────────────────────────────────────────────────────────────┘
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

  latte-theme = fetchFromGitHub {
    owner = "meowrch";
    repo = "pawlette-catppuccin-latte-theme";
    rev = "main";
    sha256 = "sha256-vJ8xKixsvaqZttRcq0v52fhT3+L2b5bgI0CFLMXXiJ0=";
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

  nativeBuildInputs = [ gtk3 ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # 1. Create directory structure in $out
    mkdir -p $out/share/pawlette/catppuccin-mocha
    mkdir -p $out/share/pawlette/catppuccin-latte
    mkdir -p $out/share/wallpapers/meowrch

    # 2. Copy the theme contents
    cp -r ${mocha-theme}/* $out/share/pawlette/catppuccin-mocha/
    cp -r ${latte-theme}/* $out/share/pawlette/catppuccin-latte/

    # 3. Copy wallpapers from BOTH themes into a common directory
    mkdir -p $out/share/wallpapers/meowrch
    [ -d "${mocha-theme}/wallpapers" ] && cp -rf ${mocha-theme}/wallpapers/* $out/share/wallpapers/meowrch/ || true
    [ -d "${latte-theme}/wallpapers" ] && cp -rf ${latte-theme}/wallpapers/* $out/share/wallpapers/meowrch/ || true
    
    # Also try to copy from original src if available (fallback), without overwriting existing
    if [ -d "${meowrch-src}/home/.local/share/wallpapers" ]; then
      cp -rn ${meowrch-src}/home/.local/share/wallpapers/* $out/share/wallpapers/meowrch/ || true
    fi

    # 4. Create and populate the wallpapers directory within the themes
    mkdir -p $out/share/pawlette/catppuccin-mocha/wallpapers
    mkdir -p $out/share/pawlette/catppuccin-latte/wallpapers

    # Use find to link files, ignoring errors if links already exist
    find $out/share/wallpapers/meowrch -type f -exec ln -sf {} $out/share/pawlette/catppuccin-mocha/wallpapers/ \;
    find $out/share/wallpapers/meowrch -type f -exec ln -sf {} $out/share/pawlette/catppuccin-latte/wallpapers/ \;

    # 5. Fix permissions to ensure everything is readable
    chmod -R u+w $out/share/pawlette

    # 6. Install GTK themes into share/themes/ so gsettings gtk-theme works
    #    pawlette sets: gtk-theme 'pawlette-catppuccin-latte' / 'pawlette-catppuccin-mocha'
    mkdir -p $out/share/themes/pawlette-catppuccin-latte
    mkdir -p $out/share/themes/pawlette-catppuccin-mocha
    if [ -d "${latte-theme}/gtk-theme" ]; then
      cp -r ${latte-theme}/gtk-theme/. $out/share/themes/pawlette-catppuccin-latte/
    fi
    if [ -d "${mocha-theme}/gtk-theme" ]; then
      cp -r ${mocha-theme}/gtk-theme/. $out/share/themes/pawlette-catppuccin-mocha/
    fi

    # 7. Install icon themes to share/icons/ so GTK/Hyprland can find them by name
    #    (pawlette ships icon themes inside icons/ subdirectory of the theme)
    if [ -d "$out/share/pawlette/catppuccin-mocha/icons" ]; then
      mkdir -p $out/share/icons
      cp -r $out/share/pawlette/catppuccin-mocha/icons/. $out/share/icons/
      # Rebuild icon cache for each installed icon theme
      for dir in $out/share/icons/*/; do
        if [ -f "$dir/index.theme" ]; then
          gtk-update-icon-cache -f -t "$dir" 2>/dev/null || true
        fi
      done
    fi

    # 8. Install the meowrch UI assets (logos consumed by rofi menus and mewline)
    #
    #    Upstream ships these in home/.local/share/meowrch/assets/ and they are
    #    NOT optional decoration -- they are referenced by absolute path:
    #
    #      rofi-menus/theme-selector.sh
    #        random.png                    -> the "Random" entry icon
    #        default-theme-logo.png        -> fallback icon for a theme with no logo
    #        dynamic-theme-on-logo.png     -> Dynamic Theme toggle, enabled state
    #        dynamic-theme-off-logo.png    -> Dynamic Theme toggle, disabled state
    #
    #      mewline (compact.music.default_album_logo)
    #        default-album-logo.png        -> placeholder cover art
    #
    #    meowrch-src is already fetched above for the wallpaper fallback, so
    #    taking the assets from it costs no extra fetch and needs no new hash.
    mkdir -p $out/share/meowrch/assets
    if [ -d "${meowrch-src}/home/.local/share/meowrch/assets" ]; then
      cp -rf ${meowrch-src}/home/.local/share/meowrch/assets/. $out/share/meowrch/assets/
      chmod -R u+w $out/share/meowrch/assets
    else
      echo "WARNING: ${meowrch-src}/home/.local/share/meowrch/assets is missing;" >&2
      echo "         the rofi theme picker will render without icons." >&2
    fi

    # 7. Patch Hyprland custom-prefs: remove borders and fix deprecated syntax (visual cleanup for NixOS)
    find $out/share/pawlette -name "*.conf" -path "*/hypr/*" -exec \
      sed -i \
        -e 's/border_size = [0-9]*/border_size = 0/' \
        -e 's/col\.active_border = .*/col.active_border = rgba(00000000)/' \
        -e 's/col\.inactive_border = .*/col.inactive_border = rgba(00000000)/' \
        -e 's/drop_shadow = yes/shadow { enabled = true }/g' \
        -e 's/drop_shadow = no/shadow { enabled = false }/g' \
        -e '/drop_shadow/d' \
        {} \;

    # NOTE: No cursor patch — the original pawlette cursor IS Bibata-Modern-Classic.
    # Cursor is managed system-wide via home.pointerCursor + HYPRCURSOR_* env vars.

    runHook postInstall
  '';


  meta = with lib; {
    description = "Official Meowrch (Arch) wallpapers and themes for NixOS";
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
  };
}
