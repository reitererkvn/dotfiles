# 🚀 HyprCachyOS: Cognitive Ergonomics meets SRE Principles

**HyprCachyOS** is a specialized, performant, and reliable Linux desktop environment designed from the ground up to address the challenges of neurodivergence (ADHD). By combining the blistering speed of **CachyOS** and the **Hyprland** compositor with strict **Site Reliability Engineering (SRE)** principles, this setup minimizes cognitive load, eliminates context-switching friction, and ensures absolute system stability.

## 🧠 The Vision: Cognitive Ergonomics

For users with ADHD, cognitive and physical ergonomics are not just preferences—they are necessities for productive work. Unnecessary visual stimuli, sluggish response times, and jarring context switches derail problem-solving and break focus.

HyprCachyOS solves this through:
*   **Bimodal Window Management:** A distraction-free, highly predictable layout system that reduces the mental overhead of window hunting.
*   **Process Isolation via Special Workspaces:** Telemetry, background apps, and communication tools are rigorously isolated into dedicated workspaces. Out of sight, out of mind, until explicitly needed.
*   **SSOT (Single Source of Truth):** Strict separation and management of system-wide and user-specific configurations to prevent configuration drift and unexpected behavior.

## ⚙️ Architecture & SRE "Reality"

This repository is built with an infrastructure-as-code mindset. It actively rejects brittle desktop Linux conventions in favor of robust, production-grade system management and a fully programmable compositor environment.

| Principle | Implementation (The Reality) | File Reference |
| :--- | :--- | :--- |
| **Programmable Compositing** | Hyprland 0.55+ uses a **native Lua API**. This moves logic from static strings to a modular, event-driven architecture (Solar scheduling, dynamic layouts). | `.config/hypr/lua/` |
| **Reliability via Systemd** | Daemons (Waybar, Agents, etc.) are managed as `systemd --user` units with proper dependency trees. This ensures clean lifecycle management and automatic restarts. | `.config/systemd/user/` |
| **State Modularity & SSOT** | Leveraging **UWSM** (Universal Wayland Session Manager), environment variables are loaded modularly via an `env.d` structure before the compositor starts. | `.config/uwsm/env` |
| **Resource Optimization** | High-overhead tools are lazy-loaded via a custom daemon (`hypr-lazy.sh`) that listens to the Hyprland IPC socket and triggers processes only when needed. | `.local/bin/hypr-lazy.sh` |
| **Idempotent Sync** | The `dotfiles-sync.sh` script acts as a state enforcer, safely creating symlinks and performing garbage collection on orphaned links. | `.local/bin/dotfiles-sync.sh` |
| **Unified Documentation** | SRE-level system facts and topology are managed via a centralized `GEMINI.md` logic, synchronized across Desktop & NAS. | `gemini-sync-docs.sh` |

## 🤖 AI-Driven Engineering (The LLM Factor)

This entire ecosystem was built from absolute **zero prior Linux knowledge**, beginning in **February 2026**. Since then, it has evolved from a simple setup to a complex SRE infrastructure.

*   **Lua-Native Migration (May 2026):** Transitioned from legacy `.conf` files to a fully modular Lua architecture, while maintaining the robust **UWSM/Systemd** foundation for process management.
*   **The Engine (Gemini LLM):** Used as an intelligent compiler and SRE consultant to enforce best practices and ensure architectural integrity across multi-host environments.

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

3.  **Synchronize System Documentation:**
    ```bash
    ~/.dotfiles/.local/bin/gemini-sync-docs.sh
    ```

4.  **Activate Service Daemons:**
    ```bash
    ~/.dotfiles/.local/bin/install-userservice.sh
    ```

5.  **Launch Session:**
    Start your session via **UWSM** (e.g., `uwsm start hyprland.desktop`) to utilize the SSOT environment loader and systemd integration.

## 📜 Key Configuration Scripts

Located in `.local/bin`, these scripts manage the system state:

| Script Name | Purpose |
| :--- | :--- |
| `gemini-sync-docs.sh` | **SRE Master Sync:** Distributes the central `GEMINI.md` across all repositories (Desktop/NAS). |
| `dotfiles-sync.sh` | The idempotent state synchronizer for symlinks. |
| `hypr-lazy.sh` | The IPC socket listener for cognitive offloading and lazy-loading of heavy applications. |
| `git-push.sh` | Automates Git state synchronization for the dotfiles repository. |
| `gdrive-live-sync.sh` | Manages rsync-based live syncs with Google Drive using intelligent exclusion lists. |
| `apply-theme.sh` | Dynamic template renderer for system-wide theming. |
| `install-userservice.sh` | Deploys and enables the `systemd --user` units for session management. |
| `sun.lua` (Config) | **Solar Scheduler:** Lua-native event handler for wallpaper and aesthetic transitions. |
