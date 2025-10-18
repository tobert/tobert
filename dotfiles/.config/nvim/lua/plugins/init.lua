-- Plugin Specification
-- Main plugin list - imports other plugin configs

return {
	-- Colorscheme (Tokyo Matrix - custom theme)
	-- This is a local plugin, so we specify the directory
	{
		dir = vim.fn.stdpath("config"), -- Point to the nvim config dir
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme harmonized")
		end,
	},

	-- Import other plugin configs
	{ import = "plugins.lsp" },
	{ import = "plugins.completion" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.tools" },
	{ import = "plugins.ui" },
}
