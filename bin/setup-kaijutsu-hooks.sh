#!/usr/bin/env bash
# Wire Claude Code into kaijutsu's ambient hook pipeline on this machine.
#
# What it does:
#   1. Symlinks ~/.claude/hooks/kaijutsu-adapter -> $KJ_SRC/contrib/adapters
#      (the adapter + jq field map stay fresh with the kaijutsu checkout).
#   2. Runs merge-claude-config.py so the hook entries in
#      dotfiles/.claude/settings.json land in ~/.claude/settings.json.
#   3. Registers kaijutsu-mcp at user scope (all projects), and removes the
#      project-scoped duplicate in the kaijutsu repo if present.
#
# The hook path is fail-open end to end: on machines without a running
# kernel (or without kaijutsu-mcp built) the hooks cost a no-op subprocess
# and Claude Code carries on. Safe to run repeatedly.
#
# Env: KJ_SRC overrides the kaijutsu checkout location (default ~/src/kaijutsu).
set -euo pipefail

KJ_SRC="${KJ_SRC:-$HOME/src/kaijutsu}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }

command -v jq >/dev/null 2>&1 || die "jq is required (the adapter uses it per event)"
[ -d "$KJ_SRC/contrib/adapters" ] || die "kaijutsu checkout not found at $KJ_SRC (set KJ_SRC)"

# 1. Adapter symlink — a dir link so claude.sh finds its jq filter beside it.
mkdir -p "$HOME/.claude/hooks"
ln -sfn "$KJ_SRC/contrib/adapters" "$HOME/.claude/hooks/kaijutsu-adapter"
echo "linked ~/.claude/hooks/kaijutsu-adapter -> $KJ_SRC/contrib/adapters"

# 2. Hook entries (and the rest of the dotfiles claude config).
python3 "$SCRIPT_DIR/merge-claude-config.py"

# 3. MCP server at user scope so every project gets an ambient context.
if ! command -v claude >/dev/null 2>&1; then
    warn "claude CLI not found — skipped MCP registration; rerun after installing Claude Code"
else
    # Remove the project-scoped entry FIRST: it would both shadow the
    # user-scoped one inside the repo and satisfy the `mcp get` existence
    # check below (get resolves any scope), which would skip the add.
    (cd "$KJ_SRC" && claude mcp remove -s local kaijutsu >/dev/null 2>&1 \
        && echo "removed project-scoped kaijutsu entry in $KJ_SRC" || true)
    if claude mcp get kaijutsu >/dev/null 2>&1; then
        echo "kaijutsu MCP server already registered"
    else
        claude mcp add --scope user kaijutsu -- kaijutsu-mcp --connect
        echo "registered kaijutsu-mcp at user scope"
    fi
fi

# Binary check last — everything above is still correct without it.
if command -v kaijutsu-mcp >/dev/null 2>&1; then
    echo "kaijutsu-mcp: $(command -v kaijutsu-mcp)"
else
    warn "kaijutsu-mcp not on PATH — build and install it:"
    warn "  cd $KJ_SRC && cargo build --release -p kaijutsu-mcp"
    warn "  install -m755 target/release/kaijutsu-mcp ~/bin/"
fi

echo "done — restart Claude Code sessions to pick up hooks"
