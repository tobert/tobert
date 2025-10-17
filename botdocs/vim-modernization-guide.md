# Vim Configuration Modernization Guide

## Project Overview
Modernize my vim configuration for professional Go and Rust development with Claude Code integration, optimized for a wezterm-based workflow with minimal multiplexing overhead.

## User Profile & Requirements

### Current Setup
- **Old vimrc**: From early 2000s using pathogen
- **Usage Pattern**: Multiple vim instances managed via bash job control
- **Terminal**: wezterm (not tmux/screen)
- **Multiplexing**: wezterm tabs + bash job control (Ctrl-Z, fg, bg)
- **Vi Subset User**: Core vi commands, not a power-user of advanced vim features
- **Primary Languages**: Go and Rust
- **AI Assistant**: Claude Code for development

### Desired Features
1. Modern LSP integration for Go (gopls) and Rust (rust-analyzer)
2. True color support with modern colorscheme
3. Nerdfonts and emoji support
4. Sixel/terminal image preview capabilities
5. Claude Code integration
6. Quality-of-life improvements without overwhelming complexity
7. Fast startup times
8. Minimal configuration approach

## Technical Decisions

### Neovim vs Vim
**Recommendation: Switch to Neovim 0.10+**

**Rationale:**
- Built-in LSP client (no coc.nvim or other heavy plugins needed)
- Native Lua configuration (faster, more maintainable than VimScript)
- Better terminal integration with wezterm
- Tree-sitter for superior syntax highlighting
- Active development and modern plugin ecosystem
- All modern vim/neovim plugins target Neovim first

**Migration Path:** Your muscle memory transfers 100% - all vi/vim commands work identically

### Plugin Manager
**Use: lazy.nvim**

**Why not pathogen:**
- Pathogen is essentially unmaintained (2013 era)
- No lazy loading = slow startup
- No automatic dependency management

**Why lazy.nvim:**
- Modern standard (replaced packer.nvim in 2024)
- Blazingly fast with automatic lazy-loading
- Clean Lua API
- Built-in profiler and plugin manager UI
- Handles all dependencies automatically

### LSP Configuration
**Go: gopls** (official Go language server)
**Rust: rust-analyzer** via rustaceanvim plugin

**No CoC, No ALE, No vim-go**
- Use native Neovim LSP client
- Simpler, faster, fewer dependencies
- Better integration with modern tooling

## Required Installation Steps

### System Prerequisites
```bash
# Install Neovim (0.10+)
# macOS:
brew install neovim

# Linux (Ubuntu/Debian):
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update && sudo apt install neovim

# Install language servers
# Go:
go install golang.org/x/tools/gopls@latest

# Rust:
rustup component add rust-analyzer

# Install tree-sitter CLI (optional but recommended)
npm install -g tree-sitter-cli

# Install ripgrep (for telescope fuzzy finding)
brew install ripgrep  # macOS
sudo apt install ripgrep  # Linux

# Install a Nerd Font
brew install --cask font-jetbrains-mono-nerd-font  # recommended
# Or download from: https://www.nerdfonts.com/
```

### Wezterm Configuration
Add to `~/.config/wezterm/wezterm.lua`:
```lua
local config = wezterm.config_builder()

-- Modern font with ligatures
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 14

-- True color support
config.term = 'wezterm'

-- Enable sixel graphics
config.enable_kitty_graphics = true

-- Disable ligatures if you prefer (many developers do)
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

return config
```

## Neovim Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── core/
│   │   ├── options.lua      # Vim options (set commands)
│   │   ├── keymaps.lua      # Key mappings
│   │   └── autocmds.lua     # Autocommands
│   └── plugins/
│       ├── init.lua         # Plugin specifications
│       ├── lsp.lua          # LSP configuration
│       ├── completion.lua   # Completion setup
│       ├── treesitter.lua   # Treesitter config
│       ├── ui.lua           # UI plugins (colorscheme, statusline)
│       └── tools.lua        # Utility plugins
```

## Configuration Files

### 1. `~/.config/nvim/init.lua`
```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Setup plugins
require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false }, -- Don't auto-check for updates
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
```

### 2. `~/.config/nvim/lua/core/options.lua`
```lua
local opt = vim.opt

