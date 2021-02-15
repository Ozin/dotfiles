# See other themes at
# ~/.config/fish/functions/__bobthefish_colors.fish
function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'

    # optionally include a base color scheme...
    __bobthefish_colors terminal-dark

    # then override everything you want! note that these must be defined with `set -x`
    set -x color_repo_dirty               bryellow $colorfg
    set -x color_repo_staged              brblue $colorfg

end

set fish_color_search_match --background=black
set fish_color_command green

set theme_title_display_process yes
set theme_title_use_abbreviated_path yes

# aliases/abbrs
abbr -ag "-" "cd -"
abbr -ag "..." "cd ../../"
abbr -ag "...." "cd ../../../"
abbr -ag "....." "cd ../../../../"

source ~/Documents/projects/dotfiles/03_config/files/computer_specific.fish