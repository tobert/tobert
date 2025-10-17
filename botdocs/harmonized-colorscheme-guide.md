# Harmonized Color Scheme Guide
**Building a cohesive color experience across Neovim, Claude Code, and Wezterm**

## Project Goal
Create a custom color scheme that provides visual harmony across my entire development environment: Neovim, Claude Code terminal, and Wezterm.

## Design Requirements

### Color Harmony Principles
1. **Consistent base colors** across all tools
2. **Comfortable for extended use** (low eye strain)
3. **Good contrast** for readability
4. **Semantic consistency** (errors red, success green, etc.)
5. **Terminal-friendly** (works well with ANSI colors)
6. **True color** (24-bit RGB, not limited to 256 colors)

### Personal Preferences
- [ ] Light or Dark theme? (specify: _____________)
- [ ] Preferred base hue? (blue, green, warm, cool, neutral, etc.)
- [ ] High contrast or subtle? (specify: _____________)
- [ ] Any favorite existing themes to reference? (specify: _____________)

## Color Palette Structure

### Required Colors (Base)
```
# Background & Foreground
background:          #______  (main background)
foreground:          #______  (main text)
background_alt:      #______  (sidebars, UI elements)
foreground_dim:      #______  (comments, less important text)

# Cursor & Selection
cursor:              #______
cursor_text:         #______  (text under cursor)
selection:           #______  (visual selection background)

# UI Elements
border:              #______  (window borders)
gutter:              #______  (line number background)
line_highlight:      #______  (current line highlight)
```

### Semantic Colors (ANSI Terminal Colors)
```
# Standard ANSI (0-7)
black:               #______  (ANSI 0)
red:                 #______  (ANSI 1 - errors, deletion)
green:               #______  (ANSI 2 - success, addition)
yellow:              #______  (ANSI 3 - warnings)
blue:                #______  (ANSI 4 - info, functions)
magenta:             #______  (ANSI 5 - keywords, special)
cyan:                #______  (ANSI 6 - strings, constants)
white:               #______  (ANSI 7)

# Bright variants (8-15)
bright_black:        #______  (ANSI 8 - comments)
bright_red:          #______  (ANSI 9)
bright_green:        #______  (ANSI 10)
bright_yellow:       #______  (ANSI 11)
bright_blue:         #______  (ANSI 12)
bright_magenta:      #______  (ANSI 13)
bright_cyan:         #______  (ANSI 14)
bright_white:        #______  (ANSI 15)
```

### Syntax Highlighting Colors
```
# Programming elements
keyword:             #______  (if, for, func, let, etc.)
function:            #______  (function names)
string:              #______  (string literals)
number:              #______  (numeric literals)
constant:            #______  (true, false, nil)
comment:             #______  (code comments)
type:                #______  (struct, interface, types)
operator:            #______  (+, -, =, etc.)
variable:            #______  (variable names)
parameter:           #______  (function parameters)

# Diagnostics
error:               #______  (LSP errors)
warning:             #______  (LSP warnings)
info:                #______  (LSP info)
hint:                #______  (LSP hints)

# Git/Diff
git_add:             #______  (added lines)
git_change:          #______  (modified lines)
git_delete:          #______  (deleted lines)
```

## Implementation Files

### 1. Neovim Custom Colorscheme
**Location:** `~/.config/nvim/colors/custom.lua`

