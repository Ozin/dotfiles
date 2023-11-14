#!/usr/bin/env fish

mkdir -p "../downloads"

# download 
curl -L https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors > "../downloads/material-design-colors.itermcolors"

# install nerd font

# curl -L https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf > "../downloads/Roboto Mono Nerd Font Complete Mono.ttf"
# open "../downloads/Roboto Mono Nerd Font Complete Mono.ttf"

curl -L https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf > "../downloads/JetBrains Mono Regular Nerd Font Complete.ttf"
open "../downloads/JetBrains Mono Regular Nerd Font Complete.ttf"

# alterative font
# https://monaspace.githubnext.com/
