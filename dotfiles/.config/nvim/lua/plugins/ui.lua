-- UI Enhancements
-- Statusline, icons, and visual improvements

return {
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Tokyomatrix theme for Lualine
      local theme = {
        normal = {
          a = { fg = "#0d0f15", bg = "#73ff73", gui = "bold" },
          b = { fg = "#d0f8d0", bg = "#1a2233" },
          c = { fg = "#d0f8d0", bg = "#13151f" },
        },
        insert = { a = { fg = "#0d0f15", bg = "#5fbfff", gui = "bold" } },
        visual = { a = { fg = "#0d0f15", bg = "#d75fd7", gui = "bold" } },
        replace = { a = { fg = "#0d0f15", bg = "#ff5f87", gui = "bold" } },
        command = { a = { fg = "#0d0f15", bg = "#e5c07b", gui = "bold" } },
        inactive = {
          a = { fg = "#d0f8d0", bg = "#13151f", gui = "bold" },
          b = { fg = "#d0f8d0", bg = "#13151f" },
          c = { fg = "#5a7a5a", bg = "#080a0f" },
        },
      }

      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Keymap popup
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
        win = {
          border = "rounded",
          position = "bottom",
          margin = { 1, 0, 1, 0 },
          padding = { 2, 2, 2, 2 },
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
