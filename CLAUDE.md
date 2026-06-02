# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file is for working *on* the repo. For installing/using it (setup commands, role and file tables, env flags) see **README.md** — don't duplicate that here.

## Read first

- **AGENTS.md** — agent working conventions: ADRs, continuous-improvement expectations, commit style, code conventions. Follow it.
- **CONCEPTS.md** — design philosophy and the full inventory of what's installed and where it comes from. Update it when a decision contradicts or extends it.
- **README.md** — user-facing setup, role/file tables, env flags. Keep accurate when packages or steps change.

## What this is

Personal Linux dotfiles (Debian/Ubuntu incl. WSL2, and Fedora/RHEL) managed by **Ansible run against localhost**. No macOS, no test suite, no build step — "running" the repo means applying the playbook (see README).

## Checking your work

```bash
ansible-lint
shellcheck setup.sh files/bin/* files/git-hooks/* files/omz-plugins/**/*.zsh
dprint fmt   # config files are formatted with dprint
```

Re-apply a role you changed to confirm it converges and is idempotent: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --tags <role> --ask-become-pass`.

## Architecture

Flow: `setup.sh` (minimal bootstrap — clone, detect apt/dnf, install Ansible) → `ansible/site.yml` → roles in `ansible/roles/`, applied in playbook order. Tunables (tool versions, `corporate` flag) live in `ansible/group_vars/all.yml`.

Two distinct layers, easy to confuse:

- **Install roles** (`packages`, `shell`, `tools`, `k8s`, …) install *software* — from system package managers, installer scripts, or GitHub releases.
- **The `dotfiles` role** places *config files*. It **symlinks** sources from `files/` into `$HOME` (`state: link, force: true`) — it does not copy them. Editing a file under `files/` immediately affects the live config. To wire up a new config file, add both the source under `files/` and a symlink task in `ansible/roles/dotfiles/tasks/main.yml` (create its parent dir in the "Ensure target directories exist" loop first).

## Conventions that bite

- **OS branching keys on `pkg_family`, not `ansible_os_family`.** `all.yml` derives `pkg_family` (`debian`/`redhat`) from the detected package manager because Fedora derivatives (e.g. Nobara) report a bogus `os_family`. Use `pkg_family` for any new per-distro logic.
- **Package names** live only in `ansible/roles/packages/vars/main.yml`: a shared `common_packages` list plus a `package_overrides` map for names that differ per family. Add OS-specific names to the override map, not to conditionals scattered in tasks.
- **Every role must be idempotent** — safe to re-run with no side effects.
- **Significant decisions get an ADR** under `docs/adr/NNNN-kebab-title.md` (next sequential number). Dropping a tool, changing structure, or picking one approach over another all qualify.
- **Commits**: single imperative one-liner, no body, no trailers, one logical change.
