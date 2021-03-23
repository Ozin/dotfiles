#!/usr/bin/env bash

apps=(
    bind
    binutils       # FSF Binutils for native development
    curl
    coreutils      # GNU File, Shell, and Text utilities
    diffutils      # File comparison utilities
    diff-so-fancy
    findutils      # GNU find, xargs, and locate
    fish
    git
    gpg
    # gnu-sed
    # gnu-which
    htop
    grep
    java
    less
    maven
    node
    # z            # Added by fisher
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
    microsoft-teams
    skype
    spotify
    telegram-desktop
    visual-studio-code
    vlc
    zoom
)

brew install --cask "${casks[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install --cask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv webpquicklook suspicious-package && qlmanage -r
