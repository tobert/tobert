-- Tokyo Matrix Theme for WezTerm
-- Matrix-inspired evolution of Tokyo Night with green tints and deeper blacks
-- Generated for harmonized color scheme across Neovim, WezTerm, and Bash

return {
  foreground = '#d0f8d0',  -- Bright green-tinted white
  background = '#0d0f15',  -- Almost black

  cursor_bg = '#80ff80',   -- Bright Matrix green cursor
  cursor_fg = '#0d0f15',   -- Dark text under cursor
  cursor_border = '#80ff80',

  selection_fg = '#d0ffd0',
  selection_bg = '#1a3d2d', -- Dark green selection

  scrollbar_thumb = '#3a4f4a',
  split = '#1a2233',

  -- Standard ANSI colors (0-7)
  ansi = {
    '#0d0f15',  -- black
    '#ff5f87',  -- red
    '#73ff73',  -- green (Matrix!)
    '#e5c07b',  -- yellow
    '#5fbfff',  -- blue
    '#d75fd7',  -- magenta
    '#5fffaf',  -- cyan
    '#d0f8d0',  -- white (bright!)
  },

  -- Bright ANSI colors (8-15)
  brights = {
    '#3a4f4a',  -- bright black (grey with green undertone)
    '#ff6b9d',  -- bright red
    '#95ff95',  -- bright green (even brighter Matrix green)
    '#ffd787',  -- bright yellow
    '#7dcfff',  -- bright blue
    '#ff87ff',  -- bright magenta
    '#87ffd7',  -- bright cyan
    '#d0ffd0',  -- bright white (almost neon green-white)
  },

  -- Tab bar colors
  tab_bar = {
    background = '#080a0f',  -- Very dark background for tab bar

    active_tab = {
      bg_color = '#0d0f15',  -- Match main background
      fg_color = '#d0f8d0',  -- Bright green-white
      intensity = 'Bold',
    },

    inactive_tab = {
      bg_color = '#13151f',  -- Slightly lighter for contrast
      fg_color = '#5a7a5a',  -- Dimmed green
    },

    inactive_tab_hover = {
      bg_color = '#1a3d2d',  -- Green tint on hover
      fg_color = '#d0f8d0',  -- Bright text
    },

    new_tab = {
      bg_color = '#13151f',
      fg_color = '#5a7a5a',
    },

    new_tab_hover = {
      bg_color = '#1a3d2d',
      fg_color = '#d0f8d0',
    },
  },

  -- Visual bell
  visual_bell = '#1a3d2d',

  -- Indexed colors (optional, for compatibility)
  indexed = {
    [16] = '#ff9e64',  -- Orange
    [17] = '#db4b4b',  -- Dark red
  },
}
