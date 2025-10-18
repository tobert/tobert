-- WezTerm Configuration
-- Cross-platform setup for WSL, Linux, and SSH (Windows/Linux compatible)
-- Uses Amy's Theme with modular host configs
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ===========================
-- Font Configuration
-- ===========================
config.font = wezterm.font_with_fallback({
	{ family = "Cascadia Code NF", weight = 200 }, -- ExtraLight
	"Consolas",
	"Noto Color Emoji",
	"Symbols Nerd Font Mono",
})
config.font_size = 14

-- Customize bold to use Regular weight instead of Bold (less heavy)
config.font_rules = {
	{
		intensity = "Bold",
		font = wezterm.font_with_fallback({
			{ family = "Cascadia Code NF", weight = 400 }, -- Regular (for bold text)
			"Noto Color Emoji",
			"Symbols Nerd Font Mono",
		}),
	},
}

-- Enable font features (ligatures, contextual alternates)
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Font rendering - HorizontalLcd hinting with light rendering
config.freetype_load_target = "HorizontalLcd"
config.freetype_render_target = "Light"

-- Allow Nerd Font icons to extend slightly for better appearance
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

-- ===========================
-- Color Scheme (Harmonized)
-- ===========================
-- Load the single source of truth for colors
local palette = require("../nvim/lua/shared/palette")

-- Map the shared palette to WezTerm's color config
config.colors = {
	foreground = palette.foreground,
	background = palette.background,

	cursor_bg = palette.cursor_bg,
	cursor_fg = palette.cursor_fg,
	cursor_border = palette.cursor_bg,

	selection_fg = palette.selection_fg,
	selection_bg = palette.selection_bg,

	split = palette.border,

	ansi = {
		palette.black,
		palette.red,
		palette.green,
		palette.yellow,
		palette.blue,
		palette.magenta,
		palette.cyan,
		palette.white,
	},

	brights = {
		palette.bright_black,
		palette.bright_red,
		palette.bright_green,
		palette.bright_yellow,
		palette.bright_blue,
		palette.bright_magenta,
		palette.bright_cyan,
		palette.bright_white,
	},

	tab_bar = palette.tab_bar,
}

-- ===========================
-- Host-Specific Configuration
-- ===========================
-- Load local and private host configs from hosts/ directory
-- This allows keeping private SSH configs separate from public dotfiles

-- SSH backend for all SSH domains
config.ssh_backend = "Ssh2"

-- Helper function to safely load host configs
local function load_host_config(name)
	local ok, host_config = pcall(require, "hosts." .. name)
	if ok then
		return host_config
	else
		wezterm.log_warn("Could not load hosts/" .. name .. ".lua: " .. tostring(host_config))
		return nil
	end
end

-- Load local domains (WSL, PowerShell, Linux, etc.)
local local_config = load_host_config("local")
if local_config then
	config.default_domain = local_config.default_domain
	config.default_prog = local_config.default_prog
end

-- Initialize SSH domains, Unix domains, and launch menu
config.ssh_domains = {}
config.unix_domains = {}
config.launch_menu = {}

-- Add local Unix domains (for persistent multiplexer)
if local_config and local_config.unix_domains then
	for _, domain in ipairs(local_config.unix_domains) do
		table.insert(config.unix_domains, domain)
	end
end

-- Add local launch menu items
if local_config and local_config.launch_menu then
	for _, item in ipairs(local_config.launch_menu) do
		table.insert(config.launch_menu, item)
	end
end

-- Load private SSH host configs (zorak, etc.)
-- Add more hosts by creating hosts/hostname.lua files
local private_hosts = { "zorak" }
for _, hostname in ipairs(private_hosts) do
	local host_config = load_host_config(hostname)
	if host_config then
		-- Merge SSH domains
		if host_config.ssh_domains then
			for _, domain in ipairs(host_config.ssh_domains) do
				table.insert(config.ssh_domains, domain)
			end
		end
		-- Merge launch menu items
		if host_config.launch_menu then
			for _, item in ipairs(host_config.launch_menu) do
				table.insert(config.launch_menu, item)
			end
		end
	end
end

-- ===========================
-- Window & Tab Configuration
-- ===========================
config.initial_cols = 120
config.initial_rows = 30
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

-- ===========================
-- Cursor
-- ===========================
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 750
config.cursor_thickness = "0.15cell"

-- ===========================
-- Scrollback
-- ===========================
config.scrollback_lines = 10000

-- ===========================
-- General Settings
-- ===========================
config.automatically_reload_config = true
config.selection_word_boundary = " \t\n{}[]()\"':;,│"
config.front_end = "WebGpu"
config.max_fps = 120
config.audible_bell = "Disabled"

-- Hyperlink detection
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ===========================
-- Leader Key (like tmux prefix)
-- ===========================
-- Press Ctrl-a, release, then press another key (just like tmux!)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- ===========================
-- Key Bindings
-- ===========================
local act = wezterm.action

