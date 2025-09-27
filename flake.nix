{
  description = "NixOS configuration (Hyprland + Home Manager + themed environment)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.45.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin-nix.url = "github:catppuccin/nix";
    yandex-music.url = "github:cucumber-sp/yandex-music-linux";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , hyprland
    , hyprland-plugins
    , yandex-music
    , spicetify-nix
    , catppuccin-nix
    , nixos-hardware
    , firefox-addons
    , zen-browser
    , ...
  }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    meowrch-scripts = pkgs.callPackage ./packages/meowrch-scripts.nix { };
    meowrch-themes  = pkgs.callPackage ./packages/meowrch-themes.nix { };

    overlay-portal-gbm-fix = import ./overlays/portal-gbm-fix.nix;
    overlay-portal-unstable = import ./overlays/portal-unstable.nix;
  in
  {
    nixosConfigurations.meowrch = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs pkgs-unstable yandex-music spicetify-nix catppuccin-nix zen-browser hyprland hyprland-plugins;
      };
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            overlay-unstable
            overlay-portal-gbm-fix
            overlay-portal-unstable
          ];
        })

        ./configuration.nix
        catppuccin-nix.nixosModules.catppuccin

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          nixpkgs.config.allowUnfree = true;

            home-manager.extraSpecialArgs = {
              inherit inputs firefox-addons meowrch-scripts meowrch-themes;
            };

            home-manager.users.meowrch = {
              imports = [
                inputs.spicetify-nix.homeManagerModules.default
                inputs.catppuccin-nix.homeModules.catppuccin
                ./home/home.nix
              ];
            };

            home-manager.backupFileExtension = "backup";
        }

        ./modules/desktop/hyprland.nix
      ];
    };

    homeConfigurations.meowrch = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs firefox-addons meowrch-scripts meowrch-themes;
      };
      modules = [
        ({ pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        inputs.catppuccin-nix.homeModules.catppuccin
        ./home/home.nix
      ];
    };

    formatter.${system} = pkgs.alejandra;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        nixd
        nil
        alejandra
      ];
      shellHook = ''
        echo "Meowrch NixOS dev shell loaded."
        echo "nix fmt"
        echo "nixos-rebuild switch --flake .#meowrch"
        echo "home-manager switch --flake .#meowrch"
      '';
    };
  };
}
