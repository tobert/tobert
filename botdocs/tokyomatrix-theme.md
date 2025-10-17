# Tokyo Matrix - Custom Color Scheme
**A Matrix-inspired evolution of Tokyo Night with enhanced contrast and green hues**

## Theme Philosophy
- **Base:** Tokyo Night's proven color relationships
- **Twist:** Deeper blacks, green-tinted text, Matrix-inspired aesthetic
- **Contrast:** Moderate-high for clarity and reduced eye strain
- **Font:** Cascadia Code Nerd Font (light weight)
- **Optimized:** Wezterm on Windows with full GPU acceleration

## Color Palette - Tokyo Matrix

```yaml
# Base Colors (darker, more Matrix-y)
background:       "#0d0f15"  # Almost black (was #1a1b26)
foreground:       "#b8e0b8"  # Green-tinted off-white (was #c0caf5)
bg_alt:           "#13151f"  # Slightly lighter black for UI
fg_dim:           "#5a7a5a"  # Dimmed green for comments
cursor:           "#80ff80"  # Bright Matrix green
cursor_text:      "#0d0f15"  # Dark text under cursor
selection:        "#1a3d2d"  # Dark green selection
border:           "#1a2233"  # Subtle blue-grey borders
gutter:           "#0d0f15"  # Match background
line_highlight:   "#151821"  # Very subtle highlight

# ANSI Colors (enhanced with green tints where appropriate)
black:            "#0d0f15"
red:              "#ff5f87"  # Slightly more vibrant
green:            "#73ff73"  # Bright Matrix green
yellow:           "#e5c07b"  # Warm but not too bright
blue:             "#5fbfff"  # Bright cyan-blue
magenta:          "#d75fd7"  # Vibrant purple
cyan:             "#5fffaf"  # Matrix-inspired cyan
white:            "#b8e0b8"  # Green-tinted white

# Bright ANSI (more punch)
bright_black:     "#3a4f4a"  # Grey with green undertone
bright_red:       "#ff6b9d"
bright_green:     "#95ff95"  # Even brighter green
bright_yellow:    "#ffd787"
bright_blue:      "#7dcfff"
bright_magenta:   "#ff87ff"
bright_cyan:      "#87ffd7"  # Very bright cyan
bright_white:     "#d0ffd0"  # Almost neon green-white

# Syntax Highlighting (Matrix-optimized)
keyword:          "#af87ff"  # Purple (keep from Tokyo Night)
function:         "#5fbfff"  # Bright cyan-blue
string:           "#95ff95"  # Bright green (Matrix!)
number:           "#ff9e64"  # Orange accent
constant:         "#ff9e64"  # Match numbers
comment:          "#5a7a5a"  # Dim green, readable
type:             "#2affaa"  # Bright cyan
operator:         "#5fffaf"  # Matrix cyan
variable:         "#b8e0b8"  # Default green-tinted
parameter:        "#87ceeb"  # Light blue for distinction
builtin:          "#7dcfff"  # Bright blue for builtins

# Diagnostics (clear and distinct)
error:            "#ff5f87"  # Bright pink-red
warning:          "#ffaf5f"  # Warm orange
info:             "#5fbfff"  # Blue
hint:             "#5fffaf"  # Cyan-green

# Git Diff (traffic light + Matrix green)
git_add:          "#73ff73"  # Matrix green
git_change:       "#ffd787"  # Yellow
git_delete:       "#ff5f87"  # Red

# UI Accents
match_paren:      "#ff87ff"  # Bright magenta
search:           "#ffd75f"  # Yellow highlight
inc_search:       "#ff9e64"  # Orange for current match
menu_sel:         "#1a3d2d"  # Dark green selection
```

## 1. Neovim Configuration

### File: `~/.config/nvim/colors/tokyomatrix.lua`

