return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.incremental_selection = {
      enable = true,
      -- Disable for specific filetypes
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
    }
  end,
}
