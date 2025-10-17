-- Autocommands
-- Automatic behaviors for specific events and filetypes

local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Go-specific settings
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

-- HTML/JS settings
autocmd("FileType", {
  pattern = { "html", "javascript" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.textwidth = 120
  end,
})

-- Markdown settings
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 120
    vim.opt_local.formatoptions:append("t")
  end,
})

-- Format Go files on save (organize imports + format)
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