```lua
-- tokyomatrix.lua - Matrix-inspired Tokyo Night evolution
-- Darker background, green-tinted text, higher contrast

local M = {}

local c = {
  -- Base
  bg = "#0d0f15",
  fg = "#b8e0b8",
  bg_alt = "#13151f",
  bg_darker = "#080a0f",
  fg_dim = "#5a7a5a",
  
  -- Cursor & Selection
  cursor = "#80ff80",
  cursor_text = "#0d0f15",
  selection = "#1a3d2d",
  visual = "#1a3d2d",
  
  -- UI Elements
  border = "#1a2233",
  gutter = "#0d0f15",
  line_highlight = "#151821",
  menu_sel = "#1a3d2d",
  
  -- ANSI Base
  black = "#0d0f15",
  red = "#ff5f87",
  green = "#73ff73",
  yellow = "#e5c07b",
  blue = "#5fbfff",
  magenta = "#d75fd7",
  cyan = "#5fffaf",
  white = "#b8e0b8",
  
  -- ANSI Bright
  bright_black = "#3a4f4a",
  bright_red = "#ff6b9d",
  bright_green = "#95ff95",
  bright_yellow = "#ffd787",
  bright_blue = "#7dcfff",
  bright_magenta = "#ff87ff",
  bright_cyan = "#87ffd7",
  bright_white = "#d0ffd0",
  
  -- Syntax
  keyword = "#af87ff",      -- Purple
  func = "#5fbfff",         -- Cyan-blue
  string = "#95ff95",       -- Matrix green
  number = "#ff9e64",       -- Orange
  constant = "#ff9e64",     -- Orange
  comment = "#5a7a5a",      -- Dim green
  type = "#2affaa",         -- Bright cyan
  operator = "#5fffaf",     -- Cyan
  variable = "#b8e0b8",     -- Base fg
  parameter = "#87ceeb",    -- Light blue
  builtin = "#7dcfff",      -- Bright blue
  
  -- Special
  special = "#ff87ff",
  match_paren = "#ff87ff",
  
  -- Diagnostics
  error = "#ff5f87",
  warning = "#ffaf5f",
  info = "#5fbfff",
  hint = "#5fffaf",
  
  -- Git
  git_add = "#73ff73",
  git_change = "#ffd787",
  git_delete = "#ff5f87",
  
  -- Search
  search = "#ffd75f",
  inc_search = "#ff9e64",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.o.termguicolors = true
  vim.g.colors_name = "tokyomatrix"
  
  -- Editor UI
  hi("Normal", { fg = c.fg, bg = c.bg })
  hi("NormalFloat", { fg = c.fg, bg = c.bg_alt })
  hi("NormalNC", { fg = c.fg, bg = c.bg })
  hi("Comment", { fg = c.comment, italic = true })
  hi("ColorColumn", { bg = c.bg_alt })
  hi("Cursor", { fg = c.cursor_text, bg = c.cursor })
  hi("lCursor", { link = "Cursor" })
  hi("CursorIM", { link = "Cursor" })
  hi("CursorLine", { bg = c.line_highlight })
  hi("CursorLineNr", { fg = c.green, bg = c.line_highlight, bold = true })
  hi("LineNr", { fg = c.bright_black, bg = c.gutter })
  hi("SignColumn", { fg = c.fg, bg = c.gutter })
  hi("Folded", { fg = c.bright_blue, bg = c.bg_alt })
  hi("FoldColumn", { fg = c.comment, bg = c.gutter })
  hi("VertSplit", { fg = c.border })
  hi("WinSeparator", { fg = c.border })
  
  -- Visual & Selection
  hi("Visual", { bg = c.selection })
  hi("VisualNOS", { bg = c.selection })
  hi("IncSearch", { fg = c.black, bg = c.inc_search, bold = true })
  hi("Search", { fg = c.black, bg = c.search })
  hi("MatchParen", { fg = c.match_paren, bold = true, underline = true })
  
  -- Status & Tab lines
  hi("StatusLine", { fg = c.fg, bg = c.bg_alt })
  hi("StatusLineNC", { fg = c.fg_dim, bg = c.bg_darker })
  hi("TabLine", { fg = c.fg_dim, bg = c.bg_alt })
  hi("TabLineFill", { bg = c.bg_darker })
  hi("TabLineSel", { fg = c.bright_white, bg = c.bg })
  
  -- Popup Menu
  hi("Pmenu", { fg = c.fg, bg = c.bg_alt })
  hi("PmenuSel", { fg = c.bright_white, bg = c.menu_sel })
  hi("PmenuSbar", { bg = c.bg_alt })
  hi("PmenuThumb", { bg = c.border })
  
  -- Messages & Command Line
  hi("ErrorMsg", { fg = c.error, bold = true })
  hi("WarningMsg", { fg = c.warning, bold = true })
  hi("ModeMsg", { fg = c.bright_green, bold = true })
  hi("MoreMsg", { fg = c.bright_green })
  hi("Question", { fg = c.bright_blue })
  
  -- Base Syntax
  hi("Constant", { fg = c.constant })
  hi("String", { fg = c.string })
  hi("Character", { fg = c.string })
  hi("Number", { fg = c.number })
  hi("Boolean", { fg = c.constant })
  hi("Float", { fg = c.number })
  
  hi("Identifier", { fg = c.variable })
  hi("Function", { fg = c.func })
  
  hi("Statement", { fg = c.keyword })
  hi("Conditional", { fg = c.keyword })
  hi("Repeat", { fg = c.keyword })
  hi("Label", { fg = c.keyword })
  hi("Operator", { fg = c.operator })
  hi("Keyword", { fg = c.keyword, bold = true })
  hi("Exception", { fg = c.keyword })
  
  hi("PreProc", { fg = c.cyan })
  hi("Include", { fg = c.keyword })
  hi("Define", { fg = c.keyword })
  hi("Macro", { fg = c.magenta })
  hi("PreCondit", { fg = c.keyword })
  
  hi("Type", { fg = c.type })
  hi("StorageClass", { fg = c.keyword })
  hi("Structure", { fg = c.type })
  hi("Typedef", { fg = c.type })
  
  hi("Special", { fg = c.special })
  hi("SpecialChar", { fg = c.special })
  hi("Tag", { fg = c.cyan })
  hi("Delimiter", { fg = c.fg })
  hi("SpecialComment", { fg = c.bright_black })
  hi("Debug", { fg = c.red })
  
  hi("Underlined", { underline = true })
  hi("Ignore", { fg = c.comment })
  hi("Error", { fg = c.error, bold = true })
  hi("Todo", { fg = c.yellow, bold = true })
  
  -- Tree-sitter
  hi("@attribute", { fg = c.cyan })
  hi("@boolean", { link = "Boolean" })
  hi("@character", { link = "Character" })
  hi("@comment", { link = "Comment" })
  hi("@constant", { link = "Constant" })
  hi("@constant.builtin", { fg = c.builtin, bold = true })
  hi("@constant.macro", { link = "Macro" })
  hi("@constructor", { fg = c.type })
  hi("@error", { link = "Error" })
  hi("@exception", { link = "Exception" })
  hi("@field", { fg = c.cyan })
  hi("@float", { link = "Float" })
  hi("@function", { link = "Function" })
  hi("@function.builtin", { fg = c.builtin, bold = true })
  hi("@function.macro", { link = "Macro" })
  hi("@include", { link = "Include" })
  hi("@keyword", { link = "Keyword" })
  hi("@keyword.function", { fg = c.keyword, italic = true })
  hi("@keyword.operator", { fg = c.operator })
  hi("@keyword.return", { fg = c.keyword, bold = true })
  hi("@label", { fg = c.blue })
  hi("@method", { link = "Function" })
  hi("@namespace", { fg = c.type })
  hi("@number", { link = "Number" })
  hi("@operator", { link = "Operator" })
  hi("@parameter", { fg = c.parameter })
  hi("@parameter.reference", { fg = c.parameter })
  hi("@property", { fg = c.cyan })
  hi("@punctuation.delimiter", { fg = c.fg })
  hi("@punctuation.bracket", { fg = c.fg })
  hi("@punctuation.special", { fg = c.special })
  hi("@repeat", { link = "Repeat" })
  hi("@string", { link = "String" })
  hi("@string.escape", { fg = c.special })
  hi("@string.regex", { fg = c.special })
  hi("@string.special", { fg = c.special })
  hi("@symbol", { fg = c.cyan })
  hi("@tag", { fg = c.blue })
  hi("@tag.attribute", { fg = c.cyan })
  hi("@tag.delimiter", { fg = c.fg })
  hi("@text", { fg = c.fg })
  hi("@text.strong", { bold = true })
  hi("@text.emphasis", { italic = true })
  hi("@text.underline", { underline = true })
  hi("@text.strike", { strikethrough = true })
  hi("@text.title", { fg = c.bright_blue, bold = true })
  hi("@text.literal", { fg = c.string })
  hi("@text.uri", { fg = c.cyan, underline = true })
  hi("@type", { link = "Type" })
  hi("@type.builtin", { fg = c.builtin })
  hi("@variable", { link = "Identifier" })
  hi("@variable.builtin", { fg = c.builtin })
  
  -- LSP Semantic Tokens
  hi("@lsp.type.class", { link = "Type" })
  hi("@lsp.type.decorator", { link = "Function" })
  hi("@lsp.type.enum", { link = "Type" })
  hi("@lsp.type.enumMember", { link = "Constant" })
  hi("@lsp.type.function", { link = "Function" })
  hi("@lsp.type.interface", { link = "Type" })
  hi("@lsp.type.macro", { link = "Macro" })
  hi("@lsp.type.method", { link = "Function" })
  hi("@lsp.type.namespace", { link = "@namespace" })
  hi("@lsp.type.parameter", { link = "@parameter" })
  hi("@lsp.type.property", { link = "@property" })
  hi("@lsp.type.struct", { link = "Type" })
  hi("@lsp.type.type", { link = "Type" })
  hi("@lsp.type.typeParameter", { link = "Type" })
  hi("@lsp.type.variable", { link = "Identifier" })
  
  -- LSP Diagnostics
  hi("DiagnosticError", { fg = c.error })
  hi("DiagnosticWarn", { fg = c.warning })
  hi("DiagnosticInfo", { fg = c.info })
  hi("DiagnosticHint", { fg = c.hint })
  hi("DiagnosticOk", { fg = c.green })
  
  hi("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
  hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warning })
  hi("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
  hi("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })
  
  hi("DiagnosticVirtualTextError", { fg = c.error, bg = c.bg_darker })
  hi("DiagnosticVirtualTextWarn", { fg = c.warning, bg = c.bg_darker })
  hi("DiagnosticVirtualTextInfo", { fg = c.info, bg = c.bg_darker })
  hi("DiagnosticVirtualTextHint", { fg = c.hint, bg = c.bg_darker })
  
  hi("DiagnosticSignError", { fg = c.error, bg = c.gutter })
  hi("DiagnosticSignWarn", { fg = c.warning, bg = c.gutter })
  hi("DiagnosticSignInfo", { fg = c.info, bg = c.gutter })
  hi("DiagnosticSignHint", { fg = c.hint, bg = c.gutter })
  
  -- Git
  hi("GitSignsAdd", { fg = c.git_add, bg = c.gutter })
  hi("GitSignsChange", { fg = c.git_change, bg = c.gutter })
  hi("GitSignsDelete", { fg = c.git_delete, bg = c.gutter })
  hi("GitSignsAddNr", { fg = c.git_add })
  hi("GitSignsChangeNr", { fg = c.git_change })
  hi("GitSignsDeleteNr", { fg = c.git_delete })
  
  hi("DiffAdd", { fg = c.git_add, bg = c.bg_alt })
  hi("DiffChange", { fg = c.git_change, bg = c.bg_alt })
  hi("DiffDelete", { fg = c.git_delete, bg = c.bg_alt })
  hi("DiffText", { fg = c.bright_white, bg = c.selection })
  
  -- Telescope
  hi("TelescopeBorder", { fg = c.border, bg = c.bg })
  hi("TelescopeNormal", { fg = c.fg, bg = c.bg })
  hi("TelescopeSelection", { fg = c.bright_white, bg = c.selection })
  hi("TelescopeSelectionCaret", { fg = c.green, bg = c.selection })
  hi("TelescopeMultiSelection", { fg = c.cyan })
  hi("TelescopeMatching", { fg = c.bright_green, bold = true })
  
  -- Lualine (statusline)
  hi("lualine_a_normal", { fg = c.black, bg = c.bright_green, bold = true })
  hi("lualine_a_insert", { fg = c.black, bg = c.bright_blue, bold = true })
  hi("lualine_a_visual", { fg = c.black, bg = c.magenta, bold = true })
  hi("lualine_a_replace", { fg = c.black, bg = c.red, bold = true })
  hi("lualine_a_command", { fg = c.black, bg = c.yellow, bold = true })
  
  -- nvim-cmp (completion menu)
  hi("CmpItemAbbrMatch", { fg = c.bright_green, bold = true })
  hi("CmpItemAbbrMatchFuzzy", { fg = c.green, bold = true })
  hi("CmpItemKindFunction", { fg = c.func })
  hi("CmpItemKindMethod", { fg = c.func })
  hi("CmpItemKindVariable", { fg = c.cyan })
  hi("CmpItemKindKeyword", { fg = c.keyword })
  hi("CmpItemKindText", { fg = c.fg })
  hi("CmpItemKindConstant", { fg = c.constant })
  hi("CmpItemKindModule", { fg = c.yellow })
  hi("CmpItemKindStruct", { fg = c.type })
  
  -- Indent-blankline
  hi("IblIndent", { fg = c.border, nocombine = true })
  hi("IblScope", { fg = c.cyan, nocombine = true })
  
  -- Terminal
  vim.g.terminal_color_0 = c.black
  vim.g.terminal_color_1 = c.red
  vim.g.terminal_color_2 = c.green
  vim.g.terminal_color_3 = c.yellow
  vim.g.terminal_color_4 = c.blue
  vim.g.terminal_color_5 = c.magenta
  vim.g.terminal_color_6 = c.cyan
  vim.g.terminal_color_7 = c.white
  vim.g.terminal_color_8 = c.bright_black
  vim.g.terminal_color_9 = c.bright_red
  vim.g.terminal_color_10 = c.bright_green
  vim.g.terminal_color_11 = c.bright_yellow
  vim.g.terminal_color_12 = c.bright_blue
  vim.g.terminal_color_13 = c.bright_magenta
  vim.g.terminal_color_14 = c.bright_cyan
  vim.g.terminal_color_15 = c.bright_white
end

M.setup()

return M
```

