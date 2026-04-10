#!/usr/bin/env bash
set -euo pipefail

echo "📗 Installing NVM + Node.js..."

export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
  echo "NVM already installed"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Source NVM to make nvm command available
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if nvm current | grep -q "^v"; then
  echo "Node.js already installed: $(nvm current)"
else
  nvm install --lts
fi

echo "✅ NVM + Node.js installed"
