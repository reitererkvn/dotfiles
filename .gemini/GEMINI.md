# Global SRE & System Context (Fallback)
**Stand:** 11. Mai 2026

## 1. Multi-Repo Architektur
Dieses System ist in drei logische Einheiten unterteilt, die jeweils ihre eigene `GEMINI.md` besitzen. Gemini CLI lädt automatisch die Datei des aktuellen Arbeitsverzeichnisses:

1.  **User-Space (`~/.dotfiles/`):** Hyprland Lua, Waybar, App-Configs.
2.  **Desktop-System (`/opt/system-dotfiles/`):** Btrfs, Snapper, Desktop-Systemd, Kern-Skripte.
3.  **NAS-System (`nas-01:/opt/system-dotfiles/`):** Cloud-Backup, HDD-Management, Immich-Tiering.

## 2. Hierarchische Regeln & Sicherheits-Check
- Bei Arbeiten in Unterverzeichnissen (z.B. `~/.dotfiles/.config/hypr/`) wird die `GEMINI.md` im jeweiligen Repository-Root gelesen.
- **Scope-Check (MANDATORY):** Bevor du ein Skript erstellst oder änderst, prüfe: "Bin ich im richtigen Repo?"
    - NAS-Skripte nur in `nas-01:/opt/system-dotfiles/`.
    - Desktop-System-Skripte nur in `/opt/system-dotfiles/`.
    - User-Configs nur in `~/.dotfiles/`.
- **Kontextwechsel:** Wenn du zwischen Desktop und NAS wechselst, achte darauf, Gemini im entsprechenden Repo-Pfad zu starten, um die spezifischen Regeln zu laden.

## 3. Zentrale SRE Prinzipien
- **Repo-First:** Keine direkten Edits in `/etc/` oder `/usr/bin/`. Immer erst im Repo ändern und dann deployen.
- **Automatisierung:** Event-basierte Trigger (z.B. `.sync_done`) bevorzugen vor stumpfem Polling.
- **Sicherheit:** Keine Secrets in `GEMINI.md` oder Repos.
