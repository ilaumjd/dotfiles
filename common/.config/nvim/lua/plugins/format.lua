-- [[ Format ]]
-- conform.nvim

vim.pack.add({ _G.gh("stevearc/conform.nvim") })

-- Use biome if biome.json exists in project root, otherwise fallback to prettier
local function ts_formatter(bufnr)
	local dir = vim.fn.expand("#" .. bufnr .. ":p:h")
	if vim.fn.findfile("biome.json", dir .. ";") ~= "" then
		return { "biome" }
	end
	return { "prettierd" }
end

require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local enabled_filetypes = {
			lua = true,
			go = true,
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
			json = true,
			jsonc = true,
			jsonl = true,
		}
		if enabled_filetypes[vim.bo[bufnr].filetype] then
			return { timeout_ms = 500 }
		end
	end,
	default_format_opts = { lsp_format = "fallback" },
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofumpt" },
		javascript = ts_formatter,
		typescript = ts_formatter,
		javascriptreact = ts_formatter,
		typescriptreact = ts_formatter,
		json = ts_formatter,
		jsonc = ts_formatter,
		jsonl = ts_formatter,
	},
})

-- vim: ts=2 sts=2 sw=2 et