-- UI
opt.number = true                 -- Show line numbers
opt.relativenumber = false        -- Absolute numbers (easier for core vi users)
opt.cursorline = true            -- Highlight current line
opt.signcolumn = "yes"           -- Always show sign column (LSP diagnostics)
opt.termguicolors = true         -- True color support

-- Indentation (matching your old config)
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false            -- Use tabs by default (you had noet commented)
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

-- Behavior
opt.mouse = ""                   -- Disable mouse (vi purist mode)
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8                -- Keep 8 lines visible when scrolling

-- Whitespace visibility (like your old config)
opt.list = true
opt.listchars = { trail = '·', tab = '» ' }

-- Performance
opt.updatetime = 250             -- Faster completion
opt.timeoutlen = 300
```

### 3. `~/.config/nvim/lua/core/keymaps.lua`
```lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key (space is modern default, but you can keep comma)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Quality of life
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- Better window navigation (if you ever split)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Clear search highlighting
keymap("n", "<Esc>", ":noh<CR>", opts)

-- Keep visual mode after indent
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- LSP keymaps (will be overridden in LSP config for specific buffers)
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Formatting
keymap("n", "<leader>f", function()
  vim.lsp.buf.format({ async = false })
end, { desc = "Format file" })
```

### 4. `~/.config/nvim/lua/core/autocmds.lua`
```lua
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save (like your old config)
autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Go-specific settings (matching your old config)
autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
    vim.opt_local.textwidth = 120
  end,
})

-- Rust-specific settings
autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- HTML/JS settings (matching your old config)
autocmd("FileType", {
  pattern = { "html", "javascript" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.textwidth = 120
  end,
})

-- Markdown settings (matching your old config)
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 120
    vim.opt_local.formatoptions:append("t")
  end,
})

-- Format Go files on save (imports + format)
autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end,
})
```

### 5. `~/.config/nvim/lua/plugins/init.lua`
```lua
return {
  -- Colorscheme (choose one)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- Alternative colorschemes (uncomment to try)
  -- { "catppuccin/nvim", name = "catppuccin" },
  -- { "rebelot/kanagawa.nvim" },
  -- { "ellisonleao/gruvbox.nvim" },

  -- LSP
  { import = "plugins.lsp" },

  -- Completion
  { import = "plugins.completion" },

  -- Treesitter
  { import = "plugins.treesitter" },

  -- Tools
  { import = "plugins.tools" },

  -- UI enhancements
  { import = "plugins.ui" },
}
```

### 6. `~/.config/nvim/lua/plugins/lsp.lua`
```lua
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Go (gopls)
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Sign icons
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },

  -- Rust (rust-analyzer via rustaceanvim)
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },
}
```

### 7. `~/.config/nvim/lua/plugins/completion.lua`
```lua
return {
  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
  },
}
```

### 8. `~/.config/nvim/lua/plugins/treesitter.lua`
```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "go", "rust", "markdown", "json", "yaml" },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
```

### 9. `~/.config/nvim/lua/plugins/ui.lua`
```lua
return {
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons" },

  -- Indent guides (subtle)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },
}
```

### 10. `~/.config/nvim/lua/plugins/tools.lua`
```lua
return {
  -- Fuzzy finder (optional but highly recommended)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
  },

  -- Git integration (optional)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Comment toggle (gc in visual mode)
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
    },
    config = true,
  },

  -- Image preview in wezterm (sixel)
  {
    "adelarsq/image_preview.nvim",
    event = "VeryLazy",
    config = function()
      require("image_preview").setup()
    end,
  },
}
```

## Claude Code Integration

### Option 1: Side-by-side in wezterm (Recommended)
This is the simplest approach - no plugins needed!

**Setup:**
1. In wezterm, split your window vertically (Ctrl+Shift+Alt+%)
2. Left pane: Run `claude` for Claude Code
3. Right pane: Run `nvim`
4. Bottom pane (optional): Run your regular shell for commands

**Advantages:**
- No configuration needed
- Clean separation
- Works perfectly with your job control workflow
- Claude Code can see and modify files
- You maintain full control over vim

### Option 2: claudecode.nvim Plugin
For tighter integration:

Add to `~/.config/nvim/lua/plugins/tools.lua`:
```lua
{
  "coder/claudecode.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("claudecode").setup({
      terminal = {
        split_side = "right",
        split_width_percentage = 0.40,
      },
    })
  end,
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
  },
},
```

## Migration Strategy

### Day 1: Basic Setup
1. Install Neovim and language servers
2. Set up basic `init.lua` with options
3. Test that you can open files and edit normally
4. Goal: Verify all your vi commands still work

### Day 2: Add LSP
1. Add LSP configuration
2. Open a Go or Rust file
3. Test `gd` (go to definition), `K` (hover), `<leader>rn` (rename)
4. Goal: Verify LSP is working

### Day 3: Add Completion
1. Add nvim-cmp
2. Test that completions appear in insert mode
3. Goal: Comfortable with Tab/Enter for completions

### Day 4: Polish
1. Add colorscheme
2. Add statusline
3. Add any optional tools you want
4. Goal: Environment feels comfortable

### Day 5: Claude Code Integration
1. Test Claude Code in separate wezterm pane
2. Or install claudecode.nvim if you prefer
3. Goal: Smooth workflow with AI assistant

## Troubleshooting

### LSP not working
```bash
# Check if language server is installed
which gopls
which rust-analyzer

