{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.portproton;
in {
  imports = [
    ./portproton/default.nix
    ./portproton/optimizations.nix
    ./portproton/desktop.nix
  ];

  options.programs.portproton = {
    enable = mkEnableOption "Port Proton - продвинутая версия Proton для запуска Windows игр на Linux";
  };

  config = mkIf cfg.enable {
    # Важные настройки системы для корректной работы Port Proton
    programs.steam.enable = mkDefault true;

    # Включаем базовые оптимизации
    programs.portproton.optimizations = {
      enable = mkDefault true;
      managedConfig = mkDefault true;
      systemTweaks = mkDefault true;
    };

    # Интеграция с рабочим столом
    programs.portproton.desktop = {
      enable = mkDefault true;
      mimeHandler = mkDefault true;
      autoCreateDesktopFiles = mkDefault true;
    };

    # Разрешения для 32-битных библиотек (необходимо для многих игр)
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Настройки звука
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Настройки для Wine
    environment.systemPackages = with pkgs; [
      wine
      winetricks
      vulkan-tools
      vulkan-loader
      gamemode
      gamescope
      mangohud
      vkBasalt
    ];

    # Расширяем capabilities для сетевых приложений и игр
    security.wrappers = {
      "fusermount" = {
        source = "${pkgs.fuse}/bin/fusermount";
        capabilities = "cap_sys_admin+ep";
        owner = "root";
        group = "root";
      };
    };

    # Специальные настройки /etc/sysctl.conf для игр
    boot.kernel.sysctl = {
      "vm.max_map_count" = 1048576;
      "fs.file-max" = 100000;
    };
  };
}
