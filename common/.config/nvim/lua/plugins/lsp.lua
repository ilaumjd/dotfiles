-- [[ LSP Plugins ]]
-- nvim-lspconfig only. Install servers via brew/npm manually.

vim.pack.add({ _G.gh("neovim/nvim-lspconfig") })

-- lua_ls — make the server aware of Neovim's runtime files
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			diagnostics = {
				globals = { "vim", "require" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
			format = { enable = false },
			hint = { enable = true, semicolon = "Disable" },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.enable("lua_ls")

-- ruby-lsp — diagnostics, completion, hover, go-to-definition. No formatting.
vim.lsp.config("ruby_lsp", {
	init_options = { formatter = "none" },
	settings = {
		rubyLsp = {
			formatter = "none",
		},
	},
})

vim.lsp.enable("ruby_lsp")

-- ts_ls — TypeScript/JavaScript LSP.
-- Install: npm install -g typescript typescript-language-server
vim.lsp.config("ts_ls", {
	init_options = { hostInfo = "neovim" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		".git",
	},
})
vim.lsp.enable("ts_ls")

-- gopls — Go LSP (built-in config).
-- Install: go install golang.org/x/tools/gopls@latest
vim.lsp.enable("gopls")

-- vim: ts=2 sts=2 sw=2 et
