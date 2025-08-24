local prefix = "<Leader>a"
return {
  {
    "yetone/avante.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts) opts.mappings.n[prefix] = { desc = " Avante" } end,
      },
    },
    opts = function(_, opts)
      opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
        submit = {
          insert = "<C-a>",
        },
        ask = prefix .. "a", -- <leader>aa
        edit = prefix .. "e", -- <leader>ae
        refresh = prefix .. "r",
        new_ask = prefix .. "n",
        focus = prefix .. "f",
        select_model = prefix .. "?",
        stop = prefix .. "S",
        select_history = prefix .. "h",
        toggle = {
          default = prefix .. "t",
          debug = prefix .. "d",
          hint = prefix .. "H",
          suggestion = prefix .. "s",
          repomap = prefix .. "R",
        },
        files = {
          add_current = prefix .. ".",
          add_all_buffers = prefix .. "B",
        },
      })
    end,
  },
}
