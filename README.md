# 🚀 HyprCachyOS: Optimized & Ergonomic Linux Desktop Setup

**HyprCachyOS** is a specialized, performant, and reliable Linux desktop environment designed from the ground up to address the challenges of neurodivergence (ADHD). By combining the blistering speed of **CachyOS** and the **Hyprland** compositor with a structured, reliable automation setup, this repository minimizes cognitive load, eliminates context-switching friction, and keeps a multi-host environment stable and easy to maintain.

> **Status:** Modular Decoupled Architecture (Stand: Mai 2026)

## 🧠 The Vision: Cognitive Ergonomics (ADHD-First Design)

For users with ADHD, cognitive and physical ergonomics are not just preferences—they are necessities for productive work. Unnecessary visual stimuli, sluggish response times, and jarring context switches derail problem-solving and break focus.

HyprCachyOS solves this through:
*   **Bimodal Window Management:** A distraction-free, highly predictable layout system that reduces the mental overhead of window hunting.
*   **Process Isolation via Special Workspaces:** Telemetry, background apps, and communication tools are rigorously isolated into dedicated workspaces. Out of sight, out of mind, until explicitly needed.
*   **SSOT (Single Source of Truth):** Strict separation and management of system-wide and user-specific configurations to prevent configuration drift and unexpected behavior.

## ⚙️ Architecture & Setup Organization

This repository is part of a **multi-repo desktop and automation setup**. It focuses on the "Upper Stack" (User Experience), while system-level orchestration is delegated to specialized system repositories.

| Layer | Repository | Responsibility |
| :--- | :--- | :--- |
| **User-Space** | `~/.dotfiles` (This) | Cognitive ergonomics, Hyprland Lua, userland configs. |
| **Infrastructure Monorepo** | `/opt/infrastructure` | **Ansible Master**, Hardware tweaks, systemd units, Docker stacks (NAS & Desktop). |

### Core User-Space Principles
*   **Programmable Compositing:** Hyprland 0.55+ uses a **native Lua API**. This moves logic from static strings to a modular, event-driven architecture (Solar scheduling, dynamic layouts).
*   **Reliability via Systemd:** Daemons (Waybar, Agents, etc.) are managed as `systemd --user` units with proper dependency trees.
*   **State Modularity & SSOT:** Leveraging **UWSM** (Universal Wayland Session Manager), environment variables are loaded modularly via an `env.d` structure.
*   **Resource Optimization:** High-overhead tools are lazy-loaded via a custom daemon (`hypr-lazy.sh`) that listens to the Hyprland IPC socket.
*   **Idempotent Sync:** The `dotfiles-sync.sh` script acts as a state enforcer for user-level symlinks.

## 🔒 Security & Secret Management (Zero-Leak Policy)

Reliability requires security. This system implements a strict zero-leak policy for credentials and sensitive data:
*   **RAM-Vault:** Bitwarden sessions are managed in RAM (`/run/vault/`) and unlocked once per boot via `vault-unlock.sh`.
*   **Environment Injection:** Secrets are never committed to Git. Docker services and scripts consume variables from local `.env` files and the Bitwarden CLI.
*   **Isolation:** Sensitive configs (like `rclone.conf`) are being migrated to the vault to eliminate static secret files.

## 🤖 AI-Driven Engineering (The LLM Factor)

This entire ecosystem was built from absolute **zero prior Linux knowledge**, beginning in **February 2026**. Since then, it has evolved from a simple setup to a robust, fully automated multi-host environment—a proof-of-concept for modern, AI-augmented engineering.

*   **Lua-Native Migration (May 2026):** Transitioned from legacy `.conf` files to a fully modular Lua architecture, while maintaining the robust **UWSM/Systemd** foundation for process management.
*   **Multi-Host Orchestration:** Expanded from a single desktop to a multi-host NAS architecture with sophisticated storage tiering (MergerFS/Btrfs) and cloud backup pipelines.
*   **The Engine (Gemini LLM):** Used as an assistant and advisor to ensure best practices and structured configurations.

## 🛠 Core Components

*   **OS Base:** CachyOS (Arch Linux optimized for extreme performance).
*   **Compositor:** Hyprland 0.55+ (**Lua-native API**).
*   **Terminal:** Kitty (GPU-accelerated).
*   **Editor:** Neovim (Kickstart.nvim).
*   **Launcher & Bar:** Fuzzel & Waybar.
*   **Theming:** Custom bash Templating (`apply-theme.sh`) using `envsubst`.

## 📦 Installation & Setup

### **Prerequisites**
Ensure your base system has `Hyprland` (0.55+), `UWSM`, `sunwait`, and standard GNU utilities installed.

### **Manual Installation**

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:reitererkvn/dotfiles.git ~/.dotfiles
    ```

2.  **Enforce Configuration State (Sync):**
    ```bash
    ~/.dotfiles/.local/bin/dotfiles-sync.sh
    ```

3.  **Activate Service Daemons:**
    ```bash
    ~/.dotfiles/.local/bin/install-userservice.sh
    ```

4.  **Launch Session:**
    Start your session via **UWSM** (e.g., `uwsm start hyprland.desktop`) to utilize the SSOT environment loader and systemd integration.

## 📜 Key Configuration Scripts

Located in `.local/bin`, these scripts manage the system state:

| Script Name | Purpose |
| :--- | :--- |
| `dotfiles-sync.sh` | The idempotent state synchronizer for symlinks. |
| `hypr-lazy.sh` | The IPC socket listener for cognitive offloading and lazy-loading of heavy applications. |
| `git-push.sh` | Automates Git state synchronization for the dotfiles repository. |
| `gdrive-live-sync.sh` | Manages rsync-based live syncs with Google Drive using intelligent exclusion lists. |
| `apply-theme.sh` | Dynamic template renderer for system-wide theming. |
| `install-userservice.sh` | Deploys and enables the `systemd --user` units for session management. |
| `vault-unlock.sh` | Manages secure RAM-based Bitwarden sessions. |
| `sun.lua` (Config) | **Solar Scheduler:** Lua-native event handler for wallpaper and aesthetic transitions. |

---
*Refer to ANTIGRAVITY.md for architectural rules and system guidelines.*
