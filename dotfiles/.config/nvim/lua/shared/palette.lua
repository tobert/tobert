-- /dotfiles/.config/nvim/lua/shared/palette.lua
-- Single source of truth for colors, based on amystheme.

return {
	-- Base
	background = "#1a1b26",
	foreground = "#e5e5e5",

	-- UI
	selection_bg = "#33467c",
	selection_fg = "#e5e5e5",
	border = "#1a2233", -- from amystheme 'split'

	-- Cursor
	cursor_bg = "#e5e5e5",
	cursor_fg = "#1a1b26",

	-- ANSI Standard
	black = "#15161e",
	red = "#f7768e",
	green = "#9ece6a",
	yellow = "#e0af68",
	blue = "#7aa2f7",
	magenta = "#bb9af7",
	cyan = "#7dcfff",
	white = "#e5e5e5",

	-- ANSI Bright
	bright_black = "#414868", -- grey
	bright_red = "#ff7a93",
	bright_green = "#b9f27c",
	bright_yellow = "#ffc777",
	bright_blue = "#82aaff",
	bright_magenta = "#c099ff",
	bright_cyan = "#b4f9f8",
	bright_white = "#f5f5f5",

	-- Syntax Highlighting (derived from ANSI for consistency)
	comment = "#414868", -- bright_black
	string = "#9ece6a", -- green
	keyword = "#bb9af7", -- magenta
	["function"] = "#7aa2f7", -- blue
	number = "#e0af68", -- yellow
	constant = "#e0af68", -- yellow
	type = "#7dcfff", -- cyan
	operator = "#b4f9f8", -- bright_cyan
	variable = "#e5e5e5", -- foreground

	-- Diagnostics
	error = "#f7768e", -- red
	warning = "#e0af68", -- yellow
	info = "#7aa2f7", -- blue
	hint = "#9ece6a", -- green

	-- Git/Diff
	git_add = "#9ece6a",
	git_change = "#e0af68",
	git_delete = "#f7768e",

	-- WezTerm Tab Bar specific colors from amystheme
	tab_bar = {
		background = "#16161e",
		active_tab = {
			bg_color = "#1a1b26",
			fg_color = "#e5e5e5",
		},
		inactive_tab = {
			bg_color = "#24283b",
			fg_color = "#787c99",
		},
		inactive_tab_hover = {
			bg_color = "#33467c",
			fg_color = "#e5e5e5",
		},
		new_tab = {
			bg_color = "#24283b",
			fg_color = "#787c99",
		},
		new_tab_hover = {
			bg_color = "#33467c",
			fg_color = "#e5e5e5",
		},
	},
}
