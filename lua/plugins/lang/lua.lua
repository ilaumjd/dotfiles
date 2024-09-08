return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      require("lspconfig").lua_ls.setup({})
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}