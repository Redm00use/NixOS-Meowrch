# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    MEOWRCH NIXOS FLAKE ENTRY POINT                       ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{
  description = "NixOS configuration (Hyprland + Home Manager + themed environment) — NixOS 25.11 Xantusia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin-nix.url = "github:catppuccin/nix";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, hyprland-plugins, spicetify-nix, catppuccin-nix, firefox-addons, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    
    overlay-meowrch = final: prev: (import ./pkgs { pkgs = final; });
    overlay-portal-gbm-fix = import ./overlays/portal-gbm-fix.nix;
  in
  {
    nixosConfigurations.meowrch = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs spicetify-nix catppuccin-nix hyprland hyprland-plugins pkgs-unstable; };
      modules = [
        ({ pkgs, ... }: { nixpkgs.overlays = [ overlay-meowrch overlay-portal-gbm-fix ]; })
        ./hosts/meowrch/configuration.nix
        catppuccin-nix.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs firefox-addons pkgs-unstable; };
          home-manager.users.meowrch = {
            imports = [
              inputs.spicetify-nix.homeManagerModules.default
              inputs.catppuccin-nix.homeModules.catppuccin
              ./hosts/meowrch/home.nix
            ];
          };
          home-manager.backupFileExtension = "backup";
        }
        ./modules/nixos/desktop/hyprland.nix
      ];
    };

    formatter.${system} = pkgs.alejandra;
  };
}
