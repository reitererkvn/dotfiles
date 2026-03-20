#!/bin/sh

# Monitor settings
export MONITOR1="DP-2"
export MONITOR2="DP-3"
export RES1="2560x1440" # Resolution Monitor 1
export RES2="2560x1440" # Resolution Monitor 2
export RFR1="144" # Refreshrate Monitor 1
export RFR2="60" # Refreshrate Monitor 2
export MPOS1="0x0" # Offset Monitor 1
export MPOS2="2560x0" # Offset Monitor 2

# GPU settings (nvidia only)
export LIBVA_DRIVER_NAME="nvidia"
export NVD_BACKEND="direct"
export XDG_SESSION_TYPE=wayland
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
