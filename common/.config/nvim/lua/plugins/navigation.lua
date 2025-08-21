return {
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      local nvim_tmux_nav = require("nvim-tmux-navigation")
      nvim_tmux_nav.setup({
        disable_when_zoomed = true, -- defaults to false
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
          ["q"] = "actions.close",
        },
      })

      vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Oil" })
    end,
  },
}
