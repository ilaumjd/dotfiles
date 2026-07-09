-- [[ Autocommands ]]
-- Yank highlight, diagnostic config, LSP attach handlers

-- Disable macro recording by default (toggle with <leader>uq)
vim.cmd("map q <Nop>")

-- Treesitter highlighting where a parser is available.
-- 0.12 bundles parsers + queries for many languages (ts, tsx, json, yaml, bash,
-- toml, html, ...), but core only auto-starts highlighting for lua/markdown/
-- vimdoc/query. This turns it on for every buffer whose language has a parser,
-- and no-ops for filetypes without one (go, ruby, python — install manually).
vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable treesitter highlighting where a parser is available",
	group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		if lang and pcall(vim.treesitter.language.add, lang) then
			pcall(vim.treesitter.start, ev.buf, lang)
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Diagnostic config
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = true,
	virtual_lines = false,
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})

-- LSP: document highlight on cursor hold
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-highlight", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight", event.buf) then
			return
		end

		local augroup = vim.api.nvim_create_augroup("lsp-doc-highlight-" .. event.buf, { clear = true })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = event.buf,
			group = augroup,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = event.buf,
			group = augroup,
			callback = vim.lsp.buf.clear_references,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			buffer = event.buf,
			group = augroup,
			callback = function()
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = augroup })
			end,
		})
	end,
})

-- vim: ts=2 sts=2 sw=2 et
