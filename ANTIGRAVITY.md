# Home Server, Desktop & Dotfiles Configuration
**Stand:** 21. Mai 2026
**Fokus:** Modular, stabil & automatisiert

## 1. System-Topologie (Hardware & Netz)
*   **Desktop (`homeserver`):** CachyOS Linux | GTX 1650 | 16GB RAM | IP: `192.168.178.22`
*   **NAS (`nas-01`):** Debian 13 | 12th Gen i5-12400F | 16GB RAM | GTX 1070 Ti | 256GB SSD + 1TB HDD (`/mnt/HDD-01`) | IP: `192.168.178.46`
*   **Connectivity:** SSH via Desktop-Agent-Forwarding; NAS -> Cloud via GDrive (API-Limit: 200 TPS, 16 Conn).

## 2. System-Architektur (HyprCachyOS & NAS-01)
*   **Storage (NAS-01):** Hybrid-Modell (SSD für DB/Ingest, HDD für Archiv) via `MergerFS` unter `/lib/immich`.
*   **Snapshot-Logik:** SSD-Subvolumes via Snapper. HDD-Snapshots nachts via Sync-Skript.
*   **Trigger-Logik:** Event-basierte Trigger via SSD-Files (`/var/lib/nas-sync-triggers/`) zur HDD-Schonung.
*   **Backup-Kette:**
    *   Desktop -> NAS via `upload_snapshots.sh` (Trigger: `homeserver_sync.done`).
    *   NAS Cloud Sync via Restic (`nas_cloud_sync.sh`) nach lokalem Sync (Trigger: `nas_local_sync.done`).

## 2. Hyprland Configuration (Lua-Native)
*   **Version:** 0.55+ (Lua API).
*   **Entry Point:** `~/.config/hypr/hyprland.lua`.
*   **Module:** `colors`, `monitors`, `look`, `keybinds`, `windowrules`, `autostart`, `sun`, `layout`.
*   **Custom Layout:** `lua:master-grid` (Zentriertes Master, Grid-Seiten mit Breiten-Auffüllung).
*   **Automation:** `sun.lua` verwaltet Wallpaper-Wechsel event-basiert (ersetzt `hypr-sun.sh` und Systemd-Timer).

## 3. Workflows & Repo-Exklusivität (Source of Truth)
*   **STRIKTE TRENNUNG:**
    *   **User-Space (`~/.dotfiles/`):** Enthält ausschließlich User-Konfigurationen (Zsh, Hyprland, Kitty, Neovim, etc.).
    *   **Infrastructure Monorepo (`/opt/infrastructure/`):** Source of Truth für das gesamte System-Setup (Ansible Playbooks, NAS-Dienste, Desktop-Hardware-Skripte, Docker Stacks). Läuft sowohl auf Desktop als auch auf NAS.
*   **Secret Management:**
    *   **RAM-Vault:** Einmaliges Entsperren via `sudo vault-unlock.sh` pro Boot. Token liegt in `/run/vault/bw_session`.
    *   **Zero-Leak:** Keine Klartext-Passwörter in Git. Docker nutzt `${VAR}` in Compose-Files, gespeist aus lokalen `.env` Dateien.
*   **Repo-First:** Änderungen MÜSSEN zuerst im jeweiligen Repository erfolgen. Deployment via `dotfiles-sync.sh` (User) oder manueller Kopie (System).

## 4. Bekannte Fallstricke & Fixes
*   **Bitwarden Token:** Der Session-Token in `/run/vault/bw_session` darf keinen Zeilenumbruch enthalten (via `printf` schreiben).
*   **Ownership:** Alle Verzeichnisse unter `/opt/docker/` werden durch Ansible auf `root:root` vereinheitlicht, um Idempotenz-Konflikte zu vermeiden.
*   **Semaphore Self-Restart:** Docker-Tasks in Semaphore nutzen den Tag `infrastructure_only` (im Task `Restart Docker Compose Stacks`), um zu verhindern, dass Semaphore sich während des Laufs selbst absägt.
*   **Semaphore Task-Auswahl:** Durch die Aufteilung der Playbooks in `nas.yml` und `desktop.yml` wird sichergestellt, dass Tasks (z. B. "NAS update") strikt nur ihre Zielsysteme ansprechen, ohne dass sich Hosts überlagern. In Semaphore müssen dafür die korrekten Playbooks in den Task Templates hinterlegt sein.

## 5. Offene Projekte
- **Paperless-ngx:** Einrichtung geplant (Pfade: SSD für DB/Ingest, HDD für Media).
- **Monitoring:** Grafana/Prometheus Stack auf NAS aktiv (Port 3001/9090 via Caddy).
- **Secret Management & Sicherheit:**
    *   ✅ Vaultwarden Instanz auf NAS (sicher über Cloudflare Tunnel auf `vault.rnet.at` exponiert, WAF aktiv & Signups via `SIGNUPS_ALLOWED=false` blockiert).
    *   ✅ **Ansible Vault:** Sämtliche Container-Secrets und Environment-Variablen werden verschlüsselt über `ansible-vault` (in `group_vars/nas/secrets.yml`) verwaltet und zur Laufzeit dynamisch injiziert. Es existieren keine Klartext-Passwords im Repository.
    *   ⏳ Bitwarden CLI Integration auf Desktop & NAS (Skript `vault-unlock.sh` erzeugt Login-Fehler wegen User/Root Mismatch).
    *   ⏳ Backup von SSH-Keys (Private Keys) in den Vault.
    *   ⏳ Migration der `rclone.conf` Tokens in den Vault.
    *   ✅ Absicherung der öffentlichen Endpunkte: Vaultwarden läuft sicher über Cloudflare Tunnel (WAF).
    *   ⏳ Weitere Endpunkte (HA, Immich) z.B. via Cloudflare Access (Zero Trust) absichern.
