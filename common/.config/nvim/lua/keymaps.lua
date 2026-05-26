-- [[ Keymaps ]]
-- Grouped by prefix and function.

local map = vim.keymap.set
local picker = function()
	return require("snacks").picker
end

-- ═══════════════════════════════════════════════════════════════
-- Navigation
-- ═══════════════════════════════════════════════════════════════

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

map("n", "H", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "L", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "J", function()
	require("buffer_manager").open()
end, { desc = "Buffer manager" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ═══════════════════════════════════════════════════════════════
-- Toggle (<leader>u)
-- ═══════════════════════════════════════════════════════════════

map("n", "<leader>uq", function()
	vim.g._macro_enabled = not vim.g._macro_enabled
	if vim.g._macro_enabled then
		vim.cmd("unmap q")
		vim.notify("Macro recording enabled")
	else
		vim.cmd("map q <Nop>")
		vim.notify("Macro recording disabled")
	end
end, { desc = "Toggle macro recording" })

-- ═══════════════════════════════════════════════════════════════
-- Show (<leader>s)
-- ═══════════════════════════════════════════════════════════════

map("n", "<leader>sn", function()
	MiniNotify.show_history()
end, { desc = "Notification history" })

-- ═══════════════════════════════════════════════════════════════
-- Find (<leader>f) — snacks picker
-- ═══════════════════════════════════════════════════════════════

-- Files & buffers
map("n", "<leader>ff", function()
	picker().files()
end, { desc = "Find files" })
map("n", "<leader>fb", function()
	picker().buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fn", function()
	picker().files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Neovim config files" })

-- Grep
map("n", "<leader>fg", function()
	picker().grep()
end, { desc = "Live grep" })
map("n", "<leader>fw", function()
	picker().grep({ search = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })

-- Recent files
map("n", "<leader>fo", function()
	picker().recent({ filter = { cwd = true } })
end, { desc = "Recent files (cwd)" })
map("n", "<leader>fO", function()
	picker().recent()
end, { desc = "Recent files (all)" })

-- Documentation & help
map("n", "<leader>fh", function()
	picker().help()
end, { desc = "Search help" })
map("n", "<leader>fk", function()
	picker().keymaps()
end, { desc = "Search keymaps" })

-- Diagnostics
map("n", "<leader>fd", function()
	picker().diagnostics_buffer()
end, { desc = "Diagnostics (buffer)" })
map("n", "<leader>fD", function()
	picker().diagnostics()
end, { desc = "Diagnostics (workspace)" })

-- Lists
map("n", "<leader>fq", function()
	picker().qflist()
end, { desc = "Quickfix list" })
map("n", "<leader>fQ", function()
	picker().loclist()
end, { desc = "Location list" })
map("n", "<leader>fr", function()
	picker().resume()
end, { desc = "Resume picker" })

-- LSP symbols (non-buffer-specific)
map("n", "<leader>fy", function()
	picker().lsp_symbols()
end, { desc = "LSP document symbols" })
map("n", "<leader>fY", function()
	picker().lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })

-- ═══════════════════════════════════════════════════════════════
-- LSP (buffer-local, attached on LspAttach)
-- ═══════════════════════════════════════════════════════════════

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("keymaps-lsp", { clear = true }),
	callback = function(event)
		local buf = event.buf
		local lsp_map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = buf, desc = "LSP: " .. desc })
		end

		-- Goto
		lsp_map("gd", function()
			picker().lsp_definitions()
		end, "Definition")
		lsp_map("gD", function()
			picker().lsp_declarations()
		end, "Declaration")
		lsp_map("grt", function()
			picker().lsp_type_definitions()
		end, "Type Definition")
		lsp_map("gri", function()
			picker().lsp_implementations()
		end, "Implementation")
		lsp_map("grr", function()
			picker().lsp_references()
		end, "References")

		-- Actions
		lsp_map("grn", vim.lsp.buf.rename, "Rename")
		lsp_map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })

		-- Symbols
		lsp_map("gO", function()
			picker().lsp_symbols()
		end, "Document Symbols")
		lsp_map("gW", function()
			picker().lsp_workspace_symbols()
		end, "Workspace Symbols")

		-- Treesitter / selection range
		lsp_map("<Enter>", function()
			vim.cmd("normal v")
			vim.lsp.buf.selection_range(vim.v.count1)
		end, "Expand selection")
		lsp_map("<Enter>", function()
			vim.lsp.buf.selection_range(vim.v.count1)
		end, "Expand selection", "x")
		lsp_map("<Backspace>", function()
			vim.lsp.buf.selection_range(-vim.v.count1)
		end, "Shrink selection", "x")

		-- Toggle inlay hints
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/inlayHint", buf) then
			lsp_map("<leader>uh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
			end, "Toggle inlay hints")
		end
	end,
})

-- ═══════════════════════════════════════════════════════════════
-- Files & Editor
-- ═══════════════════════════════════════════════════════════════

map("n", "-", function()
	require("oil").open()
end, { desc = "Open file explorer" })
map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Substitute
map("n", "s", function()
	require("substitute").operator()
end, { desc = "Substitute motion" })
map("n", "ss", function()
	require("substitute").line()
end, { desc = "Substitute line" })
map("n", "S", function()
	require("substitute").eol()
end, { desc = "Substitute to EOL" })
map("x", "s", function()
	require("substitute").visual()
end, { desc = "Substitute selection" })

-- Visual mode editing
map("x", "H", "<gv", { desc = "Decrease indent" })
map("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move selection down" })
map("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move selection up" })
map("x", "L", ">gv", { desc = "Increase indent" })

-- Treesitter selection (buffer-local, LspAttach only)
-- Global maps below trigger on all buffers -- moved into LspAttach block

-- ═══════════════════════════════════════════════════════════════
-- Git
-- ═══════════════════════════════════════════════════════════════

map("n", "<leader>gv", function()
	require("mini.diff").toggle_overlay(vim.api.nvim_get_current_buf())
end, { desc = "Toggle diff overlay" })

-- vim: ts=2 sts=2 sw=2 et
