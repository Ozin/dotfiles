# Dotfiles — Concepts

This document captures the design philosophy and key decisions for this dotfiles repo.

## Bootstrap Strategy

- Single entry point: `setup.sh` curl-able from GitHub (`curl | bash` pattern)
- WSL2 / Ubuntu only (no macOS support)
- Supports environment flags: `CORPORATE=true` for corporate-specific settings
- `setup.sh` is minimal: clone repo → install Ansible → run playbook

## Automation

- **Ansible** with local connection (`hosts: localhost`), roles-based structure
- Roles: `apt`, `shell`, `git`, `sdkman`, `nvm`, `tools`, `k8s`, `tmux`, `dotfiles`
- Each role tagged for selective execution (`--tags "shell,git"`)
- Variables (tool versions, feature flags) in `ansible/group_vars/all.yml`
- Config files stored in `files/` and placed via Ansible `copy` module

## Package Management (APT)

Core CLI tools installed via apt role:
bat, coreutils, curl, diffutils, findutils, gcc, gnupg, golang, grep, gzip,
highlight, jq, make, maven, mkcert, openjdk-21-jdk, openjdk-25-jdk, podman,
python3.12-venv, ripgrep, tmux, tree, unzip, wslu, x11-apps, xclip, zip, zsh

## Shell — Zsh

- **Framework**: Oh My Zsh (installed via official script)
- **Prompt**: Starship
- **Plugins**: git, z, diff-so-fancy, kubectl, mvn, gradle, helm, python, gstale (custom)
- **Custom aliases**: vim/vi/v → nvim, dotenv helper, git push hyperlinks
- **Path**: `~/.local/bin`, `~/.dprint/bin`

## Git

- **Conditional includes**: per-directory `.gitconfig` (`~/projects/work/`, `~/projects/private/`)
- `user.useConfigOnly = true` — forces explicit user config per repo context
- `pull.rebase = true`, `rerere.enabled = true`, `column.ui = auto`
- `init.defaultBranch = main`
- **Diff**: diff-so-fancy as core pager
- **Hooks**: `~/.git-hooks/commit-msg` (JIRA ticket prefix from branch name)

## Tools Installed from External Sources

| Tool | Method |
|------|--------|
| Oh My Zsh | installer script |
| Starship | installer script |
| SDKMAN + Gradle | installer script |
| NVM + Node.js LTS | installer script |
| Neovim | AppImage → /opt/nvim/, symlink ~/.local/bin/nvim |
| kickstart.nvim | git clone → ~/.config/nvim |
| k9s | GitHub release tar → ~/.local/bin/k9s |
| Syft | GitHub release tar → ~/.local/bin/syft |
| Terraform | HashiCorp zip → ~/.local/bin/terraform |
| OpenTofu | snap → symlink ~/.local/bin/tofu |
| tree-sitter | GitHub release gz → /opt/tree-sitter/, symlink ~/.local/bin/tree-sitter |
| dprint | installer script → ~/.dprint/bin/dprint |
| kubectl | Kubernetes apt repo |
| Helm | installer script |
| TPM | git clone → ~/.config/tmux/plugins/tpm |

## Corporate Environment

When `CORPORATE=true`:
- Work git context placed at `~/projects/work/.gitconfig`

## Design Principles

1. **Idempotent** — every role safe to re-run without side effects
2. **Tagged** — selective execution via `--tags`
3. **Declarative** — Ansible modules handle state convergence
4. **No templating** — config files copied as-is (no variables to inject)
5. **Minimal bootstrap** — `setup.sh` only ensures git + ansible, then delegates
