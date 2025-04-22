# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Flake                          ║
# ║                         Сделал: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  description = "Конфигурация NixOS redm00us (NixOS 24.11 + ядро/materialgram unstable)";

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                              INPUTS                                  ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  inputs = {

    # ────────────── Основные каналы Nixpkgs ──────────────
    nixpkgs = {                                   # Стабильная ветка Nixpkgs (основная)
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {                          # Нестабильная ветка Nixpkgs (для свежих пакетов)
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # ────────────── Менеджер домашней директории ──────────────
    home-manager = {                              # Home Manager (управление пользовательской конфигурацией)
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ────────────── Темы и оформление ──────────────
    catppuccin-nix = {                            # Catppuccin Theme (глобальная тема)
      url = "github:catppuccin/nix";
    };

    # ────────────── Мультимедиа ──────────────
    yandex-music = {                              # Yandex Music (неофициальный клиент)
      url = "github:cucumber-sp/yandex-music-linux";
    };
    spicetify-nix = {                             # Spicetify (кастомизация Spotify)
      url = "github:Gerg-L/spicetify-nix";
    };

    # ────────────── Браузеры ──────────────
    zen-browser = {                               # Zen Browser (альтернативный браузер)
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ────────────── Редакторы ──────────────
    zed = {                                       # Zed Editor (современный редактор кода)
      url = "github:zed-industries/zed/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                              OUTPUTS                                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  outputs = { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , yandex-music
    , spicetify-nix
    , catppuccin-nix
    , zed
    , ...
  }@inputs:
  let
    # ────────────── Системные параметры ──────────────
    system = "x86_64-linux";                      # Архитектура системы

    # ────────────── Импорт пакетов ──────────────
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;                  # Разрешить проприетарные пакеты
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    # ────────────── Конфигурация NixOS ──────────────
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        # Передача переменных и пакетов в модули
        inherit inputs pkgs pkgs-unstable yandex-music spicetify-nix catppuccin-nix zed;
        zed-editor-pkg = zed.packages.${system}.default or pkgs-unstable.zed-editor; # Пакет редактора Zed
      };
      modules = [
        ./configuration.nix                                 # Основная системная конфигурация

        home-manager.nixosModules.home-manager              # Модуль Home Manager

        {
          # ────────────── Настройки Home Manager ──────────────
          home-manager.useGlobalPkgs = true;                # Использовать глобальные пакеты
          home-manager.useUserPackages = true;              # Использовать пользовательские пакеты
          nixpkgs.config.allowUnfree = true;                # Разрешить проприетарные пакеты

          home-manager.extraSpecialArgs = { inherit inputs; }; # Передача inputs в Home Manager

          home-manager.users.redm00us = {
            imports = [
              inputs.spicetify-nix.homeManagerModules.default  # Модуль Spicetify для Home Manager
              ./home.nix                                      # Пользовательская конфигурация
            ];
          };
          home-manager.backupFileExtension = "backup";         # Расширение для бэкапов Home Manager
        }
      ];
    };
  };
}
