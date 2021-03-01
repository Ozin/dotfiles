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

# Add ~/bin to path variable
# https://github.com/fish-shell/fish-shell/issues/527
mkdir ~/bin
contains ~/bin $fish_user_paths; or set -Ua fish_user_paths ~/bin
contains /usr/local/opt/coreutils/libexec/gnubin $fish_user_paths; or set -Ua fish_user_paths /usr/local/opt/coreutils/libexec/gnubin

# Add /usr/local/sbin to path on behalf of homebrew
contains /usr/local/sbin $fish_user_paths; or set -Ua fish_user_paths /usr/local/sbin