### Update your `init.lua` or `plugins/ui.lua`:

```lua
-- In plugins/ui.lua, replace the tokyonight section with:
{
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme tokyomatrix")
  end,
},
```

## 2. Wezterm Configuration

### File: `~/.config/wezterm/wezterm.lua` (Windows: `%USERPROFILE%\.config\wezterm\wezterm.lua`)

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================================
-- TOKYO MATRIX THEME
-- ============================================================================

config.colors = {
  foreground = '#b8e0b8',
  background = '#0d0f15',
  cursor_bg = '#80ff80',
  cursor_fg = '#0d0f15',
  cursor_border = '#80ff80',
  selection_fg = '#d0ffd0',
  selection_bg = '#1a3d2d',
  
  scrollbar_thumb = '#3a4f4a',
  split = '#1a2233',
  
  ansi = {
    '#0d0f15',  -- black
    '#ff5f87',  -- red
    '#73ff73',  -- green
    '#e5c07b',  -- yellow
    '#5fbfff',  -- blue
    '#d75fd7',  -- magenta
    '#5fffaf',  -- cyan
    '#b8e0b8',  -- white
  },
  
  brights = {
    '#3a4f4a',  -- bright black
    '#ff6b9d',  -- bright red
    '#95ff95',  -- bright green
    '#ffd787',  -- bright yellow
    '#7dcfff',  -- bright blue
    '#ff87ff',  -- bright magenta
    '#87ffd7',  -- bright cyan
    '#d0ffd0',  -- bright white
  },
  
  -- Tab bar
  tab_bar = {
    background = '#080a0f',
    
    active_tab = {
      bg_color = '#0d0f15',
      fg_color = '#b8e0b8',
      intensity = 'Bold',
    },
    
    inactive_tab = {
      bg_color = '#13151f',
      fg_color = '#5a7a5a',
    },
    
    inactive_tab_hover = {
      bg_color = '#1a3d2d',
      fg_color = '#b8e0b8',
    },
    
    new_tab = {
      bg_color = '#13151f',
      fg_color = '#5a7a5a',
    },
    
    new_tab_hover = {
      bg_color = '#1a3d2d',
      fg_color = '#b8e0b8',
    },
  },
  
  -- Visual bell
  visual_bell = '#1a3d2d',
}

