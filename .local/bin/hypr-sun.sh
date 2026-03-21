#!/bin/bash
# Standort-Koordinaten
LAT="48.20N"
LON="16.30E"

source "$HOME/.config/uwsm/env.d/00-hardware.sh"
source "$HOME/.config/uwsm/env.d/20-theme.sh"

# Aktuelle Zeit und Sonnenereignisse via 'sunwait' oder Web-API
# Wir nutzen hier eine einfache Logik basierend auf 'sunwait' (im AUR verfügbar)
NEXT_EVENT=$(sunwait poll $LAT $LON)

if sunwait poll $LAT $LON; then
    # Die Sonne ist SICHTBAR
    WALLPAPER="$WALLPAPER0" # DAY
else
    # Die Sonne ist UNTER dem Horizont
    if sunwait poll civil $LAT $LON; then
        # Es ist hell genug für zivile Aktivitäten (Dämmerung)
        # Hier entscheiden wir anhand der Uhrzeit: Morgen oder Abend?
        HOUR=$(date +%H)
        if [ $HOUR -lt 12 ]; then
            WALLPAPER="$WALLPAPER1" # SUNRISE / MORNING
        else
            WALLPAPER="$WALLPAPER2" # SUNSET / EVENING
        fi
    else
        WALLPAPER="$WALLPAPER3" # NIGHT
    fi
fi

# Update via hyprctl (hyprpaper muss laufen)
#hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "$MONITOR1, $WALLPAPER, cover"
hyprctl hyprpaper wallpaper "$MONITOR2, $WALLPAPER, cover"
# Ressourcen-Management: Alten Cache leeren
#hyprctl hyprpaper unload all
