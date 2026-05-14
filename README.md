# Kevin's Dotfiles & Ansible Infrastructure

## Overview
This repository contains personal user configurations and the master Ansible playbook for infrastructure management.

## Key Components
- **Ansible:** Located in \`ansible/\`. Manages package installation and directory structures on Desktop and NAS.
- **Semaphore:** UI for Ansible, accessible via Tailscale.
- **Vault Logic:** \`vault-unlock.sh\` manages secure Bitwarden sessions in RAM (\`/run/vault/\`).

## Security (Zero-Leak Policy)
- All secrets are managed via environment variables and local \`.env\` files.
- \`.env\` files are strictly ignored by Git.

---
*Refer to GEMINI.md for architectural rules and SRE guidelines.*
