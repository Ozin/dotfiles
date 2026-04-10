#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# --- Neovim ---
echo "📝 Installing Neovim..."

if command -v nvim &>/dev/null; then
  echo "Neovim already installed, skipping"
else
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
  curl -fsSL "$NVIM_URL" -o "$INSTALL_DIR/nvim"
  chmod +x "$INSTALL_DIR/nvim"
  echo "Neovim installed to $INSTALL_DIR/nvim"
fi

# --- k9s ---
echo "🐶 Installing k9s..."

if command -v k9s &>/dev/null; then
  echo "k9s already installed, skipping"
else
  K9S_VERSION=$(curl -fsSL "https://api.github.com/repos/derailed/k9s/releases/latest" | jq -r '.tag_name')
  K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
  curl -fsSL "$K9S_URL" | tar xz -C "$INSTALL_DIR" k9s
  chmod +x "$INSTALL_DIR/k9s"
  echo "k9s ${K9S_VERSION} installed to $INSTALL_DIR/k9s"
fi

echo "✅ Tools installed"
