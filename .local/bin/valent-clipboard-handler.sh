#!/bin/bash
# valent-clipboard-handler.sh
# Wird von wl-paste --watch aufgerufen, um das Wayland-Clipboard an Valent zu senden.

TEXT=$(cat)
if [ -z "$TEXT" ]; then
    exit 0
fi

# Endlosschleifen-Schutz (falls das Handy das Clipboard an den PC schickt, 
# soll der PC es nicht sofort wieder ans Handy zurückschicken)
LAST_FILE="/tmp/valent_last_clip"
if [ -f "$LAST_FILE" ]; then
    LAST_TEXT=$(cat "$LAST_FILE")
    if [ "$TEXT" = "$LAST_TEXT" ]; then
        exit 0
    fi
fi
echo "$TEXT" > "$LAST_FILE"

# Valent Device ID ermitteln
DEVICE_ID=$(busctl --user tree ca.andyholmes.Valent 2>/dev/null | grep -oP '(?<=/ca/andyholmes/Valent/Device/)[a-f0-9]+' | head -n 1)

if [ -n "$DEVICE_ID" ]; then
    busctl --user call ca.andyholmes.Valent /ca/andyholmes/Valent/Device/$DEVICE_ID org.gtk.Actions Activate sava{sv} "share.text" 1 "s" "$TEXT" 0
fi
