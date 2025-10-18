-- /dotfiles/.config/nvim/colors/harmonized.lua
-- Neovim colorscheme powered by the shared color palette.

-- Load the shared color palette
local palette = require("shared.palette")
if not palette then
	vim.notify("Shared color palette not found!", vim.log.levels.ERROR)
	return
end

-- Clear existing highlights
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "harmonized"

-- Helper function to set highlight groups
local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Define highlight groups using the palette
local c = palette

-- Editor UI
hi("Normal", { fg = c.foreground, bg = c.background })
hi("NormalFloat", { fg = c.foreground, bg = c.border })
hi("Comment", { fg = c.comment, italic = true })
hi("CursorLine", { bg = c.selection_bg })
hi("CursorLineNr", { fg = c.yellow, bg = c.selection_bg })
hi("LineNr", { fg = c.bright_black, bg = c.background })
hi("SignColumn", { bg = c.background })
hi("Visual", { bg = c.selection_bg })
hi("VertSplit", { fg = c.border })
hi("StatusLine", { fg = c.foreground, bg = c.border })
hi("StatusLineNC", { fg = c.comment, bg = c.border })
hi("Search", { bg = c.yellow, fg = c.background })
hi("IncSearch", { bg = c.bright_yellow, fg = c.background })

-- Syntax highlighting
hi("Keyword", { fg = c.keyword, bold = true })
hi("Function", { fg = c["function"] })
hi("String", { fg = c.string })
hi("Number", { fg = c.number })
hi("Boolean", { fg = c.constant })
hi("Constant", { fg = c.constant })
hi("Type", { fg = c.type })
hi("Operator", { fg = c.operator })
hi("Identifier", { fg = c.variable })
hi("Special", { fg = c.magenta })

-- Tree-sitter highlights (@-prefixed groups)
hi("@keyword", { link = "Keyword" })
hi("@function", { link = "Function" })
hi("@string", { link = "String" })
hi("@number", { link = "Number" })
hi("@boolean", { link = "Boolean" })
hi("@constant", { link = "Constant" })
hi("@type", { link = "Type" })
hi("@operator", { link = "Operator" })
hi("@variable", { link = "Identifier" })
hi("@parameter", { fg = c.cyan })
hi("@comment", { link = "Comment" })

-- LSP Diagnostics
hi("DiagnosticError", { fg = c.error })
hi("DiagnosticWarn", { fg = c.warning })
hi("DiagnosticInfo", { fg = c.info })
hi("DiagnosticHint", { fg = c.hint })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warning })

-- Git signs
hi("GitSignsAdd", { fg = c.git_add })
hi("GitSignsChange", { fg = c.git_change })
hi("GitSignsDelete", { fg = c.git_delete })
hi("DiffAdd", { bg = c.git_add, fg = c.background })
hi("DiffChange", { bg = c.git_change, fg = c.background })
hi("DiffDelete", { bg = c.git_delete, fg = c.background })

-- Terminal colors (for :terminal)
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
