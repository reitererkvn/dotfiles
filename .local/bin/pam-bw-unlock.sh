#!/bin/bash
# /usr/local/bin/pam-bw-unlock.sh
# Unlocks Bitwarden automatically during PAM login

# Only trigger for the main user
if [ "$PAM_USER" != "kevin" ]; then
    exit 0
fi

# Read password from standard input (passed by PAM expose_authtok)
read -r PASSWORD
export BW_PASSWORD="$PASSWORD"

SESSION_DIR="/run/vault"
SESSION_FILE="$SESSION_DIR/bw_session"

mkdir -p "$SESSION_DIR"
chmod 755 "$SESSION_DIR"

# Unlock root vault (since background services like gdrive-live-sync use root context via sudo)
BW_SESSION_TMP=$(/usr/bin/bw unlock --passwordenv BW_PASSWORD --raw)

if [ $? -eq 0 ] && [ -n "$BW_SESSION_TMP" ]; then
    printf "%s" "$BW_SESSION_TMP" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
fi

exit 0