-- ============================================================================
-- FONT CONFIGURATION
-- ============================================================================

config.font = wezterm.font_with_fallback({
  {
    family = 'CaskaydiaCove Nerd Font',  -- Cascadia Code Nerd Font
    weight = 'Light',  -- Light weight as requested
    harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },  -- Enable ligatures
  },
  'JetBrains Mono',  -- Fallback
  'Symbols Nerd Font Mono',  -- Nerd font symbols
})

config.font_size = 11.0  -- Adjust to your preference

-- Font rendering (optimized for Windows)
config.front_end = 'WebGpu'  -- Use GPU acceleration
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'Normal'
config.freetype_load_flags = 'NO_HINTING'

-- ============================================================================
-- PERFORMANCE OPTIMIZATION
-- ============================================================================

-- GPU acceleration (Windows optimized)
config.webgpu_power_preference = 'HighPerformance'

-- Fast rendering
config.max_fps = 144  -- Match your monitor or set to 60
config.animation_fps = 1  -- Minimal animation overhead

-- Scrollback
config.scrollback_lines = 10000

-- ============================================================================
-- UI/UX CONFIGURATION
-- ============================================================================

-- Window
config.window_decorations = 'RESIZE'  -- Native Windows title bar
config.window_background_opacity = 1.0  -- Solid background
config.window_padding = {
  left = 4,
  right = 4,
  top = 2,
  bottom = 2,
}

