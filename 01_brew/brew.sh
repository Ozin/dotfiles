#!/usr/bin/env bash

apps=(
    bind
    binutils       # FSF Binutils for native development
    curl
    diffutils      # File comparison utilities
    findutils      # GNU find, xargs, and locate
    fish
    git
    # gnu-sed
    # gnu-which
    grep
    java
    less
    maven
    z
)

brew install "${apps[@]}"

# Install Caskroom
brew tap homebrew/cask

# Install packages
casks=(
    brave-browser
    docker
    dropbox
    intellij-idea-ce
    iterm2
    keepassxc
    skype
    spotify
    telegram-desktop
    visual-studio-code
    vlc
    zoom
)

brew install --cask "${casks[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install --cask qlmarkdown quicklook-json qlprettypatch quicklook-csv webpquicklook suspicious-package && qlmanage -r
