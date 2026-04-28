# 0002 — Switch from Stow+scripts to Ansible

**Status:** accepted (supersedes 0001)
**Date:** 2026-04-28

## Context

The repo used GNU Stow for symlink management and hand-written shell scripts
(`install/*.sh`) for tool installation. This worked but had limitations:

- No declarative state — scripts used `command -v` guards but couldn't converge
- Re-running was mostly safe but not truly idempotent (no change detection)
- Adding a new tool meant writing another shell script with boilerplate
- No selective execution — had to run everything or manually pick scripts
- The previous iteration (documented in CONCEPTS.md) already used Ansible,
  proving it works well for this use case

## Decision

Replace Stow + shell scripts with Ansible roles:

- `ansible/site.yml` as the main playbook (localhost, local connection)
- One role per concern: `apt`, `shell`, `git`, `sdkman`, `nvm`, `tools`, `k8s`, `tmux`, `dotfiles`
- Config files live in `files/` (no stow directory conventions)
- `setup.sh` reduced to: clone repo → install ansible → run playbook
- Feature flags (CORPORATE) passed as extra-vars

## Consequences

- **Pro:** Truly idempotent — Ansible tracks state and skips unchanged resources
- **Pro:** Selective execution via tags (`--tags "shell,git"`)
- **Pro:** Declarative — easier to reason about desired state
- **Pro:** Built-in modules for common tasks (apt, file, git, uri, unarchive)
- **Con:** Adds Python/Ansible as a runtime dependency (~60MB apt install)
- **Con:** Slightly higher learning curve for YAML playbook syntax
- **Con:** Config files are now copied (not symlinked) — edits in `$HOME` won't
  reflect back to the repo. Must edit in `files/` and re-run.
