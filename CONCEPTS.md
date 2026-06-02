# Dotfiles — Concepts

This document captures the design philosophy and key decisions for this dotfiles repo.

## Bootstrap Strategy

- Single entry point: `setup.sh` curl-able from GitHub (`curl | bash` pattern)
- Linux only (no macOS support): Debian/Ubuntu (incl. WSL2) via apt, and Fedora/RHEL via dnf
- Supports environment flags: `CORPORATE=true` for corporate-specific settings
- `setup.sh` is minimal: clone repo → detect apt-get/dnf → install Ansible → run playbook

## Automation

- **Ansible** with local connection (`hosts: localhost`), roles-based structure
- Roles: `packages`, `shell`, `git`, `sdkman`, `nvm`, `tools`, `k8s`, `tmux`, `dotfiles`
- Each role tagged for selective execution (`--tags "shell,git"`)
- Variables (tool versions, feature flags) in `ansible/group_vars/all.yml`
- Config files stored in `files/` and symlinked via Ansible `file` module

## Package Management (apt / dnf)

The `packages` role installs system packages via the generic `ansible.builtin.package`
module, which dispatches to apt (Debian) or dnf (RedHat). Package names live in a
single `roles/packages/vars/main.yml`: a shared `common_packages` list plus a
small `package_overrides` map for names that differ per OS family (e.g.
`gnupg`/`gnupg2`, `python3.12-venv` vs venv bundled in `python3`, `fuse-libs` on
Fedora for the Neovim AppImage). WSL-only packages (`wslu`, `x11-apps`) install
only when running under WSL.

Core CLI tools: bat, coreutils, curl, diffutils, findutils, gcc, gnupg, golang,
grep, gzip, highlight, jq, make, mkcert, podman, ripgrep, tmux, tree, unzip,
xclip, zip, zsh. The JVM toolchain (Java, Maven) is managed via SDKMAN, not
system packages.

## Shell — Zsh

- **Framework**: Oh My Zsh (installed via official script)
- **Prompt**: Starship
- **Plugins**: git, z, kubectl, mvn, gradle, helm, python, gstale (custom)
- **Custom aliases**: vim/vi/v → nvim, dotenv helper, git push hyperlinks
- **Path**: `~/.local/bin`, `~/.dprint/bin`

## Git

- **Conditional includes**: per-directory `.gitconfig` (`~/projects/work/`, `~/projects/private/`)
- `user.useConfigOnly = true` — forces explicit user config per repo context
- `pull.rebase = true`, `rerere.enabled = true`, `column.ui = auto`
- `init.defaultBranch = main`
- **Diff**: diff-so-fancy as core pager (installed as a binary by the `tools` role, not an OMZ plugin)
- **Hooks**: `~/.git-hooks/commit-msg` (JIRA ticket prefix from branch name)

## Tools Installed from External Sources

| Tool | Method |
|------|--------|
| Oh My Zsh | installer script |
| Starship | installer script |
| SDKMAN + Gradle, Java (GraalVM), Maven | installer script + `sdk install` |
| NVM + Node.js LTS | installer script |
| Neovim | AppImage → /opt/nvim/, symlink ~/.local/bin/nvim |
| kickstart.nvim | git clone → ~/.config/nvim |
| k9s | GitHub release tar → ~/.local/bin/k9s |
| Syft | GitHub release tar → ~/.local/bin/syft |
| Terraform | HashiCorp zip → ~/.local/bin/terraform |
| OpenTofu | GitHub release zip → ~/.local/bin/tofu |
| tree-sitter | GitHub release gz → /opt/tree-sitter/, symlink ~/.local/bin/tree-sitter |
| dprint | installer script → ~/.dprint/bin/dprint |
| diff-so-fancy | GitHub release (FatPacker script) → ~/.local/bin/diff-so-fancy |
| kubectl | Kubernetes apt repo (Debian) / yum repo (RedHat) |
| Helm | installer script |
| TPM | git clone → ~/.config/tmux/plugins/tpm |

## Corporate Environment

When `CORPORATE=true`:
- Work git context placed at `~/projects/work/.gitconfig`

## Design Principles

1. **Idempotent** — every role safe to re-run without side effects
2. **Tagged** — selective execution via `--tags`
3. **Declarative** — Ansible modules handle state convergence
4. **No templating** — config files symlinked as-is (no variables to inject)
5. **Minimal bootstrap** — `setup.sh` only ensures git + ansible, then delegates
