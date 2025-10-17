# Tokyo Matrix Theme - Implementation Guide

**Version:** 1.0
**Status:** Active (deployed 2025-10-17)
**Created for:** atobey's development environment
**Designed for:** Harmonized colors across WezTerm, Neovim, Bash, Claude Code, and Gemini CLI

---

## Theme Philosophy

Tokyo Matrix is a Matrix-inspired evolution of Tokyo Night featuring:
- **Deeper blacks** (#0d0f15 vs Tokyo Night's #16161e)
- **Green-tinted text** with enhanced brightness (#d0f8d0)
- **Matrix aesthetic** while maintaining readability
- **High contrast** for extended coding sessions
- **Semantic consistency** across all tools

### Design Principles
1. **Pop without strain** - Bright enough to read, soft enough for long sessions
2. **Green Matrix aesthetic** - Homage to the classic terminal feel
3. **Semantic colors** - Red = errors, green = success, yellow = warnings
4. **Cross-tool harmony** - Same hex codes everywhere
5. **Easy portability** - Separate theme files for syncing

---

## Complete Color Palette

### Base Colors
```yaml
background:       "#0d0f15"  # Almost black (darker than Tokyo Night)
foreground:       "#d0f8d0"  # Bright green-tinted white (enhanced for pop!)
bg_alt:           "#13151f"  # UI elements (slightly lighter)
bg_darker:        "#080a0f"  # Deepest black for accents
fg_dim:           "#5a7a5a"  # Dimmed green for comments
```

### Cursor & Selection
```yaml
cursor:           "#80ff80"  # Bright Matrix green cursor
cursor_text:      "#0d0f15"  # Dark text under cursor
selection:        "#1a3d2d"  # Dark green selection background
visual:           "#1a3d2d"  # Visual mode selection
```

### UI Elements
```yaml
border:           "#1a2233"  # Subtle blue-grey borders
gutter:           "#0d0f15"  # Line number background (matches main bg)
line_highlight:   "#151821"  # Very subtle current line highlight
menu_sel:         "#1a3d2d"  # Menu/popup selection background
```

### Standard ANSI Colors (0-7)
```yaml
black:            "#0d0f15"  # ANSI 0
red:              "#ff5f87"  # ANSI 1 - Errors, deletions
green:            "#73ff73"  # ANSI 2 - Success, additions (Matrix green!)
yellow:           "#e5c07b"  # ANSI 3 - Warnings
blue:             "#5fbfff"  # ANSI 4 - Info, functions
magenta:          "#d75fd7"  # ANSI 5 - Keywords, special
cyan:             "#5fffaf"  # ANSI 6 - Strings, constants
white:            "#d0f8d0"  # ANSI 7 - Normal text (bright!)
```

### Bright ANSI Colors (8-15)
```yaml
bright_black:     "#3a4f4a"  # ANSI 8 - Grey with green undertone
bright_red:       "#ff6b9d"  # ANSI 9
bright_green:     "#95ff95"  # ANSI 10 - Extra bright Matrix green
bright_yellow:    "#ffd787"  # ANSI 11
bright_blue:      "#7dcfff"  # ANSI 12
bright_magenta:   "#ff87ff"  # ANSI 13
bright_cyan:      "#87ffd7"  # ANSI 14
bright_white:     "#d0ffd0"  # ANSI 15 - Almost neon green-white
```

### Syntax Highlighting
```yaml
keyword:          "#af87ff"  # Purple (kept from Tokyo Night)
function:         "#5fbfff"  # Bright cyan-blue
string:           "#95ff95"  # Bright Matrix green
number:           "#ff9e64"  # Orange
constant:         "#ff9e64"  # Orange (matches numbers)
comment:          "#5a7a5a"  # Dim green (readable but subtle)
type:             "#2affaa"  # Bright cyan
operator:         "#5fffaf"  # Cyan
variable:         "#d0f8d0"  # Base foreground (bright)
parameter:        "#87ceeb"  # Light blue for distinction
builtin:          "#7dcfff"  # Bright blue for built-in functions
```

### Diagnostics (LSP)
```yaml
error:            "#ff5f87"  # Bright pink-red
warning:          "#ffaf5f"  # Warm orange
info:             "#5fbfff"  # Blue
hint:             "#5fffaf"  # Cyan-green
```

### Git Diff
```yaml
git_add:          "#73ff73"  # Matrix green
git_change:       "#ffd787"  # Yellow
git_delete:       "#ff5f87"  # Red
```

### Special
```yaml
match_paren:      "#ff87ff"  # Bright magenta
search:           "#ffd75f"  # Yellow highlight
inc_search:       "#ff9e64"  # Orange for current search match
```

---

## Implementation by Tool

### 1. WezTerm Configuration

**Location:** `~/.config/wezterm/themes/tokyomatrix.lua`

The theme is extracted into a separate file for easy syncing across machines (Linux/Windows).

**Main config:** `~/.config/wezterm/wezterm.lua`
```lua
-- Color Scheme (Tokyo Matrix)
config.colors = require('themes.tokyomatrix')
```

**Theme file structure:**
```lua
return {
  foreground = '#d0f8d0',
  background = '#0d0f15',
  cursor_bg = '#80ff80',
  cursor_fg = '#0d0f15',
  cursor_border = '#80ff80',
  selection_fg = '#d0ffd0',
  selection_bg = '#1a3d2d',

  ansi = {
    '#0d0f15', '#ff5f87', '#73ff73', '#e5c07b',
    '#5fbfff', '#d75fd7', '#5fffaf', '#d0f8d0',
  },

  brights = {
    '#3a4f4a', '#ff6b9d', '#95ff95', '#ffd787',
    '#7dcfff', '#ff87ff', '#87ffd7', '#d0ffd0',
  },

  tab_bar = { ... },
}
```

**Tab bar customization:**
Active tabs use Matrix green (#73ff73) background for immediate visibility.

**Syncing to Windows:**
Copy entire `~/.config/wezterm/` directory to:
```
%USERPROFILE%\.config\wezterm\
```

### 2. Neovim Colorscheme

**Location:** `~/.config/nvim/colors/tokyomatrix.lua`

A complete 400+ line custom colorscheme with full LSP, Tree-sitter, and plugin support.

**Activation:** `~/.config/nvim/lua/plugins/init.lua`
```lua
{
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme tokyomatrix")
  end,
},
```

**Plugin integration:**
- ✅ LSP diagnostics with proper error/warning/info/hint colors
- ✅ Tree-sitter semantic tokens
- ✅ GitSigns (git diff in gutter)
- ✅ Telescope (fuzzy finder)
- ✅ Lualine (statusline with auto-theme)
- ✅ nvim-cmp (completion menu)
- ✅ Indent-blankline

**Testing:**
```vim
:colorscheme tokyomatrix
:LspInfo  " Verify LSP colors
```

### 3. Bash Prompt

**Location:** `~/.bash_profile`

**Colors used:**
- User@hostname: ANSI 256-color 120 (bright Matrix green)
- Working directory: ANSI 256-color 87 (bright cyan)
- Root prompt: Red (safety - unchanged)

**Code:**
```bash
if [[ ${EUID} == 0 ]] ; then
    # Root stays red for safety
    PS1="\\[\\033[01;31m\\]$hostname\\[\\033[38;5;87m\\] \\W \\$\\[\\033[00m\\] "
else
    # Matrix green for user@host, bright cyan for path
    PS1="\\[\\033[38;5;120m\\]\\u@$hostname\\[\\033[38;5;87m\\] \\w \\$\\[\\033[00m\\] "
fi
```

**Activation:**
```bash
source ~/.bash_profile
```

### 4. Claude Code Integration

**No configuration needed!**

Claude Code runs in the terminal and automatically inherits WezTerm's color scheme. All ANSI colors are passed through, giving perfect theme harmony.

### 5. Gemini CLI Integration

**No configuration needed!**

Same as Claude Code - Gemini CLI is a Node.js terminal application that inherits all colors from WezTerm.

---

## Color Adjustments Made

### Original Tokyo Matrix → Final Version

**Key change:** Foreground brightness increased for better pop.

| Color      | Original  | Updated   | Reason                    |
|------------|-----------|-----------|---------------------------|
| Foreground | #b8e0b8   | #d0f8d0   | Better visibility & pop   |
| White      | #b8e0b8   | #d0f8d0   | Match foreground          |

### Comparison to Tokyo Night

| Element      | Tokyo Night | Tokyo Matrix | Change        |
|--------------|-------------|--------------|---------------|
| Background   | #16161e     | #0d0f15      | Much darker   |
| Foreground   | #c0caf5     | #d0f8d0      | Green-tinted  |
| Strings      | #9ece6a     | #95ff95      | Brighter      |
| Comments     | #565f89     | #5a7a5a      | Green-grey    |
| Overall feel | Blue-ish    | Green Matrix | Theme shift   |

---

## Testing the Theme

### Visual Test Files

Test Go code:
```go
package main

import "fmt"

// Comment: The Matrix has you...
const MaxRetries = 3

type Config struct {
    Name    string
    Port    int
    Enabled bool
}

func main() {
    config := Config{
        Name:    "Matrix",
        Port:    8080,
        Enabled: true,
    }

    for i := 0; i < MaxRetries; i++ {
        fmt.Printf("Iteration %d: %s\n", i, config.Name)
    }
}
```

What to verify:
- ✅ Keywords (`package`, `import`, `const`, `func`) are purple
- ✅ Strings are bright Matrix green
- ✅ Comments are readable but dimmed green
- ✅ Function names are bright blue
- ✅ Numbers are orange
- ✅ Background is very dark

### Preview Script

Run: `src/dotfiles/setup-scripts/preview-tokyomatrix.sh`

This script:
1. Shows all colors with hex codes
2. Displays syntax highlighting examples
3. Creates test files
4. Generates a temporary wezterm config for testing

---

## Instructions for AI Agents

### Applying Tokyo Matrix to a New System

**Prerequisites check:**
1. Verify Neovim 0.10+ installed
2. Verify WezTerm installed
3. Confirm user wants Tokyo Matrix (not another theme)

**Implementation order:**

1. **Create WezTerm theme:**
   ```bash
   mkdir -p ~/.config/wezterm/themes
   # Copy tokyomatrix.lua from reference system or create from palette above
   ```

2. **Update WezTerm config:**
   ```lua
   config.colors = require('themes.tokyomatrix')
   ```

3. **Create Neovim colorscheme:**
   ```bash
   mkdir -p ~/.config/nvim/colors
   # Copy tokyomatrix.lua from reference system
   ```

4. **Update Neovim plugins:**
   - Set colorscheme to 'tokyomatrix' in plugins/init.lua
   - Set lualine theme to 'auto' in plugins/ui.lua

5. **Update Bash prompt:**
   - Modify PS1 in ~/.bash_profile with Matrix colors
   - ANSI 120 for user@host, ANSI 87 for path

6. **Test:**
   - Restart wezterm
   - Open nvim and verify `:colorscheme tokyomatrix` works
   - Source bash_profile
   - Open test files in each tool

### Modifying Colors

**To adjust brightness:**
```lua
-- In both wezterm/themes/tokyomatrix.lua and nvim/colors/tokyomatrix.lua
foreground = '#d0f8d0'  -- Increase hex values for brighter (max #ffffff)
                         -- Decrease for dimmer
```

**To change green tint amount:**
```lua
-- Increase green channel, decrease red/blue
foreground = '#c0ffc0'  -- More green
foreground = '#e0f0e0'  -- Less green (more neutral)
```

**To make background lighter:**
```lua
background = '#0d0f15'  -- Current (very dark)
background = '#1a1f1a'  -- Lighter option
```

**Important:** Change hex codes in BOTH wezterm theme AND nvim colorscheme for consistency!

### Common Troubleshooting

**Colors don't match between nvim and terminal:**
```vim
:set termguicolors?  " Should be ON
:echo $TERM          " Should be 'wezterm' or 'xterm-256color'
```

**Wezterm theme not loading:**
```bash
# Check for syntax errors
wezterm --config-file ~/.config/wezterm/wezterm.lua
```

**Bash colors look wrong:**
```bash
# Test ANSI 256 colors are working
for i in {0..255}; do echo -e "\e[38;5;${i}mColor $i\e[0m"; done
```

---

## File Locations Reference

### Linux/macOS
```
~/.config/wezterm/themes/tokyomatrix.lua    # WezTerm theme
~/.config/wezterm/wezterm.lua               # WezTerm config (imports theme)
~/.config/nvim/colors/tokyomatrix.lua       # Neovim colorscheme
~/.config/nvim/lua/plugins/init.lua         # Sets nvim colorscheme
~/.config/nvim/lua/plugins/ui.lua           # Lualine theme config
~/.bash_profile                              # Bash prompt colors
```

### Windows
```
%USERPROFILE%\.config\wezterm\themes\tokyomatrix.lua
%USERPROFILE%\.config\wezterm\wezterm.lua
# Neovim paths same as Linux (WSL or native)
```

---

## Version History

### v1.0 (2025-10-17) - Initial Release
- Created from Tokyo Night base
- Darkened background to #0d0f15
- Changed foreground to green-tinted #d0f8d0
- Implemented across WezTerm, Neovim, Bash
- Enhanced brightness for better readability
- Added comprehensive LSP/Tree-sitter support
- Optimized for Go and Rust development

---

## Credits & Inspiration

- **Base theme:** [Tokyo Night](https://github.com/folke/tokyonight.nvim) by folke
- **Matrix aesthetic:** The Matrix (1999) film
- **Design collaboration:** Created with Claude Code AI assistant
- **For:** atobey's development environment

---

## License

This theme configuration is free to use and modify. Based on Tokyo Night which uses MIT license.

---

## Preview

**Expected appearance:**
- Very dark background (almost black)
- Bright green-tinted text that "pops"
- Matrix-green strings (#95ff95)
- Purple keywords (#af87ff)
- Bright blue functions (#5fbfff)
- Subtle green comments (#5a7a5a)
- Active tab bars in bright Matrix green
- Overall: Darker, greener, more "Matrix" than Tokyo Night

**Best for:**
- Extended coding sessions (low eye strain)
- Dark room environments
- Matrix/cyberpunk aesthetic preference
- Those who want high contrast without harsh brightness
