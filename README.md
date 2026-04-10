# 🚀 HyprCachyOS: Cognitive Ergonomics meets SRE Principles

**HyprCachyOS** is a specialized, performant, and reliable Linux desktop environment designed from the ground up to address the challenges of neurodivergence (ADHD). By combining the blistering speed of **CachyOS** and the **Hyprland** compositor with strict **Site Reliability Engineering (SRE)** principles, this setup minimizes cognitive load, eliminates context-switching friction, and ensures absolute system stability.

## 🧠 The Vision: Cognitive Ergonomics

For users with ADHD, cognitive and physical ergonomics are not just preferences—they are necessities for productive work. Unnecessary visual stimuli, sluggish response times, and jarring context switches derail problem-solving and break focus.

HyprCachyOS solves this through:
*   **Bimodal Window Management:** A distraction-free, highly predictable layout system that reduces the mental overhead of window hunting.
*   **Process Isolation via Special Workspaces:** Telemetry, background apps, and communication tools are rigorously isolated into dedicated workspaces. Out of sight, out of mind, until explicitly needed.
*   **SSOT (Single Source of Truth):** Strict separation and management of system-wide and user-specific configurations to prevent configuration drift and unexpected behavior.

## ⚙️ Architecture & SRE "Reality"

This repository is built with an infrastructure-as-code mindset. It actively rejects brittle desktop Linux conventions (like messy `exec-once` chains in compositor configs) in favor of robust, production-grade system management.

| Principle | Implementation (The Reality) | File Reference |
| :--- | :--- | :--- |
| **Reliability via Systemd** | Daemons (Waybar, Agents, etc.) are managed as `systemd --user` units with proper dependency trees. This ensures clean lifecycle management, automatic restarts on failure, and predictable session teardowns. | `.config/systemd/user/` |
| **State Modularity & SSOT** | Leveraging **UWSM** (Universal Wayland Session Manager), the environment variables are loaded modularly via an `env.d` structure. This guarantees a clean state and a Single Source of Truth before the compositor even starts. | `.config/uwsm/env` |
| **Resource Optimization (IPC)** | High-overhead tools (e.g., htop, nvtop) are not launched at startup. Instead, a custom daemon (`hypr-lazy.sh`) listens to the Hyprland IPC socket and lazy-loads these processes *only* when their specific workspace is accessed, exiting itself once its job is done. | `.local/bin/hypr-lazy.sh` |
| **Idempotent Synchronization** | The `dotfiles-sync.sh` script acts as a state enforcer. It safely creates symlinks, performs garbage collection on orphaned links, and strictly validates I/O paths to prevent accidental data loss. | `.local/bin/dotfiles-sync.sh` |
| **Fail-Safe Operations** | Built-in aliases like `snapnow` trigger instant, concurrent BTRFS snapshots of the root (`@`) und home (`@home`) subvolumes, providing an immediate rollback mechanism before risky operations. | `.alias` |

## 🤖 AI-Driven Engineering (The LLM Factor)

This entire ecosystem was built from scratch in just **6 weeks, starting with zero prior Linux knowledge**. Achieving this depth of system architecture (IPC sockets, systemd user sessions, idempotent synchronization) in such a short timeframe is not a claim of traditional Linux mastery—it is a showcase of **AI-driven Systems Engineering**.

*   **The Engine (Gemini LLM):** Used as an intelligent compiler to translate high-level architectural requirements into functional, optimized Bash and configuration syntax.
*   **The Architect (Human):** My role focused on the *vision* and *verification*. Instead of blindly accepting code, I rigorously steered the LLM to avoid "dirty hacks" and enforce SRE best practices. I dictated the *Why* (e.g., "We need fail-safes, use systemd instead of exec-once") and validated the *How* (e.g., verifying that socket communication is the most performant way to lazy-load).

This project serves as a proof-of-work for modern engineering: orchestrating AI tools not just to write code, but to build robust, production-grade systems rapidly and cleanly.

## 🛠 Core Components

The choice of software is strictly focused on minimal overhead, maximum performance, and keyboard-centric control:

*   **OS Base:** CachyOS (Arch Linux optimized for extreme performance and low latency).
*   **Compositor:** Hyprland (Wayland Tiling Window Manager).
*   **Terminal:** Kitty (GPU-accelerated, highly customizable).
*   **Editor:** Neovim (Configured via `kickstart.nvim` for a fast development loop).
*   **Launcher & Bar:** Fuzzel & Waybar (Lightweight, Wayland-native).
*   **Theming Engine:** Custom bash Templating (`apply-theme.sh`) using `envsubst` for dynamic, consistent RGBA injection across all UI elements.

## 📦 Installation & Setup

### **Prerequisites**
Ensure your base system (preferably CachyOS/Arch Linux) has the necessary Wayland tools installed, specifically `Hyprland`, `UWSM`, and standard GNU userland utilities.

### **Manual Installation**

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:reitererkvn/dotfiles.git ~/.dotfiles
    ```

2.  **Enforce Configuration State (Sync):**
    Run the idempotent sync script to link the repository to your `$HOME`.
    ```bash
    ~/.dotfiles/.local/bin/dotfiles-sync.sh
    ```

3.  **Activate Service Daemons:**
    Enable the systemd user units to hand over process control to systemd.
    ```bash
    ~/.dotfiles/.local/bin/install-userservice.sh
    ```

4.  **Launch Session:**
    Start your session via UWSM (or your display manager configured for UWSM) to utilize the SSOT environment loader.

## 📜 Key Configuration Scripts

Located in `.local/bin`, these scripts manage the system state and ensure the "HyprCachyOS" logic is enforced:

| Script Name | Purpose |
| :--- | :--- |
| `hypr-lazy.sh` | The IPC socket listener for cognitive offloading and lazy-loading of heavy applications. |
| `dotfiles-sync.sh` | The idempotent state synchronizer and garbage collector for symlinks. |
| `apply-theme.sh` | The dynamic template renderer using `envsubst` for system-wide theming. |
| `git-push.sh` | Automates Git state synchronization for the dotfiles repository. |
| `gdrive-live-sync.sh` | Manages rclone-based live syncs with intelligent exclusion lists. |
| `hypr-sun.sh` | Dynamically adjusts aesthetics based on geographic time, reducing eye strain and cognitive fatigue during twilight hours. |
