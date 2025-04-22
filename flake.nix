# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Flake                          ║
# ║                         Сделал: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  description = "Конфигурация NixOS redm00us (NixOS 24.11 + ядро/materialgram unstable)";

  inputs = {
    # --- Стабильная ветка (основная) ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # --- Нестабильная ветка (для отдельных пакетов) ---
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # --- Home Manager ---
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Yandex-music ---
    yandex-music = {
      url = "github:cucumber-sp/yandex-music-linux";
    };

    # --- Zen Browser ---
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Spicetify ---
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
    };

    # --- Catppuccin Theme ---
    catppuccin-nix = {
      url = "github:catppuccin/nix";
    };

    # --- Zed Editor ---
    zed = {
      url = "github:zed-industries/zed/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, yandex-music, spicetify-nix, catppuccin-nix, zed, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs pkgs pkgs-unstable yandex-music spicetify-nix catppuccin-nix zed;
        zed-editor-pkg = zed.packages.${system}.default or pkgs-unstable.zed-editor;
      };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          nixpkgs.config.allowUnfree = true;

          home-manager.extraSpecialArgs = { inherit inputs; };

          home-manager.users.redm00us = {
            imports = [
              inputs.spicetify-nix.homeManagerModules.default
              ./home.nix
            ];
          };
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
