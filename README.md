# 🚀 Dotfiles: Hyprland, Minimal & Performant CLI Setup

A highly optimized, minimalistic, and CLI-focused configuration for a fast and reliable Linux desktop experience. This setup leverages modular scripting and native service management to ensure unparalleled performance and session stability.

## ✨ Key Features

This repository is built around the principle of speed and stability, moving away from common pitfalls like messy `exec once` chains.

| Feature | Description | File Reference |
| :--- | :--- | :--- |
| **Systemd User Units** | Daemons (Waybar, Agents, etc.) are managed via `systemd --user` units, completely eliminating the brittle `exec once` in the compositor. This ensures robust lifecycle management, proper shutdown, and reliable restarts. | `install-userservice.sh` |
| **UWSM Environment Manager** | The User-Workspace-Session-Manager is used to load a clean and highly modular environment before the session starts, preventing configuration conflicts and ensuring a single source of truth for all environment variables. | `.config/uwsm/env` |
| **Lazy-Loading Workspaces** | Resource-intensive applications (e.g., htop, nvtop) are set to only launch when their dedicated workspace is accessed for the first time, significantly accelerating boot time and freeing up resources. | `hypr-lazy.sh` |
| **Automated Sync** | Scripts for automatically creating necessary symlinks across the home directory (`dotsync`), as well as dedicated tools for Git auto-committing and pushing dotfile changes (`gitsync`). | `dotfiles-sync.sh`, `git-push.sh`, `.alias` |
| **Dynamic Theming** | A utility script is included to dynamically convert hex color values into RGBA format and apply them across different applications (like Waybar or Kitty), ensuring a consistent look and feel based on the primary color palette. | `apply-theme.sh` |
| **Location-Aware Wallpaper** | A script to dynamically switch wallpapers based on the sunrise/sunset time and your geographic coordinates, ensuring a seamless visual transition between day and night themes. | `hypr-sun.sh` |
| **Snapper Integration** | Contains a simple alias (`snapnow`) for instant, concurrent BTRFS snapshots of the root (`@`) and home (`@home`) subvolumes, offering a quick rollback mechanism. | `.alias` |

## ⚙️ Core Components

The choice of software is strictly focused on a minimal overhead and command-line control:

| Component | Function | Reason for Choice |
| :--- | :--- | :--- |
| **Hyprland** | Window Manager (Tiling Compositor) | Extreme performance, GPU-acceleration, and fine-grained configuration via Wayland. |
| **Kitty** | Terminal Emulator | GPU-accelerated for speed, highly customizable, and supports remote control. |
| **Neovim (Kickstart)** | Text Editor | The ultimate CLI text editor, configured using the popular and easily understandable `kickstart.nvim` base for a fast development environment. |
| **Fuzzel** | Application Launcher | Fast and lightweight Wayland-native launcher. |
| **Waybar** | Status Bar | Highly customizable and modular status bar for Wayland, complementing the minimalist design. |
| **ZSH** | Shell | Used with performance-focused plugins like `zsh-autosuggestions` and `zsh-syntax-highlighting` to enhance CLI workflow. |

## 📦 Installation & Setup

These dotfiles are ideally suited as the base for an Arch Linux-based distribution, leveraging the power of its ecosystem.

### **Prerequisites**

You must have the following dependencies installed on your system (among others):

*   `Hyprland` (Wayland compositor)
*   `Kitty` (Terminal)
*   `Neovim`
*   `Waybar`
*   `Fuzzel`
*   `UWSM` (For advanced session/environment management)
*   `systemd` (Specifically the `systemd --user` component)

### **Recommended AUR Package Base**

These dotfiles provide the perfect foundation for an **Arch User Repository (AUR) package**, which would offer a complete "quick-setup" solution.

### **Manual Installation**

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:reitererkvn/dotfiles.git ~/.dotfiles
    ```

2.  **Run the Sync Script:**
    The core script automates the creation of all necessary symlinks from the repository to your home directory (`~`).
    ```bash
    ~/.dotfiles/.local/bin/dotfiles-sync.sh
    ```

3.  **Install Daemons/Services:**
    Use the service manager script to ensure your background services are running correctly via systemd:
    ```bash
    ~/.dotfiles/.local/bin/install-userservice.sh
    ```

4.  **Full Setup (Optional):**
    Use the all-in-one alias to sync files, apply the theme, and commit the changes to Git (if desired):
    ```bash
    fullsync
    ```

## 📜 Key Configuration Scripts

The setup relies on several helper scripts, located in `.local/bin`, to manage the system state and developer workflow:

| Script Name | Purpose |
| :--- | :--- |
| `dotfiles-sync.sh` | Creates symlinks from the repository into the user's `$HOME` directory. |
| `git-push.sh` | Automates `git add .`, `git commit -m "Auto-Sync..."`, and `git push` for both user and optional system dotfiles. |
| `apply-theme.sh` | Reads color variables and exports theme-specific configurations (including RGBA) for compatible applications. |
| `gdrive-live-sync.sh` | Manages rclone-based live syncs with Google Drive for backups, following an exclusion list for caches and temporary files. |
| `hypr-lazy.sh` | The core "lazy-loader" for workspaces, using the Hyprland socket to only execute commands when a user switches to a specific workspace. |
| `start-session.sh` | The main script to be called by your display manager (or manually) to initiate the Hyprland session, ensuring all prerequisites are met. |