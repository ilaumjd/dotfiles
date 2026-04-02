return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ignore_install = { "swift" },
    incremental_selection = {
      enable = true,
      disable = function(lang, buf)
        local filetype = vim.bo[buf].filetype
        return filetype == "curl"
      end,
      keymaps = {
        init_selection = "<Enter>",
        node_incremental = "<Enter>",
        node_decremental = "<Backspace>",
        scope_incremental = false,
      },
    },
  },
}
