#!/usr/bin/env bash
#
# Dotfiles setup — single entry point
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ozin/dotfiles/main/setup.sh | bash
#   CORPORATE=true ./setup.sh
#
set -euo pipefail

## Config

GIT_REPO_URL="https://github.com/ozin/dotfiles.git"
GIT_REPO_BRANCH="main"
GIT_CLONE_DIR="$HOME/projects/private/dotfiles"
DOTFILES_DIR="${DOTFILES_DIR:-$GIT_CLONE_DIR}"
CORPORATE="${CORPORATE:-false}"

## Helpers

info()  { printf "\\n\\033[1;34m→ %s\\033[0m\\n" "$*"; }
ok()    { printf "\\033[1;32m✅ %s\\033[0m\\n" "$*"; }
warn()  { printf "\\033[1;33m⚠  %s\\033[0m\\n" "$*"; }
err()   { printf "\\033[1;31m❌ %s\\033[0m\\n" "$*" >&2; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

## OS / WSL detection

detect_os() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "linux"
  else
    err "Unsupported OS: $(uname -s). Only WSL/Linux is supported."
  fi
}

## Clone repo if running via curl | bash

clone_if_needed() {
  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    info "Cloning dotfiles repo..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone --depth=1 --branch "$GIT_REPO_BRANCH" "$GIT_REPO_URL" "$DOTFILES_DIR"
  fi
  cd "$DOTFILES_DIR"
}

## Run install scripts

run_installers() {
  local scripts=(
    apt.sh
    omz.sh
    starship.sh
    sdkman.sh
    nvm.sh
    tools.sh
    k8s.sh
  )

  for script in "${scripts[@]}"; do
    local path="$DOTFILES_DIR/install/$script"
    if [ -f "$path" ]; then
      info "Running install/$script..."
      bash "$path"
    else
      warn "install/$script not found, skipping"
    fi
  done
}

## Stow packages

stow_packages() {
  info "Stowing config packages..."

  if ! command_exists stow; then
    sudo apt-get install -y -qq stow
  fi

  local packages=(zsh git omz-plugins bin tmux k9s dprint)

  for pkg in "${packages[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
      stow -v -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
      ok "Stowed $pkg"
    else
      warn "Stow package '$pkg' not found, skipping"
    fi
  done
}

## Place git-contexts

place_git_contexts() {
  info "Placing git-context configs..."

  # Private
  mkdir -p "$HOME/projects/private"
  cp "$DOTFILES_DIR/git-contexts/private.gitconfig" "$HOME/projects/private/.gitconfig"
  ok "Placed ~/projects/private/.gitconfig"

  # Corporate (work)
  if [ "$CORPORATE" = "true" ]; then
    mkdir -p "$HOME/projects/work"
    cp "$DOTFILES_DIR/git-contexts/work.gitconfig" "$HOME/projects/work/.gitconfig"
    ok "Placed ~/projects/work/.gitconfig"
  else
    info "Skipping corporate git context (set CORPORATE=true to enable)"
  fi
}

## Set default shell

set_default_shell() {
  if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    ok "Default shell set to zsh (restart terminal to take effect)"
  else
    ok "zsh is already the default shell"
  fi
}

## Make git hooks executable + install tmux plugins

fix_permissions() {
  chmod +x "$HOME/.git-hooks/commit-msg" 2>/dev/null || true
}

install_tmux_plugins() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  if [ ! -d "$tpm_dir" ]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    ok "TPM installed — run 'prefix + I' inside tmux to install plugins"
  else
    ok "TPM already installed"
  fi
}

## Main

main() {
  local os
  os=$(detect_os)

  info "Dotfiles setup starting..."
  printf "  OS:        %s\\n" "$os"
  printf "  Corporate: %s\\n" "$CORPORATE"
  printf "  Dotfiles:  %s\\n" "$DOTFILES_DIR"

  clone_if_needed
  run_installers
  stow_packages
  place_git_contexts
  fix_permissions
  install_tmux_plugins
  set_default_shell

  ok "Dotfiles setup complete! 🎉"
  echo "  Restart your terminal or run: exec zsh"
}

main "$@"
