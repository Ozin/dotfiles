# Dotfiles

Personal dev environment for Linux — Debian/Ubuntu (incl. WSL2) and Fedora/RHEL. Managed with [Ansible](https://docs.ansible.com/).

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

## Re-run Specific Roles

```bash
cd ~/projects/private/dotfiles
ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --tags "shell,git"
```

Available tags: `packages`, `shell`, `git`, `sdkman`, `nvm`, `tools`, `k8s`, `tmux`, `dotfiles`

## Structure

```
dotfiles/
├── setup.sh              # Bootstrap: clone, install ansible, run playbook
├── ansible/
│   ├── site.yml          # Main playbook
│   ├── inventory/
│   ├── group_vars/all.yml
│   └── roles/            # packages, shell, git, sdkman, nvm, tools, k8s, tmux, dotfiles
├── files/                # Config file sources (copied to $HOME by dotfiles role)
│   ├── zshrc
│   ├── gitconfig
│   ├── gitignore_global
│   ├── git-hooks/
│   ├── tmux.conf
│   ├── k9s/
│   ├── dprint/
│   ├── omz-plugins/
│   ├── bin/
│   └── git-contexts/
├── docs/adr/
├── AGENTS.md
├── CONCEPTS.md
└── README.md
```

## What's Managed

### Ansible Roles

| Role | Installs / Configures |
|------|----------------------|
| `packages` | Core CLI tools, podman, Go, zsh (apt or dnf) |
| `shell` | Oh My Zsh, Starship prompt, sets zsh as default shell |
| `git` | Git contexts (private + work when CORPORATE=true) |
| `sdkman` | SDKMAN + Gradle, Java (GraalVM), Maven |
| `nvm` | NVM + Node.js LTS |
| `tools` | Neovim, Syft, Terraform, OpenTofu, tree-sitter, dprint |
| `k8s` | kubectl, Helm, k9s |
| `tmux` | TPM (Tmux Plugin Manager) |
| `dotfiles` | All config files → `$HOME` (replaces Stow) |

### Config Files (`files/`)

| Source | Target |
|--------|--------|
| `zshrc` | `~/.zshrc` |
| `gitconfig` | `~/.gitconfig` |
| `gitignore_global` | `~/.gitignore` |
| `git-hooks/commit-msg` | `~/.git-hooks/commit-msg` |
| `tmux.conf` | `~/.config/tmux/tmux.conf` |
| `k9s/` | `~/.config/k9s/` |
| `dprint/dprint.jsonc` | `~/.config/dprint/dprint.jsonc` |
| `omz-plugins/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh` |
| `omz-plugins/plugins/gstale/` | `~/.oh-my-zsh/custom/plugins/gstale/` |
| `bin/` | `~/.local/bin/` (pbcopy, pbpaste, wslopen, xdg-open) |

## Environment Flags

| Flag | Default | Effect |
|------|---------|--------|
| `CORPORATE` | `false` | Places work git context at `~/projects/work/.gitconfig` |
