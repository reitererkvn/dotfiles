#!/usr/bin/env bash

# Dynamische Pfadauflösung im Arbeitsspeicher
SYNC_SCRIPT="$HOME/dotfiles-sync.sh"

# Bedingte I/O-Ausführung: Nur synchronisieren, wenn das Skript physisch existiert
if [ -f "$SYNC_SCRIPT" ]; then
    /bin/bash "$SYNC_SCRIPT"
fi

# Speicher-Austausch zur Wahrung der PID-Hierarchie
exec uwsm start hyprland-uwsm.desktop