# Check LSP status in neovim
:LspInfo
:checkhealth
```

### Slow startup
```bash
# Profile startup time
nvim --startuptime startup.log
```

### Colors look wrong
```bash
# Check terminal true color support
echo $TERM  # should be 'wezterm' or 'xterm-256color'

# In neovim, check:
:echo $TERM
:set termguicolors?
```

## Optional Enhancements

### Go-specific tools
- `ray-x/go.nvim` - Additional Go tooling (if you need more than gopls)
- `olexsmir/gopher.nvim` - Go struct tags, impl generator

### Rust-specific tools
- `Saecki/crates.nvim` - Manage Cargo.toml dependencies
- Debugging via `nvim-dap` with codelldb

### Image preview alternatives
- `3rd/image.nvim` - More full-featured image support
- `kjuq/sixelview.nvim` - Simpler sixel viewer

### File explorer
- `nvim-tree/nvim-tree.lua` - Traditional file tree
- `stevearc/oil.nvim` - Edit filesystem like a buffer (very vi-like!)

## Key Differences from Your Old Setup

| Old (Pathogen Era) | New (2025) |
|-------------------|-----------|
| Pathogen | lazy.nvim |
| VimScript | Lua |
| vim-go with many tools | gopls via LSP |
| No LSP | Native LSP client |
| Syntastic/ALE | LSP diagnostics |
| Manual plugin management | Automatic with lazy loading |
| 256 colors | True color (16 million) |
| ASCII icons | Nerd Font icons & emoji |
| No AI integration | Claude Code ready |

## Philosophy

This configuration follows these principles:
1. **Minimal surface area** - Only add what you need
2. **Fast startup** - Lazy loading everything possible
3. **Vi compatible** - All your muscle memory works
4. **Modern tooling** - LSP, Tree-sitter, native features
5. **Terminal native** - Works great with wezterm
6. **AI-ready** - Easy Claude Code integration

## Next Steps

1. **Backup your old config**: `cp ~/.vimrc ~/.vimrc.backup`
2. **Start fresh**: Follow the migration strategy above
3. **Iterate**: Add optional plugins only as you need them
4. **Document your choices**: Keep notes on what works for you

Remember: You can always fall back to your old config if needed. The goal is to modernize while preserving what made your workflow effective.

---

**Questions to Answer During Setup:**
- Do you prefer comma or space as leader key?
- Light or dark colorscheme?
- Relative or absolute line numbers?
- Mouse enabled or disabled?
- Tabs or spaces? (default to your old config)

**Time Estimate:**
- Basic setup: 30 minutes
- Fully comfortable: 2-3 days of use
- Customized to perfection: Ongoing (as needed)
