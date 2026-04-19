#!/bin/sh

# Theming & Mauszeiger
export XCURSOR_SIZE=24
export HYPRCURSOR_SIZE=24
export XCURSOR_THEME="Bibata-Modern-Classic"
export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export GTK_THEME="Adwaita:dark"
export FONT="FiraMono Nerd Font"
export GTK_ICON_THEME_NAME="Papirus-Dark"

# Qt-Architektur (Deaktiviert CSD-Schatten für sauberes Hyprland-Rendering)
export QT_QPA_PLATFORMTHEME=hyprqt6engine
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Wallpapers
export WALLPAPER0="$HOME/Bilder/wallpapers/Forest1-uw.png" # day
export WALLPAPER1="$HOME/Bilder/wallpapers/Archive_desktop/Forest 3 uw.png" # sunrise
export WALLPAPER2="$HOME/Bilder/wallpapers/Archive_desktop/Forest 2 uw.png" # sunset
export WALLPAPER3="$HOME/Bilder/wallpapers/Wallpaper 4 5120x1440.png" # night
