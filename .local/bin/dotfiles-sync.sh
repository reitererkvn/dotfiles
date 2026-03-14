#!/usr/bin/env bash

# Dynamische Allokation: Root zu Root Mapping
SRC="$HOME/.dotfiles"
DEST="$HOME"

# Verifikation der I/O-Quelle
if [ ! -d "$SRC" ]; then
    echo "Fehler: Quell-Verzeichnis $SRC fehlt im Dateisystem."
    exit 1
fi

# ==========================================
# PHASE 0: Pre-Flight Garbage Collection
# ==========================================
find "$DEST" -type l -xtype l -lname "$SRC/*" -print | while read -r orphan; do
    echo "Garbage Collection: Entferne verwaisten Knoten $orphan"
    rm "$orphan"
done

# ==========================================
# PHASE 1: Topologische Replikation (Ignoriert .git)
# -name ".git" -prune blockiert das Betreten des Versionskontroll-Graphen
# ==========================================
find "$SRC" -mindepth 1 -name ".git" -prune -o -type d -printf '%P\n' | while read -r relative_dir; do
    mkdir -p "$DEST/$relative_dir"
done

# ==========================================
# PHASE 2: I/O-Mapping (Daten-Verlinkung, Ignoriert .git)
	# ==========================================
find "$SRC" -mindepth 1 -name ".git" -prune -o -type f -printf '%P\n' | while read -r relative_file; do
    source_file="$SRC/$relative_file"
    target_link="$DEST/$relative_file"
    
    # Blockade-Prüfung gegen reelle Daten
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "Konflikt: Reale Datenstruktur blockiert Symlink bei $target_link"
        continue
	    fi
	    
	    # Erzeuge/Überschreibe den Symlink
    ln -sfn "$source_file" "$target_link"
done
