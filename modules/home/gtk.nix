{ config, pkgs, lib, ... }:

{
  # GTK Configuration
  gtk = {
    enable = true;

    # Force overwrite existing config files to prevent activation errors
    gtk2.configLocation = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.bookmarks = let home = config.home.homeDirectory; in [
      "file://${home}/Documents"
      "file://${home}/Downloads"
      "file://${home}/Music"
      "file://${home}/Pictures"
      "file://${home}/Videos"
    ];

    # Default theme — pawlette will override via gsettings when switching themes.
    # pawlette themes are provided by the meowrch-themes package.
    theme = {
      name = lib.mkDefault "pawlette-catppuccin-mocha";
      package = lib.mkDefault pkgs.meowrch-themes;
    };

    # Papirus (without -Dark suffix) auto-follows color-scheme: dark → -Dark, light → regular
    iconTheme = {
      name = lib.mkDefault "Papirus-Dark";
      package = lib.mkDefault pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = lib.mkForce "Bibata-Modern-Classic";
      package = lib.mkForce pkgs.bibata-cursors;
      size = lib.mkForce 24;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk2.extraConfig = ''
      gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images = 1
      gtk-menu-images = 1
      gtk-enable-event-sounds = 0
      gtk-enable-input-feedback-sounds = 0
      gtk-xft-antialias = 1
      gtk-xft-hinting = 1
      gtk-xft-hintstyle = "hintfull"
      gtk-xft-rgba = "rgb"
    '';
    
    gtk3.extraConfig = {
      # DO NOT set gtk-application-prefer-dark-theme here — pawlette manages it via gsettings.
      # mocha sets prefer-dark, latte sets prefer-light at runtime.
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = true;
      gtk-menu-images = true;
      gtk-enable-event-sounds = false;
      gtk-enable-input-feedback-sounds = false;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
    };

    gtk3.extraCss = ''
      /* Structural styling only — NO color variables here! */
      /* Colors come from the active GTK theme (set by pawlette via gsettings). */
      /* Hardcoding colors here would override the latte theme with mocha colors. */

      /* Window decorations */
      decoration {
        border-radius: 12px;
        margin: 4px;
      }

      /* Rounded buttons */
      button {
        border-radius: 8px;
        transition: all 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
      }

      /* Rounded entries */
      entry {
        border-radius: 8px;
      }

      /* Slim scrollbars */
      scrollbar slider {
        border-radius: 10px;
        min-width: 6px;
        min-height: 6px;
      }

      /* Rounded menus */
      menu {
        border-radius: 8px;
      }

      /* Rounded tooltips */
      tooltip {
        border-radius: 8px;
      }
    '';

    gtk4.extraConfig = {
      # DO NOT set gtk-application-prefer-dark-theme here — pawlette manages it via gsettings.
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
    };

    gtk4.extraCss = ''
      /* Structural styling only — NO color variables here! */
      /* Colors come from the active GTK theme (set by pawlette via gsettings). */

      /* Rounded window decorations */
      window {
        border-radius: 12px;
      }

      /* Rounded headerbar */
      headerbar {
        border-radius: 12px 12px 0 0;
      }

      /* Rounded buttons */
      button {
        border-radius: 8px;
      }

      /* Rounded entries */
      entry {
        border-radius: 8px;
      }
    '';
  };

  # Force overwrite GTK config files to prevent activation failures
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."gtk-3.0/settings.ini".force = true;

  # GNOME dconf settings for GTK
  # IMPORTANT: color-scheme and gtk-theme are NOT set here — pawlette manages them
  # at runtime via gsettings. locking them here would break theme switching.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # cursor is safe to lock — pawlette uses the same Bibata-Modern-Classic
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      # fonts are theme-independent
      font-name = "Noto Sans 11";
      document-font-name = "Noto Sans 11";
      monospace-font-name = "JetBrainsMono Nerd Font 10";
      # DO NOT set color-scheme or icon-theme here — pawlette sets them per-theme:
      # mocha: prefer-dark + Papirus-Dark + adw-gtk3-dark
      # latte: prefer-light + pawlette-catppuccin-latte + adw-gtk3 (light)
      enable-animations = true;
      gtk-enable-primary-paste = false;
      locate-pointer = true;
      show-battery-percentage = true;
      clock-show-seconds = false;
      clock-show-weekday = true;
      font-antialiasing = "rgba";
      font-hinting = "slight";
    };
    
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Noto Sans Bold 11";
      button-layout = "appmenu:minimize,maximize,close";
    };
    
    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = false;
      input-feedback-sounds = false;
    };
    
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = 4000;
      night-light-schedule-automatic = true;
    };
    
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
  };

  # Additional packages for GTK theming
  home.packages = with pkgs; [
    # GTK tools
    glib
    gsettings-desktop-schemas

    # NOTE: papirus-icon-theme is in environment.systemPackages (theming.nix).
    # Do NOT add it here — catppuccin-nix adds catppuccin-papirus-folders which
    # also ships Papirus icons and would cause a buildEnv conflict.
    adwaita-icon-theme

    # GTK dev libs (needed for palette/theming scripts)
    gtk3
    gtk4

    # Theme tools
    lxappearance
    nwg-look
  ];

  # Environment variables for GTK
  home.sessionVariables = {
    # ADW_DEBUG_COLOR_SCHEME intentionally NOT set here:
    # libadwaita apps will follow the org.gnome.desktop.interface color-scheme gsetting
    # which pawlette sets to 'prefer-dark' (mocha) or 'prefer-light' (latte).
    GTK2_RC_FILES = lib.mkForce "${config.home.homeDirectory}/.gtkrc-2.0";

    # Enable Wayland for GTK apps
    GDK_BACKEND = "wayland,x11";

    # GTK scaling
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    # NOTE: XCURSOR_THEME/SIZE set by home.pointerCursor + hyprland.nix
    # NOTE: HYPRCURSOR_THEME/SIZE set by home.pointerCursor (hyprcursor.enable = true)
  };

}
