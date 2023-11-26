local M = {}

-- In order to disable a default keymap, use
M.disabled = {
	i = {
		["<C-h>"] = "",
		["<C-j>"] = "",
		["<C-k>"] = "",
		["<C-l>"] = "",
	},
	n = {
		-- ["<h>"] = "",
		-- ["<j>"] = "",
		-- ["<k>"] = "",
		-- ["<l>"] = "",
		-- ["<o>"] = "",
		["<C-h>"] = "",
		["<C-j>"] = "",
		["<C-k>"] = "",
		["<C-l>"] = "",
		["<leader>x"] = "",
		["<A-h>"] = "",
	},
	t = {
		["<A-h>"] = "",
	},
}
-- Your custom mappings
M.general = {
	n = {
		-- ["å"] = { "o", opts = { noremap = true, silent = true } },
		-- ["l"] = { "<Up>", opts = { noremap = true, silent = true } },
		-- [","] = { "<Left>", opts = { noremap = true, silent = true } },
		-- ["."] = { "<Down>", opts = { noremap = true, silent = true } },
		-- ["-"] = {  "<Right>", opts = { noremap = true, silent = true } },

		["<leader>h"] = { "<C-w>h", "Window left", opts = { nowait = false } },
		["<leader>l"] = { "<C-w>l", "Window right", opts = { nowait = false } },
		["<leader>j"] = { "<C-w>j", "Window down", opts = { nowait = false } },
		["<leader>k"] = { "<C-w>k", "Window up", opts = { nowait = false } },

		["<leader>ö"] = { ":split <CR>", "Horizontal split", opts = { nowait = true, silent = true } },
		["<leader>ä"] = { ":vsplit <CR>", "Vertical split", opts = { nowait = true, silent = true } },
		["<A-t>"] = {
			function()
				require("nvterm.terminal").toggle("horizontal")
			end,
			"Toggle horizontal term",
		},
	},
	t = {
		["<A-t>"] = {
			function()
				require("nvterm.terminal").toggle("horizontal")
			end,
			"Toggle horizontal term",
		},
	},
	i = {
		-- ["<A-l>"] = { "<Up>", opts = { noremap = true, silent = true } },
		-- ["<A-,>"] = { "<Left>", opts = { noremap = true, silent = true } },
		-- ["<A-.>"] = { "<Down>", opts = { noremap = true, silent = true } },
		-- ["<A-->"] = { "<Right>", opts = { noremap = true, silent = true } },
	},
	v = {
		[">"] = { ">gv", "indent" },
		-- ["l"] = { "<Up>", opts = { noremap = true, silent = true } },
		-- [","] = { "<Left>", opts = { noremap = true, silent = true } },
		-- ["."] = { "<Down>", opts = { noremap = true, silent = true } },
		-- ["-"] = { "<Right>", opts = { noremap = true, silent = true } },
	},
}
M.portal = {
	n = {
		["<leader>pj"] = { "<CMD>Portal jumplist backward<CR>", "󱡁 Portal Jumplist" },
		["<leader>ph"] = {
			function()
				require("portal.builtin").harpoon.tunnel()
			end,
			"󱡁 Portal Harpoon",
		},
	},
}
M.tabufline = {
	n = {
		-- close buffer + hide terminal buffer
		["<leader>xq"] = {
			function()
				require("nvchad.tabufline").close_buffer()
			end,
			"Close buffer",
		},
	},
}
M.harpoon = {
	n = {
		["<leader>ha"] = {
			function()
				require("harpoon.mark").add_file()
			end,
			"󱡁 Harpoon Add file",
		},
		["<leader>ta"] = { "<CMD>Telescope harpoon marks<CR>", "󱡀 Toggle quick menu" },
		["<leader>hb"] = {
			function()
				require("harpoon.ui").toggle_quick_menu()
			end,
			"󱠿 Harpoon Menu",
		},
		["<leader>1"] = {
			function()
				require("harpoon.ui").nav_file(1)
			end,
			"󱪼 Navigate to file 1",
		},
		["<leader>2"] = {
			function()
				require("harpoon.ui").nav_file(2)
			end,
			"󱪽 Navigate to file 2",
		},
		["<leader>3"] = {
			function()
				require("harpoon.ui").nav_file(3)
			end,
			"󱪾 Navigate to file 3",
		},
		["<leader>4"] = {
			function()
				require("harpoon.ui").nav_file(4)
			end,
			"󱪿 Navigate to file 4",
		},
	},
}
return M
