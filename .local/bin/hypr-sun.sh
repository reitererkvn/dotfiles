#!/bin/bash
# Standort-Koordinaten: Wien
LAT="48.20N"
LON="16.30E"

source "$HOME/.config/uwsm/env.d/00-hardware.sh"
source "$HOME/.config/uwsm/env.d/20-theme.sh"

# Schritt 1: Ist die Sonne RICHTIG oben?
SUN_STATUS=$(sunwait poll $LAT $LON)
# Schritt 2: Ist es zumindest DÄMMERIG (Civil)?
CIVIL_STATUS=$(sunwait poll civil $LAT $LON)
HOUR=$(date +%H)

echo "Aktuelles Event: $EVENT (Stunde: $HOUR)"

# Schritt 3: Die Logik-Matrix
if [ "$SUN_STATUS" = "DAY" ]; then
    WALLPAPER="$WALLPAPER0" # Heller Tag
elif [ "$CIVIL_STATUS" = "DAY" ]; then
    # Wenn hier DAY ist, aber oben NIGHT war -> Dämmerung!
    if [ "$HOUR" -lt 12 ]; then
        WALLPAPER="$WALLPAPER2" # Morgen
    else
        WALLPAPER="$WALLPAPER1" # Abend
    fi
else
    WALLPAPER="$WALLPAPER3" # Tiefe Nacht
fi

# 4. IPC-Befehle an hyprpaper (KEINE Kommentare mehr!)
if [[ -f "$WALLPAPER" ]]; then


    # Auf beiden Monitoren setzen (2560x1440)
    hyprctl hyprpaper wallpaper "$MONITOR1,$WALLPAPER,cover"
    hyprctl hyprpaper wallpaper "$MONITOR2,$WALLPAPER,cover"

    # Symlink für andere Apps aktualisieren
    ln -sf "$WALLPAPER" "$HOME/.config/hypr/WALLPAPER"

else
    echo "FEHLER: Datei $WALLPAPER nicht gefunden!"
fi
