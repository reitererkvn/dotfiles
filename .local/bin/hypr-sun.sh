#!/bin/bash
# Standort-Koordinaten: Wien
LAT="48.20N"
LON="16.30E"
SYMLINK="$HOME/.config/hypr/assets/images/WALLPAPER"

source "$HOME/.config/uwsm/env.d/00-hardware.sh"
source "$HOME/.config/uwsm/env.d/20-theme.sh"

# Schritt 1: Ist die Sonne RICHTIG oben?
SUN_STATUS=$(sunwait poll $LAT $LON)
# Schritt 2: Ist es zumindest DÄMMERIG (Civil)?
CIVIL_STATUS=$(sunwait poll civil $LAT $LON)
HOUR=$(date +%H)
SWITCHING_TIMES=$(sunwait list $LAT $LON && sunwait list civil $LAT $LON)

EVENT="Sun Status: $SUN_STATUS, Civil Status: $CIVIL_STATUS (normal/civil, Day/Night $SWITCHING_TIMES)"

echo "Aktuelles Event: $EVENT"

# Schritt 3: Die Logik-Matrix
if [ "$SUN_STATUS" = "DAY" ]; then
    WALLPAPER="$WALLPAPER0" # Heller Tag
elif [ "$CIVIL_STATUS" = "DAY" ]; then
    # Wenn hier DAY ist, aber oben NIGHT war -> Dämmerung!
    if [ "$HOUR" -lt 12 ]; then
        WALLPAPER="$WALLPAPER1" # Morgen
    else
        WALLPAPER="$WALLPAPER2" # Abend
    fi
else
    WALLPAPER="$WALLPAPER3" # Tiefe Nacht
fi

# checks if active Wallpaper and Symlink for hypridle are set correctly, if yes aborts the switch to avoid flickering

ACTIVE_WALLPAPER=$(hyprctl hyprpaper listactive | grep "$MONITOR1" | cut -d: -f2- | xargs)

if [[ "$(readlink -f "$SYMLINK")" == "$WALLPAPER" && "$ACTIVE_WALLPAPER" == "$WALLPAPER" ]]; then
    echo "[Info] Wallpaper already active and symlink correct ($WALLPAPER) --> skipping..."
    exit 0
fi

# 4. IPC-Befehle an hyprpaper (KEINE Kommentare mehr!)
if [[ -f "$WALLPAPER" ]]; then


    # Auf beiden Monitoren setzen (2560x1440)
    hyprctl hyprpaper wallpaper "$MONITOR1,$WALLPAPER,cover"
    #hyprctl hyprpaper wallpaper "$MONITOR2,$WALLPAPER,cover"

    # Symlink für andere Apps aktualisieren
    ln -sf "$WALLPAPER" "$SYMLINK"

else
    echo "FEHLER: Datei $WALLPAPER nicht gefunden!"
fi
