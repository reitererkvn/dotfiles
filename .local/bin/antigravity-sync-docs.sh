#!/bin/bash
# antigravity-sync-docs.sh
# Synchronisiert die zentrale ANTIGRAVITY.md über alle relevanten Repositories.

SOURCE_ANTIGRAVITY="/home/kevin/.dotfiles/ANTIGRAVITY.md"
TARGETS=(
    "/opt/system-dotfiles/ANTIGRAVITY.md"
    "nas-01:/opt/system-dotfiles/ANTIGRAVITY.md"
)

echo "[+] Starte Dokumentations-Sync (ANTIGRAVITY.md)..."

for target in "${TARGETS[@]}"; do
    if [[ "$target" == nas-01:* ]]; then
        echo "[+] Sync zu NAS: $target"
        scp "$SOURCE_ANTIGRAVITY" "$target"
    else
        echo "[+] Sync lokal: $target"
        sudo cp "$SOURCE_ANTIGRAVITY" "$target"
    fi
done

echo "[+] Sync abgeschlossen."
