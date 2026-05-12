#!/bin/bash
# vault-unlock.sh
# Automatisiert das Entsperren des Tresors für die aktuelle Shell-Session.

if [[ -z "\$BW_CLIENTID" || -z "\$BW_CLIENTSECRET" ]]; then
    echo "Error: BW_CLIENTID oder BW_CLIENTSECRET nicht gesetzt."
    echo "Bitte erstelle einen API-Key im Bitwarden Web-Vault und exportiere die Variablen."
    exit 1
fi

# Login falls nötig
if ! bw status | grep -q "authenticated"; then
    bw login --apikey
fi

# Unlock und Token exportieren
export BW_SESSION=\$(bw unlock --passwordenv BW_PASSWORD --raw)

if [[ -n "\$BW_SESSION" ]]; then
    echo "Tresor erfolgreich entsperrt. BW_SESSION ist bereit."
    # Hinweis: Da dies ein Subprozess ist, muss das Skript gesourced werden:
    # source vault-unlock.sh
else
    echo "Fehler beim Entsperren des Tresors."
fi
