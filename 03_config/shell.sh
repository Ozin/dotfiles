#!/usr/bin/env fish

# install fisher and plugins
curl -sL https://git.io/fisher | source
set fisher_plugins \
    jorgebucaran/fisher \
    edc/bass \
    oh-my-fish/theme-bobthefish \
    laughedelic/brew-completions \
    jethrokuan/z \
    patrickf3139/colored_man_pages.fish \
    ozin/plugin-git

for plugin in $fisher_plugins
    fisher install $plugin
end

set -g theme_nerd_fonts yes

ln -sv (pwd)"/03_config/files/config.fish" ~/.config/fish
