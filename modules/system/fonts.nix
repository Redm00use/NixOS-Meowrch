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
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.ubuntu-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.meslo-lg

      # System fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      noto-fonts-extra

      # Programming fonts
      jetbrains-mono
      fira-code
      fira-code-symbols
      source-code-pro
      ubuntu_font_family
      dejavu_fonts

      # Interface fonts
      inter
      ubuntu_font_family
      noto-fonts
      open-sans
      roboto
      roboto-mono

      # Microsoft fonts (if needed)
      corefonts
      vistafonts

      # Liberation fonts (Microsoft alternatives)
      liberation_ttf

      # Additional fonts
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