```lua
-- custom.lua - Your harmonized colorscheme for Neovim

local M = {}

-- Color palette
local colors = {
  -- Base colors
  bg = "#______",
  fg = "#______",
  bg_alt = "#______",
  fg_dim = "#______",
  
  -- Cursor & Selection
  cursor = "#______",
  cursor_text = "#______",
  selection = "#______",
  
  -- UI
  border = "#______",
  gutter = "#______",
  line_highlight = "#______",
  
  -- ANSI colors
  black = "#______",
  red = "#______",
  green = "#______",
  yellow = "#______",
  blue = "#______",
  magenta = "#______",
  cyan = "#______",
  white = "#______",
  
  bright_black = "#______",
  bright_red = "#______",
  bright_green = "#______",
  bright_yellow = "#______",
  bright_blue = "#______",
  bright_magenta = "#______",
  bright_cyan = "#______",
  bright_white = "#______",
  
  -- Syntax
  keyword = "#______",
  func = "#______",
  string = "#______",
  number = "#______",
  constant = "#______",
  comment = "#______",
  type = "#______",
  operator = "#______",
  variable = "#______",
  parameter = "#______",
  
  -- Diagnostics
  error = "#______",
  warning = "#______",
  info = "#______",
  hint = "#______",
  
  -- Git
  git_add = "#______",
  git_change = "#______",
  git_delete = "#______",
}

-- Helper function to set highlight groups
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  -- Reset existing highlighting
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.o.termguicolors = true
  vim.g.colors_name = "custom"
  
  -- Editor highlights
  hi("Normal", { fg = colors.fg, bg = colors.bg })
  hi("NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
  hi("Comment", { fg = colors.comment, italic = true })
  hi("ColorColumn", { bg = colors.bg_alt })
  hi("Cursor", { fg = colors.cursor_text, bg = colors.cursor })
  hi("CursorLine", { bg = colors.line_highlight })
  hi("CursorLineNr", { fg = colors.yellow, bg = colors.line_highlight })
  hi("LineNr", { fg = colors.bright_black, bg = colors.gutter })
  hi("SignColumn", { bg = colors.gutter })
  hi("Visual", { bg = colors.selection })
  hi("VertSplit", { fg = colors.border })
  hi("StatusLine", { fg = colors.fg, bg = colors.bg_alt })
  hi("StatusLineNC", { fg = colors.fg_dim, bg = colors.bg_alt })
  
  -- Syntax highlighting
  hi("Keyword", { fg = colors.keyword, bold = true })
  hi("Function", { fg = colors.func })
  hi("String", { fg = colors.string })
  hi("Number", { fg = colors.number })
  hi("Boolean", { fg = colors.constant })
  hi("Constant", { fg = colors.constant })
  hi("Type", { fg = colors.type })
  hi("Operator", { fg = colors.operator })
  hi("Identifier", { fg = colors.variable })
  hi("Special", { fg = colors.magenta })
  
  -- Tree-sitter highlights (@-prefixed groups)
  hi("@keyword", { link = "Keyword" })
  hi("@function", { link = "Function" })
  hi("@function.builtin", { fg = colors.func, bold = true })
  hi("@string", { link = "String" })
  hi("@number", { link = "Number" })
  hi("@boolean", { link = "Boolean" })
  hi("@constant", { link = "Constant" })
  hi("@type", { link = "Type" })
  hi("@operator", { link = "Operator" })
  hi("@variable", { link = "Identifier" })
  hi("@parameter", { fg = colors.parameter })
  hi("@comment", { link = "Comment" })
  
  -- LSP Diagnostics
  hi("DiagnosticError", { fg = colors.error })
  hi("DiagnosticWarn", { fg = colors.warning })
  hi("DiagnosticInfo", { fg = colors.info })
  hi("DiagnosticHint", { fg = colors.hint })
  hi("DiagnosticUnderlineError", { undercurl = true, sp = colors.error })
  hi("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })
  
  -- Git signs
  hi("GitSignsAdd", { fg = colors.git_add })
  hi("GitSignsChange", { fg = colors.git_change })
  hi("GitSignsDelete", { fg = colors.git_delete })
  hi("DiffAdd", { fg = colors.git_add, bg = colors.bg_alt })
  hi("DiffChange", { fg = colors.git_change, bg = colors.bg_alt })
  hi("DiffDelete", { fg = colors.git_delete, bg = colors.bg_alt })
  
  -- Telescope (fuzzy finder)
  hi("TelescopeBorder", { fg = colors.border })
  hi("TelescopeSelection", { fg = colors.fg, bg = colors.selection })
  
  -- Terminal colors (for :terminal)
  vim.g.terminal_color_0 = colors.black
  vim.g.terminal_color_1 = colors.red
  vim.g.terminal_color_2 = colors.green
  vim.g.terminal_color_3 = colors.yellow
  vim.g.terminal_color_4 = colors.blue
  vim.g.terminal_color_5 = colors.magenta
  vim.g.terminal_color_6 = colors.cyan
  vim.g.terminal_color_7 = colors.white
  vim.g.terminal_color_8 = colors.bright_black
  vim.g.terminal_color_9 = colors.bright_red
  vim.g.terminal_color_10 = colors.bright_green
  vim.g.terminal_color_11 = colors.bright_yellow
  vim.g.terminal_color_12 = colors.bright_blue
  vim.g.terminal_color_13 = colors.bright_magenta
  vim.g.terminal_color_14 = colors.bright_cyan
  vim.g.terminal_color_15 = colors.bright_white
end

M.setup()

return M
```

