# SRE Infrastructure & Dotfiles Context
**Stand:** 11. Mai 2026
**Architektur-Level:** Senior SRE / Modular Decoupled

## 1. System-Architektur (HyprCachyOS & NAS-01)
*   **Storage (NAS-01):** Hybrid-Modell (SSD für DB/Ingest, HDD für Archiv) via `MergerFS` unter `/lib/immich`.
*   **Snapshot-Logik:** SSD-Subvolumes via Snapper. HDD-Snapshots nachts via Sync-Skript (Timeline DEAKTIVIERT).
*   **Backup-Kette:** 
    *   Desktop -> NAS via `upload_snapshots.sh` (Trigger-File: `.sync_done`).
    *   NAS Cloud Sync via Restic (`nas_cloud_sync.sh`) mit SRE-Limits zum Schutz der Google Drive API.

## 2. Hyprland Configuration (Lua-Native)
*   **Version:** 0.55+ (Lua API).
*   **Entry Point:** `~/.config/hypr/hyprland.lua`.
*   **Module:** `colors`, `monitors`, `look`, `keybinds`, `windowrules`, `autostart`, `sun`, `layout`.
*   **Custom Layout:** `lua:master-grid` (Zentriertes Master, Grid-Seiten mit Breiten-Auffüllung).
*   **Automation:** `sun.lua` verwaltet Wallpaper-Wechsel event-basiert (ersetzt `hypr-sun.sh` und Systemd-Timer).

## 3. Workflows (Source of Truth)
*   **Repo-First:** Änderungen an Skripten MÜSSEN zuerst in den Repositories vorgenommen werden.
    *   System-Configs: `/opt/system-dotfiles/`
    *   User-Configs: `/home/kevin/.dotfiles/`
*   **Deployment:** Nach Repo-Änderung erfolgt das Deployment nach `/usr/local/bin/` (System) oder via `dotfiles-sync.sh` (User).

## 4. Bekannte Fallstricke & Fixes
*   **Permissions:** Skripte in `/opt/system-dotfiles/` benötigen das Executable-Bit.
*   **SSH Auth:** Desktop-Root nutzt `id_ed25519_nas`. User `kevin` nutzt Desktop-Agent-Forwarding (`-A`).
*   **Colors:** `colors.lua` konvertiert `RRGGBBAA` (Env) zu `rgba()` (Hyprland), um Hex-Format-Konflikte (AARRGGBB) zu vermeiden.

## 5. Abgeschlossene Projekte
*   ✅ Hyprland Lua Migration (Mai 2026)
*   ✅ Integration intelligenter Wallpaper-Scheduler in Lua
*   ✅ Bereinigung Legacy Systemd-Units (hypr-sun)

---
*Dieses Dokument ist die primäre Instruktion für Gemini CLI Sessions in diesem Workspace.*
