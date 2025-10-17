-- Plugin Specification
-- Main plugin list - imports other plugin configs

return {
  -- Colorscheme (Tokyo Matrix - custom theme)
  -- No plugin needed - using colors/tokyomatrix.lua
  {
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyomatrix")
    end,
  },

  -- Import other plugin configs
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.treesitter" },
  { import = "plugins.tools" },
  { import = "plugins.ui" },
}
