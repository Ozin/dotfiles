# See other themes at
# ~/.config/fish/functions/__bobthefish_colors.fish
function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'

    # optionally include a base color scheme...
    __bobthefish_colors terminal-dark

    # then override everything you want! note that these must be defined with `set -x`
    set -x color_repo_dirty               bryellow $colorfg
    set -x color_repo_staged              brblue $colorfg

end

#set fish_color_search_match --background=black
#set fish_color_command green

set theme_title_display_process yes
set theme_title_use_abbreviated_path yes

# aliases/abbrs
abbr -ag "-" "cd -"
abbr -ag "..." "cd ../../"
abbr -ag "...." "cd ../../../"
abbr -ag "....." "cd ../../../../"

# Homebrew set paths
! set -q PATH; and set PATH ''; set -gx PATH "/opt/homebrew/bin" "/opt/homebrew/sbin" $PATH;
! set -q MANPATH; and set MANPATH ''; set -gx MANPATH "/opt/homebrew/share/man" $MANPATH;
! set -q INFOPATH; and set INFOPATH ''; set -gx INFOPATH "/opt/homebrew/share/info" $INFOPATH;
