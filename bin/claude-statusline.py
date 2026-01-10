#!/usr/bin/env python3
"""
Claude Code Custom Status Line 🌈

A colorful, informative statusline for Claude Code with rainbow animations.

================================================================================
SETUP INSTRUCTIONS
================================================================================

1. Ensure this script is executable:
   chmod +x ~/src/tobert/bin/claude-statusline.py

2. Add to ~/.claude/settings.json:
   {
     "statusLine": {
       "type": "command",
       "command": "/home/YOUR_USER/src/tobert/bin/claude-statusline.py",
       "padding": 0
     }
   }

3. Restart Claude Code to see the new statusline.

================================================================================
REQUIREMENTS
================================================================================

- Python 3.10+
- A terminal with 256-color support
- A Nerdfonts-patched font (for icons)
- No pip dependencies (wcwidth functionality is built-in)

================================================================================
CUSTOMIZATION
================================================================================

Adjust these constants at the top of the script:

- SAFETY_MARGIN: Increase if the line wraps on your terminal (default: 5)
- ICON_WIDTHS: Adjust if icons render at wrong width for your font
- RAINBOW: Change the color palette (256-color codes)

================================================================================
LAYOUT
================================================================================

  LEFT                              CENTER                           RIGHT
  user@host:path  branch status    󰔛 duration │ +added -removed    󰘧 Model XX% used/max

- LEFT: Rainbow username, cyan host, cornflower path, git branch with status
  - Git status: + (staged/green), ! (unstaged/yellow), ? (untracked/cyan)
- CENTER: Session duration, lines added/removed
- RIGHT: Rainbow model name, context % (traffic light colors), token usage

The rainbow colors shift slowly (~every 2 seconds) for a subtle animation.

================================================================================
JSON INPUT FROM CLAUDE CODE
================================================================================

Claude Code pipes JSON to stdin with these fields (as of v2.x):

Available:
- model.{id, display_name}
- context_window.{context_window_size, current_usage.*}
- cost.{total_cost_usd, total_duration_ms, total_lines_added, total_lines_removed}
- workspace.{current_dir, project_dir}
- version, session_id, output_style.name

NOT available (sadly):
- mcp_servers, lsp_servers, vim.mode, background_tasks, diagnostics

================================================================================
"""

import curses
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

# =============================================================================
# Configuration - Adjust these for your setup
# =============================================================================

# Safety margin to avoid line wrap (increase if wrapping occurs)
SAFETY_MARGIN = 5

# Nerdfonts icons - adjust widths based on your font's rendering
GIT_BRANCH = '\ue0a0'  # nf-pl-branch (powerline)
CLOCK = '󰔛'            # nf-md-clock
MODEL = '󰘧'            # nf-md-head_cog

ICON_WIDTHS = {
    GIT_BRANCH: 2,  # powerline icons often 2 cells
    CLOCK: 1,       # nerdfonts md icons usually 1
    MODEL: 1,       # nerdfonts md icons usually 1
    '…': 1,
    '⚡': 1,
}

# Rainbow palette (256-color codes): red, orange, yellow, green, cyan, blue, magenta, purple
RAINBOW = [196, 208, 226, 46, 51, 69, 201, 129]

# =============================================================================
# Width Calculation (no wcwidth dependency)
# =============================================================================

def char_width(c: str) -> int:
    """Get display width of a single character."""
    if c in ICON_WIDTHS:
        return ICON_WIDTHS[c]
    return 1


def wcswidth(s: str) -> int:
    """Calculate display width of string."""
    return sum(char_width(c) for c in s)


# =============================================================================
# Colors
# =============================================================================

def fg(color_code: int) -> str:
    """256-color foreground escape sequence."""
    return f"\033[38;5;{color_code}m"


DIM = "\033[2m"
RESET = "\033[0m"


def rainbow_text(text: str, offset: int = 0) -> str:
    """Apply rainbow colors to text, cycling through palette."""
    result = []
    i = 0
    for char in text:
        if char != " ":
            color = RAINBOW[(i + offset) % len(RAINBOW)]
            result.append(f"{fg(color)}{char}")
            i += 1
        else:
            result.append(char)
    result.append(RESET)
    return "".join(result)


def strip_ansi(text: str) -> str:
    """Remove ANSI escape codes from text."""
    return re.sub(r'\033\[[0-9;]*m', '', text)


def display_width(text: str) -> int:
    """Calculate display width of text (strip ANSI first)."""
    plain = strip_ansi(text)
    w = wcswidth(plain)
    return w if w >= 0 else len(plain)


# =============================================================================
# Formatting Helpers
# =============================================================================

def fmt_tokens(n: int) -> str:
    """Format token count with K suffix."""
    if n >= 1000:
        return f"{n // 1000}K"
    return str(n)


def fmt_duration(ms: int) -> str:
    """Format duration in human-readable form."""
    seconds = ms // 1000
    if seconds < 60:
        return f"{seconds}s"
    minutes = seconds // 60
    if minutes < 60:
        return f"{minutes}m"
    hours = minutes // 60
    mins = minutes % 60
    return f"{hours}h{mins}m"


# =============================================================================
# Data Extraction
# =============================================================================

