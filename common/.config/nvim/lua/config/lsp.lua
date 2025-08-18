vim.lsp.enable({
  "clangd",
  "gopls",
  "eslint",
  "lua_ls",
  "nil_ls",
  "rubocop",
  "solargraph",
  "rust_analyzer",
  "ts_ls",
})

vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

vim.o.winborder = "rounded"

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client:supports_method("textDocument/completion") then
--       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--     end
--   end,
-- })
--
