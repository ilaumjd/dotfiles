return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require "null-ls"
      opts.sources = require("astrocore").list_insert_unique(opts.sources, {
        null_ls.builtins.formatting.swiftformat,
        null_ls.builtins.formatting.swiftlint,
        null_ls.builtins.diagnostics.swiftlint,
      })
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.config = opts.config or {}
      opts.config.sourcekit = {
        on_attach = function(client, _)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }
      return opts
    end,
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/oil.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("xcodebuild").setup {
        integrations = {
          xcodebuild_offline = {
            enabled = true,
          },
        },
      }

      require("xcodebuild.integrations.dap").setup(os.getenv "HOME" .. "/bin/codelldb/extension/adapter/codelldb")
    end,
  },
}
