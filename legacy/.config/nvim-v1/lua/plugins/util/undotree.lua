return {
  "jiaoshijie/undotree",
  config = function()
    require("undotree").setup({
      float_diff = false,
      layout = "left_left_bottom",
      position = "left",
    })
    vim.keymap.set("n", "<leader>cu", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Toggle undotree" })
  end,
}
