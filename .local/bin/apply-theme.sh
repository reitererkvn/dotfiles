#!/usr/bin/env bash

# 1. Basis-Daten laden (Source)
#
COLOR_FILE="$HOME/.config/uwsm/env.d/25-colors.sh"
# Alle Variablen ($BACKGROUND0, etc.) landen jetzt im RAM
source "$COLOR_FILE"

# 2. Verbesserte Hilfsfunktion (Akzeptiert 6- und 8-stellige Hex-Werte)
hex_to_rgba() {
    # Entferne das '#'
    local hex=$(echo "$1" | sed 's/#//')

    # RGB berechnen (Basis 16 zu Basis 10)
    local r=$(printf "%d" "0x${hex:0:2}")
    local g=$(printf "%d" "0x${hex:2:2}")
    local b=$(printf "%d" "0x${hex:4:2}")

    local a="1.0" # Standardwert: 100% Deckkraft

    # Wenn der Code 8 Zeichen hat (wie #000000CC), berechne den Alpha-Wert
    if [ ${#hex} -eq 8 ]; then
        local a_hex=${hex:6:2}
        local a_dec=$(printf "%d" "0x$a_hex")
        # Umrechnung von 0-255 in 0.0-1.0 (z.B. CC -> 204 -> 0.80)
        a=$(awk "BEGIN {printf \"%.2f\", $a_dec/255}")
    fi

    echo "rgba($r, $g, $b, $a)"
}

# 3. DIE MAGISCHE SCHLEIFE (Automatischer Export)
# 'cut' trennt am '=', 'sed' entfernt das 'export ' Präfix
var_list=$(grep "=" "$COLOR_FILE" | sed 's/export //g' | cut -d'=' -f1)

for var_name in $var_list; do
    # Hole den Hex-Wert der aktuellen Variable
    hex_value="${!var_name}"

    # Erzeuge einen neuen Variablennamen (z.B. BACKGROUND0_RGBA)
    rgba_name="${var_name}_RGBA"

    # Führe die Funktion aus und exportiere die RGBA-Variable dynamisch
    export "$rgba_name"="$(hex_to_rgba "$hex_value")"
    export "${var_name}_6"="#${hex_value:0:6}" # format: #000000
    export "${var_name}_8"="#${hex_value}" # format: #000000FF
done

# 4. envsubst auf die Template anwenden

templates=$(find "$HOME/.config/hypr/assets" -name "*colors.template*")

for template in $templates; do
    # Erzeugt den Zielnamen (entfernt ".template" aus dem Namen)
    target="${template/.template/}"
    envsubst < "$template" > "$target"
done

# 5. Signal-Reload
killall -SIGUSR2 waybar
hyprctl reload
systemctl --user restart hyprpaper.service
killall -SIGUSR1 kitty
