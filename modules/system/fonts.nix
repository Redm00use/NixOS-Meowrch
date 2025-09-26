{ config, pkgs, lib, ... }:

{
  # Fonts Configuration
  fonts = {
    # Enable font configuration
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting = {
        enable = true;
        style = "slight";
        autohint = false;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      # Default fonts
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Liberation Mono" ];
        emoji = [ "Noto Color Emoji" "Twemoji" ];
      };

      # Font substitutions
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- Use JetBrainsMono for monospace -->
          <alias>
            <family>monospace</family>
            <prefer>
              <family>JetBrainsMono Nerd Font</family>
              <family>Hack Nerd Font</family>
              <family>FiraCode Nerd Font</family>
            </prefer>
          </alias>

          <!-- Use Noto fonts for general text -->
          <alias>
            <family>sans-serif</family>
            <prefer>
              <family>Noto Sans</family>
              <family>Inter</family>
              <family>Ubuntu</family>
            </prefer>
          </alias>

          <alias>
            <family>serif</family>
            <prefer>
              <family>Noto Serif</family>
              <family>Liberation Serif</family>
            </prefer>
          </alias>

          <!-- Emoji fonts -->
          <alias>
            <family>emoji</family>
            <prefer>
              <family>Noto Color Emoji</family>
              <family>Twitter Color Emoji</family>
              <family>EmojiOne Color</family>
            </prefer>
          </alias>

          <!-- Font rendering preferences -->
          <match target="font">
            <edit name="lcdfilter" mode="assign">
              <const>lcddefault</const>
            </edit>
          </match>

          <match target="font">
            <edit name="rgba" mode="assign">
              <const>rgb</const>
            </edit>
          </match>

          <!-- Disable bitmap fonts -->
          <selectfont>
            <rejectfont>
              <pattern>
                <patelt name="scalable"><bool>false</bool></patelt>
              </pattern>
            </rejectfont>
          </selectfont>
        </fontconfig>
      '';
    };

    # Font packages
    packages = with pkgs; [
      # Nerd Fonts
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
      material-icons
      material-design-icons

      # Emoji fonts
      twemoji-color-font
      openmoji-color

      # Asian fonts
      wqy_microhei
      wqy_zenhei

      # Serif fonts
      crimson
      eb-garamond

      # Math fonts
      tex-gyre.adventor
      tex-gyre.bonum
      tex-gyre.chorus
      tex-gyre.cursor
      tex-gyre.heros
      tex-gyre.pagella
      tex-gyre.schola
      tex-gyre.termes

      # Icon fonts
      siji
      unifont

      # Gaming/Display fonts
      comic-neue
      comic-relief
    ];

    # Enable default fonts
    enableDefaultPackages = true;

    # Font directories
    fontDir.enable = true;

    # Enable ghostscript fonts
    enableGhostscriptFonts = true;
  };

  # Additional font-related packages
  environment.systemPackages = with pkgs; [
    # Font management tools
    fontconfig
    fontforge

    # Font preview and management
    font-manager
    gucharmap

    # Font utilities
    python3Packages.fonttools

    # Icon management
    hicolor-icon-theme
    adwaita-icon-theme
    papirus-icon-theme

    # Emoji picker
    emote
  ];

  # XDG font directories
  environment.pathsToLink = [ "/share/fonts" ];

  # Environment variables for font rendering
  environment.sessionVariables = {
    # Font rendering
    FREETYPE_PROPERTIES = "truetype:interpreter-version=38";

    # Qt font settings
    QT_FONT_DPI = "96";

    # GTK font settings
    GDK_DPI_SCALE = "1.0";

    # Fontconfig cache
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
  };

  # System-wide font cache rebuild
  system.activationScripts.fonts = ''
    echo "Rebuilding font cache..."
    ${pkgs.fontconfig}/bin/fc-cache -f
  '';

  # Font-related services
  systemd.user.services.font-cache-update = {
    description = "Update user font cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.fontconfig}/bin/fc-cache -f";
    };
    wantedBy = [ "graphical-session.target" ];
  };

  # GTK font configuration
  programs.dconf.enable = true;

  # Font substitution for better rendering
  environment.etc."fonts/conf.d/10-nix-rendering.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>
      <!-- Enable sub-pixel rendering -->
      <match target="font">
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
      </match>

      <!-- Enable hinting -->
      <match target="font">
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
      </match>

      <!-- Set hinting style -->
      <match target="font">
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
      </match>

      <!-- Enable anti-aliasing -->
      <match target="font">
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
      </match>

      <!-- Disable auto-hinter for better fonts -->
      <match target="font">
        <edit name="autohint" mode="assign"><bool>false</bool></edit>
      </match>

      <!-- LCD filter -->
      <match target="font">
        <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
      </match>
    </fontconfig>
  '';

  # Font metrics configuration
  environment.etc."fonts/conf.d/30-nix-emoji.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>
      <!-- Emoji font fallback -->
      <alias binding="weak">
        <family>emoji</family>
        <default>
          <family>Noto Color Emoji</family>
        </default>
      </alias>

      <!-- Ensure emoji fonts are used for emoji -->
      <match target="pattern">
        <test name="family">
          <string>emoji</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Color Emoji</string>
        </edit>
      </match>
    </fontconfig>
  '';
}

# Add font-related groups (user groups defined in main configuration.nix)
