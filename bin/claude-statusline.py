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

  LEFT                                         RIGHT
  󰘧 Model host:path  branch status 󰔛 duration    used/max

- LEFT: Rainbow model, cyan host, cornflower path, git branch with status, timer
  - Git status: + (staged/green), ! (unstaged/yellow), ? (untracked/cyan)
- RIGHT: Context usage (traffic light colors: green < 60%, yellow < 80%, red >= 80%)

The rainbow colors shift slowly (~every 2 seconds) for a subtle animation.

================================================================================
JSON INPUT FROM CLAUDE CODE
================================================================================

Claude Code pipes JSON to stdin with these fields (as of v2.x):

Available:
- model.{id, display_name}
- context_window.{context_window_size, current_usage.*, used_percentage, remaining_percentage}
- cost.{total_cost_usd, total_duration_ms}
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
# Extra space accounts for Claude Code's built-in token counter (│ 28K/200K)
SAFETY_MARGIN = 18


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

# Braille wave - dots rise and fall like a sound wave
BRAILLE_WAVE = ['⠀', '⡀', '⠄', '⠂', '⠁', '⠈', '⠐', '⠠']  # dot moves up through positions

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


def braille_wave_padding(length: int, time_offset: int) -> str:
    """Generate padding with braille dots that wave like a sound visualization."""
    if length <= 0:
        return ""
    result = []
    last_color = None
    for i in range(length):
        phase = (i + time_offset) % len(BRAILLE_WAVE)
        char = BRAILLE_WAVE[phase]
        color_idx = (i + time_offset) % len(RAINBOW)
        color = RAINBOW[color_idx]
        if char != '⠀':  # not blank braille
            # Only emit color code if it changed
            if color != last_color:
                result.append(fg(color))
                last_color = color
            result.append(char)
        else:
            result.append(' ')
    result.append(RESET)
    return "".join(result)


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


def compress_path(path: str, max_len: int = 35, smart: bool = False) -> str:
    """Compress path to fit within max_len.

    Args:
        path: The path to compress (should already have ~ substituted for home)
        max_len: Maximum length for the result
        smart: If True, use breadcrumb compression (single-char middle dirs)
               If False, simple truncation from start with ellipsis

    Examples:
        smart=False: ~/src/tobert/dotfiles/nvim/lua → …bert/dotfiles/nvim/lua
        smart=True:  ~/src/tobert/dotfiles/nvim/lua → ~/s/t/d/nvim/lua
    """
    if len(path) <= max_len:
        return path

    if not smart:
        # Simple truncation from start
        return "…" + path[-(max_len - 1):]

    # Smart compression: ~/s/t/d/nvim/lua style
    parts = path.split('/')
    parts = [p for p in parts if p]  # Filter empty parts

    # Handle ~ prefix specially
    if path.startswith('~'):
        prefix = '~/'
        if parts and parts[0] == '~':
            parts = parts[1:]
    elif path.startswith('/'):
        prefix = '/'
    else:
        prefix = ''

    if len(parts) <= 2:
        # Not enough parts to compress meaningfully
        result = prefix + '/'.join(parts)
        if len(result) > max_len:
            return "…" + result[-(max_len - 1):]
        return result

    # Keep last 2 segments full, compress earlier ones to single char
    compressed = []
    keep_full = 2

    for i, part in enumerate(parts):
        if i >= len(parts) - keep_full:
            compressed.append(part)
        else:
            compressed.append(part[0] if part else '')

    result = prefix + '/'.join(compressed)

    # If still too long, fall back to truncation
    if len(result) > max_len:
        return "…" + result[-(max_len - 1):]

    return result


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
    host = os.uname().nodename.split(".")[0]
    cwd = data.get("workspace", {}).get("current_dir") or data.get("cwd", ".")
    model = data.get("model", {}).get("display_name") or data.get("model", {}).get("id", "unknown")

    # Shorten paths
    home = str(Path.home())
    raw_cwd = cwd.replace(home, "~", 1) if cwd.startswith(home) else cwd
    display_cwd = compress_path(raw_cwd, max_len=35, smart=False)
    compact_cwd = compress_path(raw_cwd, max_len=25, smart=True)

    model = model.removeprefix("Claude ")

    # -------------------------------------------------------------------------
    # LEFT: Model + Host + Path + Git + Timer
    # -------------------------------------------------------------------------
    git_info = get_git_info(cwd)
    rainbow_model = rainbow_text(model, rainbow_offset)
    cost = data.get("cost", {})

    # Rainbow timer
    duration_ms = cost.get("total_duration_ms", 0)
    timer_part = ""
    if duration_ms > 0:
        rainbow_duration = rainbow_text(fmt_duration(duration_ms), rainbow_offset + 3)
        timer_part = f" {fg(51)}{CLOCK}{RESET} {rainbow_duration}"

    left = f"{fg(129)}{MODEL}{RESET} {rainbow_model} {fg(51)}{host}{RESET} {fg(69)}{display_cwd}{RESET}{git_info}{timer_part}"
    compact_left = f"{fg(129)}{MODEL}{RESET} {rainbow_model} {fg(51)}{host}{RESET} {fg(69)}{compact_cwd}{RESET}{git_info}"

    # -------------------------------------------------------------------------
    # RIGHT: Context Usage
    # -------------------------------------------------------------------------
    ctx_pct = 0
    ctx_used = "0"
    ctx_max = "200K"

    ctx_window = data.get("context_window", {})
    size = ctx_window.get("context_window_size", 200000)
    usage = ctx_window.get("current_usage", {})

    ctx_pct = int(ctx_window.get("used_percentage", 0))
    current = (
        usage.get("input_tokens", 0) +
        usage.get("cache_creation_input_tokens", 0) +
        usage.get("cache_read_input_tokens", 0)
    ) if usage else 0
    ctx_used = fmt_tokens(current)
    ctx_max = fmt_tokens(size)

    # Traffic light colors for context usage
    if ctx_pct >= 80:
        ctx_color = fg(196)  # red - danger
    elif ctx_pct >= 60:
        ctx_color = fg(226)  # yellow - caution
    else:
        ctx_color = fg(46)   # green - good

    # Claude Code shows "Context low" warning around 70%+ - go compact mode
    compact_mode = ctx_pct >= 74  # Claude's "Context low" warning appears ~147K/200K

    # Build right: context (used/max)
    right = f"{ctx_color}{ctx_used}{RESET}{DIM}/{RESET}{ctx_color}{ctx_max}{RESET}"

    # -------------------------------------------------------------------------
    # Compose: LEFT + braille wave + RIGHT
    # -------------------------------------------------------------------------
    left_w = display_width(left)
    right_w = display_width(right)

    available = term_width - left_w - right_w

    # Wave animation - moves each refresh (ms precision ensures change each call)
    wave_offset = int(time.time() * 1000)

    if compact_mode:
        # Minimal: no timer, no diff stats, short wave
        mini_wave = braille_wave_padding(16, wave_offset)
        output = f"{compact_left} {mini_wave} {right}"
    elif available >= 10:
        # Full braille wave between left and right (with margin)
        pad = braille_wave_padding(available - 8, wave_offset)
        output = f"{left}    {pad}    {right}"
    else:
        output = f"{left} {right}"

    # Start and end with RESET to ensure clean state
    print(f"{RESET}{output}{RESET}", end="")


if __name__ == "__main__":
    main()
