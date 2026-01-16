{ config, pkgs, ... }:

{
  # GTK Configuration
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    
    font = {
      name = "Noto Sans";
      size = 11;
    };
    
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = true
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
      gtk-application-prefer-dark-theme = true;
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
      /* Catppuccin Mocha GTK Theme */
      @define-color accent_color #89b4fa;
      @define-color accent_bg_color #89b4fa;
      @define-color accent_fg_color #1e1e2e;
      @define-color destructive_color #f38ba8;
      @define-color destructive_bg_color #f38ba8;
      @define-color destructive_fg_color #1e1e2e;
      @define-color success_color #a6e3a1;
      @define-color success_bg_color #a6e3a1;
      @define-color success_fg_color #1e1e2e;
      @define-color warning_color #f9e2af;
      @define-color warning_bg_color #f9e2af;
      @define-color warning_fg_color #1e1e2e;
      @define-color error_color #f38ba8;
      @define-color error_bg_color #f38ba8;
      @define-color error_fg_color #1e1e2e;
      @define-color window_bg_color #1e1e2e;
      @define-color window_fg_color #cdd6f4;
      @define-color view_bg_color #181825;
      @define-color view_fg_color #cdd6f4;
      @define-color headerbar_bg_color #313244;
      @define-color headerbar_fg_color #cdd6f4;
      @define-color headerbar_border_color #45475a;
      @define-color headerbar_backdrop_color #1e1e2e;
      @define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
      @define-color card_bg_color #313244;
      @define-color card_fg_color #cdd6f4;
      @define-color card_shade_color rgba(0, 0, 0, 0.07);
      @define-color dialog_bg_color #313244;
      @define-color dialog_fg_color #cdd6f4;
      @define-color popover_bg_color #313244;
      @define-color popover_fg_color #cdd6f4;
      @define-color shade_color rgba(0, 0, 0, 0.07);
      @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
      
      /* Window decorations */
      decoration {
        border-radius: 12px;
        margin: 4px;
        box-shadow: 0 3px 9px 1px rgba(0, 0, 0, 0.5);
      }
      
      /* Headerbar styling */
      headerbar {
        background: @headerbar_bg_color;
        color: @headerbar_fg_color;
        border-radius: 12px 12px 0 0;
        box-shadow: inset 0 1px rgba(255, 255, 255, 0.1);
      }
      
      headerbar:backdrop {
        background: @headerbar_backdrop_color;
      }
      
      /* Button styling */
      button {
        border-radius: 8px;
        transition: all 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
      }
      
      button:hover {
        background: alpha(@accent_color, 0.1);
      }
      
      button.suggested-action {
        background: @accent_bg_color;
        color: @accent_fg_color;
      }
      
      button.destructive-action {
        background: @destructive_bg_color;
        color: @destructive_fg_color;
      }
      
      /* Entry styling */
      entry {
        border-radius: 8px;
        background: @view_bg_color;
        color: @view_fg_color;
        border: 1px solid alpha(@accent_color, 0.3);
      }
      
      entry:focus {
        border-color: @accent_color;
        box-shadow: 0 0 0 2px alpha(@accent_color, 0.3);
      }
      
      /* Scrollbar styling */
      scrollbar slider {
        border-radius: 10px;
        background: alpha(@accent_color, 0.5);
        min-width: 6px;
        min-height: 6px;
      }
      
      scrollbar slider:hover {
        background: alpha(@accent_color, 0.7);
      }
      
      /* Switch styling */
      switch {
        border-radius: 14px;
        background: @view_bg_color;
        border: 1px solid alpha(@accent_color, 0.3);
      }
      
      switch:checked {
        background: @accent_bg_color;
      }
      
      switch slider {
        border-radius: 50%;
        background: white;
        margin: 2px;
      }
      
      /* Progress bar styling */
      progressbar progress {
        background: @accent_bg_color;
        border-radius: 4px;
      }
      
      progressbar trough {
        background: @view_bg_color;
        border-radius: 4px;
      }
      
      /* Menu styling */
      menu {
        background: @popover_bg_color;
        color: @popover_fg_color;
        border-radius: 8px;
        border: 1px solid alpha(@accent_color, 0.2);
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
      }
      
      menuitem {
        border-radius: 4px;
        padding: 8px 12px;
      }
      
      menuitem:hover {
        background: alpha(@accent_color, 0.1);
      }
      
      /* Tooltip styling */
      tooltip {
        background: @popover_bg_color;
        color: @popover_fg_color;
        border-radius: 8px;
        border: 1px solid alpha(@accent_color, 0.2);
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
      }
      
      /* Notebook (tab) styling */
      notebook > header {
        background: @headerbar_bg_color;
        border-radius: 8px 8px 0 0;
      }
      
      notebook > header > tabs > tab {
        border-radius: 6px 6px 0 0;
        padding: 8px 16px;
        background: transparent;
        color: alpha(@headerbar_fg_color, 0.7);
      }
      
      notebook > header > tabs > tab:checked {
        background: @view_bg_color;
        color: @view_fg_color;
      }
      
      /* Sidebar styling */
      .sidebar {
        background: @view_bg_color;
        color: @view_fg_color;
        border-radius: 0 0 0 12px;
      }
      
      .sidebar row {
        border-radius: 6px;
        margin: 2px 6px;
      }
      
      .sidebar row:selected {
        background: alpha(@accent_color, 0.2);
      }
    '';
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
    };
    
    gtk4.extraCss = ''
      /* GTK4 Catppuccin Mocha Theme */
      @define-color accent_color #89b4fa;
      @define-color accent_bg_color #89b4fa;
      @define-color accent_fg_color #1e1e2e;
      @define-color window_bg_color #1e1e2e;
      @define-color window_fg_color #cdd6f4;
      @define-color view_bg_color #181825;
      @define-color view_fg_color #cdd6f4;
      @define-color headerbar_bg_color #313244;
      @define-color headerbar_fg_color #cdd6f4;
      @define-color card_bg_color #313244;
      @define-color card_fg_color #cdd6f4;
      
      window {
        background: @window_bg_color;
        color: @window_fg_color;
      }
      
      headerbar {
        background: @headerbar_bg_color;
        color: @headerbar_fg_color;
        border-radius: 12px 12px 0 0;
      }
      
      button {
        border-radius: 8px;
      }
      
      button.suggested-action {
        background: @accent_bg_color;
        color: @accent_fg_color;
      }
      
      entry {
        border-radius: 8px;
        background: @view_bg_color;
        color: @view_fg_color;
      }
    '';
  };

  # GNOME dconf settings for GTK
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      font-name = "Noto Sans 11";
      document-font-name = "Noto Sans 11";
      monospace-font-name = "JetBrainsMono Nerd Font 10";
      color-scheme = "prefer-dark";
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
      theme = "Adwaita-dark";
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

  # Home files for GTK configuration
  home.file = {
    ".gtkrc-2.0".text = ''
      gtk-theme-name="Adwaita-dark"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-cursor-theme-name="Bibata-Modern-Classic"
      gtk-cursor-theme-size=24
      gtk-font-name="Noto Sans 11"
      gtk-application-prefer-dark-theme=1
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=1
      gtk-menu-images=1
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintfull"
      gtk-xft-rgba="rgb"
    '';

    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-theme-name=Adwaita-dark
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-font-name=Noto Sans 11
      gtk-decoration-layout=appmenu:minimize,maximize,close
      gtk-enable-primary-paste=false
      gtk-recent-files-max-age=30
      gtk-recent-files-enabled=true
    '';
  };

  # Additional packages for GTK theming
  home.packages = with pkgs; [
    # GTK tools
    glib
    gsettings-desktop-schemas
    
    # Theme packages
    adwaita-icon-theme
    papirus-icon-theme
    bibata-cursors
    
    # GTK applications for testing
    gtk3
    gtk4
    
    # Theme tools
    lxappearance
    nwg-look
  ];

  # Environment variables for GTK
  home.sessionVariables = {
    # GTK theme variables
    GTK_THEME = "Adwaita:dark";
    GTK2_RC_FILES = "$HOME/.gtkrc-2.0";
    
    # Cursor theme
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    
    # Enable Wayland for GTK apps
    GDK_BACKEND = "wayland,x11";
    
    # GTK scaling
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };
}