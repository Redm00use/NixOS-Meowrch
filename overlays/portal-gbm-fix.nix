self: super: {
  xdg-desktop-portal-hyprland = super.xdg-desktop-portal-hyprland.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ super.mesa super.libgbm ];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.pkg-config ];
    preConfigure = ''
      export PKG_CONFIG_PATH="${super.libgbm}/lib/pkgconfig:$PKG_CONFIG_PATH"
      echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
      pkg-config --list-all | grep gbm || true
    '';
  });
}
