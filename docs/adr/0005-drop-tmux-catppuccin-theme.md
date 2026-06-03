# 0005 — Drop the tmux Catppuccin theme

**Status:** accepted
**Date:** 2026-06-03

## Context

[ADR 0004](0004-catppuccin-theme.md) standardised the stack on Catppuccin Mocha,
which included replacing tmux's Nord plugin with `catppuccin/tmux` and rendering
the Catppuccin status line (application + session modules). In practice the
default tmux status bar looks better without the plugin, so the theming on tmux
is no longer wanted.

## Decision

- Remove the `catppuccin/tmux` plugin and its `@catppuccin_flavor` setting from
  `files/tmux.conf`, along with the Catppuccin status-line configuration.
- Drop the `catppuccin/tmux` clone from the `tmux` role's plugin list.
- Drop the now-unused `xterm-ghostty:RGB` terminal-feature override (it existed
  to keep Catppuccin's hex colors from degrading); `xterm-256color:RGB` stays.

This reverses only the *tmux* part of ADR 0004. Ghostty and k9s keep their
Catppuccin Mocha theme, and the mechanism of installing tmux plugins on apply
(rather than via TPM's interactive `prefix + I`) is unchanged.

## Consequences

- **Pro:** tmux shows its default status bar, which the user prefers.
- **Pro:** Removes the duplicated plugin pin between `files/tmux.conf` and the
  `tmux` role that ADR 0004 flagged as a con.
- **Con:** Theming is no longer fully consistent across the stack — tmux is now
  unthemed while ghostty and k9s remain Catppuccin.
