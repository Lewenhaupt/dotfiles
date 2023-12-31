local M = {}

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"c",
		"markdown",
		"markdown_inline",
		"rust",
		"python",
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		-- "typescript-language-server",
		-- "tsserver",
		"deno",
		"prettier",
		"prettierd",

		"yamllint",
		-- c/cpp stuff
		"clangd",
		"clang-format",

		-- "python",
		"isort",
		"blue",

		"rustfmt",
	},
}

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	-- vim.keymap.set("n", ",", "<Left>", opts "")
	-- vim.keymap.set("n", ".", "<Down>", opts "")
	-- vim.keymap.set("n", "-", "<Right>", opts "")
	-- vim.keymap.set("n", "<C-o>", api.node.open.no_window_picker, opts "")
	-- vim.keymap.set("n", "O", api.node.open.edit, opts "")
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
end

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	on_attach = my_on_attach,

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

return M
