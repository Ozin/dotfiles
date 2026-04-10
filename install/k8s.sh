#!/usr/bin/env bash
set -euo pipefail

echo "☸️  Installing Kubernetes tools..."

# --- kubectl ---
if command -v kubectl &>/dev/null; then
  echo "kubectl already installed, skipping"
else
  echo "Adding Kubernetes apt repo..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq kubectl
fi

# --- helm ---
if command -v helm &>/dev/null; then
  echo "Helm already installed, skipping"
else
  echo "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "✅ Kubernetes tools installed"
