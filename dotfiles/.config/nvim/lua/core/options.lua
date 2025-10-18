-- Vim Options
-- Core vim settings for a modern editing experience

local opt = vim.opt

-- UI
opt.number = false                -- No line numbers
opt.relativenumber = false        -- Absolute numbers (easier for core vi users)
opt.cursorline = true            -- Highlight current line
opt.signcolumn = "auto"          -- Show sign column only when diagnostics present
opt.termguicolors = true         -- True color support
opt.cmdheight = 0                -- Hide command line when not in use

-- Indentation (matching your old config)
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false            -- Use tabs by default
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true             -- Case-sensitive if uppercase used

-- System
opt.hidden = true                -- Allow hidden buffers
opt.swapfile = false             -- No swap files
opt.backup = false
opt.undofile = true              -- Persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Clipboard (use custom ~/bin/clip and ~/bin/paste scripts)
vim.g.clipboard = {
  name = "custom-clipboard",
  copy = {
    ["+"] = vim.fn.expand("~/bin/clip"),
    ["*"] = vim.fn.expand("~/bin/clip"),
  },
  paste = {
    ["+"] = vim.fn.expand("~/bin/paste"),
    ["*"] = vim.fn.expand("~/bin/paste"),
  },
  cache_enabled = 0,
}
opt.clipboard = "unnamedplus"    -- Use system clipboard

-- Behavior
opt.mouse = "a"                  -- Enable mouse in all modes
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8                -- Keep 8 lines visible when scrolling

-- Whitespace visibility (like your old config)
opt.list = true
opt.listchars = { trail = '·', tab = '» ' }

-- Performance
opt.updatetime = 250             -- Faster completion
opt.timeoutlen = 300