config.keys = {
	-- Send Ctrl-a when pressed once (like tmux 'bind a send-prefix')
	{ key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },

	-- Last active tab (like tmux 'bind C-a last-window')
	{ key = "a", mods = "LEADER|CTRL", action = act.ActivateLastTab },

	-- Copy/Paste
	{ key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },

	-- Tab/Window navigation (Ctrl-a prefix, like tmux)
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "Q", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") },

	-- Direct tab access (Ctrl-a then number, like tmux)
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },
	{ key = "0", mods = "LEADER", action = act.ActivateTab(9) },

	-- Pane splitting (Ctrl-a then | or -, like tmux)
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pane navigation (Ctrl-a then hjkl, like tmux)
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Arrow key pane navigation (Ctrl-a then arrows)
	{ key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Window list (Ctrl-a then ", like tmux)
	{ key = '"', mods = "LEADER|SHIFT", action = act.ShowTabNavigator },

	-- Launcher menu (Ctrl-a then space)
	{ key = " ", mods = "LEADER", action = act.ShowLauncher },

	-- Search (Ctrl-a then f)
	{ key = "f", mods = "LEADER", action = act.Search({ CaseSensitiveString = "" }) },

	-- Pane zoom (Ctrl-a then z, like tmux)
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Rename tab (Ctrl-a then , or Ctrl-a then A)
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "A",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Reload config (Ctrl-a then r, like tmux)
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },

	-- Font size (direct Ctrl bindings, no leader)
	{ key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
}

-- ===========================
-- Mouse Bindings
-- ===========================
config.mouse_bindings = {
	-- Auto-copy selection on mouse release
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
	},
	-- Right click to paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
	-- Select text on triple click
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = act.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

-- Note: launch_menu is now configured in hosts/*.lua files
-- See hosts/local.lua and hosts/zorak.lua

-- ===========================
-- Tab Bar Customization
-- ===========================
-- Tab Bar Customization for Amy's Theme
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local colors = config.colors

	-- Determine colors based on state
	local bg_color = colors.tab_bar.inactive_tab.bg_color
	local fg_color = colors.tab_bar.inactive_tab.fg_color
	local left_sep_bg = colors.background
	local right_sep_fg = bg_color

	if tab.is_active then
		bg_color = colors.ansi[5] -- Blue accent for active tab
		fg_color = colors.background
		right_sep_fg = bg_color
	elseif hover then
		bg_color = colors.tab_bar.inactive_tab_hover.bg_color
		fg_color = colors.tab_bar.inactive_tab_hover.fg_color
		right_sep_fg = bg_color
	end

	local title

	-- If user has manually set a title, use that
	if tab.tab_title and #tab.tab_title > 0 then
		title = " " .. tab.tab_index + 1 .. ": " .. tab.tab_title .. " "
	else
		-- Otherwise, auto-generate the title
		local pane = tab.active_pane
		local process_name = pane.foreground_process_name and pane.foreground_process_name:match("([^/\\]+)$") or "bash"

		-- Clean up process name (remove .exe, wsl.exe wrapper, etc.)
		process_name = process_name:gsub("%.exe$", "")

		-- Map common process names to cleaner display names
		local process_display_map = {
			["wsl"] = "bash",
			["pwsh"] = "ps",
			["powershell"] = "ps",
			["nvim"] = "nvim",
			["vim"] = "vim",
			["nano"] = "nano",
			["ssh"] = "ssh",
			["git"] = "git",
			["python3"] = "py",
			["python"] = "py",
			["node"] = "node",
			["cargo"] = "cargo",
		}
		process_name = process_display_map[process_name] or process_name

		-- Get current working directory
		local cwd_name = ""
		if pane.current_working_dir then
			local cwd_str = tostring(pane.current_working_dir)
			-- Remove file:// prefix and hostname
			cwd_str = cwd_str:gsub("file://[^/]*", "")
			-- Get just the last directory name
			cwd_name = cwd_str:match("([^/\\]+)[/\\]?$") or ""
			-- If in home directory, show ~
			if cwd_str == os.getenv("HOME") or cwd_str:match("^/home/[^/]+$") then
				cwd_name = "~"
			end
		end

		-- Build title string
		local title_parts = {}

		-- For editors and special tools, show tool + directory
		local editor_tools = { nvim = true, vim = true, nano = true, git = true }
		if editor_tools[process_name] then
			if cwd_name ~= "" and cwd_name ~= "~" then
				table.insert(title_parts, process_name .. ":" .. cwd_name)
			else
				table.insert(title_parts, process_name)
			end
		else
			-- For shells and other processes, just show directory or process
			if cwd_name ~= "" and cwd_name ~= process_name then
				table.insert(title_parts, cwd_name)
			else
				table.insert(title_parts, process_name)
			end
		end

		title = " " .. tab.tab_index + 1 .. ": " .. table.concat(title_parts, " ") .. " "
	end

	-- Powerline-style separators
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

	return {
		{ Background = { Color = left_sep_bg } },
		{ Foreground = { Color = bg_color } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = bg_color } },
		{ Foreground = { Color = fg_color } },
		{ Text = title },
		{ Background = { Color = left_sep_bg } },
		{ Foreground = { Color = right_sep_fg } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- ===========================
-- Tab Bar Drag Handle
-- ===========================
-- Add a permanent drag handle on the right side of the tab bar (next to window controls)
wezterm.on("update-status", function(window, pane)
	local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

	local drag_handle = wezterm.format({
		{ Background = { Color = "#1a1b26" } },
		{ Foreground = { Color = "#24283b" } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Background = { Color = "#24283b" } },
		{ Foreground = { Color = "#7aa2f7" } },
		{ Text = " ☰ " },
	})

	window:set_right_status(drag_handle)
end)

return config
