#!/bin/sh

# Identität & Git-Umgebung
export USER="kevin"
export MAIL="reitererkvn@gmail.com"
export GIT_AUTHOR_NAME="Kevin"
export GIT_AUTHOR_EMAIL="reitererkvn@gmail.com"
export GIT_COMMITTER_NAME="Kevin"
export GIT_COMMITTER_EMAIL="reitererkvn@gmail.com"

# Grafik-Backends & Protokolle
export GDK_BACKEND="wayland,x11,*"
export QT_QPA_PLATFORM="wayland;xcb"
export CLUTTER_BACKEND="wayland"
export QT_QPA_PLATFORMTHEME="qt6ct"

# Proton Wayland driver (only which cahchyOS Proton)
export PROTON_ENABLE_WAYLAND=1
