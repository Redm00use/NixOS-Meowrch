self: super: {
  xdg-desktop-portal-hyprland = self.inputs.nixpkgs-unstable.legacyPackages.${super.system}.xdg-desktop-portal-hyprland;
}
