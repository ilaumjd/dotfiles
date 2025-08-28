return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<Enter>",
        node_incremental = "<Enter>",
        node_decremental = "<Backspace>",
        scope_incremental = false,
      },
    }
  end,
}
