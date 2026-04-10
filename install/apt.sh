#!/usr/bin/env bash
set -euo pipefail

echo "📦 Installing apt packages..."

sudo apt-get update -qq

sudo apt-get install -y -qq \
  bat \
  coreutils \
  curl \
  diffutils \
  findutils \
  gcc \
  gnupg \
  golang \
  grep \
  gzip \
  highlight \
  jq \
  make \
  maven \
  mkcert \
  openjdk-21-jdk \
  openjdk-25-jdk \
  podman \
  python3.12-venv \
  ripgrep \
  tmux \
  tree \
  unzip \
  wslu \
  x11-apps \
  xclip \
  zip \
  zsh

echo "✅ apt packages installed"
