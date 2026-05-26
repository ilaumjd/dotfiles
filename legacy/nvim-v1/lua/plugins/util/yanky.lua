return {
  "gbprod/yanky.nvim",
  dependency = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("yanky").setup({})
    require("telescope").load_extension("yank_history")

    vim.keymap.set("n", "<leader>fy", "<Cmd>Telescope yank_history<CR>", { desc = "Yank history" })
  end,
}
