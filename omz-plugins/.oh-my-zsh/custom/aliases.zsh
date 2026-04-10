alias vim="nvim"
alias vi="vim"
alias v="vi"

alias gp!="git push --force-with-lease"
alias aliasG="alias | grep"

alias gprev="gcm -q && git merge --no-commit --no-ff -- - 2> /dev/null && gdca && gma && gco -q -"

# Load .env and run a single command in a subshell (zsh-safe)
dotenv() {
  local env_file=".env"
  if [[ "$1" == "-f" && -n "$2" ]]; then
    env_file="$2"
    shift 2
  fi

  if [[ ! -f "$env_file" ]]; then
    print -u2 "dotenv: env file not found: $env_file"
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    print -u2 "dotenv: no command provided. Usage: dotenv [-f FILE] command [args...]"
    return 2
  fi

  (
    emulate -L sh
    set -a
    source "$env_file"
    set +a
    exec "$@"
  )
}

# Wrap URLs in git push output with OSC 8 hyperlinks
git() {
    if [[ "$1" == "push" ]]; then
        command git "$@" 2>&1 | sed -E 's|(https?://[^[:space:]]+)|\x1b]8;;\1\x1b\\\1\x1b]8;;\x1b\\|g'
    else
        command git "$@"
    fi
}

copilot() {
  command copilot --allow-tool "shell(man)" --allow-tool "context7-resolve-library-id" --allow-tool "context7-get-library-docs" "$@"
}
