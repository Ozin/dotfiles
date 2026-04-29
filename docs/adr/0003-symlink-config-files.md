# 0003 — Symlink config files instead of copying

**Status:** accepted
**Date:** 2026-04-29

## Context

The dotfiles and git roles used `ansible.builtin.copy` to place config files
from `files/` into `$HOME`. This meant edits in `$HOME` (e.g. `~/.zshrc`)
did not reflect back to the repo — you had to remember to edit the source in
`files/` and re-run the playbook. This friction made it easy to lose changes.

Since no config files use Ansible templating (design principle #4), there is
no reason to copy; the repo file can be used directly.

## Decision

Replace all `ansible.builtin.copy` tasks that place files from `files/` with
`ansible.builtin.file` using `state: link` and `force: true`. This applies to
the `dotfiles` role and the `git` role.

Tasks that use `copy` with inline `content:` (e.g. the k8s apt source list)
remain unchanged — those have no source file to symlink.

## Consequences

- **Pro:** Editing a config in `$HOME` immediately updates the repo checkout
- **Pro:** `git diff` in the dotfiles repo shows uncommitted config changes
- **Pro:** No need to re-run the playbook after editing a config file
- **Con:** Deleting the repo checkout breaks all symlinked configs
- **Con:** File permissions are inherited from the source — must be correct in `files/`
