# /etc/nixos/flake.nix
{
  description = "Конфигурация NixOS redm00us (NixOS 24.11 + ядро/materialgram unstable)";

  inputs = { # <-- Открывающая скобка inputs
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
      # inputs.nixpkgs.follows = "nixpkgs"; # Опционально
    };

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, yandex-music, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgs pkgs-unstable yandex-music; }; # Аргументы для модулей NixOS
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          # Настройки Home Manager для пользователя redm00us
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          nixpkgs.config.allowUnfree = true;

          # ---> ИСПРАВЛЕНИЕ: Передаем inputs в Home Manager <---
          home-manager.extraSpecialArgs = { inherit inputs; };

          # Импортируем конфигурацию пользователя
          home-manager.users.redm00us = import ./home.nix;

          # Настройка бэкапа файлов при перезаписи
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
