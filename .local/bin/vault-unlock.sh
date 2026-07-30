#!/bin/bash
# vault-unlock.sh
# Unlocks the Bitwarden vault and stores the session in RAM for automated services.

if [ "$EUID" -eq 0 ]; then
  echo "[Fehler] Bitte das Skript NICHT mit 'sudo' ausführen!"
  echo "Das Skript fordert die Sudo-Rechte für benötigte Schritte selbst an."
  exit 1
fi

# Unified RAM-disk path for the session token
SESSION_DIR="/run/vault"
SESSION_FILE="$SESSION_DIR/bw_session"

# Ensure the directory exists (requires sudo/root if it doesn't)
if [ ! -d "$SESSION_DIR" ]; then
    sudo mkdir -p "$SESSION_DIR"
fi
sudo chown -R $USER:$USER "$SESSION_DIR"
sudo chmod 755 "$SESSION_DIR"

echo "[Vault] Unlocking Bitwarden Vault..."

# Get the raw session key
BW_SESSION_TMP=$(sudo HOME=/root /usr/bin/bw unlock --raw)

if [ $? -eq 0 ] && [ -n "$BW_SESSION_TMP" ]; then
    # Write the session token WITHOUT newline (crucial for bw CLI)
    printf "%s" "$BW_SESSION_TMP" | sudo tee "$SESSION_FILE" > /dev/null
    sudo chmod 600 "$SESSION_FILE"
    
    echo ""
    echo "[Erfolg] Tresor entsperrt. Session gespeichert in $SESSION_FILE"
    echo "[Info] Automatisierte Dienste können nun auf Secrets zugreifen."
else
    echo "[Fehler] Entsperren fehlgeschlagen. Bitte Passwort prüfen."
    exit 1
fi
