return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- filter out standardrb
      opts.ensure_installed = vim.tbl_filter(
        function(item) return item ~= "standardrb" end,
        opts.ensure_installed or {}
      )

      -- make sure solargraph stays
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "solargraph" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      -- filter out standardrb
      opts.ensure_installed = vim.tbl_filter(
        function(item) return item ~= "standardrb" end,
        opts.ensure_installed or {}
      )

      -- install only solargraph
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "solargraph" })
    end,
  },
}
