#!/bin/bash
# System Update Wrapper - Ansible Transition
# This script delegates all maintenance tasks to the Ansible playbooks in ~/.dotfiles

set -e

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
ANSIBLE_DIR="$DOTFILES_DIR/ansible"
CLEANUP_MODE=0

# Argument Parsing (Keep compatibility with old flags)
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--cleanup) CLEANUP_MODE=1 ;;
        -h|--help)
            echo "Usage: $0 [-c|--cleanup]"
            exit 0
            ;;
        *) echo "Unknown signal: $1"; exit 1 ;;
    esac
    shift
done

echo "========================================"
echo " ANSIBLE MAINTENANCE INITIATED"
echo "========================================"

# Check if Ansible directory exists
if [ ! -d "$ANSIBLE_DIR" ]; then
    echo "ERROR: Ansible directory not found at $ANSIBLE_DIR"
    exit 1
fi

# Determine extra variables for Ansible
EXTRA_VARS="system_cleanup=false"
if [ "$CLEANUP_MODE" -eq 1 ]; then
    EXTRA_VARS="system_cleanup=true"
    echo ">>> Cleanup mode enabled."
fi

# Execute Ansible Playbook
# We target 'localhost' (homeserver) explicitly if run locally, 
# or we can run the full site.yml to include the NAS.
cd "$ANSIBLE_DIR"

echo ">>> Running Master Playbook..."
ansible-playbook -i inventory.ini site.yml -e "$EXTRA_VARS"

echo "========================================"
echo " MAINTENANCE COMPLETE"
echo "========================================"
