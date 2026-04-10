#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Installing Starship prompt..."

if command -v starship &>/dev/null; then
  echo "Starship already installed, skipping"
else
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

echo "✅ Starship installed"
