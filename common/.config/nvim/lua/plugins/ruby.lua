return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "ruby" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "solargraph" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "solargraph" })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "suketa/nvim-dap-ruby", config = true },
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      table.insert(opts.servers, "herb_ls")

      opts.config = opts.config or {}
      opts.config.herb_ls = {
        cmd = { "herb-language-server", "--stdio" },
        filetypes = { "eruby", "erb" },
        root_dir = function(fname)
          return vim.fs.dirname(vim.fs.find({ "Gemfile", ".git" }, { path = fname, upward = true })[1])
        end,
      }

      return opts
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require "null-ls"
      opts.sources = require("astrocore").list_insert_unique(opts.sources, {
        null_ls.builtins.formatting.erb_format,
      })
    end,
  },
}
