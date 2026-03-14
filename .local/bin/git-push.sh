#!/usr/bin/env bash

SYNC_USER=false
SYNC_SYSTEM=false

# Flag-Verarbeitung
while getopts "us" opt; do
  case $opt in
    u) SYNC_USER=true ;;
    s) SYNC_SYSTEM=true ;;
    *) echo "Usage: $0 [-u] [-s]"; exit 1 ;;
  esac
done

# Wenn kein Parameter übergeben wurde, beides auf "true" setzen
if [ $OPTIND -eq 1 ]; then
    SYNC_USER=true
    SYNC_SYSTEM=true
fi

echo "--- 📦 Starting git commit & GitHub sync ---"

# 1. User Dotfiles
if [ "$SYNC_USER" = true ]; then
    echo "» Verarbeite ~/.dotfiles..."
    cd ~/.dotfiles && git add . && git commit -m "Auto-Sync: $(date +'%Y-%m-%d %H:%M')" && git push
fi

echo "--------------------------------------------"

# 2. System Dotfiles
if [ "$SYNC_SYSTEM" = true ]; then
    echo "» Verarbeite /opt/system-dotfiles..."
    cd /opt/system-dotfiles && git add . && git commit -m "Auto-Sync: $(date +'%Y-%m-%d %H:%M')" && git push
fi

echo "--- ✅ Sync done ---"
