#!/usr/bin/env bash

SYNC_USER=false
SYNC_INFRA=false

# Flag-Verarbeitung
while getopts "ui" opt; do
  case $opt in
    u) SYNC_USER=true ;;
    i) SYNC_INFRA=true ;;
    *) echo "Usage: $0 [-u] [-i]"; exit 1 ;;
  esac
done

# Wenn kein Parameter übergeben wurde, beides auf "true" setzen
if [ $OPTIND -eq 1 ]; then
    SYNC_USER=true
    SYNC_INFRA=true
fi

echo "--- 📦 Starting git commit & GitHub sync ---"

# 1. User Dotfiles
if [ "$SYNC_USER" = true ]; then
    echo "» Verarbeite ~/.dotfiles..."
    cd ~/.dotfiles && git add . && oco --yes && git push
fi

echo "--------------------------------------------"

# 2. Infrastructure Monorepo
if [ "$SYNC_INFRA" = true ]; then
    echo "» Verarbeite /opt/infrastructure..."
    cd /opt/infrastructure && git add . && oco --yes && sudo -u kevin git push || git push
fi

echo "--- ✅ Sync done ---"
