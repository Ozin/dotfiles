#!/usr/bin/env bash
set -euo pipefail

echo "🐚 Installing Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed, skipping"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "✅ Oh My Zsh installed"
