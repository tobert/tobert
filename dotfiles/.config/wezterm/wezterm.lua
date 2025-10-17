-- WezTerm Configuration
-- Cross-platform setup for WSL, Linux, and SSH (Windows/Linux compatible)
-- Uses Tokyo Matrix theme with modular host configs
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ===========================
-- Font Configuration
-- ===========================
config.font = wezterm.font_with_fallback({
  { family = 'Cascadia Code NF', weight = 'Light' },
  { family = 'JetBrains Mono Nerd Font', weight = 'Light' },
  { family = 'FiraCode Nerd Font', weight = 'Light' },
  'Consolas',
  'Noto Color Emoji',
  'Symbols Nerd Font Mono',
})
config.font_size = 11

-- Customize bold to use Regular weight instead of Bold (less heavy)
-- Particularly useful on Windows
config.font_rules = {
  {
    intensity = 'Bold',
    font = wezterm.font_with_fallback({
      { family = 'Cascadia Code NF', weight = 'Regular' },
      { family = 'JetBrains Mono Nerd Font', weight = 'Regular' },
      { family = 'FiraCode Nerd Font', weight = 'Regular' },
      'Consolas',
      'Noto Color Emoji',
      'Symbols Nerd Font Mono',
    }),
  },
}

-- Enable font features (ligatures, contextual alternates)
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Font rendering (auto-detects platform optimization)
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'Normal'

-- Allow Nerd Font icons to extend slightly for better appearance
config.allow_square_glyphs_to_overflow_width = 'WhenFollowedBySpace'

-- ===========================
-- Color Scheme (Tokyo Matrix)
-- ===========================
-- Matrix-inspired theme with green tints and deep blacks
-- Theme file allows easy syncing to Windows and other machines
config.colors = require('themes.tokyomatrix')

-- ===========================
-- Host-Specific Configuration
-- ===========================
-- Load local and private host configs from hosts/ directory
-- This allows keeping private SSH configs separate from public dotfiles

-- SSH backend for all SSH domains
config.ssh_backend = 'Ssh2'

-- Helper function to safely load host configs
local function load_host_config(name)
  local ok, host_config = pcall(require, 'hosts.' .. name)
  if ok then
    return host_config
  else
    wezterm.log_warn('Could not load hosts/' .. name .. '.lua: ' .. tostring(host_config))
    return nil
  end
end

-- Load local domains (WSL, PowerShell, Linux, etc.)
local local_config = load_host_config('local')
if local_config then
  config.default_domain = local_config.default_domain
  config.default_prog = local_config.default_prog
end

-- Initialize SSH domains and launch menu
config.ssh_domains = {}
config.launch_menu = {}

-- Add local launch menu items
if local_config and local_config.launch_menu then
  for _, item in ipairs(local_config.launch_menu) do
    table.insert(config.launch_menu, item)
  end
end

-- Load private SSH host configs (zorak, etc.)
-- Add more hosts by creating hosts/hostname.lua files
local private_hosts = { 'zorak' }
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
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_close_confirmation = 'NeverPrompt'
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
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 750
config.cursor_thickness = '0.15cell'

-- ===========================
-- Scrollback
-- ===========================
config.scrollback_lines = 10000

-- ===========================
-- General Settings
-- ===========================
config.automatically_reload_config = true
config.selection_word_boundary = ' \t\n{}[]()"\':;,│'
config.front_end = 'WebGpu'
config.max_fps = 120
config.audible_bell = 'Disabled'

-- Hyperlink detection
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ===========================
-- Leader Key (like tmux prefix)
-- ===========================
-- Press Ctrl-a, release, then press another key (just like tmux!)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- ===========================
-- Key Bindings
-- ===========================
local act = wezterm.action