**To use:** Add to your `init.lua`:
```lua
-- In plugins/ui.lua, replace the colorscheme section with:
vim.cmd("colorscheme custom")
```

### 2. Wezterm Configuration
**Location:** `~/.config/wezterm/wezterm.lua`

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 14

-- Your custom color scheme
config.colors = {
  -- Base colors
  foreground = '#______',
  background = '#______',
  cursor_bg = '#______',
  cursor_fg = '#______',
  cursor_border = '#______',
  selection_fg = '#______',
  selection_bg = '#______',
  
  -- ANSI colors (0-7)
  ansi = {
    '#______',  -- black
    '#______',  -- red
    '#______',  -- green
    '#______',  -- yellow
    '#______',  -- blue
    '#______',  -- magenta
    '#______',  -- cyan
    '#______',  -- white
  },
  
  -- Bright ANSI colors (8-15)
  brights = {
    '#______',  -- bright black
    '#______',  -- bright red
    '#______',  -- bright green
    '#______',  -- bright yellow
    '#______',  -- bright blue
    '#______',  -- bright magenta
    '#______',  -- bright cyan
    '#______',  -- bright white
  },
  
  -- Tab bar colors (optional)
  tab_bar = {
    background = '#______',  -- match bg_alt from nvim
    
    active_tab = {
      bg_color = '#______',  -- match bg from nvim
      fg_color = '#______',  -- match fg from nvim
    },
    
    inactive_tab = {
      bg_color = '#______',  -- match bg_alt from nvim
      fg_color = '#______',  -- match fg_dim from nvim
    },
    
    inactive_tab_hover = {
      bg_color = '#______',  -- match selection from nvim
      fg_color = '#______',  -- match fg from nvim
    },
  },
}

-- Enable true color
config.term = 'wezterm'

-- Tab bar appearance
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Window appearance
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- Optional: window background opacity
-- config.window_background_opacity = 0.95

return config
```

### 3. Claude Code Configuration
**Location:** `~/.config/claude/config.json` (may vary by system)

Claude Code typically inherits terminal colors from wezterm, but you can configure its UI theme:

```json
{
  "theme": {
    "mode": "dark",
    "colors": {
      "background": "#______",
      "foreground": "#______",
      "accent": "#______",
      "error": "#______",
      "warning": "#______",
      "success": "#______"
    }
  }
}
```

**Note:** Claude Code primarily uses your terminal's color scheme. The key is making sure wezterm's colors match your Neovim theme.

## Color Scheme Templates

### Template 1: Modern Dark Blue (Inspired by Tokyo Night)
```yaml
# Base
background:       "#1a1b26"
foreground:       "#c0caf5"
bg_alt:           "#16161e"
fg_dim:           "#565f89"
cursor:           "#c0caf5"
selection:        "#283457"
border:           "#1f2335"
line_highlight:   "#1f2335"

# ANSI Standard
black:            "#15161e"
red:              "#f7768e"
green:            "#9ece6a"
yellow:           "#e0af68"
blue:             "#7aa2f7"
magenta:          "#bb9af7"
cyan:             "#7dcfff"
white:            "#a9b1d6"

# ANSI Bright
bright_black:     "#414868"
bright_red:       "#f7768e"
bright_green:     "#9ece6a"
bright_yellow:    "#e0af68"
bright_blue:      "#7aa2f7"
bright_magenta:   "#bb9af7"
bright_cyan:      "#7dcfff"
bright_white:     "#c0caf5"

# Syntax
keyword:          "#bb9af7"
function:         "#7aa2f7"
string:           "#9ece6a"
number:           "#ff9e64"
constant:         "#ff9e64"
comment:          "#565f89"
type:             "#2ac3de"
operator:         "#89ddff"
variable:         "#c0caf5"

# Diagnostics
error:            "#f7768e"
warning:          "#e0af68"
info:             "#7aa2f7"
hint:             "#1abc9c"

# Git
git_add:          "#9ece6a"
git_change:       "#e0af68"
git_delete:       "#f7768e"
```

### Template 2: Warm Dark (Inspired by Gruvbox)
```yaml
# Base
background:       "#282828"
foreground:       "#ebdbb2"
bg_alt:           "#1d2021"
fg_dim:           "#928374"
cursor:           "#ebdbb2"
selection:        "#504945"
border:           "#3c3836"
line_highlight:   "#3c3836"

