# OpenSpec shell completions
fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit

export PATH=$HOME/.local/bin:$HOME/.dprint/bin:$PATH

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git z diff-so-fancy kubectl mvn gradle helm python gstale)

source $ZSH/oh-my-zsh.sh

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Java
export JAVA_HOME=$(readlink -nf $(which java) | xargs dirname | xargs dirname)
export M2_HOME=$HOME/.sdkman/candidates/maven/current/bin/mvn

# Starship prompt
eval "$(starship init zsh)"

# SSH agent with tmux persistence
eval "$(tmux showenv -sg | grep ^SSH | sed 's/^/export /')" 2>/dev/null || true
if [ -z "${SSH_AUTH_SOCK:-}" ] || [ -z "${SSH_AGENT_PID:-}" ] || ! ps -p "${SSH_AGENT_PID:-0}" > /dev/null 2>&1 || [ ! -S "${SSH_AUTH_SOCK:-}" ]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
  tmux set-environment -g SSH_AGENT_PID "$SSH_AGENT_PID" 2>/dev/null || true
  tmux set-environment -g SSH_AUTH_SOCK "$SSH_AUTH_SOCK" 2>/dev/null || true
fi

# SDKMAN (must be near end)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# NVM (must be at end)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