config.keys = {
  -- Send Ctrl-a when pressed once (like tmux 'bind a send-prefix')
  { key = 'a', mods = 'LEADER', action = act.SendKey{ key = 'a', mods = 'CTRL' } },

  -- Last active tab (like tmux 'bind C-a last-window')
  { key = 'a', mods = 'LEADER|CTRL', action = act.ActivateLastTab },

  -- Copy/Paste
  { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- Tab/Window navigation (Ctrl-a prefix, like tmux)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'q', mods = 'LEADER', action = act.CloseCurrentPane{ confirm = false } },
  { key = 'Q', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab{ confirm = false } },
  { key = 'd', mods = 'LEADER', action = act.DetachDomain 'CurrentPaneDomain' },

  -- Direct tab access (Ctrl-a then number, like tmux)
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },
  { key = '0', mods = 'LEADER', action = act.ActivateTab(9) },

  -- Pane splitting (Ctrl-a then | or -, like tmux)
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },

  -- Pane navigation (Ctrl-a then hjkl, like tmux)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Arrow key pane navigation (Ctrl-a then arrows)
  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Window list (Ctrl-a then ", like tmux)
  { key = '"', mods = 'LEADER|SHIFT', action = act.ShowTabNavigator },

  -- Launcher menu (Ctrl-a then space)
  { key = ' ', mods = 'LEADER', action = act.ShowLauncher },

  -- Search (Ctrl-a then f)
  { key = 'f', mods = 'LEADER', action = act.Search{ CaseSensitiveString = '' } },

  -- Pane zoom (Ctrl-a then z, like tmux)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- Rename tab (Ctrl-a then ,)
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
    description = 'Enter new name for tab',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }},

  -- Reload config (Ctrl-a then r, like tmux)
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },

  -- Font size (direct Ctrl bindings, no leader)
  { key = '+', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
}

-- ===========================
-- Mouse Bindings
-- ===========================
config.mouse_bindings = {
  -- Auto-copy selection on mouse release
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
  },
  -- Right click to paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
  -- Select text on triple click
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = act.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
}

-- Note: launch_menu is now configured in hosts/*.lua files
-- See hosts/local.lua and hosts/zorak.lua

-- ===========================
-- Tab Bar Customization
-- ===========================
-- Tab Bar Customization based on tokyo-matrix.md guide
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local colors = config.colors
  local has_unseen_output = tab.has_unseen_output

  -- Determine colors based on state
  local bg_color = colors.tab_bar.inactive_tab.bg_color
  local fg_color = colors.tab_bar.inactive_tab.fg_color
  local left_sep_bg = colors.background
  local right_sep_fg = bg_color

  if tab.is_active then
    bg_color = colors.ansi[3] -- Matrix Green (#73ff73)
    fg_color = colors.background
    right_sep_fg = bg_color
  elseif hover then
    bg_color = colors.tab_bar.inactive_tab_hover.bg_color
    fg_color = colors.tab_bar.inactive_tab_hover.fg_color
    right_sep_fg = bg_color
  end

  -- Get pane info for the title
  local pane = tab.active_pane
  local process_name = pane.foreground_process_name and pane.foreground_process_name:match("([^/\\]+)$") or 'shell'
  local domain_name = pane.domain_name
  local has_ssh_domain = domain_name and domain_name ~= 'local' and domain_name ~= ''
  local cwd_name = ''
  if pane.current_working_dir then
    local cwd_str = tostring(pane.current_working_dir):gsub('file://[^/]*', '')
    cwd_name = cwd_str:match("([^/\\]+)[/\\]?$") or cwd_str
  end

  -- Build title string
  local title_parts = {}
  if has_ssh_domain then
    table.insert(title_parts, '[' .. domain_name .. ']')
  end
  table.insert(title_parts, process_name)
  if cwd_name ~= '' and cwd_name ~= process_name then
    table.insert(title_parts, '(' .. cwd_name .. ')')
  end
  local title = ' ' .. tab.tab_index + 1 .. ': ' .. table.concat(title_parts, ' ') .. ' '

  -- Add an indicator for tabs with unseen output
  if has_unseen_output then
    title = title .. '● '
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
wezterm.on('update-status', function(window, pane)
  local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

  local drag_handle = wezterm.format {
    { Background = { Color = '#0d0f15' } },
    { Foreground = { Color = '#13151f' } },
    { Text = SOLID_RIGHT_ARROW },
    { Background = { Color = '#13151f' } },
    { Foreground = { Color = '#73ff73' } },
    { Text = ' ☰ ' },
  }

  window:set_right_status(drag_handle)
end)

return config
