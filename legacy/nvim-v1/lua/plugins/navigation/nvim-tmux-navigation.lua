return {
  "alexghergh/nvim-tmux-navigation",
  config = function()
    require("nvim-tmux-navigation")
    local map = vim.keymap.set
    map("n", "<C-h>", "<cmd>NvimTmuxNavigateLeft<CR>", { desc = "Tmux Navigate Left" })
    map("n", "<C-j>", "<cmd>NvimTmuxNavigateDown<CR>", { desc = "Tmux Navigate Left" })
    map("n", "<C-k>", "<cmd>NvimTmuxNavigateUp<CR>", { desc = "Tmux Navigate Left" })
    map("n", "<C-l>", "<cmd>NvimTmuxNavigateRight<CR>", { desc = "Tmux Navigate Right" })
  end,
}
