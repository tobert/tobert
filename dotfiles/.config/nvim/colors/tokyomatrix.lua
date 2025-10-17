-- tokyomatrix.lua - Matrix-inspired Tokyo Night evolution
-- Darker background, green-tinted text, higher contrast

local M = {}

local c = {
  -- Base (updated with brighter foreground)
  bg = "#0d0f15",
  fg = "#d0f8d0",        -- Brighter green-tinted white (was #b8e0b8)
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
  white = "#d0f8d0",     -- Brighter (was #b8e0b8)

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
  variable = "#d0f8d0",     -- Base fg (brighter)
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
