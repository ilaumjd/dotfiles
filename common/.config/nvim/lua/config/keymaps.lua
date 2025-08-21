-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

------ NORMAL ------
vim.keymap.set("n", "x", '"_x', { desc = "Delete character without copying to register" })
vim.keymap.set("n", "<leader>ch", ":nohl<CR>", { desc = "Clear highlights" })

------ VISUAL BLOCK ------
vim.keymap.set("x", "H", "<gv", { desc = "Decrease indent tab" })
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move selected text down" })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move selected text up" })
vim.keymap.set("x", "L", ">gv", { desc = "Increase indent tab" })

-- Tmux navigation keymaps
vim.keymap.set("n", "<C-h>", "<cmd>NvimTmuxNavigateLeft<cr>", { desc = "Navigate left to tmux pane" })
vim.keymap.set("n", "<C-j>", "<cmd>NvimTmuxNavigateDown<cr>", { desc = "Navigate down to tmux pane" })
vim.keymap.set("n", "<C-k>", "<cmd>NvimTmuxNavigateUp<cr>", { desc = "Navigate up to tmux pane" })
vim.keymap.set("n", "<C-l>", "<cmd>NvimTmuxNavigateRight<cr>", { desc = "Navigate right to tmux pane" })