# ANSI Standard
black:            "#282828"
red:              "#cc241d"
green:            "#98971a"
yellow:           "#d79921"
blue:             "#458588"
magenta:          "#b16286"
cyan:             "#689d6a"
white:            "#a89984"

# ANSI Bright
bright_black:     "#928374"
bright_red:       "#fb4934"
bright_green:     "#b8bb26"
bright_yellow:    "#fabd2f"
bright_blue:      "#83a598"
bright_magenta:   "#d3869b"
bright_cyan:      "#8ec07c"
bright_white:     "#ebdbb2"

# Syntax
keyword:          "#fb4934"
function:         "#b8bb26"
string:           "#b8bb26"
number:           "#d3869b"
constant:         "#d3869b"
comment:          "#928374"
type:             "#fabd2f"
operator:         "#fe8019"
variable:         "#ebdbb2"

# Diagnostics
error:            "#fb4934"
warning:          "#fabd2f"
info:             "#83a598"
hint:             "#8ec07c"

# Git
git_add:          "#b8bb26"
git_change:       "#fabd2f"
git_delete:       "#fb4934"
```

### Template 3: Soft Pastel Dark (Inspired by Catppuccin Mocha)
```yaml
# Base
background:       "#1e1e2e"
foreground:       "#cdd6f4"
bg_alt:           "#181825"
fg_dim:           "#6c7086"
cursor:           "#f5e0dc"
selection:        "#45475a"
border:           "#313244"
line_highlight:   "#313244"

# ANSI Standard
black:            "#45475a"
red:              "#f38ba8"
green:            "#a6e3a1"
yellow:           "#f9e2af"
blue:             "#89b4fa"
magenta:          "#f5c2e7"
cyan:             "#94e2d5"
white:            "#bac2de"

# ANSI Bright
bright_black:     "#585b70"
bright_red:       "#f38ba8"
bright_green:     "#a6e3a1"
bright_yellow:    "#f9e2af"
bright_blue:      "#89b4fa"
bright_magenta:   "#f5c2e7"
bright_cyan:      "#94e2d5"
bright_white:     "#a6adc8"

# Syntax
keyword:          "#cba6f7"
function:         "#89b4fa"
string:           "#a6e3a1"
number:           "#fab387"
constant:         "#fab387"
comment:          "#6c7086"
type:             "#f9e2af"
operator:         "#89dceb"
variable:         "#cdd6f4"

# Diagnostics
error:            "#f38ba8"
warning:          "#fab387"
info:             "#89b4fa"
hint:             "#94e2d5"

# Git
git_add:          "#a6e3a1"
git_change:       "#fab387"
git_delete:       "#f38ba8"
```

## Implementation Checklist

### Step 1: Choose or Create Your Palette
- [ ] Select a template or define custom colors
- [ ] Fill in all hex values in the palette structure above
- [ ] Test colors for sufficient contrast (use a contrast checker tool)

### Step 2: Implement Neovim Theme
- [ ] Create `~/.config/nvim/colors/custom.lua`
- [ ] Copy the template and fill in your colors
- [ ] Update `init.lua` to use `colorscheme custom`
- [ ] Test in Neovim: `:colorscheme custom`
- [ ] Verify syntax highlighting looks good in Go and Rust files

### Step 3: Configure Wezterm
- [ ] Update `~/.config/wezterm/wezterm.lua` with matching colors
- [ ] Restart wezterm or reload config
- [ ] Verify ANSI colors match (run `ls --color=auto`)
- [ ] Check that vim inside wezterm looks identical to standalone nvim

### Step 4: Test Harmony
- [ ] Open Neovim in wezterm
- [ ] Open Claude Code in adjacent wezterm pane
- [ ] Verify colors feel cohesive across all windows
- [ ] Test with actual code files (Go/Rust)
- [ ] Check LSP diagnostics (errors, warnings) are clearly visible

### Step 5: Fine-tune
- [ ] Adjust any colors that feel off
- [ ] Ensure comment visibility (important!)
- [ ] Verify cursor is easily visible
- [ ] Test selection backgrounds work well
- [ ] Confirm git diff colors make sense

## Testing Your Color Scheme

### Visual Tests
1. **Syntax test file for Go:**
```go
package main

import "fmt"

// Comment: check visibility
const MaxSize = 100

