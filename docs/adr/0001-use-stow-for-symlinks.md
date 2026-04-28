# 0001 — Use GNU Stow for symlink management

**Status:** accepted
**Date:** 2026-04-28

## Context

The previous iteration used Ansible to manage dotfile symlinks. Ansible adds significant
complexity (Python dependency, role structure, playbook syntax) for what is essentially
creating symlinks from a git repo to `$HOME`.

## Decision

Use GNU Stow as the symlink manager. Each top-level directory in the repo is a "stow
package" that mirrors the target directory structure (defaulting to `$HOME`).

## Consequences

- Simpler mental model: directory layout *is* the symlink layout
- No Python/Ansible dependency — Stow is a single Perl script available via apt
- Trade-off: no built-in conditional logic (handled by `setup.sh` instead)
