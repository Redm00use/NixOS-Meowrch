#!/bin/sh

# Using .Xresources for X11 applications
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Set the border colors for focused and normal windows
bspc config focused_border_color "#7287fd"
bspc config border_width 3
bspc config borderless_monocle true

# Configure gaps and window gap size
bspc config gapless_monocle false
bspc config window_gap 10

# Set color scheme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

# Set gtk theme
gsettings set org.gnome.desktop.interface gtk-theme 'pawlette-catppuccin-latte'

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'pawlette-catppuccin-latte'

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'pawlette-catppuccin-latte'
gsettings set org.gnome.desktop.interface cursor-size 20

# Use the cursor for X11 (if necessary)
xsetroot -cursor_name left_ptr