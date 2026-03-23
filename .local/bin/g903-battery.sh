#!/bin/bash

# Stderr-Leak blockieren
exec 2>/dev/null

# Persistenter Speicher im RAM
CACHE_CAP="0"
CACHE_STAT="Unknown"

print_battery() {
    DEVICE=""

    # 1. Dynamischer Scan
    for dev in $(upower -e | grep hidpp_battery); do
        if upower -i "$dev" | grep -q "percentage"; then
            DEVICE="$dev"
            break
        fi
    done

    # 2. Daten-Extraktion & Cache Update
    if [ -n "$DEVICE" ]; then
        CUR_CAP=$(upower -i "$DEVICE" | awk '/percentage/ {print $2}' | tr -d '% \n\r')
        CUR_STAT=$(upower -i "$DEVICE" | awk '/state/ {print $2}' | tr -d '\n\r')

        if [ -n "$CUR_CAP" ]; then
            CACHE_CAP="$CUR_CAP"
            CACHE_STAT="$CUR_STAT"
        fi
    else
        # HARDWARE-LÜCKE DETEKTIERT (Kabel gezogen, Dongle lädt noch)
        # Wir überschreiben den Akku NICHT, markieren aber den Status
        CACHE_STAT="transition"
    fi

    # 3. Cold-Boot Fallback (Wenn der Rechner startet und die Maus wirklich aus ist)
    if [ "$CACHE_CAP" = "0" ]; then
        printf '{"text": "󰂲 Offline", "tooltip": "Maus nicht verbunden", "class": "disconnected"}\n'
        return
    fi

    # 4. Logik-Gate für Icons & CSS
    if [ "$CACHE_STAT" = "charging" ] || [ "$CACHE_STAT" = "fully-charged" ]; then
        ICON="󰂄"
        CLASS="charging"
    elif [ "$CACHE_CAP" -le 15 ]; then
        ICON="󰀰"
        CLASS="critical"
    elif [ "$CACHE_CAP" -le 45 ]; then
        ICON="󰁾"
        CLASS="warning"
    else
        ICON="󰁹"
        CLASS="normal"
    fi

    # Tooltip-Routing
    if [ "$CACHE_STAT" = "transition" ]; then
        TOOLTIP="Hardware Handshake..."
    else
        TOOLTIP="G903: $CACHE_STAT"
    fi

    # Deterministischer Output
    printf '{"text": "%s %s%%", "tooltip": "%s", "class": "%s"}\n' "$ICON" "$CACHE_CAP" "$TOOLTIP" "$CLASS"
}

# Initialer Render-Vorgang
print_battery

# Event-Driven Loop mit Delay-Injektion
upower --monitor | while read -r line; do
    if echo "$line" | grep -q "hidpp_battery"; then
        # DER FIX: Wir geben der CPU und dem USB-Bus 1,5 Sekunden Zeit,
        # das neue Gerät vollständig zu mounten, bevor wir die Daten abfragen.
        sleep 1.5
        print_battery
    fi
done
