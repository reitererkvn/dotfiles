#!/bin/sh

# Theming & Mauszeiger
export XCURSOR_SIZE=24
export HYPRCURSOR_SIZE=24
export XCURSOR_THEME="Bibata-Modern-Classic"
export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export GTK_THEME="Adwaita:dark"

# Qt-Architektur (Deaktiviert CSD-Schatten für sauberes Hyprland-Rendering)
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Dynamische Assets & Basis-Farben
export WALLPAPER0="$HOME/.config/hypr/assets/wallpapers/Forest1.png"