-- Tab bar
config.use_fancy_tab_bar = false  -- Retro tabs, faster
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32

-- Cursor
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0  -- No blinking (vi-style)
config.cursor_thickness = 2

-- Bell
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- ============================================================================
-- TERMINAL BEHAVIOR
-- ============================================================================

-- Set terminal type for full color
config.term = 'wezterm'

-- Default shell (adjust for your Windows setup)
-- config.default_prog = { 'pwsh.exe' }  -- PowerShell
-- config.default_prog = { 'bash.exe' }  -- Git Bash
-- config.default_prog = { 'wsl.exe' }   -- WSL

-- ============================================================================
-- KEYBINDINGS (VI-FRIENDLY)
-- ============================================================================

config.keys = {
  -- Pane navigation (Ctrl+Shift+hjkl for vi users)
  {
    key = 'h',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  
  -- Pane splitting (vi-style)
  {
    key = '|',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  
  -- Pane resizing
  {
    key = 'H',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'J',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'K',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'L',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.AdjustPaneSize { 'Right', 5 },
  },
  
  -- Close pane
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  
  -- Quick config reload
  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ReloadConfiguration,
  },
}

-- ============================================================================
-- MOUSE BEHAVIOR
-- ============================================================================

config.mouse_bindings = {
  -- Paste on right click
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

return config
```

## 3. Quick Setup Script for Windows

Save as `setup-tokyomatrix.ps1`:

```powershell
# Tokyo Matrix Setup Script for Windows
Write-Host "Setting up Tokyo Matrix theme..." -ForegroundColor Green

# Neovim config
$nvimConfigPath = "$env:LOCALAPPDATA\nvim\colors"
if (-not (Test-Path $nvimConfigPath)) {
    New-Item -ItemType Directory -Path $nvimConfigPath -Force
}
Write-Host "Created Neovim colors directory: $nvimConfigPath" -ForegroundColor Cyan

# Wezterm config
$weztermConfigPath = "$env:USERPROFILE\.config\wezterm"
if (-not (Test-Path $weztermConfigPath)) {
    New-Item -ItemType Directory -Path $weztermConfigPath -Force
}
Write-Host "Created Wezterm config directory: $weztermConfigPath" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy tokyomatrix.lua to: $nvimConfigPath" -ForegroundColor White
Write-Host "2. Copy wezterm.lua to: $weztermConfigPath" -ForegroundColor White
Write-Host "3. In Neovim init.lua, use: vim.cmd('colorscheme tokyomatrix')" -ForegroundColor White
Write-Host "4. Restart Wezterm" -ForegroundColor White
Write-Host ""
Write-Host "Font check:" -ForegroundColor Yellow
Write-Host "Make sure 'CaskaydiaCove Nerd Font' is installed." -ForegroundColor White
Write-Host "Download from: https://www.nerdfonts.com/font-downloads" -ForegroundColor Cyan
```

## 4. Color Comparison

```
                Tokyo Night      →      Tokyo Matrix
Background:     #1a1b26                 #0d0f15 (much darker)
Foreground:     #c0caf5 (blue-ish)     #b8e0b8 (green-tinted)
Strings:        #9ece6a                 #95ff95 (brighter green)
Functions:      #7aa2f7                 #5fbfff (brighter blue)
Keywords:       #bb9af7                 #af87ff (kept purple)
Comments:       #565f89 (blue-grey)    #5a7a5a (green-grey)
```

## 5. Testing & Verification

### Test File: `test-theme.go`
```go
package main

import (
    "fmt"
    "time"
)

// Comment: The Matrix has you...
const (
    MaxRetries = 3
    Timeout    = 5 * time.Second
)

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
    
    // Error simulation (should show red diagnostic)
    undefinedVariable := unknownFunc()
}
```

### Visual Checklist
- [ ] Background is very dark (almost black)
- [ ] Normal text has slight green tint
- [ ] Strings are bright Matrix green (#95ff95)
- [ ] Functions are bright blue (#5fbfff)
- [ ] Keywords are purple (#af87ff)
- [ ] Comments are readable but dimmed (#5a7a5a)
- [ ] Cursor is bright green (#80ff80)
- [ ] Selection background is dark green
- [ ] Line numbers visible but not distracting
- [ ] LSP errors show clearly in red
- [ ] Overall feeling: Matrix terminal aesthetic

## 6. Wezterm Performance Tips (Windows)

### Enable GPU Acceleration
Already configured in wezterm.lua:
```lua
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
```

### Check GPU Usage
In wezterm, press `Ctrl+Shift+L` to open the debug overlay and verify GPU is being used.

### Optimize for High Refresh Rate Monitors
```lua
config.max_fps = 144  -- Or 120, 60 depending on your monitor
```

### Disable Unnecessary Features
```lua
config.animation_fps = 1  -- Minimal animations
config.cursor_blink_rate = 0  -- No cursor blinking
```

## 7. Font Installation (Windows)

1. Download **CaskaydiaCove Nerd Font** from https://www.nerdfonts.com/font-downloads
2. Extract the ZIP
3. Right-click `CaskaydiaCoveNerdFont-Light.ttf` → Install
4. Restart Wezterm

Alternative fonts if Cascadia doesn't work:
- JetBrains Mono Nerd Font
- Fira Code Nerd Font  
- Victor Mono Nerd Font

## 8. Claude Code Integration

Claude Code will automatically inherit your Wezterm color scheme. For best results:

### Side-by-side Layout in Wezterm:
```
┌──────────────┬──────────────┐
│              │              │
│   Claude     │   Neovim     │
│   Code       │              │
│              │              │
├──────────────┴──────────────┤
│        Shell / Commands      │
└──────────────────────────────┘
```

Use the keybindings:
- `Ctrl+Shift+|` - Split vertically
- `Ctrl+Shift+-` - Split horizontally  
- `Ctrl+Shift+h/j/k/l` - Navigate panes

### Everything will use Tokyo Matrix colors automatically!

## 9. Troubleshooting

### Colors don't match between Neovim and terminal
```vim
" In Neovim, check:
:set termguicolors?  " Should be on
:echo $TERM          " Should be 'wezterm'
```

### Font not rendering correctly
- Verify font is installed: Check Windows Fonts settings
- Try different font weight: Change from 'Light' to 'Regular' in wezterm.lua
- Check font name: Run `wezterm ls-fonts` to see available fonts

### Performance issues
- Lower max_fps: `config.max_fps = 60`
- Disable ligatures: Remove `harfbuzz_features` line
- Check GPU usage: `Ctrl+Shift+L` in wezterm

### Theme looks washed out
- Check monitor brightness/contrast
- Adjust `window_background_opacity` if needed
- Verify true color support: `:set termguicolors` in nvim

## 10. Customization Ideas

### Make it more/less Matrix-y

**More green:**
```lua
-- In tokyomatrix.lua, shift these toward green:
fg = "#a0f0a0",  -- Even greener foreground
variable = "#c0ffc0",  -- Bright green variables
```

**Less green (subtler):**
```lua
fg = "#c0d0c0",  -- Just a hint of green
variable = "#c0caf5",  -- Back to blue-ish
```

### Adjust contrast

**Higher contrast:**
```lua
bg = "#000000",  -- Pure black
fg = "#e0ffe0",  -- Brighter foreground
```

**Lower contrast:**
```lua
bg = "#1a1f1a",  -- Lighter black
fg = "#a0c0a0",  -- Dimmer foreground
```

---

**Your Tokyo Matrix theme is ready!** 🟢

The combination of deep blacks, green-tinted text, and Matrix-inspired highlights will give you a unique, eye-friendly coding environment that looks great across Neovim, Wezterm, and Claude Code.
