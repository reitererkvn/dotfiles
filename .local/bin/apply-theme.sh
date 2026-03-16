#!/usr/bin/env bash

# 1. Basis-Daten laden (Source)
# Alle Variablen ($BACKGROUND0, etc.) landen jetzt im RAM
source "$HOME/.config/uwsm/env.d/25-colors.sh"

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
# Wir scannen den RAM nach Variablen, die mit BACKGROUND, BORDER, TEXT oder ICON beginnen
for var_name in $(compgen -v | grep -E '^(BACKGROUND|BORDER|TEXT|ICON)'); do
    # Hole den Hex-Wert der aktuellen Variable
    hex_value="${!var_name}"

    # Erzeuge einen neuen Variablennamen (z.B. BACKGROUND0_RGBA)
    rgba_name="${var_name}_RGBA"

    # Führe die Funktion aus und exportiere die RGBA-Variable dynamisch
    export "$rgba_name"="$(hex_to_rgba "$hex_value")"
done

# 4. envsubst auf das Template anwenden
envsubst < "$HOME/.config/hypr/assets/colors.template.css" > "$HOME/.config/hypr/assets/colors.css"
envsubst < "$HOME/.config/hypr/assets/mako-colors.template" > "$HOME/.config/hypr/assets/mako-colors"
envsubst < "$HOME/.config/hypr/assets/kitty-colors.template" > "$HOME/.config/hypr/assets/kitty-colors"
# 5. Signal-Reload
killall -SIGUSR2 waybar
hyprctl reload
killall -SIGUSR1 kitty
