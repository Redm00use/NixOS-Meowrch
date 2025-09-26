{ config, pkgs, lib, ... }:

{
  # Lean fonts configuration
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      inter
      noto-fonts
      noto-fonts-emoji
      dejavu_fonts
      font-awesome
      papirus-icon-theme
    ];

    enableDefaultPackages = false;
  };

  environment.systemPackages = with pkgs; [
    fontconfig
    gucharmap
  ];
}

# Add font-related groups (user groups defined in main configuration.nix)
