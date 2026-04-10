# Dotfiles

Personal dev environment for WSL2 / Ubuntu. Managed with [GNU Stow](https://www.gnu.org/software/stow/) + shell scripts.

## Quick Start

```bash
# Fresh machine (curl | bash)
curl -fsSL https://raw.githubusercontent.com/ozin/dotfiles/main/setup.sh | bash

# Corporate environment
CORPORATE=true curl -fsSL https://raw.githubusercontent.com/ozin/dotfiles/main/setup.sh | bash
```

## Manual Setup

```bash
git clone https://github.com/ozin/dotfiles.git ~/projects/private/dotfiles
cd ~/projects/private/dotfiles
./setup.sh
```

## What's Inside

### Stow Packages (config files → `$HOME`)

| Package | Contents |
|---------|----------|
| `zsh/` | `.zshrc` — Oh My Zsh, Starship prompt, SDKMAN, NVM, SSH agent + tmux |
| `git/` | `.gitconfig`, global `.gitignore`, `.git-hooks/commit-msg` (JIRA ticket prefix) |
| `omz-plugins/` | Custom OMZ plugin: `gstale` (stale branch management) |

### Install Scripts (`install/`)

| Script | Installs |
|--------|----------|
| `apt.sh` | Core CLI tools, podman, Java, Go, zsh |
| `omz.sh` | Oh My Zsh |
| `starship.sh` | Starship prompt |
| `sdkman.sh` | SDKMAN + Gradle |
| `nvm.sh` | NVM + Node.js LTS |
| `tools.sh` | Neovim, k9s |
| `k8s.sh` | kubectl, Helm |

### Git Contexts (`git-contexts/`)

Per-project Git user configs placed by `setup.sh`:

- `private.gitconfig` → `~/projects/private/.gitconfig`
- `work.gitconfig` → `~/projects/work/.gitconfig` (only when `CORPORATE=true`)

## Re-stow After Changes

```bash
cd ~/projects/private/dotfiles
stow -v -t $HOME zsh git omz-plugins
```

## Environment Flags

| Flag | Default | Effect |
|------|---------|--------|
| `CORPORATE` | `false` | Enables corporate git context (work) |