def get_git_info(cwd: str) -> str:
    """Get git branch and status indicators."""
    try:
        subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--git-dir"],
            capture_output=True, check=True
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""

    try:
        result = subprocess.run(
            ["git", "-C", cwd, "symbolic-ref", "--short", "HEAD"],
            capture_output=True, text=True
        )
        branch = result.stdout.strip() if result.returncode == 0 else "⚡"
    except FileNotFoundError:
        return ""

    status_chars = ""

    # Staged changes
    result = subprocess.run(["git", "-C", cwd, "diff", "--cached", "--quiet"], capture_output=True)
    if result.returncode != 0:
        status_chars += f"{fg(46)}+{RESET}"

    # Unstaged changes
    result = subprocess.run(["git", "-C", cwd, "diff", "--quiet"], capture_output=True)
    if result.returncode != 0:
        status_chars += f"{fg(226)}!{RESET}"

    # Untracked files
    result = subprocess.run(
        ["git", "-C", cwd, "ls-files", "--others", "--exclude-standard", "--directory", "--no-empty-directory"],
        capture_output=True, text=True
    )
    if result.stdout.strip():
        status_chars += f"{fg(51)}?{RESET}"

    if status_chars:
        return f" {fg(201)}{GIT_BRANCH}{RESET} {fg(129)}{branch}{RESET} {status_chars}"
    else:
        return f" {fg(201)}{GIT_BRANCH}{RESET} {fg(46)}{branch}{RESET}"


def get_term_width() -> int:
    """Get terminal width - tries multiple methods."""
    # Method 1: stty size via /dev/tty (works even when stdout is piped)
    try:
        with open("/dev/tty") as tty:
            result = subprocess.run(
                ["stty", "size"],
                stdin=tty,
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                _, cols = result.stdout.strip().split()
                return int(cols)
    except Exception:
        pass

    # Method 2: COLUMNS env var
    if "COLUMNS" in os.environ:
        return int(os.environ["COLUMNS"])

    # Method 3: curses/terminfo
    try:
        curses.setupterm()
        cols = curses.tigetnum("cols")
        if cols and cols > 0:
            return cols
    except Exception:
        pass

    return 120  # fallback


# =============================================================================
# Main
# =============================================================================

def main():
    # Rainbow offset shifts every ~2 seconds for subtle animation
    rainbow_offset = int(time.time() / 2) % len(RAINBOW)

    # Read JSON context from Claude Code
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        data = {}

    term_width = get_term_width() - SAFETY_MARGIN

    # Basic info
    user = os.environ.get("USER", "user")
    host = os.uname().nodename.split(".")[0]
    cwd = data.get("workspace", {}).get("current_dir") or data.get("cwd", ".")
    model = data.get("model", {}).get("display_name") or data.get("model", {}).get("id", "unknown")

    # Shorten paths
    home = str(Path.home())
    display_cwd = cwd.replace(home, "~", 1) if cwd.startswith(home) else cwd
    if len(display_cwd) > 35:
        display_cwd = "…" + display_cwd[-34:]

    model = model.removeprefix("Claude ")

    # -------------------------------------------------------------------------
    # LEFT: PS1-style + Git
    # -------------------------------------------------------------------------
    git_info = get_git_info(cwd)
    rainbow_user = rainbow_text(user, rainbow_offset)
    left = f"{rainbow_user}{DIM}@{RESET}{fg(51)}{host}{RESET}{DIM}:{RESET}{fg(69)}{display_cwd}{RESET}{git_info}"

    # -------------------------------------------------------------------------
    # CENTER: Session duration + Lines changed
    # -------------------------------------------------------------------------
    center_parts = []
    cost = data.get("cost", {})

    duration_ms = cost.get("total_duration_ms", 0)
    if duration_ms > 0:
        center_parts.append(f"{fg(51)}{CLOCK}{RESET} {fmt_duration(duration_ms)}")

    lines_added = cost.get("total_lines_added", 0)
    lines_removed = cost.get("total_lines_removed", 0)
    if lines_added > 0 or lines_removed > 0:
        lines_str = f"{fg(46)}+{lines_added}{RESET} {fg(196)}-{lines_removed}{RESET}"
        center_parts.append(lines_str)

    sep = f" {fg(208)}│{RESET} "
    center = sep.join(center_parts) if center_parts else ""

    # -------------------------------------------------------------------------
    # RIGHT: Model + Context Usage
    # -------------------------------------------------------------------------
    ctx_pct = 0
    ctx_used = "0"
    ctx_max = "200K"

    ctx_window = data.get("context_window", {})
    usage = ctx_window.get("current_usage", {})
    size = ctx_window.get("context_window_size", 200000)

    if usage and size > 0:
        current = (
            usage.get("input_tokens", 0) +
            usage.get("cache_creation_input_tokens", 0) +
            usage.get("cache_read_input_tokens", 0)
        )
        ctx_pct = (current * 100) // size
        ctx_used = fmt_tokens(current)
        ctx_max = fmt_tokens(size)

    # Traffic light colors for context percentage
    if ctx_pct >= 80:
        pct_color = fg(196)  # red - danger
    elif ctx_pct >= 60:
        pct_color = fg(226)  # yellow - caution
    else:
        pct_color = fg(46)   # green - good

    rainbow_model = rainbow_text(model, rainbow_offset)
    right = f"{fg(129)}{MODEL}{RESET} {rainbow_model} {pct_color}{ctx_pct}%{RESET} {DIM}{ctx_used}/{ctx_max}{RESET}"

    # -------------------------------------------------------------------------
    # Compose with whitespace padding
    # -------------------------------------------------------------------------
    left_w = display_width(left)
    center_w = display_width(center)
    right_w = display_width(right)

    total_content = left_w + center_w + right_w
    available = term_width - total_content

    if available >= 2:
        if center:
            left_gap = available // 2
            right_gap = available - left_gap
            output = f"{left}{' ' * left_gap}{center}{' ' * right_gap}{right}"
        else:
            output = f"{left}{' ' * available}{right}"
    else:
        output = f"{left} {center} {right}" if center else f"{left} {right}"

    print(output)


if __name__ == "__main__":
    main()
