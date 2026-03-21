#!/bin/bash

# Telemetrie-Log
exec > /tmp/hypr-lazy.log 2>&1
sleep 2

# 1. Die Konfigurations-Matrix (Assoziatives Array)
declare -A LAZY_MAP

# --- DEINE PLUGINS HIER EINTRAGEN ---
# Syntax: LAZY_MAP["<Socket-Signal-Präfix>"]="[workspace <ziel> silent] <befehl>"

# Plugin A: htop & nvtop auf dem Special-Monitor
LAZY_MAP["createworkspace>>special:monitor"]="sh -c 'hyprctl dispatch exec \"[workspace special:monitor silent] uwsm app -- kitty -e htop\" && hyprctl dispatch exec \"[workspace special:monitor silent] uwsm app -- kitty -e nvtop\"'"

# Plugin B: Discord auf Workspace 4 (Beispiel für einen normalen Workspace)
#LAZY_MAP["workspace>>4"]="[workspace 4 silent] uwsm app --Vesktop"

# Plugin C: Spotify auf Workspace 5 (Beispiel)
#LAZY_MAP["workspace>>5"]="[workspace 5 silent] uwsm app -- spotify"
# ------------------------------------

echo "Initialisiere modularen Listener für ${#LAZY_MAP[@]} Workspaces..."

# 2. Den UNIX-Socket abhören
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r event; do

    # 3. Das Event gegen unsere Matrix prüfen
    for trigger in "${!LAZY_MAP[@]}"; do

        # Die Messung: Beginnt das Event mit unserem definierten Trigger?
        if [[ "$event" == "$trigger"* ]]; then
            echo "Signal erfasst: $trigger -> Injiziere App..."

            # Befehl ausführen
            hyprctl dispatch exec "${LAZY_MAP[$trigger]}"

            # 4. Ressourcen-Freigabe (Eintrag aus dem RAM löschen)
            unset LAZY_MAP["$trigger"]

            # 5. Selbstzerstörung, wenn die Matrix leer ist
            if [[ ${#LAZY_MAP[@]} -eq 0 ]]; then
                echo "Alle Lazy-Load-Module gestartet. Beende Daemon."
                exit 0
            fi

            # Event wurde verarbeitet, Schleife für dieses Event abbrechen
            break
        fi
    done
done
