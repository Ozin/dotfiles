#!/usr/bin/env bash
#
# Dotfiles bootstrap — clone repo, install Ansible, run playbook
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ozin/dotfiles/main/setup.sh | bash
#   CORPORATE=true ./setup.sh
#
set -euo pipefail

REPO_URL="https://github.com/ozin/dotfiles.git"
CLONE_DIR="$HOME/projects/private/dotfiles"
CORPORATE="${CORPORATE:-false}"

info() { printf "\n\033[1;34m→ %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m❌ %s\033[0m\n" "$*" >&2; exit 1; }

# OS check
if [[ "$(uname -s)" != "Linux" ]]; then
  err "Unsupported OS. Only Linux (incl. WSL2) is supported."
fi

# Clone if needed
if [ ! -d "$CLONE_DIR/.git" ]; then
  info "Cloning dotfiles repo..."
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone --depth=1 "$REPO_URL" "$CLONE_DIR"
fi
cd "$CLONE_DIR"

# Install Ansible
if ! command -v ansible-playbook &>/dev/null; then
  info "Installing Ansible..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ansible
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y -q ansible
  else
    err "No supported package manager found (need apt-get or dnf)."
  fi
fi

# Run playbook
info "Running Ansible playbook..."
ansible-playbook ansible/site.yml \
  --inventory ansible/inventory/localhost.yml \
  --extra-vars "corporate=$CORPORATE" \
  --ask-become-pass

printf "\n\033[1;32m✅ Dotfiles setup complete!\033[0m\n"
echo "  Default shell changed to zsh. Opening a new terminal window is NOT enough —"
echo "  your desktop session still holds the old \$SHELL. Log out and back in (or reboot)."
echo "  To switch the current shell immediately: exec zsh"
