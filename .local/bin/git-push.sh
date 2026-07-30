#!/usr/bin/env bash

SYNC_USER=false
SYNC_SYSTEM=false
SYNC_NAS01=false

# Flag-Verarbeitung
while getopts "usn" opt; do
  case $opt in
    u) SYNC_USER=true ;;
    s) SYNC_SYSTEM=true ;;
    n) SYNC_NAS01=true ;;
    *) echo "Usage: $0 [-u] [-s] [-n]"; exit 1 ;;
  esac
done

# Wenn kein Parameter übergeben wurde, beides auf "true" setzen
if [ $OPTIND -eq 1 ]; then
    SYNC_USER=true
    SYNC_SYSTEM=true
    SYNC_NAS01=true
fi

echo "--- 📦 Starting git commit & GitHub sync ---"

# 1. User Dotfiles
if [ "$SYNC_USER" = true ]; then
    echo "» Verarbeite ~/.dotfiles..."
    cd ~/.dotfiles && git add . && oco --yes && git push
fi

echo "--------------------------------------------"

# 2. System Dotfiles
if [ "$SYNC_SYSTEM" = true ]; then
    echo "» Verarbeite /opt/system-dotfiles..."
    cd /opt/system-dotfiles && git add . && oco --yes && git push
fi

echo "--------------------------------------------"

# 3. nas-01 Dotfiles (Remote via SSH)
if [ "$SYNC_NAS01" = true ]; then
    echo "» nas-01: Verarbeite /opt/system-dotfiles remote via SSH..."

    # Der SSH-Befehl kapselt die gesamte Kette.
    # -A leitet den lokalen SSH-Agent weiter, damit das NAS den Key vom Desktop nutzen kann.
    ssh -A kevin@nas-01 "source ~/.keychain/nas-01-sh && cd /opt/system-dotfiles && git add . && oco --yes && git push"
fi

echo "--- ✅ Sync done ---"
