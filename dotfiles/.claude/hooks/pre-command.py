#!/usr/bin/env python3
"""PreToolUse hook for Bash: block dangerous patterns, warn on risky ones."""
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from typing import Optional

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Soft-block approval cache (XDG-compliant, JSONL format)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CACHE_DIR = Path(os.environ.get('XDG_CACHE_HOME', Path.home() / '.cache')) / 'claude-hooks'
SOFT_BLOCK_CACHE = CACHE_DIR / 'soft-blocked.jsonl'
SOFT_BLOCK_TTL = 300  # 5 minutes

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BLOCKED: Hard deny - command will not run
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCKED = {
    'git': [
        (r'\bgit\s+add\s+(-A|--all)\b', 'git add -A/--all', 'Use explicit paths or `git add -p`'),
        (r'\bgit\s+add\s+\.\s*($|[;&|])', 'git add .', 'Use explicit paths or `git add -p`'),
        (r'\bgit\s+commit\s+-[a-zA-Z]*a', 'git commit -a', 'Stage files explicitly first'),
    ],
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SOFT_BLOCKED: Deny but suggest asking user to confirm
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SOFT_BLOCKED = {
    'git': [
        (r'\bgit\s+commit\s+.*--amend\b', 'git commit --amend', 'rewrites history'),
        (r'\bgit\s+push\s+.*--force\b', 'git push --force', 'rewrites remote history'),
        (r'\bgit\s+reset\s+--hard\b', 'git reset --hard', 'discards uncommitted changes'),
    ],
    'rm': [
        (r'\brm\s+-[a-zA-Z]*r[a-zA-Z]*f', 'rm -rf', 'recursive force delete'),
        (r'\brm\s+-[a-zA-Z]*f[a-zA-Z]*r', 'rm -fr', 'recursive force delete'),
    ],
    'find': [
        (r'\bfind\b.*-exec\b', 'find -exec', 'executes commands on matches'),
        (r'\bfind\b.*-execdir\b', 'find -execdir', 'executes commands on matches'),
        (r'\bfind\b.*-ok\b', 'find -ok', 'executes commands on matches'),
    ],
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WARNED: Allow but log a warning message
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WARNED = {
    'rm': [
        (r'\brm\s+.*\.local/share/', 'rm in ~/.local/share', 'contains app data'),
        (r'\brm\s+.*\.config/', 'rm in ~/.config', 'contains config files'),
        (r'\brm\s+.*\.db\b', 'rm *.db files', 'databases are hard to recover'),
        (r'\brm\s+-[a-zA-Z]*r', 'rm -r', 'recursive delete'),
        (r'\brm\s+-[a-zA-Z]*f', 'rm -f', 'force delete'),
    ],
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Soft-block cache operations
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def cmd_hash(cmd: str) -> str:
    """Hash command for cache key."""
    return hashlib.sha256(cmd.encode()).hexdigest()[:16]


def cache_soft_block(cmd: str, name: str):
    """Record a soft-blocked command for potential retry approval."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    entry = {'hash': cmd_hash(cmd), 'name': name, 'ts': time.time()}
    with open(SOFT_BLOCK_CACHE, 'a') as f:
        f.write(json.dumps(entry) + '\n')


def check_and_consume_approval(cmd: str) -> Optional[str]:
    """Check if command was recently soft-blocked (user approved retry). Consumes entry."""
    if not SOFT_BLOCK_CACHE.exists():
        return None

    h = cmd_hash(cmd)
    now = time.time()
    kept, matched_name = [], None

    with open(SOFT_BLOCK_CACHE) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            # Expire old entries
            if now - entry.get('ts', 0) > SOFT_BLOCK_TTL:
                continue

            # First match wins, consume it
            if entry.get('hash') == h and matched_name is None:
                matched_name = entry.get('name', 'command')
                continue  # Don't keep this one

            kept.append(entry)

    # Rewrite cache without matched/expired entries
    if matched_name is not None or len(kept) == 0:
        if kept:
            with open(SOFT_BLOCK_CACHE, 'w') as f:
                for entry in kept:
                    f.write(json.dumps(entry) + '\n')
        else:
            SOFT_BLOCK_CACHE.unlink(missing_ok=True)

    return matched_name


def get_git_status_summary() -> Optional[dict]:
    """Quick count of unstaged files."""
    try:
        r = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True, text=True, timeout=5
        )
        if r.returncode != 0:
            return None
        lines = [l for l in r.stdout.strip().split('\n') if l]
        return {
            'untracked': sum(1 for l in lines if l.startswith('??')),
            'modified': sum(1 for l in lines if len(l) > 1 and l[1] in 'MD'),
            'total': len(lines),
        }
    except Exception:
        return None


def deny(message: str):
    """Hard deny - block the command entirely."""
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'deny',
            'permissionDecisionReason': message,
        },
    }))
    sys.exit(0)


def soft_deny(cmd: str, name: str, reason: str):
    """Soft deny - block but cache for retry approval."""
    cache_soft_block(cmd, name)
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'deny',
            'permissionDecisionReason': (
                f"🛑 `{name}` blocked ({reason}). "
                f"If intentional, ask the user to confirm before retrying."
            ),
        },
    }))
    sys.exit(0)


def warn(message: str):
    """Allow but inject a warning message."""
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'allow',
            'permissionDecisionReason': message,
        },
    }))


def allow():
    """Allow the command."""
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'allow',
        },
    }))


def check_patterns(cmd: str, patterns: dict) -> Optional[tuple]:
    """Check command against a category dict of patterns."""
    for category, rules in patterns.items():
        for pattern, name, hint in rules:
            if re.search(pattern, cmd):
                return (category, name, hint)
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        allow()
        return

    if data.get('tool_name') != 'Bash':
        allow()
        return

    cmd = data.get('tool_input', {}).get('command', '')

    # Check if this is an approved retry of a soft-blocked command
    approved = check_and_consume_approval(cmd)
    if approved:
        warn(f"✅ `{approved}` approved by user, allowing retry.")
        return

    # Hard blocks
    match = check_patterns(cmd, BLOCKED)
    if match:
        category, name, hint = match
        if category == 'git':
            status = get_git_status_summary()
            count = status['total'] if status else '?'
            deny(f"⛔ Blocked: `{name}` would stage {count} files. {hint}")
        else:
            deny(f"⛔ Blocked: `{name}`. {hint}")
        return

    # Soft blocks (deny but encourage user confirmation)
    match = check_patterns(cmd, SOFT_BLOCKED)
    if match:
        _, name, reason = match
        soft_deny(cmd, name, reason)
        return

    # Warnings (allow but log)
    match = check_patterns(cmd, WARNED)
    if match:
        _, name, reason = match
        warn(f"⚠️ `{name}` ({reason})")
        return

    allow()


if __name__ == '__main__':
    main()
