---
name: commit
description: This skill should be used when the user asks to "commit", "commit this", "git commit", "save my work", "stage and commit", "make a commit", "check in my changes", "do commits", "commit changes", mentions "/commit", or when completing a task where committing is the natural next step. Provides a streamlined git commit workflow for multi-session development.
version: 0.1.0
---

# Commit Workflow

The user runs multiple Claude sessions across tmux panes in the same repo.
Any session may have modified files, staged changes, or committed since this
session last looked.

## Orient First (every time)

Before any git operation, run in parallel:
- `git status` + `git log --oneline -5` + `git diff --stat`

If unexpected changes appear (files this session didn't touch, surprise
commits on HEAD), flag them before proceeding.

## Assess Granularity

"Commit" / "commit this" → probably one commit, keep it together.
"Do commits" / "commit changes" → assess the diff and split into logical units.

When splitting:
- Obvious boundaries (refactor + feature, unrelated files) → just do it
- Ambiguous → briefly confirm: "I'll commit the lexer fix and parser change separately — good?"

## Autonomy

**Just commit:** Small/clear changes, completed tasks, obvious fixes, tests, docs.
Prefer frequent small commits over batching.

**Ask first:** Ambiguous scope, unexpected working tree state, failing tests
with non-obvious fixes, judgment calls about what belongs together.

## Pre-Commit Checks

Run the project's test/lint suite before committing. Check the project's
CLAUDE.md for specific commands; fall back to standard markers (`Cargo.toml`
→ clippy + test, `go.mod` → vet + test, `package.json` → npm test).

## Attribution & Format

Conventional commits, dense model-readable tokens. Always include
Co-Authored-By via HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
type(scope): subject line

Body if needed.

Co-Authored-By: Claude <claude@anthropic.com>
EOF
)"
```

See `references/message-format.md` for style examples.
