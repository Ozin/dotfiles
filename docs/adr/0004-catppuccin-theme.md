# 0004 — Standardise on Catppuccin Mocha and install tmux plugins on apply

**Status:** accepted (tmux theming reversed by [ADR 0005](0005-drop-tmux-catppuccin-theme.md))
**Date:** 2026-06-02

## Context

Theming had drifted across tools. Ghostty was set to **Catppuccin Mocha**
(the most recently added terminal), while tmux still loaded the **Nord** theme
(`arcticicestudio/nord-tmux`) and k9s used a Nord skin. With the shell now
auto-attaching to a tmux session on every interactive launch, tmux's theme is
always on screen — so the Nord/Catppuccin mismatch became the dominant visual.

Two further problems surfaced:

- The tmux role cloned TPM but never installed the plugins it references, so
  themes only applied after a manual `prefix + I`. Until then tmux showed its
  stock green status bar — neither Nord nor Catppuccin.
- The tmux truecolor override targeted `xterm-256color`, but ghostty reports
  `TERM=xterm-ghostty`, so RGB passthrough never matched and hex colors
  degraded to the 256-color palette.

## Decision

- Use **Catppuccin Mocha** as the single theme across the stack. Replace the
  tmux Nord plugin with `catppuccin/tmux` (pinned `v2.3.0`, `@catppuccin_flavor
  mocha`) and the k9s Nord skin with the upstream `catppuccin-mocha` skin.
- Install tmux plugins as part of the `tmux` role by cloning each referenced
  plugin repo with `ansible.builtin.git` (mirroring the existing TPM clone),
  rather than relying on TPM's interactive install. This avoids a dependency on
  the `dotfiles` role (which symlinks `tmux.conf`) having run first.
- Fix truecolor by setting the `RGB` terminal feature for `xterm-ghostty`.

## Consequences

- **Pro:** One consistent look across ghostty, tmux, and k9s.
- **Pro:** Themes apply on `ansible-playbook` with no manual `prefix + I`.
- **Pro:** Correct truecolor rendering inside tmux under ghostty.
- **Con:** The plugin list (and the `catppuccin/tmux` version pin) is duplicated
  between `files/tmux.conf` and the `tmux` role — they must be kept in sync.
