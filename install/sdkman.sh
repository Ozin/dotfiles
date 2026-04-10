#!/usr/bin/env bash
set -euo pipefail

echo "☕ Installing SDKMAN + Gradle..."

export SDKMAN_DIR="$HOME/.sdkman"

if [ -d "$SDKMAN_DIR" ]; then
  echo "SDKMAN already installed"
else
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
fi

# Source SDKMAN to make sdk command available
source "$SDKMAN_DIR/bin/sdkman-init.sh"

if sdk current gradle &>/dev/null; then
  echo "Gradle already installed via SDKMAN"
else
  sdk install gradle
fi

echo "✅ SDKMAN + Gradle installed"
