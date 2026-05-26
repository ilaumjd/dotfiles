-- [[ File Management ]]
-- Oil.nvim — directory as editable buffer

vim.pack.add({ _G.gh("stevearc/oil.nvim") })
require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	keymaps = { ["q"] = "actions.close" },
	view_options = { show_hidden = true },
})

-- Auto-open oil when editing a directory
vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Open Oil on directory",
	callback = function(args)
		local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
		if stats and stats.type == "directory" then
			vim.schedule(function()
				require("oil").open(vim.api.nvim_buf_get_name(args.buf))
			end)
			return true
		end
	end,
})

-- vim: ts=2 sts=2 sw=2 et