- **Ansible Playbooks:** Automatisierung des System-Setups für Desktop und NAS.
    *   *Architektur:* Das Setup ist modularisiert. `site.yml` fungiert als Master-Include, während `nas.yml` und `desktop.yml` eine strikte, fehlerfreie Host-Trennung (für z. B. Semaphore) ermöglichen.
    *   *Docker-Deployment:* Die Rolle `nas_docker` verwaltet alle Container. Sie verwendet eine zentrale, hochdynamische Master-Jinja2-Vorlage (`docker-compose.yml.j2`), um über Wenn-Dann-Schleifen alle isolierten `docker-compose.yml`-Dateien der verschiedenen Container (Grafana, Immich, Caddy etc.) im Loop zu generieren. Alle Web-Services kommunizieren sicher isoliert über das `proxy_net`-Docker-Netzwerk.
- **DNS-Infrastruktur:** Lokaler DNS-Server (z.B. Pi-hole/AdGuard) für herstellerunabhängige Namensauflösung (ohne Tailscale-Zwang).
- **Openclaw Container (Gemini Telegram Bot):**
    - **Ziel:** Einrichtung und Fertigstellung des Openclaw Docker Containers.
    - **Anforderung:** Vollständige Konversations-Unterstützung zur Remote-Steuerung via Telegram.
    - **Workflow:** Session startet bei Nachricht, endet bei `/quit`. Läuft als zentraler Docker-Dienst auf dem NAS.

## 6. Abgeschlossene Projekte
*   ✅ Hyprland Lua Migration (Mai 2026)
*   ✅ Integration intelligenter Wallpaper-Scheduler in Lua
*   ✅ Secret Management Foundation (Vaultwarden & CLI Automation)
*   ✅ Zentralisierung der Dokumentations-Infrastruktur (`ANTIGRAVITY.md` als SSOT)

---

## 7. Allgemeine Agenten-Richtlinien & System-Prompts
*   **Niemals raten (Never guess):** Antworten müssen so deterministisch wie möglich sein. Falls Informationen fehlen, frage nach oder ermittle sie über System-Tools.
*   **Fakten verifizieren (Verify facts):** Lösungen und Antworten müssen mit Live-Daten, dem Internet oder Dokumentationen abgeglichen werden, um Halluzinationen auszuschließen.
*   **Live-Statusprüfung vor kritischen Aktionen (Live State Check):** Überprüfe vor jeder systemkritischen Aktion (z. B. Snapper-Snapshots, Service-Restarts) den tatsächlichen Ist-Zustand des Systems via CLI.
*   **Idempotenz-Nachweis bei Ansible & Skripten:** Führe geänderte Ansible-Playbooks oder Skripte ein zweites Mal aus, um sicherzustellen, dass sie idempotente Zustände erzeugen und keine unbeabsichtigten Nebenwirkungen oder wiederholte Änderungen auftreten.
*   **Validierung vor Dateierstellungen (Dry-Run / Lint):** Nutze verfügbare Validierungstools (z. B. `systemd-analyze verify`, `caddy validate`) vor dem Schreiben von Konfigurationen und arbeite mit minimalen Zeilen-Ersetzungen (diffs).
*   **Rollback-Sicherung (Fail-Safe):** Erstelle vor Skriptänderungen Backups (`.bak`) oder verifiziere das Vorhandensein von Snapper-Snapshots, um im Fehlerfall ein direktes Rollback durchführen zu können.
*   **LLM-Empfehlung bei Bedarf (Model Suggestions):** Falls du im Vorhinein abschätzen kannst, dass eine Aufgabe mit einem anderen verfügbaren LLM (z. B. Claude für tiefes Coding/Refactoring oder ChatGPT für breites Reasoning) zuverlässiger gelöst werden kann, schlage dem Nutzer explizit vor, das Modell vor der Bearbeitung zu wechseln.
*   **Strikte Repo-Trennung & Aktualität:** Stelle sicher, dass die verschiedenen Repositories (User-Space `~/.dotfiles` und System-Space `/opt/infrastructure`) bei Änderungen jeweils separat und zeitnah über Git eingecheckt/gepusht werden, ohne dass sich deren Inhalte (z.B. Desktop-Skripte im User-Repo) vermischen.
*   **Einheitliche Git-Identität:** Verwende bei automatisierten Git-Commits stets die globale Identität `bot@homeserver` (Name: `Antigravity`), um die Historie sauber und nachvollziehbar zu halten.

---
*Dieses Dokument ist die primäre Instruktion für Antigravity CLI Sessions in diesem Workspace.*
