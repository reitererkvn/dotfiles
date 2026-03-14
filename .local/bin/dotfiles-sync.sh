#!/usr/bin/env bash

# Dynamische Allokation: Root zu Root Mapping
SRC="$HOME/.dotfiles"
DEST="$HOME"

# Verifikation der I/O-Quelle
if [ ! -d "$SRC" ]; then
    echo "Error: Source-File $SRC missing."
    exit 1
else
    echo "$SRC found, resuming..."
fi

# ==========================================
# PHASE 0: Pre-Flight Garbage Collection
# ==========================================
find "$DEST" -type l -xtype l -lname "$SRC/*" -printf '%P\n' | while read -r orphan; do
    echo "Garbage Collection: Removing orphaned symlinks $orphan"
    rm "$orphan"
done
echo "Done removing, resuming..."

# ==========================================
# PHASE 1: Topologische Replikation (Ignoriert .git)
# -name ".git" -prune blockiert das Betreten des Versionskontroll-Graphen
# ==========================================
find "$SRC" -mindepth 1 -name ".git" -prune -o -type d -printf '%P\n' |  while read -r relative_dir; do
    echo "Destined dir $DEST not found, creating $DEST/$relative_dir..."
    mkdir -p "$DEST/$relative_dir"
    echo "$DEST/$relative_dir created..."
done

# ==========================================
# PHASE 2: I/O-Mapping (Daten-Verlinkung, Ignoriert .git)
# ==========================================
find "$SRC" -mindepth 1 -name ".git" -prune -o -type f -printf '%P\n' | while read -r relative_file; do
    source_file="$SRC/$relative_file"
    target_link="$DEST/$relative_file"
    
    # Blockade-Prüfung gegen reelle Daten
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "Warning: target $target_link is not a symlink, skipping ..."
        continue
	    fi
	    
	    # Erzeuge/Überschreibe den Symlink
    ln -sfn "$source_file" "$target_link"
    echo "linked $source_file:$target_link"
done
echo "Done!"
