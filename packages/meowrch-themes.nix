{ lib, stdenv, fetchFromGitHub, python3, gtk3, qt5, papirus-icon-theme, bibata-cursors }:

stdenv.mkDerivation rec {
  pname = "meowrch-themes";
  version = "1.0.0";

  src = ../dotfiles/themes;

  nativeBuildInputs = [ ];

  buildInputs = [
    python3
    gtk3
    qt5.qtbase
    papirus-icon-theme
    bibata-cursors
  ];

  # Don't build, just copy themes
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Create theme directories
    mkdir -p $out/share/themes
    mkdir -p $out/share/icons
    mkdir -p $out/share/cursors
    mkdir -p $out/share/wallpapers
    mkdir -p $out/share/meowrch

    # Copy theme files if they exist
    if [ -d "themes" ]; then
      cp -r themes/* $out/share/themes/
    fi

    if [ -d "icons" ]; then
      cp -r icons/* $out/share/icons/
    fi

    if [ -d "cursors" ]; then
      cp -r cursors/* $out/share/cursors/
    fi

    if [ -d "wallpapers" ]; then
      cp -r wallpapers/* $out/share/wallpapers/
    fi

    # Create default Meowrch theme structure
    mkdir -p $out/share/themes/Meowrch-Dark/gtk-3.0
    mkdir -p $out/share/themes/Meowrch-Dark/gtk-4.0
    mkdir -p $out/share/themes/Meowrch-Light/gtk-3.0
    mkdir -p $out/share/themes/Meowrch-Light/gtk-4.0

    # Create default GTK theme files
    cat > $out/share/themes/Meowrch-Dark/gtk-3.0/gtk.css << 'EOF'
/* Meowrch Dark Theme - GTK3 */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");

/* Color definitions */
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
EOF

    cat > $out/share/themes/Meowrch-Light/gtk-3.0/gtk.css << 'EOF'
/* Meowrch Light Theme - GTK3 */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained.css");

/* Color definitions */
@define-color accent_color #89b4fa;
@define-color accent_bg_color #89b4fa;
@define-color accent_fg_color #ffffff;
@define-color destructive_color #f38ba8;
@define-color destructive_bg_color #f38ba8;
@define-color destructive_fg_color #ffffff;
@define-color success_color #a6e3a1;
@define-color success_bg_color #a6e3a1;
@define-color success_fg_color #000000;
@define-color warning_color #f9e2af;
@define-color warning_bg_color #f9e2af;
@define-color warning_fg_color #000000;
@define-color error_color #f38ba8;
@define-color error_bg_color #f38ba8;
@define-color error_fg_color #ffffff;
@define-color window_bg_color #ffffff;
@define-color window_fg_color #000000;
@define-color view_bg_color #fafafa;
@define-color view_fg_color #000000;
@define-color headerbar_bg_color #f0f0f0;
@define-color headerbar_fg_color #000000;
@define-color headerbar_border_color #d0d0d0;
@define-color headerbar_backdrop_color #ffffff;
@define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
@define-color card_bg_color #f5f5f5;
@define-color card_fg_color #000000;
@define-color card_shade_color rgba(0, 0, 0, 0.07);
@define-color dialog_bg_color #f5f5f5;
@define-color dialog_fg_color #000000;
@define-color popover_bg_color #f5f5f5;
@define-color popover_fg_color #000000;
@define-color shade_color rgba(0, 0, 0, 0.07);
@define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
EOF

    # Create theme index files
    cat > $out/share/themes/Meowrch-Dark/index.theme << 'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Meowrch Dark
Comment=A dark theme for the Meowrch desktop environment
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Meowrch-Dark
MetacityTheme=Meowrch-Dark
IconTheme=Papirus-Dark
CursorTheme=Bibata-Modern-Classic
ButtonLayout=appmenu:minimize,maximize,close
EOF

    cat > $out/share/themes/Meowrch-Light/index.theme << 'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Meowrch Light
Comment=A light theme for the Meowrch desktop environment
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Meowrch-Light
MetacityTheme=Meowrch-Light
IconTheme=Papirus
CursorTheme=Bibata-Modern-Classic
ButtonLayout=appmenu:minimize,maximize,close
EOF

    # Create Qt theme configuration
    mkdir -p $out/share/meowrch/qt
    cat > $out/share/meowrch/qt/dark.conf << 'EOF'
[Appearance]
color_scheme_path=$out/share/meowrch/qt/dark.colors
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=gtk2

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
general="Noto Sans,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

    cat > $out/share/meowrch/qt/light.conf << 'EOF'
[Appearance]
color_scheme_path=$out/share/meowrch/qt/light.colors
custom_palette=false
icon_theme=Papirus
standard_dialogs=default
style=gtk2

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
general="Noto Sans,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

    # Create color schemes
    cat > $out/share/meowrch/qt/dark.colors << 'EOF'
[ColorScheme]
active_colors=#ffcdd6f4, #ff313244, #ff45475a, #ff585b70, #ff6c7086, #ff7f849c, #ffcdd6f4, #ffffff, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ff000000, #ff313244, #ffcdd6f4, #80cdd6f4
disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff585b70, #ff6c7086, #ff7f849c, #ff6c7086, #ffffff, #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff45475a, #ff6c7086, #ff45475a, #fff38ba8, #ff313244, #ff000000, #ff313244, #ff6c7086, #806c7086
inactive_colors=#ffcdd6f4, #ff313244, #ff45475a, #ff585b70, #ff6c7086, #ff7f849c, #ffcdd6f4, #ffffff, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ff000000, #ff313244, #ffcdd6f4, #80cdd6f4
EOF

    cat > $out/share/meowrch/qt/light.colors << 'EOF'
[ColorScheme]
active_colors=#ff000000, #ffffffff, #ffeeeeee, #ffdddddd, #ffcccccc, #ffbbbbbb, #ff000000, #ffffff, #ff000000, #ffffffff, #fffafafa, #fff5f5f5, #ff89b4fa, #ffffffff, #ff89b4fa, #fff38ba8, #ffffffff, #ff000000, #ffffffff, #ff000000, #80000000
disabled_colors=#ff666666, #ffffffff, #ffeeeeee, #ffdddddd, #ffcccccc, #ffbbbbbb, #ff666666, #ffffff, #ff666666, #ffffffff, #fffafafa, #fff5f5f5, #ffeeeeee, #ff666666, #ffeeeeee, #fff38ba8, #ffffffff, #ff000000, #ffffffff, #ff666666, #80666666
inactive_colors=#ff000000, #ffffffff, #ffeeeeee, #ffdddddd, #ffcccccc, #ffbbbbbb, #ff000000, #ffffff, #ff000000, #ffffffff, #fffafafa, #fff5f5f5, #ff89b4fa, #ffffffff, #ff89b4fa, #fff38ba8, #ffffffff, #ff000000, #ffffffff, #ff000000, #80000000
EOF

    # Create default wallpapers if directory exists
    if [ ! -d "$out/share/wallpapers" ]; then
      mkdir -p $out/share/wallpapers/meowrch
      
      # Create a simple gradient wallpaper as fallback
      cat > $out/share/wallpapers/meowrch/default.svg << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1e1e2e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#313244;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#bg)"/>
  <text x="960" y="540" font-family="JetBrainsMono Nerd Font" font-size="48" text-anchor="middle" fill="#cdd6f4" opacity="0.8">Meowrch ≽ܫ≼</text>
</svg>
EOF
    fi

    # Create theme management scripts
    mkdir -p $out/bin
    cat > $out/bin/meowrch-theme-apply << 'EOF'
#!/usr/bin/env bash
# Meowrch theme application script

THEME_NAME="$1"
THEME_DIR="$out/share/themes/$THEME_NAME"

if [ ! -d "$THEME_DIR" ]; then
    echo "Theme '$THEME_NAME' not found!"
    exit 1
fi

# Apply GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME"

# Apply icon theme
if [[ "$THEME_NAME" == *"Dark"* ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
else
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
fi

# Apply Qt theme
if [[ "$THEME_NAME" == *"Dark"* ]]; then
    export QT_QPA_PLATFORMTHEME=qt5ct
    cp "$out/share/meowrch/qt/dark.conf" "$HOME/.config/qt5ct/qt5ct.conf"
    cp "$out/share/meowrch/qt/dark.conf" "$HOME/.config/qt6ct/qt6ct.conf"
else
    export QT_QPA_PLATFORMTHEME=qt5ct
    cp "$out/share/meowrch/qt/light.conf" "$HOME/.config/qt5ct/qt5ct.conf"
    cp "$out/share/meowrch/qt/light.conf" "$HOME/.config/qt6ct/qt6ct.conf"
fi

echo "Theme '$THEME_NAME' applied successfully!"
EOF

    chmod +x $out/bin/meowrch-theme-apply

    # Create theme listing script
    cat > $out/bin/meowrch-theme-list << 'EOF'
#!/usr/bin/env bash
# List available Meowrch themes

echo "Available Meowrch themes:"
for theme in $out/share/themes/Meowrch-*; do
    if [ -d "$theme" ]; then
        basename "$theme"
    fi
done
EOF

    chmod +x $out/bin/meowrch-theme-list

    runHook postInstall
  '';

  postInstall = ''
    # Create desktop entries for theme management
    mkdir -p $out/share/applications
    
    cat > $out/share/applications/meowrch-themes.desktop << 'EOF'
[Desktop Entry]
Name=Meowrch Themes
Comment=Manage Meowrch desktop themes
Exec=$out/bin/meowrch-theme-list
Icon=preferences-desktop-theme
Terminal=true
Type=Application
Categories=Settings;DesktopSettings;
EOF

    # Create symlinks for easier access
    mkdir -p $out/share/meowrch-themes
    ln -sf $out/share/themes $out/share/meowrch-themes/gtk
    ln -sf $out/share/meowrch/qt $out/share/meowrch-themes/qt
    ln -sf $out/share/wallpapers $out/share/meowrch-themes/wallpapers
    ln -sf $out/share/icons $out/share/meowrch-themes/icons
  '';

  meta = with lib; {
    description = "Meowrch desktop environment themes";
    longDescription = ''
      A comprehensive theme package for the Meowrch desktop environment.
      Includes GTK3/4 themes, Qt themes, icon themes, cursor themes,
      and wallpapers designed to provide a cohesive and beautiful
      desktop experience.
    '';
    homepage = "https://github.com/meowrch/meowrch";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}