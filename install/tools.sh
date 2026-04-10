#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
OPT_DIR="/opt"
mkdir -p "$INSTALL_DIR"

# --- Neovim ---
echo "📝 Installing Neovim..."

if command -v nvim &>/dev/null; then
  echo "Neovim already installed, skipping"
else
  sudo mkdir -p "$OPT_DIR/nvim"
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
  sudo curl -fsSL "$NVIM_URL" -o "$OPT_DIR/nvim/nvim-linux-x86_64.appimage"
  sudo chmod +x "$OPT_DIR/nvim/nvim-linux-x86_64.appimage"
  ln -sf "$OPT_DIR/nvim/nvim-linux-x86_64.appimage" "$INSTALL_DIR/nvim"
  echo "Neovim installed to $OPT_DIR/nvim/, symlinked to $INSTALL_DIR/nvim"
fi

# --- Neovim config (kickstart.nvim) ---
echo "📝 Setting up Neovim config..."

if [ -d "$HOME/.config/nvim/.git" ]; then
  echo "kickstart.nvim already cloned, skipping"
else
  git clone --depth=1 https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
  echo "kickstart.nvim cloned to ~/.config/nvim/"
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

# --- syft ---
echo "📦 Installing Syft..."

if command -v syft &>/dev/null; then
  echo "Syft already installed, skipping"
else
  SYFT_VERSION=$(curl -fsSL "https://api.github.com/repos/anchore/syft/releases/latest" | jq -r '.tag_name')
  SYFT_URL="https://github.com/anchore/syft/releases/download/${SYFT_VERSION}/syft_${SYFT_VERSION#v}_linux_amd64.tar.gz"
  curl -fsSL "$SYFT_URL" | tar xz -C "$INSTALL_DIR" syft
  chmod +x "$INSTALL_DIR/syft"
  echo "Syft ${SYFT_VERSION} installed to $INSTALL_DIR/syft"
fi

# --- terraform ---
echo "🏗️  Installing Terraform..."

if command -v terraform &>/dev/null; then
  echo "Terraform already installed, skipping"
else
  TF_VERSION=$(curl -fsSL "https://api.github.com/repos/hashicorp/terraform/releases/latest" | jq -r '.tag_name | ltrimstr("v")')
  TF_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
  curl -fsSL "$TF_URL" -o /tmp/terraform.zip
  unzip -qo /tmp/terraform.zip -d "$INSTALL_DIR"
  chmod +x "$INSTALL_DIR/terraform"
  rm -f /tmp/terraform.zip
  echo "Terraform ${TF_VERSION} installed to $INSTALL_DIR/terraform"
fi

# --- OpenTofu ---
echo "🟩 Installing OpenTofu..."

if command -v tofu &>/dev/null; then
  echo "OpenTofu already installed, skipping"
else
  sudo snap install opentofu --classic
  ln -sf /snap/opentofu/current/tofu "$INSTALL_DIR/tofu"
  echo "OpenTofu installed via snap, symlinked to $INSTALL_DIR/tofu"
fi

# --- tree-sitter ---
echo "🌳 Installing tree-sitter CLI..."

if command -v tree-sitter &>/dev/null; then
  echo "tree-sitter already installed, skipping"
else
  sudo mkdir -p "$OPT_DIR/tree-sitter"
  TS_VERSION=$(curl -fsSL "https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest" | jq -r '.tag_name')
  TS_URL="https://github.com/tree-sitter/tree-sitter/releases/download/${TS_VERSION}/tree-sitter-linux-x64.gz"
  curl -fsSL "$TS_URL" | gunzip | sudo tee "$OPT_DIR/tree-sitter/tree-sitter-linux-x64" >/dev/null
  sudo chmod +x "$OPT_DIR/tree-sitter/tree-sitter-linux-x64"
  ln -sf "$OPT_DIR/tree-sitter/tree-sitter-linux-x64" "$INSTALL_DIR/tree-sitter"
  echo "tree-sitter ${TS_VERSION} installed to $OPT_DIR/tree-sitter/, symlinked to $INSTALL_DIR/tree-sitter"
fi

# --- dprint ---
echo "🖨️  Installing dprint..."

if command -v dprint &>/dev/null; then
  echo "dprint already installed, skipping"
else
  curl -fsSL https://dprint.dev/install.sh | sh
  echo "dprint installed to ~/.dprint/bin/dprint"
fi

echo "✅ Tools installed"
