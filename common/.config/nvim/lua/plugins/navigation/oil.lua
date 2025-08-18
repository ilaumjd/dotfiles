return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["q"] = "actions.close",
      },
    })

    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil" })
  end,
}
