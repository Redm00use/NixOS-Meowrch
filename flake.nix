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
      url = "github:hyprwm/Hyprland-plugins";
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

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    hyprland,
    hyprland-plugins,
    spicetify-nix,
    catppuccin-nix,
    firefox-addons,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Overlay с кастомными пакетами
    overlay-meowrch = final: prev: (import ./pkgs {pkgs = final;});
    overlay-portal-gbm-fix = import ./overlays/portal-gbm-fix.nix;

    userConfigPath =
      if builtins.pathExists ./hosts/meowrch/user-local.nix
      then ./hosts/meowrch/user-local.nix
      else ./hosts/meowrch/user.nix;
    userConfig = import userConfigPath;
    meowrchUser = userConfig.meowrch.user or "meowrch";
    meowrchHostname = userConfig.meowrch.hostname or "meowrch-machine";
  in {
    nixosConfigurations.meowrch = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs spicetify-nix catppuccin-nix hyprland hyprland-plugins pkgs-unstable;
        inherit meowrchUser meowrchHostname;
        firefox-addons = inputs.firefox-addons.packages.${system};
      };
      modules = [
        ({pkgs, ...}: {
          nixpkgs.overlays = [
            overlay-meowrch
            overlay-portal-gbm-fix
          ];
        })

        ./hosts/meowrch/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit inputs pkgs-unstable meowrchUser meowrchHostname;
            firefox-addons = inputs.firefox-addons.packages.${system};
          };

          home-manager.users.${meowrchUser} = {
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

    # Standalone home-manager (опционально)
    homeConfigurations.meowrch = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs pkgs-unstable meowrchUser meowrchHostname;
        firefox-addons = inputs.firefox-addons.packages.${system};
      };
      modules = [
        inputs.spicetify-nix.homeManagerModules.default
        inputs.catppuccin-nix.homeModules.catppuccin
        ./hosts/meowrch/home.nix
      ];
    };

    formatter.${system} = pkgs.alejandra;

    packages.${system} = let
      customPkgs = import ./pkgs {inherit pkgs;};
    in {
      inherit (customPkgs) fabric fabric-cli mewline pawlette meowrch-themes hotkeyhub meowrch-settings meowrch-scripts meowrch-tools;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ git nixd nil alejandra ];
    };
  };
}
