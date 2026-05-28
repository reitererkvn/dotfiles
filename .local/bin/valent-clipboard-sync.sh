#!/bin/bash
# valent-clipboard-sync.sh
# Push current Wayland clipboard to Valent via D-Bus (Workaround for GTK background limitations)

# Kurze Verzögerung, damit die eigentliche App (z.B. Terminal oder Browser) 
# Zeit hat, den Text ins Wayland-Clipboard zu schreiben.
sleep 0.2

TEXT=$(wl-paste 2>/dev/null)

# Wenn nichts im Clipboard ist, brechen wir ab.
if [ -z "$TEXT" ]; then
    exit 0
fi

# Finde die Device ID dynamisch heraus (nimmt das erste verfügbare Valent-Gerät)
DEVICE_ID=$(busctl --user tree ca.andyholmes.Valent 2>/dev/null | grep -oP '(?<=/ca/andyholmes/Valent/Device/)[a-f0-9]+' | head -n 1)

if [ -n "$DEVICE_ID" ]; then
    # Sende den Text via "share.text" Action an das Handy
    busctl --user call ca.andyholmes.Valent /ca/andyholmes/Valent/Device/$DEVICE_ID org.gtk.Actions Activate sava{sv} "share.text" 1 "s" "$TEXT" 0
fi
