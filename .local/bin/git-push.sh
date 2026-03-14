#!/usr/bin/env bash
# dotsync - Synchronisiert User- und System-Dotfiles

echo "--- 📦 Starte Sync der Dualen Architektur ---"

# 1. User Dotfiles
echo "» Verarbeite ~/.dotfiles..."
cd ~/.dotfiles && git add . && git commit -m "Auto-Sync: $(date +'%Y-%m-%d %H:%M')" && git push

echo "--------------------------------------------"

# 2. System Dotfiles (Dank ACLs ohne sudo möglich!)
echo "» Verarbeite /opt/system-dotfiles..."
cd /opt/system-dotfiles && git add . && git commit -m "Auto-Sync: $(date +'%Y-%m-%d %H:%M')" && git push

echo "--- ✅ Architektur-Backup abgeschlossen! ---"
