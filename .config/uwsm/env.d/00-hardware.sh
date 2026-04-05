#!/bin/sh

# Monitor settings
export MONITOR1="DP-3"
#export MONITOR2="DP-2"
export RES1="5120x1440" # Resolution Monitor 1
#export RES2="2560x1440" # Resolution Monitor 2
export RFR1="120" # Refreshrate Monitor 1
#export RFR2="60" # Refreshrate Monitor 2
export MPOS1="0x0" # Offset Monitor 1 (divide by scaling)
#export MPOS2="2048x0" # Offset Monitor 2 (divide by scaling)

# GPU settings (nvidia only)
export LIBVA_DRIVER_NAME="nvidia"
export NVD_BACKEND="direct"
export XDG_SESSION_TYPE=wayland
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
