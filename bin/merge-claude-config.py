#!/usr/bin/env python3
"""
Merge dotfiles/.claude config into ~/.claude.

- Merges hooks from settings.json
- Copies hook scripts
- Adds Exa MCP if ~/.exakey exists (personal machines only)
"""
import json
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

DOTFILES = Path(__file__).parent.parent / "dotfiles" / ".claude"
TARGET = Path.home() / ".claude"
TIMESTAMP = datetime.now().strftime("%Y%m%d-%H%M%S")


def backup(path: Path):
    """Create timestamped backup of a file."""
    if path.exists():
        backup_path = path.with_suffix(f".{TIMESTAMP}.bak")
        shutil.copy2(path, backup_path)
        print(f"📦 Backed up {path.name} → {backup_path.name}")


def merge_settings():
    """Merge hooks from dotfiles settings into target settings."""
    src = DOTFILES / "settings.json"
    dst = TARGET / "settings.json"

    if not src.exists():
        print("⚠️  No dotfiles settings.json found")
        return

    backup(dst)

    with open(src) as f:
        dotfile_settings = json.load(f)

    if dst.exists():
        with open(dst) as f:
            target_settings = json.load(f)
    else:
        target_settings = {}

    # Merge hooks (dotfiles hooks take precedence)
    if "hooks" in dotfile_settings:
        target_settings["hooks"] = dotfile_settings["hooks"]
        print("✅ Merged hooks config")

    with open(dst, "w") as f:
        json.dump(target_settings, f, indent=2)
        f.write("\n")


def copy_hooks():
    """Copy hook scripts to ~/.claude/hooks/."""
    src_dir = DOTFILES / "hooks"
    dst_dir = TARGET / "hooks"

    if not src_dir.exists():
        print("⚠️  No dotfiles hooks directory found")
        return

    dst_dir.mkdir(parents=True, exist_ok=True)

    for hook in src_dir.glob("*.py"):
        dst = dst_dir / hook.name
        if dst.is_symlink() and dst.resolve() == hook.resolve():
            print(f"✅ {hook.name} already linked")
            continue
        backup(dst)
        if dst.exists() or dst.is_symlink():
            dst.unlink()
        dst.symlink_to(hook.resolve())
        print(f"🔗 Linked {hook.name}")


def setup_exa():
    """Add Exa MCP if ~/.exakey exists."""
    exakey = Path.home() / ".exakey"
    if not exakey.exists():
        print("⏭️  No ~/.exakey - skipping Exa MCP (work machine?)")
        return

    # Check if npx is available
    try:
        subprocess.run(["npx", "--version"], capture_output=True, timeout=5, check=True)
    except Exception:
        print("⚠️  npx not available - skipping Exa MCP")
        return

    api_key = exakey.read_text().strip()
    try:
        subprocess.run(
            ["claude", "mcp", "add", "exa", "-e", f"EXA_API_KEY={api_key}",
             "--", "npx", "-y", "exa-mcp-server"],
            check=True,
            capture_output=True
        )
        print("✅ Added Exa MCP")
    except subprocess.CalledProcessError as e:
        if b"already exists" in e.stderr:
            print("✅ Exa MCP already configured")
        else:
            print(f"⚠️  Failed to add Exa MCP: {e.stderr.decode()}")
    except FileNotFoundError:
        print("⚠️  claude CLI not found - skipping Exa MCP")


def main():
    print(f"📁 Source: {DOTFILES}")
    print(f"📁 Target: {TARGET}")
    print()

    TARGET.mkdir(parents=True, exist_ok=True)

    merge_settings()
    copy_hooks()
    setup_exa()

    print()
    print("🔗 Done! Restart Claude Code to pick up changes.")


if __name__ == "__main__":
    main()
