#!/bin/bash
# gemini-sync-docs.sh
# Synchronisiert die zentrale GEMINI.md über alle relevanten Repositories.

SOURCE_GEMINI="/home/kevin/.dotfiles/GEMINI.md"
TARGETS=(
    "/opt/system-dotfiles/GEMINI.md"
    "nas-01:/opt/system-dotfiles/GEMINI.md"
)

echo "[+] Starte Dokumentations-Sync (GEMINI.md)..."

for target in "${TARGETS[@]}"; do
    if [[ "$target" == nas-01:* ]]; then
        echo "[+] Sync zu NAS: $target"
        scp "$SOURCE_GEMINI" "$target"
    else
        echo "[+] Sync lokal: $target"
        sudo cp "$SOURCE_GEMINI" "$target"
    fi
done

echo "[+] Sync abgeschlossen."
