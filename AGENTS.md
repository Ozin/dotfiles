# Agent Instructions

Guidelines for AI agents in this repo.

## Philosophy

Repo is living system. Agents **improve continuously** — not just complete immediate task.
Notice something better (structure, docs, naming, automation)? Fix or propose.

## Critical Thinking

**Stay critical.** No default agreement. Evaluate honestly — weigh trade-offs, name downsides,
suggest alternatives. Praise only what deserves it. Goal: best outcome, not comfortable conversation.

## Architecture Decision Records (ADRs)

Record significant decisions in `docs/adr/NNNN-kebab-title.md`.

### When to write

- Choosing tool/approach over alternatives (e.g. Stow vs Ansible)
- Changing project structure or conventions
- Dropping previously supported thing
- Any decision future reader might ask "why?"

### Template

```markdown
# NNNN — Title

**Status:** accepted | superseded | deprecated
**Date:** YYYY-MM-DD

## Context

Problem or situation?

## Decision

What decided?

## Consequences

Trade-offs?
```

### Numbering

Next sequential number. Check `docs/adr/` for current max.

## Continuous Improvement

Every task, also consider:

1. **CONCEPTS.md** — Decision contradicts/extends it? Update.
2. **README.md** — Keep accurate. Add/remove packages or steps? Reflect here.
3. **Structure** — Wrong place or unclear name? Fix or propose.
4. **Automation gaps** — Manual step scriptable? Add as Ansible task in the appropriate role.
5. **Dead code** — Tool no longer used? Remove config.

## Commit Style

- One logical change per commit
- Imperative one-liner: `add starship config`, `remove fish remnants`
- No Co-authored-by trailers

## Code Conventions

- Shell: `bash`, `set -euo pipefail`, shellcheck-clean
- Config files: comment non-obvious settings
- Ansible roles: one role per concern under `ansible/roles/`
- Config sources: plain files under `files/`, copied by the `dotfiles` role
