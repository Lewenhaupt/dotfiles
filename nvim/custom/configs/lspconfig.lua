-- local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local utils = require("custom.utils")

local lspconfig = require("lspconfig")

-- lspconfig.inlay_hints = {
-- 	enabled = true,
-- }

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local bufnr = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

		local function get_bufopts(desc)
			return { noremap = true, silent = true, buffer = bufnr, desc = desc }
		end

		vim.keymap.set("n", "<space>lm", function()
			local options = {
				["1. Start LSP"] = "LspStart",
				["2. Stop LSP"] = "LspStop",
				["3. Restart LSP"] = "LspRestart",
				["4. Info"] = "LspInfo",
				["4. Log"] = "LspLog",
			}
			utils.create_select_menu("Lsp Options", options)()
		end, get_bufopts("Lsp Menu Options"))

		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, get_bufopts("Go to declaration"))
		vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", get_bufopts("Go to definitions"))
		vim.keymap.set("n", "K", vim.lsp.buf.hover, get_bufopts("Hover documentation"))
		vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", get_bufopts("Restart LSP"))
		--https://github.com/EuCaue/dotfiles/blob/5b10a4be6997f62b1a633b7ddbc8100a64e0f16f/dotconfig/nvim/lua/user/config/user_commands.lua#L85
		-- vim.keymap.set("n", "<space>o", "<cmd>Navbuddy<CR>", get_bufopts("Outline Icons"))
		vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", get_bufopts("Go to implementations"))
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, get_bufopts("Add workspace folder"))
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, get_bufopts("Remove workspace folder"))
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, get_bufopts("List workspace folders"))
		vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", get_bufopts("Go to type definition"))
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, get_bufopts("LSP Rename"))
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, get_bufopts("Code action"))
		vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", get_bufopts("References"))
		vim.keymap.set("n", "<space>L", function()
			vim.cmd("ToggleInlayHints")
		end, get_bufopts("Toggle LSP Inlay Hint"))
		vim.keymap.set("n", "<space>ls", vim.lsp.buf.signature_help, get_bufopts("LSP Signature"))
		vim.keymap.set("n", "<space>ltd", "<cmd>ToggleLspDiag<cr>", get_bufopts("Toggle LSP Diagnostics"))
		vim.keymap.set("n", "<space>lf", function()
			vim.lsp.buf.format({ async = true })
		end, get_bufopts("LSP Format"))

		-- if client.server_capabilities.documentSymbolProvider then
		-- 	navic.attach(client, bufnr)
		-- 	navbuddy.attach(client, bufnr)
		-- end
		--
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(bufnr, true)
		end
		--
		if client.name == "eslint" then
			client.server_capabilities.documentFormattingProvider = true
		elseif client.name == "tsserver" then
			client.server_capabilities.documentFormattingProvider = false
		elseif client.name == "html" then
			client.server_capabilities.documentFormattingProvider = false
		end
	end,
})

lspconfig.rust_analyzer.setup({
	-- on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "rust" },
	root_dir = lspconfig.util.root_pattern("Cargo.toml"),
})

lspconfig.stylua.setup({
	-- on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "lua" },
	-- root_dir = lspconfig.util.root_pattern("stylua.toml"),
})

lspconfig.eslint.setup({
	on_attach = function(client, bufnr)
		-- on_attach(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
	-- handlers = handlers,
	cmd = { "bunx", "vscode-eslint-language-server", "--stdio" },
	capabilities = capabilities,
	completions = {
		completeFunctionCalls = true,
	},
})

require("typescript-tools").setup({
	handlers = {},
	settings = {
		-- spawn additional tsserver instance to calculate diagnostics on it
		separate_diagnostic_server = true,
		-- "change"|"insert_leave" determine when the client asks the server about diagnostic
		publish_diagnostic_on = "insert_leave",
		-- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
		-- "remove_unused_imports"|"organize_imports") -- or string "all"
		-- to include all supported code actions
		-- specify commands exposed as code_actions
		expose_as_code_action = "all",
		-- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
		-- not exists then standard path resolution strategy is applied
		tsserver_path = nil,
		-- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
		-- (see 💅 `styled-components` support section)
		tsserver_plugins = {},
		-- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
		-- memory limit in megabytes or "auto"(basically no limit)
		tsserver_max_memory = "auto",
		-- described below
		tsserver_format_options = {},
		tsserver_file_preferences = {
			includeInlayEnumMemberValueHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayFunctionParameterTypeHints = true,
			includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
			includeInlayParameterNameHintsWhenArgumentMatchesName = true,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayVariableTypeHints = true,
			quotePreference = "auto",
		},
		-- locale of all tsserver messages, supported locales you can find here:
		-- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
		tsserver_locale = "en",
		-- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
		complete_function_calls = true,
		include_completions_with_insert_text = true,
		-- CodeLens
		-- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
		-- possible values: ("off"|"all"|"implementations_only"|"references_only")
		code_lens = "off",
		-- by default code lenses are displayed on all referencable values and for some of you it can
		-- be too much this option reduce count of them by removing member references from lenses
		disable_member_code_lens = true,
	},
})

-- lspconfig.tsserver.setup({
-- 	-- on_attach = on_attach,
-- 	capabilities = capabilities,
-- 	settings = {
-- 		typescript = {
-- 			inlayHints = {
-- 				includeInlayParameterNameHints = "literal",
-- 				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
-- 				includeInlayFunctionParameterTypeHints = true,
-- 				includeInlayVariableTypeHints = true,
-- 				includeInlayPropertyDeclarationTypeHints = true,
-- 				includeInlayFunctionLikeReturnTypeHints = true,
-- 				includeInlayEnumMemberValueHints = true,
-- 			},
-- 		},
-- 		javascript = {
-- 			inlayHints = {
-- 				includeInlayParameterNameHints = "all",
-- 				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
-- 				includeInlayFunctionParameterTypeHints = true,
-- 				includeInlayVariableTypeHints = true,
-- 				includeInlayPropertyDeclarationTypeHints = true,
-- 				includeInlayFunctionLikeReturnTypeHints = true,
-- 				includeInlayEnumMemberValueHints = true,
-- 			},
-- 		},
-- 	},
-- })

lspconfig.pylsp.setup({
	-- on_attach = on_attach,
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 200,
	},
	settings = {
		plugins = {
			rope_completion = { enabled = true },
			rope_autoimport = {
				enabled = true,
			},
		},
	},
})

local servers = { "html", "cssls", "clangd" }

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		-- on_attach = on_attach,
		capabilities = capabilities,
	})
end
