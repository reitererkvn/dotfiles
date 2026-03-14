#!/bin/bash
WATCH_LIST="$HOME/.config/rclone/inotify-watch.txt"
CLOUD_ROOT="gdrive:backups/live"


# --- NEU: PFADE EINLESEN ---
# Ohne diesen Block bleibt VALID_PATHS leer und das Skript bricht ab.
VALID_PATHS=()
if [[ -f "$WATCH_LIST" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Entferne Kommentare und Leerzeichen
        clean_path=$(echo "$line" | sed 's/#.*//' | xargs)
        if [[ -n "$clean_path" ]]; then
            VALID_PATHS+=("$clean_path")
        fi
    done < "$WATCH_LIST"
else
    echo "[Fehler] $WATCH_LIST nicht gefunden!"
    exit 1
fi

# Sicherheitscheck
if [ ${#VALID_PATHS[@]} -eq 0 ]; then
    echo "[Fehler] Keine gültigen Pfade in $WATCH_LIST gefunden."
    exit 1
fi

# --- PHASE 1: INITIALER SYNC ---
echo "[System] Baseline-Sync startet..."
for p in "${VALID_PATHS[@]}"; do
    if [ ! -e "$p" ]; then
        echo "[Warnung] Pfad existiert nicht: $p"
        continue
    fi
    echo "[Sync] Initialisiere: $p"
    if [ -d "$p" ]; then
        rclone sync "$p" "${CLOUD_ROOT}${p}" -l --fast-list --bwlimit 15M
    else
        rclone copy "$p" "${CLOUD_ROOT}$(dirname "$p")" -l
    fi
done
echo "[System] Baseline-Sync abgeschlossen."

# --- PHASE 2: ECHTZEIT ---
echo "[System] Inotify-Überwachung aktiv..."
inotifywait -m -r -q -e modify,create,delete,move --format "%w%f" "${VALID_PATHS[@]}" | \
while read -r FULL_EVENT_PATH; do
    echo "[Event] Änderung an: $FULL_EVENT_PATH"
    
    # Debounce, damit der i7-7700K bei schnellen Schreibvorgängen nicht überlastet
    sleep 2

    if [ -f "$FULL_EVENT_PATH" ]; then
        REL_DIR=$(dirname "$FULL_EVENT_PATH")
        rclone copy "$FULL_EVENT_PATH" "${CLOUD_ROOT}${REL_DIR}" -l
    elif [ -d "$FULL_EVENT_PATH" ]; then
        rclone sync "$FULL_EVENT_PATH" "${CLOUD_ROOT}${FULL_EVENT_PATH}" -l --fast-list
    fi
done

