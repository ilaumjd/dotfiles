-- nvim-lint — async linting with linters by filetype.
-- Install linters separately:
--   brew install selene
--   npm install -g @biomejs/biome
--   npm install -g @fsouza/prettierd

vim.pack.add({ _G.gh("mfussenegger/nvim-lint") })

require("lint").linters_by_ft = {
	lua = { "selene" },
	go = { "staticcheck" },
}

-- Run linter on save and on BufEnter
-- For JS/TS: use biome if biome.json exists, otherwise eslint
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	callback = function()
		local ft = vim.bo.filetype
		local ts_like = {
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
		}
		if ts_like[ft] then
			local dir = vim.fn.expand("%:p:h")
			if vim.fn.findfile("biome.json", dir .. ";") ~= "" then
				require("lint").try_lint("biomejs")
			else
				require("lint").try_lint("eslint")
			end
		else
			require("lint").try_lint()
		end
	end,
})

-- vim: ts=2 sts=2 sw=2 et
