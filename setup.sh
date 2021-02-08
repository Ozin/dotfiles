#!/usr/bin/env bash

set -eux

if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v git &> /dev/null
then
    brew install git
fi

mkdir -p ~/Documents/projects
cd ~/Documents/projects

git clone https://github.com/Ozin/dotfiles.git
cd dotfiles

ls */**.sh | sh -x
