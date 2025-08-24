return {
  {
    "yetone/avante.nvim",
    opts = function(_, opts)
      opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
        submit = {
          insert = "<C-a>",
        },
      })
      opts.auto_suggestions_provider = "openai"
    end,
  },
}
