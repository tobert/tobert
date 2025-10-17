-- Key Mappings
-- Modern keybindings while preserving vi muscle memory

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key (comma)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Quality of life
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Clear search highlighting
keymap("n", "<Esc>", ":noh<CR>", opts)

-- Keep visual mode after indent
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- LSP keymaps (available when LSP attaches)
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
