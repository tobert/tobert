-- Amy's Theme for WezTerm
-- Clean, bright color scheme optimized for readability and eye comfort
-- Inspired by Windows Terminal defaults with refined aesthetics

return {
  foreground = '#e5e5e5',  -- Bright light grey
  background = '#1a1b26',  -- Soft dark blue-grey

  cursor_bg = '#e5e5e5',   -- Bright grey cursor
  cursor_fg = '#1a1b26',   -- Dark text under cursor
  cursor_border = '#e5e5e5',

  selection_fg = '#e5e5e5',
  selection_bg = '#33467c', -- Muted blue selection

  scrollbar_thumb = '#3a4f4a',
  split = '#1a2233',

  -- Standard ANSI colors (0-7)
  ansi = {
    '#15161e',  -- black
    '#f7768e',  -- red
    '#9ece6a',  -- green
    '#e0af68',  -- yellow
    '#7aa2f7',  -- blue
    '#bb9af7',  -- magenta
    '#7dcfff',  -- cyan
    '#e5e5e5',  -- white (bright!)
  },

  -- Bright ANSI colors (8-15)
  brights = {
    '#414868',  -- bright black (grey)
    '#ff7a93',  -- bright red
    '#b9f27c',  -- bright green
    '#ffc777',  -- bright yellow
    '#82aaff',  -- bright blue
    '#c099ff',  -- bright magenta
    '#b4f9f8',  -- bright cyan
    '#f5f5f5',  -- bright white (very bright!)
  },

  -- Tab bar colors
  tab_bar = {
    background = '#16161e',  -- Dark background for tab bar

    active_tab = {
      bg_color = '#1a1b26',  -- Match main background
      fg_color = '#e5e5e5',  -- Bright grey
      intensity = 'Bold',
    },

    inactive_tab = {
      bg_color = '#24283b',  -- Slightly lighter for contrast
      fg_color = '#787c99',  -- Muted grey
    },

    inactive_tab_hover = {
      bg_color = '#33467c',  -- Blue tint on hover
      fg_color = '#e5e5e5',  -- Bright text
    },

    new_tab = {
      bg_color = '#24283b',
      fg_color = '#787c99',
    },

    new_tab_hover = {
      bg_color = '#33467c',
      fg_color = '#e5e5e5',
    },
  },

  -- Visual bell
  visual_bell = '#33467c',

  -- Indexed colors (optional, for compatibility)
  indexed = {
    [16] = '#ff9e64',  -- Orange
    [17] = '#db4b4b',  -- Dark red
  },
}
