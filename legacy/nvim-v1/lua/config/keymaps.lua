-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local options = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

------ NORMAL ------
map("n", "x", '"_x', { desc = "Delete character without copying to register" })
-- map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>ch", ":nohl<CR>", { desc = "Clear highlights" })

------ VISUAL BLOCK ------
map("x", "H", "<gv", { desc = "Decrease indent tab" })
map("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move selected text down" })
map("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move selected text up" })
map("x", "L", ">gv", { desc = "Increase indent tab" })
