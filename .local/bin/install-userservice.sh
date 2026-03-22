#!/bin/bash
# installer for wayland services (waybar, hyprpaper, ssh-agent, etc.)

ENV_FILE="$HOME/.config/uwsm/env.d/35-daemons.sh"

mapfile -t SETUP_LIST < <(grep "=" "$ENV_FILE" | sed 's/export //g' | cut -d'=' -f1)

echo "installing and enabling Wayland-Daemons..."

for app in "${SETUP_LIST[@]}"; do
    if [[ -n "$app" ]]; then
        echo "Konfiguriere Unit: $app"

        systemctl --user enable --now "$app"

        if [ $? -eq 0 ]; then
            echo "[ OK ] $app enabled."
        else
            echo "[ERROR] Unit $app could not be enabled."
        fi
    fi
done

echo "installation done."
exit 0
