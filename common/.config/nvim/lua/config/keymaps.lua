-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Tmux navigation keymaps
vim.keymap.set("n", "<C-h>", "<cmd>NvimTmuxNavigateLeft<cr>", { desc = "Navigate left to tmux pane" })
vim.keymap.set("n", "<C-j>", "<cmd>NvimTmuxNavigateDown<cr>", { desc = "Navigate down to tmux pane" })
vim.keymap.set("n", "<C-k>", "<cmd>NvimTmuxNavigateUp<cr>", { desc = "Navigate up to tmux pane" })
vim.keymap.set("n", "<C-l>", "<cmd>NvimTmuxNavigateRight<cr>", { desc = "Navigate right to tmux pane" })
