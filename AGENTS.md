# Agent Instructions

Guidelines for AI agents working in this repository.

## Philosophy

This repo is a living system. Agents should **improve it continuously** — not just complete
the immediate task. If you notice something that could be better (structure, docs, naming,
missing automation), fix it or propose it.

## Critical Thinking

**Stay critical.** Do not default to agreement or the path of least resistance. When the user
proposes an approach, evaluate it honestly — weigh trade-offs, name downsides, suggest
alternatives. Praise only what genuinely deserves it. The goal is the best outcome, not
a comfortable conversation.

## Architecture Decision Records (ADRs)

Record significant decisions in `docs/adr/` using the format `NNNN-kebab-title.md`.

### When to write an ADR

- Choosing a tool or approach over alternatives (e.g. Stow vs Ansible)
- Changing project structure or conventions
- Dropping support for something previously supported
- Any decision a future reader might ask "why?"

### ADR template

```markdown
# NNNN — Title

**Status:** accepted | superseded | deprecated
**Date:** YYYY-MM-DD

## Context

What is the problem or situation?

## Decision

What was decided?

## Consequences

What are the trade-offs?
```

### Numbering

Use the next sequential number. Check existing files in `docs/adr/` to determine the next
available number.

## Continuous Improvement

When working on any task, also consider:

1. **CONCEPTS.md** — If a decision contradicts or extends what's documented there, update it.
2. **README.md** — Keep it accurate. If you add/remove packages or change setup steps, reflect
   that here.
3. **Structure** — If a file is in the wrong place or a directory name is unclear, propose or
   fix it.
4. **Automation gaps** — If a manual step could be scripted, add it to `install/` or `setup.sh`.
5. **Dead code** — Remove configs for tools no longer used.

## Commit Style

- One logical change per commit
- Simple one-line messages (imperative mood): `add starship config`, `remove fish remnants`
- No Co-authored-by trailers

## Code Conventions

- Shell scripts: `bash`, use `set -euo pipefail`, shellcheck-clean
- Config files: comment non-obvious settings
- Stow packages: one directory per tool at repo root, mirroring `$HOME` structure
