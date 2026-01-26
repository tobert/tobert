#!/usr/bin/env python3
"""Tests for pre-command.py hook."""
import json
import subprocess
import sys
import os
from pathlib import Path

HOOK = Path(__file__).parent / 'pre-command.py'
CACHE_DIR = Path(os.environ.get('XDG_CACHE_HOME', Path.home() / '.cache')) / 'claude-hooks'
CACHE_FILE = CACHE_DIR / 'soft-blocked.jsonl'


def run_hook(command: str) -> tuple[dict, int]:
    """Run the hook with a command, return (output_dict, exit_code)."""
    input_data = json.dumps({
        'tool_name': 'Bash',
        'tool_input': {'command': command}
    })
    result = subprocess.run(
        ['python3', str(HOOK)],
        input=input_data,
        capture_output=True,
        text=True
    )
    try:
        output = json.loads(result.stdout)
    except json.JSONDecodeError:
        output = {'raw': result.stdout, 'stderr': result.stderr}
    return output, result.returncode


def clear_cache():
    """Remove the soft-block cache file."""
    CACHE_FILE.unlink(missing_ok=True)


def test(name: str, command: str, expect_blocked: bool, expect_soft: bool = False):
    """Run a single test case."""
    output, code = run_hook(command)

    blocked = code != 0 or output.get('hookSpecificOutput', {}).get('permissionDecision') == 'deny'
    msg = output.get('systemMessage', '')

    # Check result
    if expect_blocked and not blocked:
        print(f"❌ {name}: expected BLOCK, got ALLOW")
        print(f"   cmd: {command}")
        print(f"   out: {output}")
        return False
    elif not expect_blocked and blocked:
        print(f"❌ {name}: expected ALLOW, got BLOCK")
        print(f"   cmd: {command}")
        print(f"   out: {output}")
        return False

    # Check soft vs hard
    if expect_soft and blocked:
        if '🛑' not in msg:
            print(f"❌ {name}: expected SOFT block (🛑), got: {msg}")
            return False

    status = "🛑 soft" if expect_soft else ("⛔ hard" if expect_blocked else "✅ allow")
    print(f"✅ {name}: {status}")
    return True


def test_soft_retry(name: str, command: str):
    """Test the soft-block retry flow."""
    clear_cache()

    # First attempt should block
    output1, code1 = run_hook(command)
    if code1 == 0:
        print(f"❌ {name}: first attempt should block")
        return False

    # Second attempt (simulating user approval) should allow
    output2, code2 = run_hook(command)
    if code2 != 0:
        print(f"❌ {name}: retry should be allowed")
        print(f"   out: {output2}")
        return False

    if '✅' not in output2.get('systemMessage', ''):
        print(f"❌ {name}: retry should show approval message")
        return False

    # Third attempt should block again (one-time approval consumed)
    output3, code3 = run_hook(command)
    if code3 == 0:
        print(f"❌ {name}: third attempt should block (approval consumed)")
        return False

    print(f"✅ {name}: soft-retry flow works")
    return True


def main():
    clear_cache()
    passed = 0
    failed = 0

    print("=" * 60)
    print("BLOCKED (hard deny)")
    print("=" * 60)

    tests = [
        ("git add -A", "git add -A", True, False),
        ("git add --all", "git add --all", True, False),
        ("git add .", "git add .", True, False),
        ("git add . &&", "git add . && git commit", True, False),
        ("git commit -a", "git commit -am 'msg'", True, False),
        ("git add specific", "git add foo.py bar.py", False, False),
    ]

    for name, cmd, expect_blocked, expect_soft in tests:
        if test(name, cmd, expect_blocked, expect_soft):
            passed += 1
        else:
            failed += 1

    print()
    print("=" * 60)
    print("SOFT_BLOCKED (deny + cache for retry)")
    print("=" * 60)

    tests = [
        ("git commit --amend", "git commit --amend", True, True),
        ("git push --force", "git push --force origin main", True, True),
        ("git reset --hard", "git reset --hard HEAD~1", True, True),
        ("rm -rf", "rm -rf /tmp/test", True, True),
        ("rm -fr", "rm -fr /tmp/test", True, True),
        ("find -exec", "find . -name '*.tmp' -exec rm {} \\;", True, True),
        ("find -execdir", "find . -execdir mv {} {}.bak \\;", True, True),
        ("find -ok", "find . -ok rm {} \\;", True, True),
        ("find without exec", "find . -name '*.py'", False, False),
    ]

    for name, cmd, expect_blocked, expect_soft in tests:
        clear_cache()
        if test(name, cmd, expect_blocked, expect_soft):
            passed += 1
        else:
            failed += 1

    print()
    print("=" * 60)
    print("WARNED (allow + message)")
    print("=" * 60)

    tests = [
        ("rm -r", "rm -r /tmp/foo", False, False),
        ("rm -f", "rm -f /tmp/foo", False, False),
        ("rm .config", "rm ~/.config/test", False, False),
        ("rm .local/share", "rm ~/.local/share/test", False, False),
        ("rm .db", "rm data.db", False, False),
    ]

    for name, cmd, expect_blocked, expect_soft in tests:
        if test(name, cmd, expect_blocked, expect_soft):
            passed += 1
        else:
            failed += 1

    print()
    print("=" * 60)
    print("SOFT-BLOCK RETRY FLOW")
    print("=" * 60)

    if test_soft_retry("rm -rf retry", "rm -rf /tmp/unique-test-path"):
        passed += 1
    else:
        failed += 1

    if test_soft_retry("find -exec retry", "find /tmp/unique -exec cat {} \\;"):
        passed += 1
    else:
        failed += 1

    print()
    print("=" * 60)
    total = passed + failed
    print(f"Results: {passed}/{total} passed")
    if failed:
        print(f"         {failed} FAILED")
        sys.exit(1)
    print("=" * 60)

    clear_cache()


if __name__ == '__main__':
    main()
