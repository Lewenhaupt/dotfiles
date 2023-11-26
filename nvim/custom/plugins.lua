local overrides = require("custom.configs.overrides")

local plugins = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			-- {
			--   "jose-elias-alvarez/null-ls.nvim",
			--   config = function()
			--     require "custom.configs.null-ls"
			--   end,
			-- },
			{
				"stevearc/conform.nvim",
				event = { "BufWritePre" },
				cmd = { "ConformInfo" },
				keys = {
					{
						-- Customize or remove this keymap to your liking
						"<leader>fm",
						function()
							require("conform").format({ async = true, lsp_fallback = true })
						end,
						mode = "",
						desc = "Format buffer",
					},
				},
				-- Everything in opts will be passed to setup()
				opts = {
					-- Define your formatters
					formatters_by_ft = {
						lua = { "stylua" },
						python = { "isort", "blue" },
						javascript = { { "prettierd", "prettier" } },
						javascriptreact = { { "prettierd", "prettier" } },
						typescript = { { "prettierd", "prettier" } },
						typescriptreact = { { "prettierd", "prettier" } },
						json = { { "prettierd", "prettier" } },
						html = { { "prettierd", "prettier" } },
						css = { { "prettierd", "prettier" } },
						scss = { { "prettierd", "prettier" } },
						markdown = { { "prettierd", "prettier" } },
						yaml = { { "prettierd", "prettier" } },
						sh = { "beautysh" },
						zsh = { "beautysh" },
						rust = { "rustfmt" },
						["_"] = { "trim_whitespace" },
					},
					-- Set up format-on-save
					format_on_save = function(bufnr)
						local bufname = vim.api.nvim_buf_get_name(bufnr)
						if bufname:match("/nodue_modules/") then
							return
						end
						return { timeout_ms = 500, lsp_fallback = true }
					end,
					-- Customize formatters
					formatters = {
						shfmt = {
							prepend_args = { "-i", "2" },
						},
					},
				},
				config = function(_, opts)
					local conform = require("conform")
					local util = require("conform.util")

					conform.setup(opts)

					-- Customize prettier args
					require("conform.formatters.prettier").args = function(ctx)
						local args = { "--stdin-filepath", "$FILENAME" }
						local localPrettierConfig = vim.fs.find(".prettierrc.json", {
							upward = true,
							path = ctx.dirname,
							type = "file",
						})[1]
						local globalPrettierConfig = vim.fs.find(".prettierrc.json", {
							path = vim.fn.expand("~/.config/nvim"),
							type = "file",
						})[1]

						-- Project config takes precedence over global config
						if localPrettierConfig then
							vim.list_extend(args, { "--config", localPrettierConfig })
						elseif globalPrettierConfig then
							vim.list_extend(args, { "--config", globalPrettierConfig })
						end

						local isUsingTailwind = vim.fs.find("tailwind.config.js", {
							upward = true,
							path = ctx.dirname,
							type = "file",
						})[1]
						local localTailwindcssPlugin =
							vim.fs.find("node_modules/prettier-plugin-tailwindcss/dist/index.mjs", {
								upward = true,
								path = ctx.dirname,
								type = "file",
							})[1]

						if localTailwindcssPlugin then
							vim.list_extend(args, { "--plugin", localTailwindcssPlugin })
						else
							if isUsingTailwind then
								vim.notify(
									"Tailwind was detected for your project. You can really benefit from automatic class sorting. Please run npm i -D prettier-plugin-tailwindcss",
									vim.log.levels.WARN
								)
							end
						end

						return args
					end

					local beautysh = require("conform.formatters.beautysh")
					conform.formatters.beautysh = vim.tbl_deep_extend("force", beautysh, {
						args = util.extend_args(
							beautysh.args,
							{ "--indent-size", "2", "--force-function-style", "fnpar" }
						),
					})
				end,
				init = function()
					-- If you want the formatexpr, here is the place to set it
					vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
				end,
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
		config = function()
			require("custom.configs.neotest")
		end,
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
	},
	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				config = function()
					require("nvim-treesitter.configs").setup({
						textobjects = {
							move = {
								enable = true,
								set_jumps = true, -- whether to set jumps in the jumplist
								goto_next_start = {
									["]m"] = "@function.outer",
									["]]"] = { query = "@class.outer", desc = "Next class start" },
									--
									-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
									["]o"] = "@loop.*",
									-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
									--
									-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
									-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
									["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
									["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
								},
								goto_next_end = {
									["]M"] = "@function.outer",
									["]["] = "@class.outer",
								},
								goto_previous_start = {
									["[m"] = "@function.outer",
									["[["] = "@class.outer",
								},
								goto_previous_end = {
									["[M"] = "@function.outer",
									["[]"] = "@class.outer",
								},
								-- Below will go to either the start or the end, whichever is closer.
								-- Use if you want more granular movements
								-- Make it even more gradual by adding multiple queries and regex.
								goto_next = {
									["]d"] = "@conditional.outer",
								},
								goto_previous = {
									["[d"] = "@conditional.outer",
								},
							},
							swap = {
								enable = true,
								swap_next = {
									["<leader>a"] = "@parameter.inner",
								},
								swap_previous = {
									["<leader>A"] = "@parameter.inner",
								},
							},
							select = {
								enable = true,

								-- Automatically jump forward to textobj, similar to targets.vim
								lookahead = true,

								keymaps = {
									-- You can use the capture groups defined in textobjects.scm
									["af"] = "@function.outer",
									["if"] = "@function.inner",
									["ac"] = "@class.outer",
									-- You can optionally set descriptions to the mappings (used in the desc parameter of
									-- nvim_buf_set_keymap) which plugins like which-key display
									["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
									-- You can also use captures from other query groups like `locals.scm`
									["as"] = {
										query = "@scope",
										query_group = "locals",
										desc = "Select language scope",
									},
								},
								-- You can choose the select mode (default is charwise 'v')
								--
								-- Can also be a function which gets passed a table with the keys
								-- * query_string: eg '@function.inner'
								-- * method: eg 'v' or 'o'
								-- and should return the mode ('v', 'V', or '<c-v>') or a table
								-- mapping query_strings to modes.
								selection_modes = {
									["@parameter.outer"] = "v", -- charwise
									["@function.outer"] = "V", -- linewise
									["@class.outer"] = "<c-v>", -- blockwise
								},
								-- If you set this to `true` (default is `false`) then any textobject is
								-- extended to include preceding or succeeding whitespace. Succeeding
								-- whitespace has priority in order to act similarly to eg the built-in
								-- `ap`.
								--
								-- Can also be a function which gets passed a table with the keys
								-- * query_string: eg '@function.inner'
								-- * selection_mode: eg 'v'
								-- and should return true of false
								include_surrounding_whitespace = true,
							},
						},
						lsp_interop = {
							enable = true,
							border = "none",
							floating_preview_opts = {},
							peek_definition_code = {
								["<leader>df"] = "@function.outer",
								["<leader>dF"] = "@class.outer",
							},
						},
					})
					local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

					-- Repeat movement with ; and ,
					-- ensure ; goes forward and , goes backward regardless of the last direction
					vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
					vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

					-- vim way: ; goes to the direction you were moving.
					-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
					-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

					-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
					vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
					vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
					vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
					vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
				end,
			},
		},
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},
	{
		"mfussenegger/nvim-dap",

		dependencies = {

			-- fancy UI for the debugger
			{
				"rcarriga/nvim-dap-ui",
        -- stylua: ignore
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
          { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
        },
				opts = {},
				config = function(_, opts)
					-- setup dap config by VsCode launch.json file
					require("dap.ext.vscode").load_launchjs()
					local dap = require("dap")
					local dapui = require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end
				end,
			},

			-- virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},

			-- which key integration
			{
				"folke/which-key.nvim",
				optional = true,
				opts = {
					defaults = {
						["<leader>d"] = { name = "+debug" },
						["<leader>da"] = { name = "+adapters" },
					},
				},
				config = function()
					vim.o.timeout = true
					vim.o.timeoutlen = 300

					-- local lmu = require "langmapper.utils"
					--local view = require "which-key.view"
					--local execute = view.execute

					-- wrap `execute()` and translate sequence back
					--view.execute = function(prefix_i, mode, buf)
					-- Translate back to English characters
					--prefix_i = lmu.translate_keycode(prefix_i, "default", "sv")
					--execute(prefix_i, mode, buf)
					--end

					-- If you want to see translated operators, text objects and motions in
					-- which-key prompt
					-- local presets = require('which-key.plugins.presets')
					-- presets.operators = lmu.trans_dict(presets.operators)
					-- presets.objects = lmu.trans_dict(presets.objects)
					-- presets.motions = lmu.trans_dict(presets.motions)
					-- etc

					require("which-key").setup()
				end,
			},

			-- mason.nvim integration
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = "mason.nvim",
				cmd = { "DapInstall", "DapUninstall" },
				opts = {
					-- Makes a best effort to setup the various debuggers with
					-- reasonable debug configurations
					automatic_installation = true,

					-- You can provide additional configuration to the handlers,
					-- see mason-nvim-dap README for more information
					handlers = {},

					-- You'll need to check that you have the required things installed
					-- online, please don't ask me how to install them :)
					ensure_installed = {
						-- Update this to ensure that you have the debuggers for the langs you want
					},
				},
			},
		},

    -- stylua: ignore
    keys = {
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        desc =
        "Breakpoint Condition"
      },
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc =
        "Toggle Breakpoint"
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc =
        "Continue"
      },
      {
        "<leader>dC",
        function() require("dap").run_to_cursor() end,
        desc =
        "Run to Cursor"
      },
      {
        "<leader>dg",
        function() require("dap").goto_() end,
        desc =
        "Go to line (no execute)"
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc =
        "Step Into"
      },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end,   desc = "Up" },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc =
        "Run Last"
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc =
        "Step Out"
      },
      {
        "<leader>dO",
        function() require("dap").step_over() end,
        desc =
        "Step Over"
      },
      {
        "<leader>dp",
        function() require("dap").pause() end,
        desc =
        "Pause"
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc =
        "Toggle REPL"
      },
      {
        "<leader>ds",
        function() require("dap").session() end,
        desc =
        "Session"
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc =
        "Terminate"
      },
      {
        "<leader>dw",
        function() require("dap.ui.widgets").hover() end,
        desc =
        "Widgets"
      },
    },

		config = function()
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			local icons = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = " ",
				BreakpointCondition = " ",
				BreakpointRejected = { " ", "DiagnosticError" },
				LogPoint = ".>",
			}

			for name, sign in pairs(icons) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
    },
		opts = {},
		config = function(_, opts)
			-- setup dap config by VsCode launch.json file
			require("dap.ext.vscode").load_launchjs()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},
	-- {
	--   "Pocco81/auto-save.nvim",
	--   config = function()
	--     require("auto-save").setup {
	--       -- your config goes here
	--       -- or just leave it empty :)
	--     }
	--   end,
	--   lazy = false,
	-- },
	{ "ThePrimeagen/harpoon", cmd = "Harpoon" },
	{
		"cbochs/portal.nvim",
		keys = { "<leader>pj", "<leader>ph" },
	},
	-- {
	--   "Wansmer/langmapper.nvim",
	--   lazy = false,
	--   priority = 1, -- High priority is needed if you will use `autoremap()`
	--   config = function()
	--     require("langmapper").setup {
	--       hack_keymap = true,
	--       default_layout = [[p[]j{}]],
	--       layouts = {
	--         sv = {
	--           id = "1",
	--           layout = [[på"jÅ^]],
	--         },
	--       },
	--       os = {
	--         Linux = {
	--           get_current_layout_id = function()
	--             return "1"
	--           end,
	--         },
	--       },
	--     }
	--   end,
	-- },
	{
		"ggandor/leap.nvim",
		lazy = false,
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup()
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		event = "LspAttach",
		cmd = "Refactor",
		keys = {
			{ "<leader>re", ":Refactor extract ", mode = "x", desc = "Extract function" },
			{ "<leader>rf", ":Refactor extract_to_file ", mode = "x", desc = "Extract function to file" },
			{ "<leader>rv", ":Refactor extract_var ", mode = "x", desc = "Extract variable" },
			{ "<leader>ri", ":Refactor inline_var", mode = { "x", "n" }, desc = "Inline variable" },
			{ "<leader>rI", ":Refactor inline_func", mode = "n", desc = "Inline function" },
			{ "<leader>rb", ":Refactor extract_block", mode = "n", desc = "Extract block" },
			{ "<leader>rf", ":Refactor extract_block_to_file", mode = "n", desc = "Extract block to file" },
		},
		config = function()
			require("refactoring").setup()
		end,
	},
	{
		"fedepujol/move.nvim",
		lazy = false,
		event = "BufEnter",
		keys = {
			{ "<M-Down>", "<Cmd>MoveLine(1)<CR>", desc = "Move line up" },
			{ "<M-Up>", "<Cmd>MoveLine(-1)<CR>", desc = "Move line down" },
			-- { "<M-Left>", "<Cmd>MoveWord(-1)<CR>}", desc = "Move word left" },
			-- { "<M-Right>", "<Cmd>MoveWord(1)<CR>}", desc = "Move word right" },

			-- Visual-mode commands
			{ "<M-Up>", "<Cmd>MoveBlock(-1)<CR>", mode = "v", desc = "Move block up" },
			{ "<M-Down>", "<Cmd>MoveBlock(1)<CR>", mode = "v", desc = "Move block down" },
			-- { "<M-Left>", "<Cmd>MoveHBlock(-1)<CR>", mode = "v", desc = "Move block left" },
			-- { "<M-Right>", "<Cmd>MoveHBlock(1)<CR>", mode = "v", desc = "Move block right" },
		},
		config = function()
			-- local opts = { noremap = true, silent = true }
			-- -- Normal-mode commands
			-- vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts)
			-- vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts)
			-- vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts)
			-- vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts)
			-- vim.keymap.set("n", "<leader>wf", ":MoveWord(1)<CR>", opts)
			-- vim.keymap.set("n", "<leader>wb", ":MoveWord(-1)<CR>", opts)
			--
			-- -- Visual-mode commands
			-- vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts)
			-- vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts)
			-- vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
			-- vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts)
		end,
	},
	{
		"mrjones2014/smart-splits.nvim",
		lazy = false,
		config = function()
			vim.keymap.set("n", "<M-h>", require("smart-splits").resize_left)
			vim.keymap.set("n", "<M-j>", require("smart-splits").resize_down)
			vim.keymap.set("n", "<M-k>", require("smart-splits").resize_up)
			vim.keymap.set("n", "<M-l>", require("smart-splits").resize_right)
			-- moving between splits
			vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
			vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
			vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
			vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
			-- swapping buffers between windows
			vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
			vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
			vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
			vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
		end,
	},
	{
		"mawkler/modicator.nvim",
		dependencies = "mawkler/onedark.nvim", -- Add your colorscheme plugin here
		lazy = false,
		init = function()
			-- These are required for Modicator to work
			vim.o.cursorline = true
			vim.o.number = true
			vim.o.termguicolors = true
		end,
		opts = {},
	},
	{
		"axelvc/template-string.nvim",
		ft = { "javascript", "javascriptreact", "typescriptreact", "typescript", "python", "html" },
		config = function()
			require("template-string").setup({
				filetypes = { "html", "typescript", "javascript", "typescriptreact", "javascriptreact", "python" }, -- filetypes where the plugin is active
				jsx_brackets = true, -- must add brackets to JSX attributes
				remove_template_string = false, -- remove backticks when there are no template strings
				restore_quotes = {
					-- quotes used when "remove_template_string" option is enabled
					normal = [[']],
					jsx = [["]],
				},
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<C-g>o",
					insert_line = "<C-g>O",
					normal = "yo",
					normal_cur = "yoo",
					normal_line = "yO",
					normal_cur_line = "yOO",
					visual = "O",
					visual_line = "gO",
					delete = "do",
					change = "co",
					change_line = "cO",
				},
			})
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "TroubleToggle", "Trouble" },
		opts = { use_diagnostic_signs = true },
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
			{ "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xF", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").previous({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next trouble/quickfix item",
			},
		},
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,
				tmux = true,
				kitty = { enabled = false, font = "+2" },
			},
		},
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
	},
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",
		config = true,
		keys = { { mode = "n", "<leader>rN", ":IncRename " } },
	},
	{
		"olimorris/persisted.nvim",
		lazy = false,
		priority = 1,
		config = function()
			require("persisted").setup({
				use_git_branch = true,
				autoload = true,
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		lazy = false,
		opts = {
			filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		},
		config = function(_, opts)
			-- vim.api.nvim_create_autocmd("FileType", {
			-- 	group = vim.api.nvim_create_augroup("local_detach_ufo", { clear = true }),
			-- 	pattern = opts.filetype_exclude,
			-- 	callback = function()
			-- 		require("ufo").detach()
			-- 	end,
			-- })

			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities.textDocument.foldingRange = {
			-- 	dynamicRegistration = false,
			-- 	lineFoldingOnly = true,
			-- }
			-- local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			-- for _, ls in ipairs(language_servers) do
			-- 	require("lspconfig")[ls].setup({
			-- 		capabilities = capabilities,
			-- 		-- you can add other fields for setting up lsp server in this table
			-- 	})
			-- end
			--
			vim.opt.foldcolumn = "1" -- '0' is not bad
			vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.opt.foldlevelstart = 99
			vim.opt.foldenable = true

			require("ufo").setup(opts)
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		event = "BufEnter",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"typescript-language-server",
					"eslint",
					"html",
					"cssls",
					"pylsp",
				},
			})

			-- automatic_installation is handled by lsp-manager
			local settings = require("mason-lspconfig.settings")
			settings.current.automatic_installation = false
		end,
		lazy = true,
		event = "User FileOpened",
		dependencies = "mason.nvim",
	},
}

return plugins
