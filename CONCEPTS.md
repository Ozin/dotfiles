# Dotfiles — Concepts from Previous Setup

This document captures the ideas, tools, and configurations from the previous dotfiles iteration
so they can inform a fresh rewrite.

## Bootstrap Strategy

- Single entry point: `setup.sh` curl-able from GitHub (`curl | bash` pattern)
- OS detection (macOS / Linux) with per-OS install paths
- Supports environment flags: `CORPORATE=true` for corporate-specific settings
- Installs prerequisites first (Xcode CLI tools → Homebrew → Ansible), then hands off to Ansible

## Automation

- **Ansible** with local connection (`hosts: localhost`), roles-based structure
- Roles: `homebrew`, `fish`, `git`, `iterm2`, `vscode`, `dockutil`, `macos`, `homebrew_cleanup`
- An older **shell-script layer** coexisted (`01_brew/`, `02_set_shell/`, `03_config/`) — was partially superseded by Ansible
- Inspired by [github.com/lony/dotFiles](https://github.com/lony/dotFiles)

## Package Management (Homebrew)

### Taps

- `homebrew/cask-fonts`

### Formulae (selection of what was actively used)

- **Core CLI**: coreutils, binutils, diffutils, findutils, inetutils, gawk, grep, less, curl, tree, watch, htop, jq, brotli
- **Shell**: bash, fish
- **Git**: git, diff-so-fancy, grc
- **Security**: gnupg, openssl, ssh-copy-id
- **Dev tools**: neovim, asdf, ansible, dockutil, z, screen
- **Java**: openjdk, maven, graalvm-jdk
- **JavaScript**: node
- **Cloud/Infra**: awscli

### Casks (selection of what was actively used)

- **Browsers**: Firefox, Brave, DuckDuckGo
- **Terminal**: iTerm2
- **Editor/IDE**: Visual Studio Code, IntelliJ IDEA CE
- **Fonts**: JetBrains Mono, Monaspace, Monaspace Nerd Font
- **Productivity**: Obsidian, Dropbox, TomatoBar, Telegram, Webex, Spotify, DrawIO, GIMP
- **Security**: KeePassXC, Keystore Explorer, AlDente (battery)
- **DevOps**: Docker, kubernetes-cli, k9s, Helm
- **Java**: IntelliJ IDEA CE

## Shell — Fish

- **Plugin manager**: Fisher
- **Theme**: bobthefish (with Nerd Fonts enabled, terminal-dark base, custom dirty/staged colors)
- **Plugins**: fisher, bass, bobthefish, brew-completions, z, colored_man_pages, custom git plugin (`ozin/plugin-git`)
- **Abbreviations**: `-` → `cd -`, `...` → `cd ../../`, etc.
- **Path additions**: `~/bin`, `/usr/local/sbin`, Homebrew paths, OpenJDK
- **Config**: `config.fish` symlinked into `~/.config/fish/`
- **Computer-specific overrides**: sourced from a separate `computer_specific.fish` file (gitignored)

## Git

- **Conditional includes**: per-directory `.gitconfig` (e.g. `~/Documents/projects/allianz/`, `~/Documents/projects/private/`)
- `user.useConfigOnly = true` — forces explicit user config per repo context
- `pull.rebase = true`
- `rerere.enabled = true`
- `column.ui = auto`
- `init.defaultBranch = main`
- **Diff**: diff-so-fancy as core pager with custom color scheme

## Terminal — iTerm2

- Material Design color scheme
- JetBrains Mono / Monaspace Nerd Fonts
- Settings managed via plist file

## Editor — VS Code

- Settings symlinked from dotfiles repo
- **Theme**: Nord, Material Theme
- **Key extensions**: GitLens, Prettier, ESLint, Docker, Java pack (RedHat + vscjava), Rust Analyzer, Svelte, YAML/XML, Markdown All in One, indent-rainbow, Fish syntax, OpenAPI lint, Live Server

## macOS Settings

- **Locale**: German (`de_DE`), EUR currency, metric units
- **Timezone**: Europe/Berlin
- **Clock**: `EEE d. MMM HH:mm:ss` format in menu bar
- **Trackpad**: Tap-to-click enabled
- **Boot**: System audio volume silenced
- **Battery**: Percentage shown in menu bar
- **Keyboard**: Disabled "Search man Page" shortcut, hidden input menu selector

## Dock (via dockutil)

Curated app order: Telegram, Citrix Workspace, Spotify, Obsidian, IntelliJ, VS Code,
Teams, Outlook, Webex, Firefox, DuckDuckGo, iTerm, KeePassXC

## Corporate Environment

When `CORPORATE=true`:
- `HOMEBREW_AUTO_UPDATE_SECS=86400` (daily updates only)
- `HOMEBREW_CASK_OPTS='--appdir=~/Applications --fontdir=/Library/Fonts'`
- `HOMEBREW_INSTALL_CLEANUP=1`
- `HOMEBREW_NO_ANALYTICS=1`
- Ansible skips tags marked `corporate-do-not`