type Config struct {
    Name string
    Port int
}

func main() {
    var count int = 42
    message := "Hello, World!"
    
    if count > 0 {
        fmt.Println(message)
    }
}
```

2. **Syntax test file for Rust:**
```rust
// Comment: check visibility
use std::io;

const MAX_SIZE: usize = 100;

struct Config {
    name: String,
    port: u16,
}

fn main() {
    let count: i32 = 42;
    let message = "Hello, World!";
    
    if count > 0 {
        println!("{}", message);
    }
}
```

3. **LSP Diagnostic test:**
- Introduce an intentional error (e.g., typo in variable name)
- Check that error highlighting is visible but not jarring
- Verify warning colors are distinct from errors

4. **ANSI color test:** Run in terminal:
```bash
# Test script to show all 16 ANSI colors
for i in {0..15}; do
    echo -e "\e[38;5;${i}m Color $i \e[0m"
done
```

## Color Harmony Tips

### Contrast Guidelines
- **Background to foreground:** Minimum 7:1 ratio (WCAG AAA)
- **Syntax highlighting:** 4.5:1 ratio to background
- **Comments:** 3:1 ratio (less than normal text is okay)
- **Cursor:** Maximum contrast (should be immediately visible)

### Color Temperature
- Keep all accent colors in similar temperature range (all cool or all warm)
- Use temperature for semantic meaning (warm = danger/error, cool = info)

### Saturation
- Lower saturation = easier on eyes for long sessions
- Reserve high saturation for important elements (errors, cursor)
- Comments should be lowest saturation

### Testing Environment
Test your theme in multiple scenarios:
- Bright room (daytime)
- Dim room (evening)
- Different screen types (if applicable)
- After 30+ minutes of use (eye strain test)

## Troubleshooting

### Colors don't match between Neovim and terminal
- Verify `set termguicolors` is enabled in Neovim
- Check `$TERM` environment variable: `echo $TERM`
- Should be `wezterm` or `xterm-256color`

### Claude Code colors look different
- Claude Code uses terminal colors from wezterm
- Make sure wezterm config is loaded: restart wezterm
- Check wezterm config path: `~/.config/wezterm/wezterm.lua`

### Syntax highlighting missing
- Ensure Tree-sitter is installed: `:checkhealth nvim-treesitter`
- Install language parsers: `:TSInstall go rust`
- Verify colorscheme sets `@` highlight groups

### Colors look washed out
- Check terminal emulator settings (contrast, gamma)
- Increase saturation in your color palette
- Verify true color support: `:set termguicolors?`

## Export Your Theme

Once you're happy with your colors, document them:

```markdown
# My Custom Theme - [Your Theme Name]

**Philosophy:** [Brief description]
**Inspiration:** [Any themes you referenced]
**Best for:** [Time of day, use case, etc.]

## Palette
[Copy your final color values here]

## Screenshots
[Add screenshots of actual usage]

## Installation
[Brief installation steps]
```

## Advanced: Programmatic Color Generation

If you want to generate colors programmatically, here's a Lua helper:

```lua
-- Color manipulation helpers
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16) / 255,
    g = tonumber(hex:sub(3, 4), 16) / 255,
    b = tonumber(hex:sub(5, 6), 16) / 255,
  }
end

local function rgb_to_hex(rgb)
  return string.format("#%02x%02x%02x",
    math.floor(rgb.r * 255),
    math.floor(rgb.g * 255),
    math.floor(rgb.b * 255)
  )
end

local function blend(color1, color2, ratio)
  local rgb1 = hex_to_rgb(color1)
  local rgb2 = hex_to_rgb(color2)
  return rgb_to_hex({
    r = rgb1.r * (1 - ratio) + rgb2.r * ratio,
    g = rgb1.g * (1 - ratio) + rgb2.g * ratio,
    b = rgb1.b * (1 - ratio) + rgb2.b * ratio,
  })
end

-- Example: create intermediate shades
local bg = "#1a1b26"
local fg = "#c0caf5"
local bg_alt = blend(bg, fg, 0.05)  -- 5% lighter than bg
local fg_dim = blend(fg, bg, 0.50)  -- 50% dimmer than fg
```

---

**Ready to build your theme?** Start with one of the templates above, or define your own colors using a tool like [Coolors.co](https://coolors.co/) or [Adobe Color](https://color.adobe.com/), then work through the implementation checklist!
